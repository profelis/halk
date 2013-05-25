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
		while (true)
			Sys.sleep(0.1);
	}
	
	@liveUpdate function live():Void {
		trace("");
		trace("");
		trace(Sys.getCwd());
		for (f in FileSystem.readDirectory(".")) 
			if (FileSystem.isDirectory(f)) trace(f);
	}
	
}