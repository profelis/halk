package live;

import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;

using haxe.macro.Tools;
using Lambda;



class Macro
{
	static var methods = [];
	
	static var classFields:Array<String>;
	static var classMethods:Array<String>;
	static var staticFields:Array<String>;
	static var varTypes:Map < String, Bool > = new Map();
	
	static var inited:Null<Bool> = null;
	
	static function registerMacroType(t:Type):String {
		trace(t);
		t = Context.follow(t, false);
		trace(t);
		return switch (t) {
			case TType(t, params):
				
				var t = t.get();
				var n = t.name;
				registerType(n, t.module);
				//{expr:EField(macro $i { n }, field), pos:expr.pos };
				//expr;
				
			case TInst(t, _):
				
				var t = t.get();
				var n = t.name;
				registerType(n, t.module);
				//macro $i { n };
				//expr;
				//null;
			case TAnonymous(_):
			case _:
				throw "Unknown: " + t + ". Please report problem";
		}
	}
	
	inline static function registerType(n:String, m:String):String {
		if (StringTools.startsWith(n, "#")) n = n.substr(1);
		// соберем правильное имя, зная имя класса и модуль
		n = if (m.indexOf(".") != -1) m.substr(0, m.lastIndexOf(".") + 1) + n;
			else n;
		trace("register: " + n + " " + m);
		varTypes[n] = true;
		return n;
	}
	
	// один и тотже путь для скрипта в Live и тут, чтобы не думать куда его ложить
	// TODO: nme, mac need test
	static function getOutPath() {
		var path = Compiler.getOutput();
		var p = new Path(path);
		if (FileSystem.isDirectory(p.dir)) return p.dir + "/script.hs";
		
		p = new Path(p.dir);
		return p.dir + "/script.hs";
	}
	
	// раз за компиляцию создадим фаил со всем скриптами из всех классов
	static function onGenerate(types:Array<Type>) {
		
		//trace("inited: " + methods.length + " inited: " + inited);
		if (inited) return;
		inited = true;
		
		var script = "{" + methods.join(",\n");
		if (varTypes.keys().hasNext()) 
			script += ",\n__types__:[\"" + [for (n in varTypes.keys()) n].join("\", \"") + "\"]";
		script += "\n}";
		
		sys.io.File.saveContent(getOutPath(), script);
	}
	
	// удалим старую url и сделаем новую, с нашим путем
	public static function buildLive() {
		var res = Context.getBuildFields();
		for (f in res) if (f.name == "url") { res.remove(f); break; }
		
		res.push( { kind:FVar(null, macro $v{getOutPath()}), name:"url", pos:Context.currentPos() }  );
		return res;
	}
	
	static var firstBuild = true;
	
	public static function build()
	{
		//trace("build");
		Context.onGenerate(onGenerate);
		if( firstBuild ) {
			firstBuild = false;
			Context.onMacroContextReused(function() {
				inited = false;
				if (varTypes.keys().hasNext()) varTypes = new Map();
				methods = [];
				return true;
			});
		}
		var fields = Context.getBuildFields();
		
		classFields = [];
		classMethods = [];
		staticFields = [];
		
		for (f in fields) {
			switch (f.kind) {
				case FProp(_, _, _, _), FVar(_, _):
					if (f.access.has(AStatic))
						staticFields.push(f.name);
					else
						classFields.push(f.name);
				case FFun(_):
					if (f.access.has(AStatic))
						staticFields.push(f.name);
					else
						classMethods.push(f.name);
			}
		}
		classMethods.remove("new");
		
		var type = Context.getLocalClass().get();
		var prefix = type.module.split(".").join("_") + "_" + type.name + "_";

		
		var ctor = null;
		var liveListeners = [];
		var firstField:Field = null;
		
		for (field in fields)
		{
			if (firstField == null) firstField = field;
			if (field.name == "new") ctor = field;
			if (field.meta.exists(function(m) return m.name=="live" || m.name=="liveUpdate"))
			{
				switch (field.kind)
				{
					case FFun(f):
						var name = prefix + field.name;
						var args = f.args.map(function(a) { return a.name; } ).join(",");
						var method = f.expr;
						var expr = f.expr.map(processExpr);
						var body = expr.toString();
						//trace(body);
						
						methods.push('$name:function($args)$body');
						var args = f.args.map(function (a) return macro $v{a.value});
						f.expr = macro { live.Live.instance.call(this, $v { name }, $v { args } ); return; $method; };
						//f.expr = macro live.Live.instance.call(this, $v { name }, $v { args } );
					case _:
				}
			} 
			if (field.meta.exists(function(m) return m.name == "liveUpdate")) {
				switch (field.kind) {
					case FFun(f):
						if (f.args.length > 0) Context.error("liveUpdate method doesn't support arguments", field.pos);
						liveListeners.push(field.name);
					case _: Context.error("only methods can be liveUpdate", field.pos);
				}
			}
		}
		
		if (ctor == null && liveListeners.length > 0) {
			// если нет конструктора, то заставим программиста его сделать самому
			// не самое красивое решение, но проще, чем самому его генерировать
			Context.error("Please, define constructor here", firstField.pos);
		}
		
		if (liveListeners.length > 0) {
			switch (ctor.kind) {
				case FFun( { expr:e, args:args, ret:ret, params:params } ):
					
					// добавим подписку на обновление в тело конструктора
					var listeners = [];
					for (l in liveListeners) listeners.push(macro live.Live.instance.addListener($i { l } ));
					
					var add = { pos:ctor.pos, expr:EBlock(listeners)};
					
					if (e == null) e = add;
					else e = macro { $e; $add; };
					
					ctor.kind = FFun( { args:args, ret:ret, expr:e, params:params } ); 
				case _: throw "ctor != FFun %(";
			}
		}
		
		return fields;
	}
	
	static function processExpr(expr:Expr):Expr
	{
		//trace(expr);
		//trace(expr.toString());
		return switch (expr.expr)
		{
			case EVars(vars):
				for (v in vars) {
					if (v.type != null) {
						switch (v.type) {
							
							case TPath(p):
								var t = Context.getType((p.pack.length > 0 ? p.pack + "." : "") + p.name);
								registerMacroType(t);
							case _:
						}
					}
					v.type = null;
				}	
				expr;
				
			case EBinop(OpAssignOp(op), e1, e2):  // разворачиваем a+=1 в a=a+1
				e1 = processExpr(e1);
				e2 = processExpr(e2);
				
				var op = { expr:EBinop(op, e1, e2), pos:expr.pos };
				processExpr(macro $e1 = $op);
				
			case ECall( { expr:EConst(CIdent(name)) }, params): // если идентификатор класса, то добавляем this
				
				//trace(macro this.$name);
				//trace(Context.typeof(expr));
				if (classMethods.has(name)) {
					params = params.map(function (p) return processExpr(p));
					macro callField(this, $v{name}, $a { params } );
				}
				else expr.map(processExpr);
				
			case ECall( { expr:EField(e, field) }, params): // если вызов haxe.Log.clear() то надо зарегистрировать тип haxe.Log
				
				params = params.map(function (p) return processExpr(p));
				
				var t = null;
				try {
					t = Context.typeof(e);
				} catch (e:Dynamic) { }
				if (t == null) {
					try {
						t = Context.getType(e.toString() + "." + field);
					} catch (e:Dynamic) {}
				}
				e = processExpr(e);
				
				if (t != null) {
					var path = registerMacroType(t);
					if (path != null) e = path.split(".").toFieldExpr();
				}
				
				macro callField($e, $v { field }, $a { params } );
				
			case EConst(CIdent(n)):  // если идентификатор принадлежит классу, то добавим this
				
				var t = null;
				try {
					t = Context.getType(n);
				} catch (e:Dynamic) { }
				
				if (t != null) registerMacroType(t);
				
				if (classFields.has(n))
					macro getProperty(this, $v{n});
				else expr;
				
			case EBinop(OpAssign, e1, e2):
				
				getSetter(processExpr(e1), processExpr(e2));
				
			case ENew(t, params):  // в конструкторах тоже найдем тип для регистрации
				
				params = params.map(function (p) return processExpr(p));
				var res = { expr:ENew(t, params), pos:expr.pos };
				
				var t = Context.getType((t.pack.length > 0 ? t.pack.join(".") + "." : "") + t.name);
				registerMacroType(t);
				res;
				
			case EField(e, field):
				//trace(expr);
				var t = null;
				try {
					t = Context.typeof(e);
				} catch (e:Dynamic) { }
				if (t == null) {
					try {
						t = Context.getType(e.toString() + "." + field);
					} catch (e:Dynamic) {}
				}
				if (t != null) registerMacroType(t);
				e = processExpr(e);
				macro getProperty($e, $v{field} );
				
				
			case _: 
				expr.map(processExpr);
		}
	}
	
	inline static function getSetter(expr:Expr, value:Expr):Expr
	{
		return switch (expr.expr)
		{
			case ECall(e, params):
				switch (e.expr) {
					case EConst(CIdent("getProperty")):
						var p1 = params[0];
						var p2 = params[1];
						macro setProperty($p1, $p2, $value);
					case _ : macro $expr = $value;
				}
			case EField(e, field):
				macro setProperty($e, $v{field}, $value);
			case _:
				macro $expr = $value;
				//expr.map(processExpr);
		}
	}
}