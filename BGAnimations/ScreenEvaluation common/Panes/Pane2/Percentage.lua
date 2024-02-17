local player, controller = unpack(...)

local percent = nil
local diffuse = nil

if SL[ToEnumShortString(player)].ActiveModifiers.ShowEXScore then
	percent = CalculateExScore(player)
	diffuse = SL.JudgmentColors[SL.Global.GameMode][1]
else
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local PercentDP = stats:GetPercentDancePoints()
	percent = FormatPercentScore(PercentDP):gsub("%%", "")
	-- Format the Percentage string, removing the % symbol
	percent = tonumber(percent)
	diffuse = Color.White
end
local itgstylemargin = ThemePrefs.Get("ITG1") and -10 or 0
local SameW0Weight = (ThemePrefs.Get("EnableTournamentMode") and
						ThemePrefs.Get("ScoringSystem") == "EX" and
						ThemePrefs.Get("FantasticPlusWindowWeight") == "Same")


return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	

	-- NOTE(teejusb): If SameW0Weight is set, then that means EX score is also set so it's always the
	-- "primary" displayed score.
	LoadFont("_futurist metalic")..{
		Name="Percent",
		Text=("%.2f"):format(percent)..(SameW0Weight and "'" or ""),
		InitCommand=function(self)
			self:horizalign(right):xy(55,5):diffuse(GetCurrentColor(true))
			if player == PLAYER_2 then self:x(240):diffuse(GetCurrentColor(true)) end
			
		end
	}
	
}
