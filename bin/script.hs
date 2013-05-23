{Main_Main_update:function(_){
	var t=10*10;
	var s=getProperty(this,"sprite");
	callField(getProperty(getProperty(this,"sprite"),"graphics"),"clear",[]);
	callField(getProperty(s,"graphics"),"beginFill",[0x000000]);
	callField(getProperty(s,"graphics"),"drawRect",[0,0,t,t]);
	setProperty(s,"x",getProperty(s,"x")+5);
	if(getProperty(s,"x")>400) setProperty(s,"x",-t) ;
}}