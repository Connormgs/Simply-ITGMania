local style = ThemePrefs.Get("ITG1") and "ITG1/" or ""
return Def.ActorFrame{
	OnCommand=function(self)
		self:ztest(1):addx(-420):sleep(0.35):linear(0.5):addx(420):diffuse(GetCurrentColor(true))
	end;
	OffCommand=function(s) s:linear(0.5):addx(-420) end;
	CancelMessageCommand=function(s) if GAMESTATE:Env()["WorkoutMode"] then s:linear(0.5):addx(-420) end end;

	Def.Sprite{ Texture="WheelItems/"..style.."SectionCollapsed" },
	InitCommand=function(self)
		self:diffuse(GetCurrentColor(true))
	end;
	Def.BitmapText{
    Font="_eurostile normal", Text=string.upper( THEME:GetString("MusicWheel","Portal") ),
    InitCommand=function(self)
		self:diffuse(GetCurrentColor(true)):x(-28):strokecolor(0.2,0.2,0.2,1):maxwidth(220)
	end;
	},
};