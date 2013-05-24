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
	static var varTypes:Map < String, String > = new Map();
	
	static var inited:Null<Bool> = null;
	
	inline static function registerType(n, m) {
		//trace("register: " + n + " " + m);
		varTypes[n] = m;
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
	static function init(_) {
		
		//trace("inited: " + methods.length + " inited: " + inited);
		if (inited) return;
		inited = true;
		
		var types = [];
		for (n in varTypes.keys()) {
			types.push(n);
			types.push(varTypes[n]);
		}
		
		var script = "{" + methods.join(",\n");
		if (types.length > 0) script += ",\n__types__:[\"" + types.join("\", \"") + "\"]";
		script += "}";
		sys.io.File.saveContent(getOutPath(), script);
		
		//if (types.length > 0) varTypes = new Map();
		//methods = [];
	}
	
	// удалим старую вару url и сделаем новую, с нашим путем
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
		Context.onGenerate(init);
		if( firstBuild ) {
			firstBuild = false;
			Context.onMacroContextReused(function() {
				inited = false;
				return true;
			});
		}
		var fields = Context.getBuildFields();
		
		classFields = [];
		classMethods = [];
		
		for (f in fields) {
			switch (f.kind) {
				case FProp(_, _, _, _), FVar(_, _): classFields.push(f.name);
				case FFun(_): classMethods.push(f.name);
			}
		}
		classMethods.remove("new");
		
		var type = Context.getLocalClass().get();
		//trace(type);
		var prefix = type.module.split(".").join("_") + "_" + type.name + "_";

		
		var ctor = null;
		var liveListeners = [];
		
		for (field in fields)
		{
			if (field.name == "new") ctor = field;
			if (field.meta.exists(function(m) return m.name=="live" || m.name=="liveUpdate"))
			{
				switch (field.kind)
				{
					case FFun(f):
						var name = prefix + field.name;
						var args = f.args.map(function(a){ return a.name; }).join(",");
						var expr = f.expr.map(processExpr);
						var body = expr.toString();
						//trace(body);
						
						methods.push('$name:function($args)$body');
						var args = f.args.map(function (a) return macro $v{a.value});
						f.expr = macro live.Live.instance.call(this, $v{name}, $v{args});
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
		
		if (ctor == null && liveListeners.length > 0) { // если нет конструктора, сделаем его
			// TODO: test
			ctor = { name:"new", pos:Context.currentPos(), access:[APublic],
				kind:FFun( { args:[], ret:null, expr:null, params:[] } ) };
				
			fields.push(ctor);
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
				case _:
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
			case EBinop(OpAssignOp(op), e1, e2):  // разворачиваем a+=1 в a=a+1
				e1 = processExpr(e1);
				e2 = processExpr(e2);
				
				var op = { expr:EBinop(op, e1, e2), pos:expr.pos };
				processExpr(macro $e1 = $op);
				
			case ECall( { expr:EConst(CIdent(name)) }, params): // если идентификатор класса, то добавляем this
				
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
				if (t != null) {
					switch (t) {
						case TType(t, params):
							
							var t = t.get();
							var n = t.name;
							if (StringTools.startsWith(n, "#")) n = n.substr(1);
							registerType(n, t.module);
							
						case TInst(t, _):
							
							var t = t.get();
							var n = t.name;
							if (StringTools.startsWith(n, "#")) n = n.substr(1);
							registerType(n, t.module);
						
						case _:
							throw "unknown: " + t;
					}
				}
				
				e = processExpr(e);
				macro callField($e, $v { field }, $a { params } );
				
			case EConst(CIdent(n)):  // если идентификатор принадлежит классу, то добавим this
				
				var t = null;
				try {
					t = Context.getType(n);
				} catch (e:Dynamic) { }
				if (t != null)
					switch (t) {
						case TInst(t, _):
							var t = t.get();
							registerType(t.name, t.module);
							
						case _:
							throw "Unknown: " + t;
					}
				
				if (classFields.has(n))
					macro getProperty(this, $v{n});
				else expr;
				
			case EBinop(OpAssign, e1, e2):
				
				getSetter(processExpr(e1), processExpr(e2));
				
			case ENew(t, params):  // в конструкторах тоже найдем тип для регистрации
				
				params = params.map(function (p) return processExpr(p));
				var res = { expr:ENew(t, params), pos:expr.pos };
				
				var t = Context.getType((t.pack.length > 0 ? t.pack.join(".") + "." : "") + t.name);
				switch (t) {
					case TInst(t, _):
						var t = t.get();
						registerType(t.name, t.module);
						
					case _:
						throw "Unknown: " + t;
						res;
				}
				res;
				
			case EField(e, field):
				
				var t = null;
				try {
					t = Context.typeof(e);
				} catch (e:Dynamic) { }
				if (t == null) {
					try {
						t = Context.getType(e.toString() + "." + field);
					} catch (e:Dynamic) {}
				}
				if (t != null) {
					switch (t) {
						case TType(t, params):
							
							var t = t.get();
							var n = t.name;
							if (StringTools.startsWith(n, "#")) n = n.substr(1);
							registerType(n, t.module);
							{expr:EField(macro $i { n }, field), pos:expr.pos };
							
						case TInst(t, _):
							
							var t = t.get();
							var n = t.name;
							if (StringTools.startsWith(n, "#")) n = n.substr(1);
							registerType(n, t.module);
							macro $i { n };
						
						case _:
							throw "assert";
					}
				}
				else {
					e = processExpr(e);
					macro getProperty($e, $v{field} );
				}
				
				
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