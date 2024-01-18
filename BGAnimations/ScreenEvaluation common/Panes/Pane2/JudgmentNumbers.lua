local player, controller = unpack(...)
local IsNotWide = (GetScreenAspectRatio() < 16 / 9)
local IsWide = (GetScreenAspectRatio() > 4 / 3)
local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W0', 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
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

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Rolls',   },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}

-- TODO(Zankoku) - EX judgments are in storage now, so we shouldn't have to calculate this all over again
local counts = GetExJudgmentCounts(player)

local t = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(90,_screen.cy-24) end,
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if controller == PLAYER_2 then
			self:x( self:GetX() + 40 )
			
		end
		if IsNotWide and player == PLAYER_1 then self:x(150) end
	end
}

-- The FA+ window shares the status as the FA window.
-- If the FA window is disabled, then we consider the FA+ window disabled as well.
local windows = {SL[pn].ActiveModifiers.TimingWindows[1]}
for v in ivalues( SL[pn].ActiveModifiers.TimingWindows) do
	windows[#windows + 1] = v
end

local PColor = {
	["PlayerNumber_P1"] = color("#836002"),
	["PlayerNumber_P2"] = color("#2F8425"),
};
-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = counts[window] or 0
	local number15 = number
	local display15 = false
	
	if i == 1 then
		number15 = counts["W015"]
	elseif i == 2 then
		number15 = counts["W115"]
	end


	-- actual numbers
	t[#t+1] = Def.BitmapText{
		Font="ScreenEvaluation judge",
		InitCommand=function(self)
			self:zoom(0.63):horizalign(right):diffuse(GetCurrentColor(true))

			

			

			-- if some TimingWindows were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			if windows[i]==false and i ~= #TapNoteScores.Types then
				self:Load("RollingNumbersEvaluationNoDecentsWayOffs")
				

	
			end
		end,
		BeginCommand=function(self)
			self:x( TapNoteScores.x[ToEnumShortString(controller)] ):diffuse(GetCurrentColor(true))
		
			self:settext(("%04.0f"):format( number ))
			local leadingZeroAttr = { Length=4-tonumber(tostring(number):len()); Diffuse=PColor[player] }
			self:AddAttribute(0, leadingZeroAttr)
				self:x(-218)
			self:y((i-1)*20 -20)
			self:addy(140)
			
			
		end
	}

end
-- then handle hands/ex, holds, mines, rolls


return t
