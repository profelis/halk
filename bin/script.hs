{Main_Brick_draw:function(){
	trace("draw");
	var t=10*15;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF0000]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*15;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+15);
	setProperty(s,"y",getProperty(s,"y")+4);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
	[getProperty(this,"sprite")];
},
___types___:["Brick", "Main"]
}