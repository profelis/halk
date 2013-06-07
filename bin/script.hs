{Game_Game_init:function(){
	setProperty(this, "level", 3);
},
Ball_Ball_draw:function(){
	var gfx = getProperty(this, "graphics");
	callField(gfx, "clear", []);
	callField(gfx, "lineStyle", [5, 0xFFFFFF * callField(Math, "random", [])]);
	callField(gfx, "beginFill", [callField(Std, "int", [0xFFFFFF * callField(Math, "random", [])])]);
	callField(gfx, "drawCircle", [0, 0, setProperty(this, "size", 20 + callField(Math, "random", []) * 20)]);
},
Ball_Ball_init:function(){
	var level = getProperty(getProperty(this, "game"), "level");
	setProperty(this, "vy", callField(Math, "random", []) * level + 1.5);
	setProperty(this, "vx", (callField(Math, "random", []) - 0.5) * 15);
},
Ball_Ball_update:function(){
	setProperty(this, "x", getProperty(this, "x") + getProperty(this, "vx"));
	setProperty(this, "y", getProperty(this, "y") - getProperty(this, "vy"));
	if(getProperty(this, "x") < 0 || getProperty(this, "x") > getProperty(getProperty(this, "stage"), "stageWidth")) {
		setProperty(this, "vx", -getProperty(this, "vx") * 0.9);
		setProperty(this, "x", getProperty(this, "x") + getProperty(this, "vx") * 2);
	} ;
	if(getProperty(this, "y") < (-100)) {
		callField(this, "onKill", [this, true]);
	} ;
},
___types___:["Std", "Ball", "Math", "Game"]
}