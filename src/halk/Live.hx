package halk;

import haxe.Timer;
import hscript.Parser;
import hscript.Interp;

@:build(halk.Macro.buildLive()) 
class Live
{
	
	var parser:Parser;
	var interp:Interp;
	var script:String;
	var methods:Dynamic;
	
	static public var instance(default, null):Live = new Live();
	
	static function callField(d:Dynamic, n:String, args:Array<Dynamic>) {
		return Reflect.callMethod(d, Reflect.getProperty(d, n), args);
	}
	
	static function setProperty(d:Dynamic, n:String, v:Dynamic) {
		Reflect.setProperty(d, n, v);
		return v;
	}
	
	function new()
	{
		parser = new Parser();
		//parser.allowTypes = true;
		parser.allowJSON = true;
		interp = new Interp();
		methods = { };
		listeners = [];

		interp.variables.set("callField", Live.callField);
		interp.variables.set("callMethod", Reflect.callMethod);
		interp.variables.set("getProperty", Reflect.getProperty);
		interp.variables.set("setProperty", setProperty);

		#if sys delayed(load, 500); #else
		load(); #end
	}
	
	var url = "script.hs";
	
	#if sys
	function delayed(f:Dynamic, time) {
		#if neko neko.vm.Thread #else cpp.vm.Thread #end
		.create(function() {
		Sys.sleep(time / 1000);
			f();
		});
	}
	#end

	function load()
	{
		#if sys
		var data = sys.io.File.getContent(url);
		parse(data);
		delayed(load, 500);
		#else
		
		url += "?r="+ (Timer.stamp() * 10e6);

		var http = new haxe.Http(url);
		http.onData = function(data) {
			parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.onError = function(data) {
			trace('can\'t load "$url" file');
			//parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.request();
		
		#end
	}

	function parse(data:String)
	{
		if (data == script) return;
		script = data;
		// trace("parse: " + data);
		
		var nmethods = null;
		try {
			var program = parser.parseString(script);
			nmethods = interp.execute(program);
		}
		catch (e:Dynamic) { 
			trace("hscript: Error in live code");
			trace(e);
		}
		
		if (nmethods != null) {
			var types:Array<String> = Reflect.field(nmethods, "___types___");
			//trace(types);
			var ok = true;
			if (types != null) {
				var i = 0;
				while (i < types.length) {
					var n = types[i++];
					var ref = null;
					try {
						ref = Type.resolveClass(n);
					} catch (e:Dynamic) { }
					
					if (ref == null) {
						ok = false;
						trace("can't find type in app: '" + n + "'");
					}
					else {
						var arr = n.split(".");
						if (arr.length == 1) interp.variables.set(n, ref);
						else {
							var res:Dynamic;
							var root = arr.shift();
							var last = arr.pop();
							if (interp.variables.exists(root)) {
								res = interp.variables.get(root);
							} else {
								interp.variables.set(root, res = { } );
							}
							for (s in arr) {
								if (Reflect.hasField(res, s))
									res = Reflect.field(res, s);
								else 
									Reflect.setField(res, s, res = { } );
							}
							Reflect.setField(res, last, ref);
						}
					}
				}
			}
			
			if (ok) {
				methods = nmethods;
				for (l in listeners) l();
			}
		}
	}
	
	var listeners:Array<Dynamic>;
	
	public function addListener(f:Dynamic) {
		listeners.remove(f);
		listeners.push(f);
	}
	
	public function removeListener(f:Dynamic) {
		listeners.remove(f);
	}

	public function call(instance:Dynamic, method:String, args:Array<Dynamic>)
	{
		if (Reflect.field(methods, method) == null) return;
		
		interp.variables.set("this", instance);
		try {
			Reflect.callMethod(instance, Reflect.field(methods, method), args);
		} catch (e:Dynamic) {
			trace("hscript: execute error");
			trace(e);
		}
	}
}