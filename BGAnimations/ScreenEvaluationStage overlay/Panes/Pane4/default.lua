-- Pane4 displays a list of HighScores for the stepchart that was played.

local player, controller = unpack(...)

local pane = Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy - 62):zoom(1)
		if player == PLAYER_2 then self:x(0) end
	end
}
---------------------------------------------------------

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local NumHighScores = math.min(10, PREFSMAN:GetPreference("MaxHighScoresPerListForMachine"))

local HighScoreIndex = {
	-- Machine HighScoreIndex will always be -1 in EventMode and is effectively useless there
	Machine =  pss:GetMachineHighScoreIndex(),
	Personal = pss:GetPersonalHighScoreIndex()
}

-- -----------------------------------------------------------------------
-- custom logic to (try to) assess if a MachineHighScore was achieved when in EventMode

local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
local MachineHighScores = PROFILEMAN:GetMachineProfile():GetHighScoreList(SongOrCourse,StepsOrTrail):GetHighScores()

local EarnedMachineHighScoreInEventMode = function()
	-- if no DancePoints were earned, it's not a HighScore
	if pss:GetPercentDancePoints() <= 0.01 then return false end
	-- if DancePoints were earned, but no MachineHighScores exist at this point, it's a fail which was not considered a HighScore
	if #MachineHighScores < 1 then return false end
	-- otherwise, check if this score is better than the worst current HighScore retrieved from MachineProfile
	return pss:GetHighScore():GetPercentDP() >= MachineHighScores[math.min(NumHighScores, #MachineHighScores)]:GetPercentDP()
end

-- -----------------------------------------------------------------------

local EarnedMachineRecord = GAMESTATE:IsEventMode() and EarnedMachineHighScoreInEventMode() or HighScoreIndex.Machine  >= 0
local EarnedTop2Personal  = (HighScoreIndex.Personal >= 0 and HighScoreIndex.Personal < 2)

-- -----------------------------------------------------------------------

-- Novice players frequently improve their own score while struggling to
-- break into an overall leaderboard.  The lack of *visible* leaderboard
-- progress can be frustrating/demoralizing, so let's do what we can to
-- alleviate that.
--
-- If this score is not high enough to be a machine record, but it *is*
-- good enough to be a top-2 personal record, show two HighScore lists:
-- 1-8 machine HighScores, then 1-2 personal HighScores
--
-- If the player isn't using a profile (local or USB), there won't be any
-- personal HighScores to compare against.
--
-- Also, this 8+2 shouldn't show up on privately owned machines where only
-- one person plays, which is a common scenario in 2020.
--
-- This idea of showing both machine and personal HighScores to help new players
-- track progress is based on my experiences maintaining a heavily-used
-- public SM5 machine for several years while away at school.


-- 22px RowHeight by default, which works for displaying 10 machine HighScores
local args = { Player=player, RoundsAgo=1, RowHeight=22}

if (not EarnedMachineRecord and EarnedTop2Personal) then

	-- less line spacing between HighScore rows to fit the horizontal line
	args.RowHeight = 20.25

	-- top 8 machine HighScores
	args.NumHighScores = 8
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
	InitCommand=function(self) self:xy(0, -15)
	 self:x( (controller == PLAYER_1 and -89) or -36 ):zoom(0.85)

	end
	
	}

	-- horizontal line visually separating machine HighScores from player HighScores
	pane[#pane+1] = Def.Quad{ InitCommand=function(self) self:zoomto(100, 1):y(args.RowHeight*9):diffuse(1,1,1,0.33) end }

	-- top 2 player HighScores
	args.NumHighScores = 2
	args.Profile = PROFILEMAN:GetProfile(player)
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
		InitCommand=function(self) self:y(args.RowHeight*9) 
		 self:x( (controller == PLAYER_1 and -999) or 999 ):zoom(0.85)
		 
end,
		OnCommand=function(self) self:xy( (controller == PLAYER_1 and -90) or -40,140 ) end
	}

-- the player did not meet the conditions to show the 8+2 HighScores
-- Just show top 10 machine HighScores
-- We can also hijack the 10 rows of high scores to display those ones fetched from GrooveStats.
else
	-- top 10 machine HighScores
	args.NumHighScores = 10
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
	OnCommand=function(self) self:xy(-85, -18):zoom(0.85) end
	}
end
	pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base3.png"),
	
	InitCommand=function(self)
		self:xy(-70,118):diffuse(GetCurrentColor(true))
		if player == PLAYER_2 then self:x(9999) end
	end,
}

	pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base3.png"),
	
	InitCommand=function(self)
		self:xy(-30,118):diffuse(GetCurrentColor(true))
		if player == PLAYER_1 then self:x(9999) end
	end,
}
return pane


