{NekoTest_NekoTest_live:function(){
	trace("");
	trace("");
	trace(callField(Sys,"getCwd",[]));
	for(f in callField(sys.FileSystem,"readDirectory",["."])) if(callField(sys.FileSystem,"isDirectory",[f])) trace(f) ;
},
___types___:["Sys", "sys.FileSystem", "NekoTest"]
}