package ;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Ball extends Sprite {

	function new() {
		
		init();
		draw();
		
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	var level = 3;
	
	function init() {
		level = 4;
		vy = Math.random() * level;
		vx = (Math.random() - 0.5) * level * 0.1;
	}
	
	public function draw() {
		var gfx = graphics;
		gfx.clear();
		gfx.lineStyle();
		gfx.beginFill(0xFF0000);
		gfx.drawCircle(0, 0, 50 + Math.random() * 50);
	}
	
	var vx:Float;
	var vy:Float;
	
	public function update(_) {
		x += vx;
		y -= vy;
		
		if (y < -100) {
			kill();
		}
	}
	
	function kill() {
		parent.removeChild(this);
		removeEventListener(Event.ENTER_FRAME, update);
	}
	
	static public function build(stage:Stage):Ball {
		var b = new Ball();
		b.x = stage.stageWidth * Math.random();
		b.y = stage.stageHeight;
	}
	
}