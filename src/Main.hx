import flash.display.Sprite;
import flash.events.IEventDispatcher;
import haxe.ds.ObjectMap;
import haxe.Log;
import live.ILive;

/**
 * Haxe 3 requered
 * 
 * Что не работает:
 *  - enum-ы
 *  - switch
 *  - function внутри другой функции
 *  - массивы вида [for(a in 0...10) a]
 *  - определение нескольких переменных в одной строке (TODO)
 *  
 * Важно:
 *  - cast(a, Type) заменяются на if(Std.is(a, Type)) a; else throw "can't cast 'a' to 'Type'";
 *  - a += 10 заменяются на a = a + 10;
 *  - $type(a) заменяются на a
 */
class Main extends Sprite implements ILive
{
	static function main() new Main();

	public var sprite:Brick;

	function new()
	{
		super();
		flash.Lib.current.stage.frameRate = 60;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		sprite = new Brick();
		flash.Lib.current.addChild(sprite);

		sprite.addEventListener(flash.events.Event.ENTER_FRAME, update);
	}
	
	@liveUpdate function ttt() {
		trace([x, this.y]);
		{
			var x = 10;
			
			{
				var x = 20;
				trace(x);
				trace(this.x);
			}
			trace(x);
		}
		trace(x);
		
		var s2 = new flash.display.Sprite();
		trace(s2);
		
		Brick.a = 12;
		trace(Brick.a);
		
		new Sprite();
		new flash.display.Sprite();
	}
	
	@live function update(_)
	{
		//[for(i in 0...10) i];
		
		//Log.trace(11);
		var a = new Array();
		
		var t = 10 * 15;
		var s = this.sprite;
		s.x += 15;
		s.y += 4;
		if (s.x > sprite.stage.stageWidth) s.x = -t;
		if (s.y > sprite.stage.stageHeight) s.y = -t;
		
		
		//Log.clear();
		//callMethod(this, this.draw, [0xFF]);
		//this.sprite.x = this.sprite.x - 1;
		//if (this.sprite.x < 0) this.sprite.x = 400;
	}
}

enum A {
	B;
	C;
}

class Brick extends Sprite implements ILive {
	
	static public var a = 10;
	public function new() {
		super();
	}
	@liveUpdate public function draw() {
		trace("draw");
		
		var t = 10 * 15;
		
		var gfx = graphics;
		gfx.clear();
		gfx.beginFill(0xFF0000);
		gfx.drawRect(0, 0, t, t);
	}
}

