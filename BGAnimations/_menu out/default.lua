
return Def.ActorFrame{
	LoadActor("_moveono")..{
	StartTransitioningCommand=function(s)
		if ThemePrefs.Get("ITG1") then s:xy(GetTitleSafeH(0.9),GetTitleSafeV(0.8)) else s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y) end
		s:diffuse(GetCurrentColor(true)):sleep(0.2):linear(0.1):diffusealpha(1):sleep(0.2)
	end;
	},
	LoadActor("_moveonw")..{
	StartTransitioningCommand=function(s)
		if ThemePrefs.Get("ITG1") then s:xy(GetTitleSafeH(0.9),GetTitleSafeV(0.8)) else s:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y) end
		s:sleep(0.2):linear(0.1):diffusealpha(1):sleep(0.2)
	end;
	},
}