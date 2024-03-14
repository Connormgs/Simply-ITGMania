local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")
InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
local t = Def.ActorFrame{}
	
if not GAMESTATE:IsCourseMode() then

end

return t;
