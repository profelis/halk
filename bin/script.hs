{Main_Main_d:function(){
	setProperty(this,"color",0x00FF00);
},
Main_Main_draw:function(){
	trace("draw");
	callField(this,"d",[]);
},
Main_Main_update:function(_){
	var t=10*15;
	var s=getProperty(this,"sprite");
	callField(getProperty(getProperty(this,"sprite"),"graphics"),"clear",[]);
	callField(getProperty(s,"graphics"),"beginFill",[getProperty(this,"color")]);
	callField(getProperty(s,"graphics"),"drawRect",[0,0,t,t]);
	setProperty(s,"x",getProperty(s,"x")+2);
	if(getProperty(s,"x")>400) setProperty(s,"x",-t) ;
}}