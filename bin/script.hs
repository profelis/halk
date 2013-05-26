{Game_Game_init:function(){
	setProperty(this,"level",3);
},
Ball_Ball_init:function(){
	var gfx=getProperty(this,"graphics");
	callField(gfx,"clear",[]);
	callField(gfx,"lineStyle",[4,0x000000]);
	callField(gfx,"beginFill",[0xFF0000]);
	callField(gfx,"drawCircle",[0,0,setProperty(this,"size",20+callField(Math,"random",[])*20)]);
	var level=getProperty(getProperty(this,"game"),"level");
	setProperty(this,"vy",callField(Math,"random",[])*level+1);
	setProperty(this,"vx",(callField(Math,"random",[])-0.5)*level*3);
},
___types___:["Ball", "Math", "Game"]
}