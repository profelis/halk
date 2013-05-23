import flash.display.Sprite;
import haxe.Log;
import live.ILive;

/**
 * Haxe 3 requered
 * 
 * Что не работает:
 *  - енумы можно объявлять только с именем класса EnumName.EnumCtor (так и будет скорее всего)
 *  - не поддерживаются поля из родительских классов (планирую сделать)
 * 
 */
class Main implements ILive
{
	static function main() new Main();

	public var sprite:flash.display.Sprite;

	function new()
	{
		flash.Lib.current.stage.frameRate = 60;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		sprite = new flash.display.Sprite();
		flash.Lib.current.addChild(sprite);

		sprite.addEventListener(flash.events.Event.ENTER_FRAME, update);
		
		new A();
	}
	
	var color = 0xFF0000;
	
	@live function d() {
		color = 0x00FF00;
	}

	@liveUpdate function draw()
	{
		trace("draw");
		d();
		var t = 10 * 10;
		var s = sprite;
		this.sprite.graphics.clear();
		s.graphics.beginFill(color);
		s.graphics.drawRect(0, 0, t, t);
	}
	
	@live function update(_)
	{
		
		
		var t = 10 * 10;
		//Log.clear();
		//trace("1");
		var s = sprite;
		s.x += 5;
		s.y += 3;
		if (s.x > sprite.stage.stageWidth) s.x = -t;
		if (s.y > sprite.stage.stageHeight) s.y = -t;
		
		
		//callMethod(this, this.draw, [0xFF]);
		//this.sprite.x = this.sprite.x - 1;
		//if (this.sprite.x < 0) this.sprite.x = 400;
	}
}
