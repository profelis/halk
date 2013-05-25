package ;

import halk.ILive;
import neko.vm.Thread;
import sys.FileSystem;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class NekoTest implements ILive
{

	public function new() {
	}
	
	static function sub() {
		new NekoTest();
	}
	
	public static function main() {
		
		Thread.create(sub);
		while (true) {}
			//Sys.sleep(0.1);
	}
	
	static function test(a:Float) {}
	
	@liveUpdate function live():Void {
		trace("");
		trace("");
		for (f in FileSystem.readDirectory(".")) 
			trace(f);
	}
	
}