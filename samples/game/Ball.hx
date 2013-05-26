package ;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import halk.ILive;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Ball extends Sprite implements ILive {

	var game:Game;
	
	function new(game) {
		
		super();
		this.game = game;
		
		init();
		x = game.stage.stageWidth * Math.random();
		y = game.stage.stageHeight + height;
		
		useHandCursor = true;
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	function onClick(_) {
		onKill(this, false);
	}
	
	public var size:Float;
	
	@liveUpdate function init() {
		
		var gfx = graphics;
		gfx.clear();
		gfx.lineStyle(4, 0x000000);
		gfx.beginFill(0xFF0000);
		gfx.drawCircle(0, 0, size = 20 + Math.random() * 20);
		
		var level = game.level;
		vy = Math.random() * level + 1;
		vx = (Math.random() - 0.5) * level * 3;
	}
	
	public var vx:Float = 0;
	public var vy:Float = 0;
	
	@live public function update() {
		x += vx;
		y -= vy;
		if (x < 0 || x > stage.stageWidth) {
			vx = -vx * 0.9;
			x += vx * 2;
		}
		
		if (y < -100) {
			onKill(this, true);
		}
	}
	
	public function destroy() {
		game = null;
		#if halk removeLiveListers(); #end
	}
	
	public dynamic function onKill(ball:Ball, self:Bool):Void {}
	
}