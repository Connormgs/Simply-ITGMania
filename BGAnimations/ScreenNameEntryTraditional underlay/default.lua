local AlphabetWheels = {}
local Players = GAMESTATE:GetHumanPlayers()

---------------------------------------------------------------------------
-- The number of stages that were played this game cycle
local NumStages = SL.Global.Stages.PlayedThisGame
-- The duration (in seconds) each stage should display onscreen before cycling to the next
local DurationPerStage = 2
---------------------------------------------------------------------------
for player in ivalues(Players) do
	if SL[ToEnumShortString(player)].HighScores.EnteringName then
		-- Add one AlphabetWheel per human player
		AlphabetWheels[ToEnumShortString(player)] = setmetatable({}, sick_wheel_mt)
	end
end
---------------------------------------------------------------------------
-- Add the reusable metatable for a generic alphabet character
local alphabet_character_mt = LoadActor("./AlphabetCharacterMT.lua")

---------------------------------------------------------------------------
-- Alphanumeric Characters available to our players for highscore name use
local PossibleCharacters = {
	"&BACK;", "&OK;",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "?", "!"
}
---------------------------------------------------------------------------
-- Primary ActorFrame
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:queuecommand("CaptureInput")
	end,
	CaptureInputCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()

		for player in ivalues(Players) do
			local wheel = AlphabetWheels[ToEnumShortString(player)]

			if wheel then
				local profile = PROFILEMAN:GetProfile(player)
				-- if a profile is in use and has a HighScoreName, make the starting index 2 ("ok"); otherwise, 3 ("A")
				local StartingCharIndex = (profile and (profile:GetLastUsedHighScoreName() ~= "") and 2) or 3

				-- set_info_set() takes two arguments:
				--		a table of meaningful data to divvy up to wheel items
				--		the index of which wheel item we want to initially give focus to
				-- here, we are passing it all the possible characters,
				-- and either 2 ("ok") or 3 ("A") as the starting index
				AlphabetWheels[ToEnumShortString(player)]:set_info_set(PossibleCharacters, StartingCharIndex)
			end
		end

		-- actually attach the InputHandler function to our screen
		topscreen:AddInputCallback( LoadActor("InputHandler.lua", {self, AlphabetWheels}) )
	end,
	AttemptToFinishCommand=function(self)
		if not SL.P1.HighScores.EnteringName and not SL.P2.HighScores.EnteringName then
			self:playcommand("Finish")
		end
	end,
	MenuTimerExpiredCommand=function(self, param)

		-- if the timer runs out, check if either player hasn't finished entering his/her name
		-- if so, fade out that player's cursor and alphabetwheel and play the "start" sound
		for player in ivalues(Players) do
			local pn = ToEnumShortString(player)
			if SL[pn].HighScores.EnteringName then
				-- hide this player's cursor
				self:GetChild("PlayerNameAndDecorations_"..pn):GetChild("Cursor"):queuecommand("Hide")
				-- hide this player's AlphabetWheel
				self:GetChild("AlphabetWheel_"..pn):queuecommand("Hide")
				-- play the "enter" sound
				self:GetChild("enter"):playforplayer(player)
			end
		end

		self:playcommand("Finish")
	end,
	FinishCommand=function(self)
		-- store the highscore name for this game
		for player in ivalues(Players) do
			GAMESTATE:StoreRankingName(player, SL[ToEnumShortString(player)].HighScores.Name)

			-- if a profile is in use
			if PROFILEMAN:IsPersistentProfile(player) then
				-- update that profile's LastUsedHighScoreName attribute
				PROFILEMAN:GetProfile(player):SetLastUsedHighScoreName( SL[ToEnumShortString(player)].HighScores.Name )
			end
		end

		-- manually transition to the next screen (defined in Metrics)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}
t[#t+1] = LoadActor("../ScreenWithMenuElements underlay")
local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualStyle")
local banner_directory = FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")
local stages,stgindex = {},1
for i,v in ipairs( STATSMAN:GetAccumPlayedStageStats():GetPlayedSongs() ) do
	stages[#stages+1] = v
end


local function side(pn)
	local s = 1
	if pn == PLAYER_1 then return s end
	return s*(-1)
end

local function pnum(pn)
	if pn == PLAYER_2 then return 2 end
	return 1
end

local function TrailOrSteps(pn)
	if GAMESTATE:IsCourseMode() then return GAMESTATE:GetCurrentTrail(pn) end
	return GAMESTATE:GetCurrentSteps(pn)
end
local stages,stgindex = {},1
for i,v in ipairs( STATSMAN:GetAccumPlayedStageStats():GetPlayedSongs() ) do
	stages[#stages+1] = v
end

local ni=0

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	local MetricsName = "Keyboard" .. PlayerNumberToString(pn)
	t[#t+1] = LoadActor( THEME:GetPathG("ScreenNameEntryTraditional","Wheel"),pn)..{
		InitCommand=function(self) self:player(pn) end,
		OnCommand=function(self)
			self:xy(
				pn == PLAYER_1 and SCREEN_CENTER_X-157 or SCREEN_CENTER_X+157,
				SCREEN_CENTER_Y+90
			)
			:addx( pn == PLAYER_1 and -SCREEN_WIDTH or SCREEN_WIDTH )
			:decelerate(0.5):addx( pn == PLAYER_1 and SCREEN_WIDTH or -SCREEN_WIDTH )
		end,
		OffCommand=function(self) self:accelerate(0.5):addx( pn == PLAYER_1 and -SCREEN_WIDTH or SCREEN_WIDTH ) end
	}




	t[#t+1] = Def.ActorFrame{
		OnCommand=function(self)
			self:xy(
			pn == PLAYER_1 and SCREEN_CENTER_X-214 or SCREEN_CENTER_X+214,
			SCREEN_CENTER_Y-118
			)
			:addx( pn == PLAYER_1 and -SCREEN_WIDTH or SCREEN_WIDTH )
			:decelerate(0.5):addx( pn == PLAYER_1 and SCREEN_WIDTH or -SCREEN_WIDTH )
		end,
		OffCommand=function(self) self:accelerate(0.5):addx( pn == PLAYER_1 and -SCREEN_WIDTH or SCREEN_WIDTH ) end,
		
		Def.Sprite{
			Texture=THEME:GetPathG("NameEntry","Items/BGA score frame"),
			Condition=not ThemePrefs.Get("ITG1")
		},



		Def.BitmapText{
			Font="_futurist metal",
			OnCommand=function(self)
				self:diffuse(PlayerColor(pn))
				if STATSMAN:GetPlayedStageStats( ni ) and STATSMAN:GetPlayedStageStats( ni ):GetPlayerStageStats(pn) then
					self:settext( string.format( "%.2f%%", STATSMAN:GetPlayedStageStats( ni ):GetPlayerStageStats(pn):GetPercentDancePoints()*100 ) )
				end
			end,
			ChangeDisplayedFeatMessageCommand=function(self,param)
				if STATSMAN:GetPlayedStageStats( ni ) and STATSMAN:GetPlayedStageStats( ni ):GetPlayerStageStats(pn) then
					self:settext( string.format( "%.2f%%", STATSMAN:GetPlayedStageStats( ni ):GetPlayerStageStats(pn):GetPercentDancePoints()*100 ) )
				end
			end
		},
		LoadActor("name frame")..{
			OnCommand=function(s)
				s:xy(40,95)
			end;
		}
	
	}

	t[#t+1] = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(
			pn == PLAYER_1 and SCREEN_CENTER_X-214 or SCREEN_CENTER_X+214,
			SCREEN_CENTER_Y-160
		)
	end,
	OffCommand=function(self) self:accelerate(0.5):addx( pn == PLAYER_1 and -SCREEN_WIDTH or SCREEN_WIDTH ) end,
	ChangeDisplayedFeatMessageCommand=function(self)
		self:stoptweening():linear(0.2):diffusealpha(0.4):linear(0.2):diffusealpha(1)
	end,
		Def.Sprite{
			Texture=THEME:GetPathG('',ThemePrefs.Get("ITG1") and '_evaluation difficulty icons' or '_difficulty icons'),
			OnCommand=function(self)
				self:xy(0,0):animate(0):playcommand("Update")
			end,
			UpdateCommand=function(self,parent) self:setstate( SetFrameDifficulty(pn,true) ) end,
		},	
		Def.BitmapText{
			Font="Common Normal",
			OnCommand=function(self)
				if ThemePrefs.Get("ITG1") then
					self:diffuse(Color.Black)
				end
				self:zoom(0.5):x( -38*side(pn) )
				:halign( pnum(pn)-1 ):playcommand("Update")
			end,
			ChangeDisplayedFeatMessageCommand=function(self,param)
				local stats = STATSMAN:GetPlayedStageStats( stgindex ):GetPlayerStageStats(pn):GetPlayedSteps()
				self:settext( THEME:GetString("Difficulty",ToEnumShortString(stats[1]:GetDifficulty()) ) )
				if not ThemePrefs.Get("ITG1") then
					self:diffuse( ContrastingDifficultyColor( stats[1]:GetDifficulty() ) )
				end
			end
		},	
		Def.BitmapText{
			Font="Common Normal",
			OnCommand=function(self)
				if ThemePrefs.Get("ITG1") then
					self:diffuse(Color.Black)
				end
				self:zoom(0.5):x(36*side(pn)):horizalign(pn == PLAYER_1 and right or left):playcommand("Update")
			end,
			ChangeDisplayedFeatMessageCommand=function(self,param)
				local stats = STATSMAN:GetPlayedStageStats( stgindex ):GetPlayerStageStats(pn):GetPlayedSteps()
				self:settext( stats[1]:GetMeter() )
				if not ThemePrefs.Get("ITG1") then
					self:diffuse( ContrastingDifficultyColor( stats[1]:GetDifficulty() ) )
				end
			end
		}
	}
end


t[#t+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(SCREEN_CENTER_X-1,SCREEN_CENTER_Y-126):zoom( ThemePrefs.Get("ITG1") and 0.9 or 1 ) end,
	OnCommand=function(self)
		self:y(SCREEN_TOP-100):decelerate(0.5):y(SCREEN_CENTER_Y-( ThemePrefs.Get("ITG1") and 160 or 138))
	end,
	OffCommand=function(self)
		self:accelerate(0.5):addy(-SCREEN_CENTER_X)
	end,
	Def.Sprite{
		Texture=THEME:GetPathG("ScreenEvaluation banner","frame"),
		OnCommand=function(self)
			self:zoom(1.02)
		end
	},
	Def.Sprite{
		Texture=THEME:GetPathG("Evaluation","banner frame mask"),
		Condition=not ThemePrefs.Get("ITG1"),
		OnCommand=function(self)
			self:zwrite(1):z(1):blend("BlendMode_NoEffect"):zoom(1.02)
		end
	},



	Def.Banner{
		InitCommand=function(self)
			self:LoadFromSong( stages[stgindex] )
		end,
		OnCommand=function(self)
			self:scaletoclipped(ThemePrefs.Get("ITG1") and 418/1.6 or 418/2,164/2):ztest(1)
		end,
		ChangeDisplayedFeatMessageCommand=function(self,param)
			stgindex = param.CurrentIndex
			ni = param.NewIndex
			self:linear(0.1):diffusealpha(0):queuecommand("UpdateImage")
		end,
		UpdateImageCommand=function(self)
			self:LoadFromSong( stages[ni] ):scaletoclipped(ThemePrefs.Get("ITG1") and 418/1.6 or 418/2,164/2):linear(0.5):diffusealpha(1)
		end
	},

	Def.Sprite{
		Texture=THEME:GetPathG("ScreenEvaluation banner","frame"),
		Condition=not ThemePrefs.Get("ITG1")
	},
	

	
}
for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	local x_offset = (player == PLAYER_1 and -120) or 200

	t[#t+1] = LoadActor("PlayerNameAndDecorations.lua", player)
	t[#t+1] = LoadActor("./HighScores.lua", player)

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	-- create_actors() takes five arguments
	--		a name
	--		the number of wheel actors to actually create onscreen
	--			note that this is NOT equal to how many items you want to be able to scroll through
	--			it is how many you want visually onscreen at a given moment
	--		a metatable defining a generic item in the wheel
	--		x position
	--		y position
	if SL[pn].HighScores.EnteringName then
		t[#t+1] = AlphabetWheels[pn]:create_actors( "AlphabetWheel_"..pn, 7, alphabet_character_mt, _screen.cx + x_offset, _screen.cy+38)
	end
end

-- ActorSounds
t[#t+1] = LoadActor( THEME:GetPathS("", "_change value"))..{    Name="delete",  IsAction=true, SupportPan=true }
t[#t+1] = LoadActor( THEME:GetPathS("Common", "start"))..{      Name="enter",   IsAction=true, SupportPan=true }
t[#t+1] = LoadActor( THEME:GetPathS("MusicWheel", "change"))..{ Name="move",    IsAction=true, SupportPan=true }
t[#t+1] = LoadActor( THEME:GetPathS("common", "invalid"))..{    Name="invalid", IsAction=true, SupportPan=true }

--
return t
