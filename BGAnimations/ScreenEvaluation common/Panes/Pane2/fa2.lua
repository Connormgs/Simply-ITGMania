local player, controller = unpack(...)
local IsNotWide = (GetScreenAspectRatio() < 16 / 9)
local IsWide = (GetScreenAspectRatio() > 4 / 3)
local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W0', 'W1' },
	Colors = {
		SL.JudgmentColors["FA+"][1],
		SL.JudgmentColors["FA+"][2],
		SL.JudgmentColors["FA+"][3],
		SL.JudgmentColors["FA+"][4],
		SL.JudgmentColors["FA+"][5],
		SL.JudgmentColors["ITG"][5], -- FA+ mode doesn't have a Way Off window. Extract color from the ITG mode.
		SL.JudgmentColors["FA+"][6],
	},
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}


-- TODO(Zankoku) - EX judgments are in storage now, so we shouldn't have to calculate this all over again
local counts = GetExJudgmentCounts(player)

local t = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(90,_screen.cy-24) end,
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if controller == PLAYER_2 then
			self:x( self:GetX() * -1 )
			
		end
		if IsNotWide and player == PLAYER_1 then self:x(121) end
	end
}

-- The FA+ window shares the status as the FA window.
-- If the FA window is disabled, then we consider the FA+ window disabled as well.
local windows = {SL[pn].ActiveModifiers.TimingWindows[1]}
for v in ivalues( SL[pn].ActiveModifiers.TimingWindows) do
	windows[#windows + 1] = v
end



-- then handle hands/ex, holds, mines, rolls
local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}
for index, RCType in ipairs(RadarCategories.Types) do
-- Swap to displaying ITG score if we're showing EX score in gameplay.
	local percent = nil
	if SL[pn].ActiveModifiers.ShowEXScore then
		local PercentDP = pss:GetPercentDancePoints()
		percent = FormatPercentScore(PercentDP):gsub("%%", "")
		-- Format the Percentage string, removing the % symbol
		percent = tonumber(percent)
	else
		percent = CalculateExScore(player)
	end

	if index == 1 then
		t[#t+1] = LoadFont("ScreenEvaluation judge")..{
			Name="Percent",
			Text=("%.2f"):format(percent),
			InitCommand=function(self)
				self:horizalign(right):zoom(0.63)
				self:x( (controller == PLAYER_1 and -10) or 236 )
				self:y(118)
				if SL[pn].ActiveModifiers.ShowEXScore then
					self:diffuse(GetCurrentColor(True))
				else
					self:diffuse(GetCurrentColor(True))
				end
			end
		}
	end



end
		

return t
