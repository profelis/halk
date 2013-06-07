{NekoTest_NekoTest_live:function(){
	trace("");
	for(f in callField(sys.FileSystem, "readDirectory", ["../src/halk"])) trace(f);
},
___types___:["NekoTest", "sys.FileSystem"]
}