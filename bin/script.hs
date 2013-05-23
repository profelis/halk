{Main_Main_d:function(){
	setProperty(this,"color",0x00FFFF);
},
Main_Main_draw:function(){
	trace("draw");
	callField(this,"d",[]);
	var t=10*10;
	var s=getProperty(this,"sprite");
	callField(getProperty(getProperty(this,"sprite"),"graphics"),"clear",[]);
	callField(getProperty(s,"graphics"),"beginFill",[getProperty(this,"color")]);
	callField(getProperty(s,"graphics"),"drawRect",[0,0,t,t]);
},
Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	setProperty(s,"x",getProperty(s,"x")+5);
	setProperty(s,"y",getProperty(s,"y")+3);
	if(getProperty(s,"x")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageWidth")) setProperty(s,"x",-t) ;
	if(getProperty(s,"y")>getProperty(getProperty(getProperty(this,"sprite"),"stage"),"stageHeight")) setProperty(s,"y",-t) ;
}}