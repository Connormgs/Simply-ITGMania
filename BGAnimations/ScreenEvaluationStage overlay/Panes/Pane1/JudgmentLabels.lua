local player, controller = unpack(...)

local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local GetTNSStringFromTheme = function( arg )
	return THEME:GetString(tns_string, arg)
end

-- iterating through the TapNoteScore enum directly isn't helpful because the
-- sequencing is strange, so make our own data structures for this purpose
local TapNoteScores = {}
TapNoteScores.Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
TapNoteScores.Names = map(GetTNSStringFromTheme, TapNoteScores.Types)

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Jumps'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls'),
	
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Jumps')] = "Jumps",
	[THEME:GetString("ScreenEvaluation", 'Hands')] = "Hands",
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
	
}

local scores_table = {}
for index, window in ipairs(TapNoteScores.Types) do
	local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
	scores_table[window] = number
end


local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(50 * (controller==PLAYER_1 and 1 or -1), _screen.cy-24)
		if player == PLAYER_2 then self:x(-150) end
	end,
}

	t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base.png"),
	Name="base",
	InitCommand=function(self)
		self:xy(-120,80):diffuse(GetCurrentColor(true)) 
		if player == PLAYER_2 then self:x(9999) end
	end,
}

	t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base.png"),
	Name="base",
	InitCommand=function(self)
		self:xy(120,80):diffuse(GetCurrentColor(true)) 
		if player == PLAYER_1 then self:x(9999) end
	end,
}

local windows = SL[pn].ActiveModifiers.TimingWindows
local maxCount = 1
for i=1, #TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
	if number > maxCount then maxCount = number end
end
local itgstylemargin = ThemePrefs.Get("ITG1") and -10 or 0
local battlegraphloc = ThemePrefs.Get("ITG1") and "ITG1/" or ""
t[#t+1] = Def.Sprite{
	Condition=GAMESTATE:GetPlayMode() == "PlayMode_Rave",
	Texture=THEME:GetPathG("ScreenEvaluation grade frame/battle/"..battlegraphloc.."graph","frame"),
	OnCommand=function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+500)
		:sleep(2.8):decelerate(0.5)
		:y(SCREEN_CENTER_Y+54+itgstylemargin*1.8)
	end,
	OffCommand=function(self)
		self:accelerate(0.3):addy(500)
	end
}
local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()
t[#t+1] = LoadActor(THEME:GetPathG("", "_grade models/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(-100 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-252)
		if player == PLAYER_1 then self:x(-220) end
		if player == PLAYER_2 then self:x(20) end
	end,
	
}
-- Grade and Frame Info

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
local DoublesIsOn = GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides"
for player in ivalues(PlayerNumber) do
	if GAMESTATE:IsPlayerEnabled(player) then
		t[#t+1] = Def.ActorFrame{
			LoadActor( THEME:GetPathG("","ScreenEvaluation grade frame"), player )..{
				InitCommand=function(self)
					local margin = GAMESTATE:GetPlayMode() == "PlayMode_Rave" and 164 or 145
					self:xy( DoublesIsOn and SCREEN_CENTER_X or ( SCREEN_CENTER_X+((-margin+itgstylemargin*1.2)*side(player)) ),SCREEN_CENTER_Y-1690)
				end,
				OnCommand=function(self)
					self:addx( (DoublesIsOn and -SCREEN_WIDTH/1.2 or -SCREEN_WIDTH/2)*side(player) )
					:sleep(3):decelerate(0.3)
					:addx( (DoublesIsOn and SCREEN_WIDTH/1.2 or SCREEN_WIDTH/2)*side(player) )
					if player == PLAYER_1 then self:x(9999) end
					if player == PLAYER_2 then self:x(9999) end
				end,
				OffCommand=function(self)
					self:accelerate(0.3):addx( (DoublesIsOn and -SCREEN_WIDTH/1.2 or -SCREEN_WIDTH/2)*side(player) )
				end,
			}
		}

	
	end
end

-- labels: hands/ex, holds, mines, rolls
for index, label in ipairs(RadarCategories) do
	-- Replace hands with the EX score only in FA+ mode.
	-- We have a separate FA+ pane for ITG mode.
	if index == 1 and SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadFont("_eurostile normal")..{
			Text="EX",
			InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
			BeginCommand=function(self)
				if player == PLAYER_1 then self:x(0) end
				if player == PLAYER_2 then self:x(60) end
				self:y(38)
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			end
		}
	else
		local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )


		
	end
	

	
	local itgstylemargin = ThemePrefs.Get("ITG1") and -10 or 0
	local JudgmentInfo = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	Names = { "Fantastic", "Excellent", "Great", "Decent", "Way Off", "Miss" },
	RadarVal = { "Jumps", "Holds", "Mines", "Hands", "Rolls" },
};

--Fantastic etc. text
	for index, ValTC in ipairs(JudgmentInfo.Types) do
	t[#t+1] = Def.ActorFrame{
		Condition=not GAMESTATE:Env()["WorkoutMode"],
		OnCommand=function(self) self:xy(-290,95) end;
		Def.BitmapText{ Font="_eurostile normal", Text=THEME:GetString("TapNoteScore",ValTC),
		OnCommand=function(s)
			s:y(16*index):zoom(0.5):horizalign(left):shadowlength(0):maxwidth(130)
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then
				s:xy(60,-94+15.8*index)
			end
				if player == PLAYER_1 then s:x(40) end
			if player == PLAYER_2 then s:x(280) end
		end;
		};
		
	};
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


local PColor = {
	["PlayerNumber_P1"] = color("#836002"),
	["PlayerNumber_P2"] = color("#2F8425"),
};

local itgstylemargin = ThemePrefs.Get("ITG1") and -10 or 0
local battlegraphloc = ThemePrefs.Get("ITG1") and "ITG1/" or ""
t[#t+1] = Def.Sprite{
	Condition=GAMESTATE:GetPlayMode() == "PlayMode_Rave",
	Texture=THEME:GetPathG("ScreenEvaluation grade frame/battle/"..battlegraphloc.."graph","frame"),
	OnCommand=function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y+500)
		:sleep(2.8):decelerate(0.5)
		:y(SCREEN_CENTER_Y+54+itgstylemargin*1.8)
	end,
	OffCommand=function(self)
		self:accelerate(0.3):addy(500)
	end
}



-- Max Combo
local function pnum(pn)
	if pn == PLAYER_2 then return 2 end
	return 1
end
local function TrailOrSteps(pn)
	if GAMESTATE:IsCourseMode() then return GAMESTATE:GetCurrentTrail(pn) end
	return GAMESTATE:GetCurrentSteps(pn)
end
t[#t+1] = Def.ActorFrame{
	Condition=not GAMESTATE:Env()["WorkoutMode"],
	OnCommand=function(s)
		if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then
			s:xy(-71,-4)
		end
	end;
	Def.BitmapText{ Font="_eurostile normal", Text="Max Combo",
	OnCommand=function(self)
		self:xy( -120, 16*7-2+80 ):zoom(0.5):halign(0):maxwidth(150)
		if player == PLAYER_2 then self:x(120) end
	end;
	};
Def.Sprite{
			Texture=THEME:GetPathG('',ThemePrefs.Get("ITG1") and '_evaluation difficulty icons' or '_difficulty icons'),
			OnCommand=function(self)
				self:animate(0):playcommand("Update")
				if player == PLAYER_1 then self:xy(-215,-68) end
				if player == PLAYER_2 then self:xy(208,-68) end
			end,
			UpdateCommand=function(self,parent) self:setstate( SetFrameDifficulty(player,true) ) end,
			
		},
		
		Def.BitmapText{
			Font="_eurostile normal",
			OnCommand=function(self)
				self:zoom(0.5):x( -250*side(player) )
				:halign( pnum(player)-1 ):playcommand("Update")
				self:y( 18*side(player) )
				if player == PLAYER_1 then self:y(-68) end
				if player == PLAYER_2 then self:y(-68) end
			end,
			UpdateCommand=function(self)
				local steps = TrailOrSteps(player):GetDifficulty()
				if GAMESTATE:IsCourseMode() then
					self:settext( DifficultyName("Trail", player) )
				else
					self:settext( DifficultyName("Steps", player) )
				end
				self:diffuse( ThemePrefs.Get("ITG1") and Color.Black or ContrastingDifficultyColor( steps ) )
				:shadowlength( ThemePrefs.Get("ITG1") and 1 or 0 )
			end
		},
		Def.BitmapText{
			Font="Common Normal",
			OnCommand=function(self)
				self:zoom(0.5):x( -200*side(player) )
				:halign( pnum(player)-1 ):playcommand("Update")
				self:y( 18*side(player) )
				if player == PLAYER_1 then self:y(-68) end
				if player == PLAYER_2 then self:y(-68) end
			end,
			UpdateCommand=function(self)
				self:settext( TrailOrSteps(player):GetMeter() )
				self:diffuse( ThemePrefs.Get("ITG1") and Color.Black or ContrastingDifficultyColor( TrailOrSteps(player):GetDifficulty() ) )
				:shadowlength( ThemePrefs.Get("ITG1") and 1 or 0 )
			end
		},
		
	Def.BitmapText{ Font="ScreenEvaluation judge";
	OnCommand=function(self)
		self:xy( 10, 16*7-1+80 ):zoom(0.5):halign(1)
		local combo = GetPSStageStats(player):MaxCombo()
		self:settext( ("%05.0f"):format( combo ) )

		local leadingZeroAttr = { Length=5-tonumber(tostring(combo):len()); Diffuse=PColor[player] }
		self:AddAttribute(0, leadingZeroAttr )

		:diffuse( PlayerColor(player) )
		if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then
			self:x(137) end
			if player == PLAYER_2 then self:x(249) end
	
	end;
	};

		


}
--Hands etc  values
for index, RCType in ipairs(JudgmentInfo.RadarVal) do
	local performance = GetPSStageStats(player):GetRadarActual():GetValue( "RadarCategory_"..RCType )
	local possible = GetPSStageStats(player):GetRadarPossible():GetValue( "RadarCategory_"..RCType )

	t[#t+1] = Def.ActorFrame{
		Condition=not GAMESTATE:Env()["WorkoutMode"],
		OnCommand=function(self)
			self:xy(-35,111-16+itgstylemargin)
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then
				self:xy(66,32-18+itgstylemargin)
			end
		end;
	Def.BitmapText{ Font="Common Normal", Text=THEME:GetString("RadarCategory",RCType),
		OnCommand=function(self)
			self:xy( -85, 16*index -1 ):zoom(0.5):halign(0)
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then self:xy(-134,-1+15.8*index) end
		end;
		};
		Def.BitmapText{ Font="ScreenEvaluation judge",
		OnCommand=function(self)
			self:xy( -40, 16*index ):zoom(0.5):halign(1)
			self:settext(("%03.0f"):format(performance)):diffuse( PlayerColor(player) )
			local leadingZeroAttr = { Length=3-tonumber(tostring(performance):len()); Diffuse=PColor[player] }
			self:AddAttribute(0, leadingZeroAttr )
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then self:y(15.8*index) end
			if player == PLAYER_1 then self:x(6) end
			if player == PLAYER_2 then self:x(244) end
		end;
		};
		
		Def.BitmapText{ Font="ScreenEvaluation judge",
		OnCommand=function(self)
			self:y( 16*index ):zoom(0.5):halign(1)
			self:settext(("%03.0f"):format(possible)):diffuse( PlayerColor(player) )
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=PColor[player] }
			self:AddAttribute(0, leadingZeroAttr )
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then self:y(15.8*index) end
			if player == PLAYER_1 then self:x(45) end
			if player == PLAYER_2 then self:x(284) end
		end;
		};

	
		Def.BitmapText{ Font="ScreenEvaluation judge", Text="/",
		OnCommand=function(self)
			self:xy( -40, 16*index -1 ):zoom(0.5):halign(0):diffuse( PlayerColor(player) )
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then self:y(15.8*index) end
			if player == PLAYER_1 then self:x(5) end
			if player == PLAYER_2 then self:x(243) end
		end;

		};
			Def.BitmapText{
		 Font="_futurist metalic", Text=CalculatePercentage(player), OnCommand=function(self)
			self:horizalign(right):xy(5,-92+(itgstylemargin*2.7)):diffuse(PlayerColor(player))
			if player == PLAYER_2 then self:x(220) end
			
		end
	},
	};
	
	
end

--player judgment values
for index, ScWin in ipairs(JudgmentInfo.Types) do
	t[#t+1] = Def.ActorFrame{
		Condition=not GAMESTATE:Env()["WorkoutMode"],
		OnCommand=function(self) self:xy(-180,95) end;
		Def.BitmapText{ Font="ScreenEvaluation judge",
		OnCommand=function(self)
			self:y(16*index):zoom(0.5):halign(1):diffuse( PlayerColor(player) )
			local sco = GetPSStageStats(player):GetTapNoteScores("TapNoteScore_"..ScWin)
			self:settext(("%04.0f"):format( sco )):diffuse( PlayerColor(player) )
			local leadingZeroAttr = { Length=4-tonumber(tostring(sco):len()); Diffuse=PColor[player] }
			self:AddAttribute(0, leadingZeroAttr )
			if GAMESTATE:GetPlayMode() == "PlayMode_Rave" then
				self:xy(84,-70+15.8*index)
			end
			if player == PLAYER_1 then self:x(45) end
			if player == PLAYER_2 then self:x(285) end
		end;
		};
	};
	
end

end

return t

