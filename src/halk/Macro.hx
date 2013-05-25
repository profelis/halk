package halk;

import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

using haxe.macro.Tools;
using Lambda;
using StringTools;

private typedef TypeDesc = {
	var methods:Array<String>;
	var smethods:Array<String>;
	var vars:Array<String>;
	var svars:Array<String>;
}

private typedef MethodData = {name:String, args:String, method:Expr}

class Macro
{
	static var methods:Map<String, Array<MethodData>> = new Map();
	
	static var typeDesc:TypeDesc;
	static var typeCall:Expr;
	
	static var varTypes:Map < String, Bool > = new Map();
	
	static var inited:Null<Bool> = null;
	static var firstBuild = true;
	
	// один и тотже путь для скрипта в Live и тут, чтобы не думать куда его ложить
	// TODO: nme, mac need test
	static function getOutPath() {
		var path = Compiler.getOutput();
		var p = new Path(path);
		if (FileSystem.isDirectory(p.dir)) return p.dir + "/script.hs";
		
		p = new Path(p.dir);
		return p.dir + "/script.hs";
	}
	
	// кеш описаний классов. Сильно ускоряет работу describeType
	static var descCache:Map<String, TypeDesc> = new Map();
	
	// получим описание класса (все поля и методы)
	static function describeType(t:ClassType):TypeDesc {
		
		var tn = typeName(t);
		if (descCache.exists(tn)) return descCache[tn];
		
		var smethods = [];
		var methods = [];
		var svars = [];
		var vars = [];
		
		for (f in t.statics.get()) {
			switch (f.kind) {
				case FVar(_, _): svars.push(f.name);
				case FMethod(_): smethods.push(f.name);
			}
		}
		
		for (f in t.fields.get()) {
			switch (f.kind) {
				case FVar(_, _): vars.push(f.name);
				case FMethod(_): methods.push(f.name);
			}
		}
		
		var res = { smethods:smethods, svars:svars, methods:methods, vars:vars };
		
		if (t.superClass != null) {
			
			var s = describeType(t.superClass.t.get());
			
			res.methods = res.methods.concat(s.methods);
			res.smethods = res.smethods.concat(s.smethods);
			res.vars = res.vars.concat(s.vars);
			res.svars = res.svars.concat(s.svars);
		}
		
		descCache[tn] = res;
		
		return res;
	}
	
	// раз за компиляцию создадим фаил со всем скриптами из всех классов
	static function onGenerate(types:Array<Type>) {
		
		//trace("inited: " + methods.length + " inited: " + inited);
		if (inited) return;
		inited = true;
		
		if (!methods.keys().hasNext()) return;
			
		var classTypes:Array<ClassType> = [];
		for (t in types) 
			switch (t) {
				case TInst(t, _):
					var t = t.get();
					if (!(t.isInterface || t.isExtern)) {
						//trace(typeName(t));
						classTypes.push(t);
					}
				case _:
			}
		
		var res = [];
		
		for (tn in methods.keys()) {
			
			var type = null;
			for (t in classTypes) {
				if (typeName(t) == tn) type = t;
			}
			if (type == null) throw "unknown type: " + tn;
			
			typeCall = type.pack.concat([type.name]).toFieldExpr();
			typeDesc = describeType(type);
			
			for (m in methods[tn]) {
				//trace(m.name);
				var body = process(m.method, []).toString();
				res.push('${m.name}:function(${m.args})$body');
			}
		}
		
		var script = "{" + res.join(",\n");
		if (varTypes.keys().hasNext()) 
			script += ",\n___types___:[\"" + [for (n in varTypes.keys()) n].join("\", \"") + "\"]";
		script += "\n}";
		
		File.saveContent(getOutPath(), script);
	}
	
	// удалим старую url и сделаем новую, с нашим путем
	public static function buildLive() {
		var res = Context.getBuildFields();
		for (f in res) if (f.name == "url") { res.remove(f); break; }
		
		res.push( { kind:FVar(null, macro $v{getOutPath()}), name:"url", pos:Context.currentPos() }  );
		return res;
	}
	
	inline static function typeName(type:ClassType) {
		return (type.module.length > 0 ? type.module + "." : "") + type.name;
	}
	
	public static function build()
	{
		//trace("build");
		Context.onGenerate(onGenerate);
		if ( firstBuild ) {
			firstBuild = false;
			Context.onMacroContextReused(function() {
				inited = false;
				descCache = new Map();
				varTypes = new Map();
				methods = new Map();
				return true;
			});
		}
		var fields = Context.getBuildFields();
		if (fields.length == 0) return fields;

		var type = Context.getLocalClass().get();
		registerType(type.name, type.pack);
		
		var tn = typeName(type);

		var ctor = null;
		var liveListeners = [];
		var firstField = null;
		
		var res = [];
		for (field in fields)
		{
			if (firstField == null) firstField = field;
			if (field.name == "new") ctor = field;
			
			if (field.meta.exists(function(m) return m.name=="live" || m.name=="liveUpdate"))
			{
				switch (field.kind)
				{
					case FFun(f):
						
						if (field.access.has(AStatic)) Context.error("static method can't be live", f.expr.pos);
						switch (f.expr.expr) {
							case EBlock(exprs): if (exprs.length == 0) continue;
							case _:
						}
						
						var name = tn.replace(".", "_") + "_" + field.name;
						res.push({
							name : name,
							args : [for (a in f.args) a.name].join(","),
							method : f.expr,
						});
						var args = [for (a in f.args) macro $v { a.value } ];
						var m = f.expr;
						f.expr = macro { halk.Live.instance.call(this, $v { name }, $v { args } ); return; $m; };
							//f.expr = macro live.Live.instance.call(this, $v { name }, $v { args } );
							
					case _: 
						
						Context.error("only methods can be live", field.pos);
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
		if (res.length > 0) methods.set(tn, res);
		
		if (ctor == null && liveListeners.length > 0) {
			// если нет конструктора, то заставим программиста его сделать самому
			// не самое красивое решение, но проще, чем самому его генерировать
			Context.error("Please define constructor for live listeners", firstField.pos);
		}
		
		if (liveListeners.length > 0) {
			switch (ctor.kind) {
				case FFun( f ):
					
					// добавим подписку на обновление в тело конструктора
					var listeners = [for (l in liveListeners) macro halk.Live.instance.addListener($i { l } )];
					
					var add = { pos:ctor.pos, expr:EBlock(listeners)};
					
					if (f.expr == null) f.expr = add;
					else {
						var m = f.expr;
						f.expr = macro { $m; $add; };
					}
					
					ctor.kind = FFun( f ); 
				case _:
			}
		}
		
		return fields;
	}
	
	static function process(expr:Expr, vars:Array<String>):Expr
	{
		
		var localVars:Array<String> = vars;
		//trace(expr);
		//trace(expr.toString());
		
		function processExpr(expr:Expr) {
			//trace(expr);
			return switch (expr.expr)
			{
				case EBlock(exprs):
					var vars = localVars.copy();
					return {expr:EBlock([for (e in exprs) process(e, vars)]), pos:expr.pos};
				
				case ESwitch(_, _, _), EFunction(_, _):
					var s = expr.toString();
					var a = s.split("\n");
					if (a.length > 1) s = a[0] + "...";
					else if (s.length > 20) s = s.substr(0, 20) + "...";
					
					Context.error("Live doesn't support: " + s, expr.pos);
				
				case  EArrayDecl(t):
					if (t.length > 0) {
						switch (t[0].expr) {
							case EFor(_, _), EWhile(_, _, _):
								Context.error("Live doesn't support Array comprehensions", expr.pos);
								
							case EBinop(OpArrow, _, _):
								Context.error("Live doesn't support Map", expr.pos);
							case _:
						}
					}
					t = [for (e in t) processExpr(e) ];
					macro $a { t };
				
				case ECast(e, t):
					
					switch (t) {
						case TPath(t):
							var tn = (t.pack.length > 0 ? t.pack.join(".") + "." : "") + t.name;
							var type = Context.getType(tn);
							registerMacroType(type, expr.pos);
							
							tn = type.toString();
							var e = processExpr(e);
							var msg = "can't cast '" + e.toString() + "' to '" + tn + "'";
							registerType("Std", []);
							macro if (Std.is($e, $i { tn } )) $e; else throw $v { msg };
							
						case _:
							expr;
					}
					
				case EVars(vars):
					
					if (vars.length > 1) Context.error("Live doesn't support multiple vars on one line", expr.pos);
					for (v in vars) {
						localVars.push(v.name);
						if (v.type != null) {
							switch (v.type) {
								
								case TPath(p):
									var t = Context.getType((p.pack.length > 0 ? p.pack + "." : "") + p.name);
									registerMacroType(t, expr.pos);
								case _:
							}
						}
						v.expr = v.expr != null ? processExpr(v.expr) : v.expr;
						v.type = null;
					}
					expr;
					
					
				case EBinop(OpAssignOp(op), e1, e2):  // разворачиваем a+=1 в a=a+1
					e1 = processExpr(e1);
					e2 = processExpr(e2);
					
					var op = { expr:EBinop(op, e1, e2), pos:expr.pos };
					processExpr(macro $e1 = $op);
					
				case ECall( { expr:EConst(CIdent(name)) }, params): // если идентификатор класса, то добавляем this
					
					if (name == "$type") processExpr(params[0]);
					else {
						if (typeDesc.methods.has(name)) {
							params = [for (p in params) processExpr(p)];
							macro callField(this, $v{name}, $a { params } );
						} else if (typeDesc.smethods.has(name)) {
							params = [for (p in params) processExpr(p)];
							macro callField($typeCall, $v { name }, $a { params }  );
						}
						else expr.map(processExpr);
					}
					
				case ECall( { expr:EField(e, field) }, params): // если вызов haxe.Log.clear() то надо зарегистрировать тип haxe.Log
					
					params = [for (p in params) processExpr(p)];
					
					var t = null;
					try {
						t = Context.typeof(e);
					} catch (e:Dynamic) { }
					if (t == null) {
						try {
							var s = e.toString();
							if (s.length > 0) s += ".";
							t = Context.getType(s + field);
						} catch (e:Dynamic) {}
					}
					e = processExpr(e);
					
					if (t != null) {
						var path = registerMacroType(t, expr.pos);
						if (path != null) e = path.split(".").toFieldExpr();
					}
					
					macro callField($e, $v { field }, $a { params } );
					
				case EConst(CIdent(n)):  // если идентификатор принадлежит классу, то добавим this
					
					var t = null;
					try {
						t = Context.getType(n);
					} catch (e:Dynamic) { }
					if (t == null) {
						try {
							t = Context.typeof(expr);
						}
						catch (e:Dynamic) { }
					}
					
					var path = null;
					if (t != null) path = registerMacroType(t, expr.pos);
					
					if (localVars.has(n)) expr;
					else if (typeDesc.vars.has(n))
						macro getProperty(this, $v{n});
					else if (typeDesc.svars.has(n))
						macro getProperty($typeCall, $v { n } );
					else if (t != null) {
						var e = path.split(".").toFieldExpr();
						macro $e;
					} else expr;
					
				case EBinop(OpAssign, e1, e2):
					
					var expr = processExpr(e1);
					var value = processExpr(e2);
					
					switch (expr.expr)
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
				
				case ENew(t, params):  // в конструкторах тоже найдем тип для регистрации
					
					if (t.params.length > 0) Context.error("Live doesn't support type params", expr.pos);
					
					var type = Context.getType((t.pack.length > 0 ? t.pack.join(".") + "." : "") + t.name);
					registerMacroType(type, expr.pos);
					var tn = type.toString();
					var pack = tn.split(".");
					pack.pop();
					
					{expr:ENew( { name:t.name, pack:pack, params:t.params, sub:t.sub }, params), pos:expr.pos };
					
				case EField(e, field):
					//trace(expr);
					var t = null;
					try {
						t = Context.typeof(e);
					} catch (e:Dynamic) { }
					if (t == null) {
						try {
							var s = e.toString();
							if (s.length > 0) s += ".";
							t = Context.getType(s + field);
						} catch (e:Dynamic) {}
					}
					if (t != null) registerMacroType(t, expr.pos);
					e = processExpr(e);
					macro getProperty($e, $v{field} );
					
					
				case _: 
					expr.map(processExpr);
			}
		}
		
		return processExpr(expr);
	}
	
	static function registerMacroType(t:Type, pos:Position):String {
		//trace(t);
		t = Context.follow(t, false);
		//trace(t);
		return switch (t) {
			case TType(t, _):
				
				var t = t.get();
				registerType(t.name, t.pack);
				//{expr:EField(macro $i { n }, field), pos:expr.pos };
				
			case TInst(t, _):
				
				var t = t.get();
				registerType(t.name, t.pack);
				//macro $i { n };
				
			case TMono(t):
				var t = t.get();
				if (t != null) registerMacroType(t, pos);
				null;
				
			case TAbstract(t, _):
				
				var t = t.get();
				if (t != null) registerType(t.name, t.pack);
				null;
				
			case TDynamic(t):
				if (t != null) registerMacroType(t, pos);
				null;
				
			case TEnum(t, _):
				Context.error("Live doesn't support enums", pos);
				
			case TAnonymous(_), TFun(_, _): null;
			
			case _:
				throw "Unknown type: " + t + ". Please report to author";
		}
	}
	
	inline static function registerType(n:String, p:Array<String>):String {
		
		if (StringTools.startsWith(n, "#")) n = n.substr(1);
		// соберем правильное имя, зная имя класса и модуль
		if (p.length > 0) n = p.join(".") + "." + n;
		//trace("register: " + n);
		varTypes[n] = true;
		return n;
	}
}