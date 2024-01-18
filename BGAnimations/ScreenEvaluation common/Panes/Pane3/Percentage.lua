local pn = ...
local player = ...
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local IsNotWide = (GetScreenAspectRatio() < 16 / 9)
local IsWide = (GetScreenAspectRatio() > 4 / 3)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")
local t = Def.ActorFrame{
	InitCommand=function(self) self:xy(50 * (player==PLAYER_2 and -1 or 1), _screen.cy-36) end
}
return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(pn),
	InitCommand=function(self)
		self:x( -115 )
		self:y( _screen.cy-40 )
		if IsNotWide and player == PLAYER_1 then self:x(-60) end
	end,



	LoadFont("Wendy/_wendy white")..{
		Text=percent,
		Name="Percent",
		InitCommand=function(self) self:horizalign(right):zoom(0.25):xy( 30, -2) 
			if player == PLAYER_1 then
			self:x(-30)
		else
			self:x(-8)
		end
		
		end
	}
}
