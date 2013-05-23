import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using Lambda;

class Macro
{
	static var methods = [];
	
	static var classFields:Array<String>;
	static var classMethods:Array<String>;
	static var varTypes:Map < String, String > = new Map();
	
	static var inited:Null<Bool> = null;
	
	static function registerType(n, m) {
		trace("register: " + n + " " + m);
		varTypes[n] = m;
	}
	
	public static function build()
	{
		Context.onGenerate(init);
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
		var prefix = type.module.split(".").join("_") + "_" + type.name + "_";

		for (field in fields)
		{
			if (field.meta.exists(function(m){return m.name=="live";}))
			{
				switch (field.kind)
				{
					case FFun(f):
						var name = prefix + field.name;
						var args = f.args.map(function(a){ return a.name; }).join(",");
						var expr = f.expr.map(processExpr);
						var body = expr.toString();
						trace(body);
						
						methods.push('$name:function($args)$body');
						var args = f.args.map(function (a) return macro $v{a.value});
						f.expr = macro Live.instance.call(this, $v{name}, $v{args});
					case _:
				}
			}
		}
		
		return fields;
	}
	
	static function init(_) {
		//trace("init");
		
		var types = [];
		for (n in varTypes.keys()) {
			types.push(n);
			types.push(varTypes[n]);
		}
		
		var script = "{" + methods.join(",\n");
		if (types.length > 0) script += ",\n__types__:[\"" + types.join("\", \"") + "\"]";
		script += "}";
		sys.io.File.saveContent("bin/script.hs", script);
		
		if (types.length > 0) varTypes = new Map();
		methods = [];
	}

	static function processExpr(expr:Expr):Expr
	{
		trace(expr);
		//trace(expr.toString());
		return switch (expr.expr)
		{
			case EBinop(OpAssignOp(op), e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);
				
				var op = { expr:EBinop(op, e1, e2), pos:expr.pos };
				processExpr(macro $e1 = $op);
				
			case ECall( { expr:EConst(CIdent(name)) }, params):
				
				if (classMethods.has(name)) {
					params = params.map(function (p) return processExpr(p));
					macro callField(this, $v{name}, $a { params } );
				}
				else expr.map(processExpr);
				
			case ECall( { expr:EField(e, field) }, params): 
				
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
				
				e = processExpr(e);
				macro callField($e, $v { field }, $a { params } );
				
			case EConst(CIdent(n)):
				
				if (classFields.has(n))
					macro getProperty(this, $v{n});
				else expr;
				
			case EBinop(OpAssign, e1, e2):
				
				getSetter(processExpr(e1), processExpr(e2));
				
			case ENew(t, params):
				
				params = params.map(function (p) return processExpr(p));
				var res = { expr:ENew(t, params), pos:expr.pos };
				
				var t = Context.getType((t.pack.length > 0 ? t.pack.join(".") + "." : "") + t.name);
				switch (t) {
					case TInst(t, _):
						var t = t.get();
						registerType(t.name, t.module);
						
					case _:
						throw "Unknown: " + t;
						// TODO:
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
	
	static function getSetter(expr:Expr, value:Expr):Expr
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