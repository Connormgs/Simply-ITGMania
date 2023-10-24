
return Def.ActorFrame{

LoadActor("_moveonw")..{
	StartTransitioningCommand=function(s)
		if ThemePrefs.Get("ITG1") then s:xy(GetTitleSafeH(0.9),GetTitleSafeV(0.8)) else s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y) end
		s:linear(0.2):diffusealpha(0)
	end;
	},
	LoadActor("_moveono")..{
	StartTransitioningCommand=function(s)
		if ThemePrefs.Get("ITG1") then s:xy(GetTitleSafeH(0.9),GetTitleSafeV(0.8)) else s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y) end
		s:diffuse(GetCurrentColor(true)):linear(0.2):diffusealpha(0)
	end;
	},
	
}