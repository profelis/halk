package live;

import hscript.Parser;
import hscript.Interp;

class Live
{
	var parser:Parser;
	var interp:Interp;
	var script:String;
	var methods:Dynamic;
	
	static public var instance(default, null):Live = new Live();
	
	static function callField(d:Dynamic, n:String, args:Array<Dynamic>) {
		Reflect.callMethod(d, Reflect.getProperty(d, n), args);
	}
	
	function new()
	{
		parser = new Parser();
		interp = new Interp();
		methods = { };
		listeners = [];

		interp.variables.set("callField", Live.callField);
		interp.variables.set("callMethod", Reflect.callMethod);
		interp.variables.set("getProperty", Reflect.getProperty);
		interp.variables.set("setProperty", Reflect.setProperty);

		load();

		#if sys
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		#end
	}
	
	var counter = 0;
	function update(_)
	{
		counter++;
		if (counter > 30)
		{
			counter = 0;
			load();
		}
	}

	function load()
	{
		var url = "script.hs";
		
		#if (flash || js)
		url += "?r="+Math.round(Math.random()*10000000);

		var http = new haxe.Http(url);
		http.onData = function(data) {
			parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.onError = function(data) {
			parse(http.responseData);
			haxe.Timer.delay(load, 500);
		}
		http.request();
		#end

		#if sys
		url = "../../../../" + url;
		var data = sys.io.File.getContent(url);
		parse(data);
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
		catch (e:Dynamic) { }
		
		if (nmethods != null) {
			var types:Array<String> = Reflect.field(nmethods, "__types__");
			//trace(types);
			var ok = true;
			if (types != null) {
				var i = 0;
				while (i < types.length) {
					var n = types[i++];
					var cn = types[i++];
					var ref = null;
					try {
						ref = Type.resolveClass(cn);
					} catch (e:Dynamic) { }
					
					if (ref == null) {
						ok = false;
						trace("can't use type: '" + cn + "'");
					}
					else interp.variables.set(n, ref);
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

	public function call(instance:Dynamic, method:String, args:Array<Dynamic>)
	{
		if (Reflect.field(methods, method) == null) return;
		
		interp.variables.set("this", instance);
		Reflect.callMethod(instance, Reflect.field(methods, method), args);
	}
}