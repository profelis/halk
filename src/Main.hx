import flash.display.Sprite;
import flash.events.IEventDispatcher;
import haxe.Log;
import live.ILive;

/**
 * Haxe 3 requered
 * 
 * Что не работает:
 *  - енумы можно объявлять только с именем класса EnumName.EnumCtor (так и будет скорее всего)
 *  - не поддерживаются поля из родительских классов (планирую сделать)
 *  - статичные поля не обрабатываются (+ к проблеме выше)
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
		//trace([x, y]);
		{
			var x = 10;
			trace(x);
		}
		//trace(x);
	}
	
	@live function update(_)
	{
		
		//[for(i in 0...10) i];
		//haxe.Log.trace(10);
		//Log.trace(11);
		/*
		//trace("1");
		var t = 10 * 15;
		var s = this.sprite;
		s.x += 15;
		s.y += 4;
		if (s.x > sprite.stage.stageWidth) s.x = -t;
		if (s.y > sprite.stage.stageHeight) s.y = -t;
		*/
		
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
	
	public function new() {
		super();
	}
	@liveUpdate public function draw() {
		/*trace("draw");
		//
		var t = 10 * 15;
		//
		var gfx = graphics;
		gfx.clear();
		gfx.beginFill(0xFF0000);
		gfx.drawRect(0, 0, t, t);*/
	}
}

