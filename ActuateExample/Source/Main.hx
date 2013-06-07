package;


import flash.display.Sprite;
import flash.events.Event;
import halk.ILive;
import motion.Actuate;
import motion.easing.Quad;


class Main extends Sprite implements ILive {
	
	
	public function new () {
		
		super ();
		
		initialize ();
		construct ();
		
	}
	
	
	private function animateCircle (circle:Sprite):Void {
		
		var duration = 1.5 + Math.random () * 4.5;
		var targetX = Math.random () * stage.stageWidth;
		var targetY = Math.random () * stage.stageHeight;
		
		draw(circle);
		Actuate.tween (circle, duration, { x: targetX, y: targetY }, false).ease (Quad.easeOut).onComplete (animateCircle, [ circle ]);
		
	}
	
	@live private function draw(circle:Sprite) {
		
		circle.graphics.clear();
		
		var size = 5 + Math.random () * 35 + 20;
		circle.graphics.beginFill (Std.int (Math.random() * 0xffffff), 1);
		circle.graphics.drawCircle (0, 0, size);
		circle.alpha = 0.2 + Math.random () * 0.6;
	}
	
	
	private function construct ():Void {
		
		for (i in 0...80) {
			
			var creationDelay = Math.random () * 10;
			Actuate.timer (creationDelay).onComplete (createCircle);
			
		}
		
	}
	
	
	private function createCircle ():Void {
		
		var circle = new Sprite ();
		
		draw(circle);
		circle.x = Math.random () * stage.stageWidth;
		circle.y = Math.random () * stage.stageHeight;
		
		addChildAt (circle, 0);
		animateCircle (circle);
		
	}
	
	
	private function initialize ():Void {
		
		stage.addEventListener (Event.ACTIVATE, stage_onActivate);
		stage.addEventListener (Event.DEACTIVATE, stage_onDeactivate);
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function stage_onActivate (event:Event):Void {
		
		//Actuate.resumeAll ();
		
	}
	
	
	private function stage_onDeactivate (event:Event):Void {
		
		//Actuate.pauseAll ();
		
	}
	
	
}