import flash.display.Sprite;
import haxe.Log;
import live.ILive;

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
	}
	
	var color = 0xFF0000;
	
	@live function d() {
		color = 0x00FF00;
	}

	@liveUpdate function draw()
	{
		trace("draw");
		d();
	}
	
	@live function update(_)
	{
		var t = 10 * 15;
		var s = sprite;
		this.sprite.graphics.clear();
		s.graphics.beginFill(color);
		s.graphics.drawRect(0, 0, t, t);
		
		//Log.clear();
		//trace("1");
		//Utf8.decode("123");
		
		s.x += 2;
		if (s.x > 400) s.x = -t;
		
		
		//callMethod(this, this.draw, [0xFF]);
		//this.sprite.x = this.sprite.x - 1;
		//if (this.sprite.x < 0) this.sprite.x = 400;
	}
}
