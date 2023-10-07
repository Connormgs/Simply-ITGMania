local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grade models/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(-100 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-44)
		if player == PLAYER_1 then self:x(-170) end
		if player == PLAYER_2 then self:x(170) end
	end,
	
}

return t