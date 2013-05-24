{Main_Brick_draw:function(){
	var t=10*15;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+5);
	setProperty(s,"y",getProperty(s,"y")+3);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+5);
	setProperty(s,"y",getProperty(s,"y")+3);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+8);
	setProperty(s,"y",getProperty(s,"y")+3);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+3);
	setProperty(s,"y",getProperty(s,"y")+3);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+3);
	setProperty(s,"y",getProperty(s,"y")+0);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF00FF]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+3);
	setProperty(s,"y",getProperty(s,"y")+6);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
},
Main_Brick_draw:function(){
	var t=10*10;
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"beginFill",[0xFF0000]);
	callField(gfx,"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+3);
	setProperty(s,"y",getProperty(s,"y")+6);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
}}