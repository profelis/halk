package ;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Ball extends Sprite {

	var game:Game;
	function new(game) {
		
		super();
		
		this.game = game;
		x = game.stage.stageWidth * Math.random();
		y = game.stage.stageHeight;
		init();
		draw();
		useHandCursor = true;
		buttonMode = true;
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	function onClick(_) {
		onKill(this, false);
	}
	
	function init() {
		var level = game.level;
		vy = Math.random() * level;
		vx = (Math.random() - 0.5) * level * 0.1;
	}
	
	public function draw() {
		var gfx = graphics;
		gfx.clear();
		gfx.lineStyle(0, 0x000000);
		gfx.beginFill(0xFF0000);
		gfx.drawCircle(0, 0, 10 + Math.random() * 20);
	}
	
	var vx:Float;
	var vy:Float;
	
	public function update() {
		x += vx;
		y -= vy;
		
		if (y < -100) {
			onKill(this, true);
		}
	}
	
	public function destroy() {
		game = null;
	}
	
	public dynamic function onKill(ball:Ball, self:Bool):Void {}
	
}