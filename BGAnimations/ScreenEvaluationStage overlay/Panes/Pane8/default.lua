-- Pane8 displays a list of High Scores obrained from GrooveStats for the stepchart that was played.

if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) then return end

local player, controller = unpack(...)

local pane = Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- -----------------------------------------------------------------------

-- 22px RowHeight by default, which works for displaying 10 machine HighScores
local args = { Player=player, RowHeight=22, HideScores=true }

args.NumHighScores = 10
pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
InitCommand=function(self) self:x( (controller == PLAYER_1 and -80) or -30,25 ):zoom(1.2) end

}
pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","GrooveStats.png"),
	Name="GrooveStats_Logo",
	InitCommand=function(self)
		self:zoom(0.3)
		self:addx(-240):addy(-40)
		if player == PLAYER_2 then self:x(90) end
	end,
}
pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base3.png"),
	Name="base",
	InitCommand=function(self)
		self:xy(-88,148):diffuse(GetCurrentColor(true)):zoom(1.25)
		if player == PLAYER_2 then self:x(9999) end
	end,
}

pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","base3.png"),
	Name="base",
	InitCommand=function(self)
		self:xy(-37,148):diffuse(GetCurrentColor(true)):zoom(1.25)
		if player == PLAYER_1 then self:x(9999) end
	end,
}
return pane
