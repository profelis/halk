package ;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import halk.ILive;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Game extends Sprite implements ILive {

	public var level:Int = 1;
	
	var points:Int = 0;
	var pointsLabel:TextField;
	
	var balls:Array<Ball>;
	
	public function new(stage) {
		
		super();
		stage.addChild(this);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		addChild(pointsLabel = new TextField());
		pointsLabel.autoSize = TextFieldAutoSize.LEFT;
		pointsLabel.defaultTextFormat = new TextFormat("serif", 20);
		updatePointsLabel();
		
		balls = [];
		init();
		
		addEventListener(Event.ENTER_FRAME, render);
	}
	
	function updatePointsLabel() {
		pointsLabel.text = 'Points: $points';
	}
	
	@liveUpdate public function init() {
		level = 3;
	}
	
	function render(_) {
		
		var num = level * 3;
		if (balls.length < num) {
			for (i in balls.length...num) {
				if (Math.random() < 0.95) continue;
				var b = new Ball(this);
				b.onKill = onKillBall;
				addChild(b);
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
			points += Std.int(100 / b.size * b.vy);
			updatePointsLabel();
		}
	}
	
	static function main() {
		
		new Game(Lib.current.stage);
	}
	
}