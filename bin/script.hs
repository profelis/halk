{Main_Brick_draw:function(){
	trace("draw");
	var t=10*15;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF0000]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_ttt:function(){
	trace([getProperty(this,"x"),getProperty(this,"y")]);
	{
		var x=10;
		{
			var x=20;
			trace(x);
			trace(getProperty(this,"x"));
		};
		trace(x);
	};
	trace(getProperty(this,"x"));
	var s2=new flash.display.Sprite();
	trace(s2);
	setProperty(Brick,"a",12);
	trace(getProperty(Brick,"a"));
},
Main_Main_update:function(_){
	var a=if(Std.is(this,flash.events.IEventDispatcher)) this else throw "can't cast 'this' to 'flash.events.IEventDispatcher'";
	var t=10*15;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+15);
	setProperty(s,"y",getProperty(s,"y")+4);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
___types___:["Brick", "Main", "flash.events.IEventDispatcher", "Std", "flash.display.Sprite"]
}