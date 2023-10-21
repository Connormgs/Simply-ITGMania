local t = Def.ActorFrame{}
local itgstylemargin = ThemePrefs.Get("ITG1") and -10 or 0
local Players = GAMESTATE:GetHumanPlayers()
local NumPanes = SL.Global.GameMode=="Casual" and 1 or 8
local InputHandler = nil
local EventOverlayInputHandler = nil

if ThemePrefs.Get("WriteCustomScores") then
	WriteScores()
end



if SL.Global.GameMode ~= "Casual" then
	-- add a lua-based InputCalllback to this screen so that we can navigate
	-- through multiple panes of information; pass a reference to this ActorFrame
	-- and the number of panes there are to InputHandler.lua
	t.OnCommand=function(self)
		InputHandler = LoadActor("./InputHandler.lua", {self, NumPanes})
		EventOverlayInputHandler = LoadActor("./Shared/EventInputHandler.lua")
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		PROFILEMAN:SaveMachineProfile()
	end
	t.DirectInputToEngineCommand=function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(EventOverlayInputHandler)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)

		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, false)
		end
	end
	t.DirectInputToEventOverlayHandlerCommand=function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
		SCREENMAN:GetTopScreen():AddInputCallback(EventOverlayInputHandler)

		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
	end
else
	t.OnCommand=function(self)
		PROFILEMAN:SaveMachineProfile()
	end
end



local function side(pn)
	local s = 1
	if pn == PLAYER_1 then return s end
	return s*(-1)
end

local function Gradeside(pn)
	local s = -365+(itgstylemargin*1.2)
	if pn == PLAYER_2 then s = 56+(itgstylemargin*-1.3) end
	return s
end

local function pnum(pn)
	if pn == PLAYER_2 then return 2 end
	return 1
end




t[#t+1] = Def.ActorFrame{
	-- The biggest challenge here was to compesate the positions because of SM5's TextureFiltering.
	-- It is different from 3.95/OpenITG's filters, which differ a lot with the original positions.
	-- IN ADDITION of the different x and y handling anyways.
	-- 																			Jose_Varela
	Def.ActorFrame{
		OnCommand=function(self)
			self:xy(35,38)
		end,

		Def.BitmapText{
		Font=_eurostileColorPick(),
		Text=string.upper(THEME:GetString("ScreenEvaluation","HeaderText")),
			InitCommand=function(self) self:shadowlength(4):x(self:GetWidth()/2):skewx( ThemePrefs.Get("ITG1") and 0 or -0.16) end,
			OnCommand=function(self)
				self:zoomx(0):zoomy(6):sleep(0.3):bounceend(0.3):zoom(1)
			end,
			OffCommand=function(self)
				self:accelerate(0.2):zoomx(2):zoomy(0):diffusealpha(0)
				SOUND:PlayOnce( ThemePrefs.Get("ITG1") and THEME:GetPathS("ITG1/Common","start") or THEME:GetPathS("_ITGCommon","start") )
			end
		},

		Def.Sprite{
			Texture=THEME:GetPathG("ScreenWithMenuElements Items/stage",""..StageIndexBySegment(true)),
			Condition=not ThemePrefs.Get("ITG1"),
			OnCommand=function(self)
				if GAMESTATE:GetCurrentStage() == "Stage_Final" then
					self:Load( THEME:GetPathG("ScreenWithMenuElements Items/stage","final") )
				end
				self:x(30):y(34):addx(-SCREEN_WIDTH):sleep(3):decelerate(0.3):addx(SCREEN_WIDTH)
			end,
			OffCommand=function(self)
				self:accelerate(.2):zoomx(2):zoomy(0):diffusealpha(0)
			end
		},
	
		LoadActor( THEME:GetPathG("ScreenWithMenuElements","Items/ITG1"), true )..{
			Condition=ThemePrefs.Get("ITG1"),
			OnCommand=function(self)
				self:xy(SCREEN_RIGHT-140,0):addx(SCREEN_WIDTH):sleep(0.2):decelerate(0.6):addx(-SCREEN_WIDTH)
			end,
			OffCommand=function(self) self:accelerate(.5):addx(SCREEN_WIDTH) end
		}
	},

	-- Banner frame
	LoadActor( THEME:GetPathG("Evaluation","banner frame mask") )..{
		Condition=not ThemePrefs.Get("ITG1"),
		InitCommand=function(self) self:xy(SCREEN_CENTER_X-1,SCREEN_CENTER_Y-126) end,
		OnCommand=function(self)
			self:zwrite(1):z(1):blend("BlendMode_NoEffect"):y(SCREEN_TOP-100):sleep(3):decelerate(0.3):y(SCREEN_CENTER_Y-125):zoom(1.02)
		end,
		OffCommand=function(self)
			self:accelerate(0.3):addy(-SCREEN_CENTER_X)
		end
	},



	Def.Sprite{
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X-1,SCREEN_CENTER_Y-126)
			local bannerPath = THEME:GetPathG( (ThemePrefs.Get("ITG1") and "ITG1/" or "ITG2 ") .."Common fallback", "banner")
			if GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetBannerPath() ~= nil then
				bannerPath = GAMESTATE:GetCurrentCourse():GetBannerPath()
			end
			if GAMESTATE:GetCurrentSong() and not GAMESTATE:IsCourseMode() then
				if GAMESTATE:GetCurrentSong():GetBannerPath() ~= nil then 
					bannerPath = GAMESTATE:GetCurrentSong():GetBannerPath()
				end
				for pn in ivalues(PlayerNumber) do
					if GAMESTATE:GetCurrentSong():GetGroupName() == PROFILEMAN:GetProfile(pn):GetDisplayName() then
						bannerPath = THEME:GetPathG("Banner","custom")
					end
				end
			end

			self:Load( bannerPath )
		end,
		OnCommand=function(self)
			self:scaletoclipped( ThemePrefs.Get("ITG1") and 418/1.6 or 418/2,164/2):ztest(1):y(SCREEN_TOP-100):sleep(3):decelerate(0.3):y(SCREEN_CENTER_Y-124+(itgstylemargin*2.4))
		end,
		OffCommand=function(self)
			self:accelerate(0.3):addy(-SCREEN_CENTER_X)
		end
	},


	
	LoadActor( THEME:GetPathG("","ScreenEvaluation banner frame") )..{
		Condition=not ThemePrefs.Get("ITG1"),
		InitCommand=function(self) self:xy(SCREEN_CENTER_X-1,SCREEN_CENTER_Y-126) end,
		OnCommand=function(self)
			self:y(SCREEN_TOP-100):sleep(3):decelerate(0.3):y(SCREEN_CENTER_Y-124):diffuse(GetCurrentColor(true))
		end,
		OffCommand=function(self)
			self:accelerate(0.3):addy(-SCREEN_CENTER_X)
		end
	},

	Def.HelpDisplay {
		File="_eurostile normal",
		OnCommand=function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y+203):zoom(0.7):diffuseblink():maxwidth(SCREEN_WIDTH/0.8)
			:zoomy(0):sleep(2.5):linear(0.5):zoomy(0.7)
		end,
		InitCommand=function(self)
			local s = THEME:GetString("ScreenEvaluation","HelpTextNormal") .. "::" .. THEME:GetString("ScreenEvaluation","TakeScreenshotHelpTextAppend")
			self:SetSecsBetweenSwitches(THEME:GetMetric("HelpDisplay","TipSwitchTime"))
			self:SetTipsColonSeparated(s)
		end,
		OffCommand=function(self)
			self:linear(0.5):zoomy(0)
		end
	}
}
-- First, add actors that would be the same whether 1 or 2 players are joined.

-- code for triggering a screenshot and animating a "screenshot" texture
t[#t+1] = LoadActor("./Shared/ScreenshotHandler.lua")

-- the title of the song and its graphical banner, if there is one
t[#t+1] = LoadActor("./Shared/TitleAndBanner.lua")

-- text to display BPM range (and ratemod if ~= 1.0) and song length immediately
-- under the banner
t[#t+1] = LoadActor("./Shared/SongFeatures.lua")

-- store some attributes of this playthrough of this song in the global SL table
-- for later retrieval on ScreenEvaluationSummary
t[#t+1] = LoadActor("./Shared/GlobalStorage.lua")

-- help text that appears if we're in Casual gamemode
t[#t+1] = LoadActor("./Shared/CasualHelpText.lua")
for player in ivalues(Players) do

	-- the per-player upper half of ScreenEvaluation, including: letter grade, nice
	-- stepartist, difficulty text, difficulty meter, machine/personal HighScore text
	t[#t+1] = LoadActor("./PerPlayer/Upper/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/Lower/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/ItlFile.lua", player)

end
t[#t+1] = LoadActor("./Panes/default.lua", NumPanes)
t[#t+1] = LoadActor("./Shared/AutoSubmitScore.lua")
collectgarbage()
return t
