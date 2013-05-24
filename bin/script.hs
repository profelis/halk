{Main_Brick_draw:function(){
	trace("start");
	var t=10*10;
	var gfx=this.graphics;
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF6600]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=this.sprite;
	setProperty(s,"x",getProperty(s,"x")+3);
	setProperty(s,"y",getProperty(s,"y")+4);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
}
}