import flash.display.Sprite;
import haxe.Log;

@:build(Macro.build())
class Main
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
	}
	
	var color = 0xFF0000;

	@liveUpdate function draw()
	{
		color = 0xFF00FF;
	}
	
	@live function update(_)
	{
		var t = 10 * 10;
		var s = sprite;
		sprite.graphics.clear();
		s.graphics.beginFill(0x000000);
		s.graphics.drawRect(0, 0, t, t);
		
		//Log.clear();
		//trace("1");
		//Utf8.decode("123");
		
		s.x += 5;
		if (s.x > 400) s.x = -t;
		
		//callMethod(this, this.draw, [0xFF]);
		//this.sprite.x = this.sprite.x - 1;
		//if (this.sprite.x < 0) this.sprite.x = 400;
	}
}
