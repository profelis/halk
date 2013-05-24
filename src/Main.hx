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
		
		new A();
	}
	
	@live function update(_)
	{
		var t = 10 * 10;
		//Log.clear();
		//trace("1");
		var s = this.sprite;
		s.x += 3;
		s.y += 4;
		if (s.x > sprite.stage.stageWidth) s.x = -t;
		if (s.y > sprite.stage.stageHeight) s.y = -t;
		
		//Log.clear();
		//callMethod(this, this.draw, [0xFF]);
		//this.sprite.x = this.sprite.x - 1;
		//if (this.sprite.x < 0) this.sprite.x = 400;
	}
}

class Brick extends Sprite implements ILive {
	
	public function new() {
		super();
	}
	@liveUpdate public function draw() {
		trace("start");
		
		var t = 10 * 10;
		
		var gfx = this.graphics;
		gfx.clear();
		gfx.beginFill(0xFF6600);
		gfx.drawRect(0, 0, t, t);
	}
}

