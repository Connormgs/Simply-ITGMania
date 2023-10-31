local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")
InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
local t = Def.ActorFrame{}
	
if not GAMESTATE:IsCourseMode() then
t[#t+1] = Def.ActorFrame{
		Def.Sprite{
		Condition=not ThemePrefs.Get("ITG1"),
		Texture=THEME:GetPathG( "StageAndCourses/ScreenGameplay","stagew ".. ToEnumShortString(GAMESTATE:GetCurrentStage()) ),
		OnCommand=function(self)
			if #GAMESTATE:GetHumanPlayers() == 1 and GetNotefieldX( GAMESTATE:GetMasterPlayerNumber() ) == _screen.cx then
			local player = GAMESTATE:GetHumanPlayers()[1]
			self:x(_screen.cx + (GetNotefieldWidth()*0.5 + self:GetWidth()*0.25) * (player==PLAYER_1 and -1 or 1)):zoom(0.25):y(_screen.h-30):diffusealpha(1):sleep(2)
		else
			self:Center():draworder(105):zoom(1):sleep(1.2):linear(0.3):zoom(0.25):y(SCREEN_BOTTOM-40)
		end
	end,
		OffCommand=function(self)
			self:accelerate(0.8):addy(150)
		end;
		},
		Def.Sprite{
		Condition=not ThemePrefs.Get("ITG1"),
		Texture=THEME:GetPathG( "StageAndCourses/ScreenGameplay","stageo ".. ToEnumShortString(GAMESTATE:GetCurrentStage()) ),
		OnCommand=function(self)
			if #GAMESTATE:GetHumanPlayers() == 1 and GetNotefieldX( GAMESTATE:GetMasterPlayerNumber() ) == _screen.cx then
			local player = GAMESTATE:GetHumanPlayers()[1]
			self:diffuse(GetCurrentColor(true)):x(_screen.cx + (GetNotefieldWidth()*0.5 + self:GetWidth()*0.25) * (player==PLAYER_1 and -1 or 1)):zoom(0.25):y(_screen.h-30):diffusealpha(1):sleep(2)
		else
			self:diffuse(GetCurrentColor(true)):Center():draworder(105):zoom(1):sleep(1.2):linear(0.3):zoom(0.25):y(SCREEN_BOTTOM-40)
		end
	end,
		OffCommand=function(self)
			self:accelerate(0.8):addy(150)
		end;
		},
LoadActor( THEME:GetPathB("","_frame 3x1"), {"name entry",100} )..{
			Condition=ThemePrefs.Get("ITG1") and not GAMESTATE:IsDemonstration();
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-40):addy(300):sleep(1.2):decelerate(0.3):addy(-300)
			end;
		};
		LoadActor( THEME:GetPathB("","_frame 3x1"), {"name entry",100} )..{
			Condition=ThemePrefs.Get("ITG1") and not GAMESTATE:IsDemonstration();
			OnCommand=function(self)
				self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-40):addy(300):sleep(1.2):decelerate(0.3):addy(-300)
			end;
		};
		
};
end

return t;
