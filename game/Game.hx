package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Game extends Sprite {

	public var level:Int = 1;
	
	var points:Int = 0;
	
	var balls:Array<Ball>;
	
	public function new(stage) {
		
		super();
		stage.addChild(this);
		
		balls = [];
		init();
		
		addEventListener(Event.ENTER_FRAME, render);
	}
	
	public function init() {
		level = 3;
	}
	
	function render(_) {
		
		if (balls.length < level * 10) {
			for (i in balls.length...level * 10) {
				var b = new Ball(this);
				addChild(b);
				b.onKill = onKillBall;
				balls.push(b);
			}
		}
		
		for (b in balls) b.update();
	}
	
	function onKillBall(b:Ball, self:Bool) {
		balls.remove(b);
		b.destroy();
		removeChild(b);
		if (!self) {
			points ++;
			trace('Points: $points');
		}
	}
	
	
	
	static function main() {
		
		new Game(Lib.current.stage);
	}
	
}