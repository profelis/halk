package ;
import flash.display.Sprite;
import flash.Lib;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Main extends Sprite {

	public function new() {
		
		super();
	}
	
	static function main() {
		
		Lib.current.addChild(new Main());
	}
	
}