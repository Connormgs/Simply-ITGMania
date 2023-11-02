-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.
local height = 64
local width = IsUsingWideScreen() and 286 or 276

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:xy(_screen.cx-182, _screen.cy+18)

		if player == PLAYER_2 then
			self:addy(height+110)
			self:addx(430)
		end

		if IsUsingWideScreen() then
			self:addx(-5)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,
	PlayerProfileSetMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Redraw")
		end
	end,
	CodeMessageCommand=function(self, params)
		-- Toggle between the density graph and the pattern info
		if params.Name == "TogglePatternInfo" and params.PlayerNumber == player then
			-- Only need to toggle in versus since in single player modes, both
			-- panes are already displayed.
			if GAMESTATE:GetNumSidesJoined() == 2 then
				self:queuecommand("TogglePatternInfo")
			end
		end
	end,
}

-- Background quad for the density graph
af[#af+1] = Def.Quad{
	InitCommand=function(self)
	self:x(99999)
		self:diffuse(color("#1e282f")):zoomto(width, height)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
			
		end
	end
}

af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	-- Hide when scrolling through the wheel. This also handles the case of
	-- going from song -> folder. It will get unhidden after a chart is parsed
	-- below.
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Hide")
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		self:queuecommand("Hide")
		self:stoptweening()
		self:sleep(0.4)
		self:queuecommand("ParseChart")
	end,
	ParseChartCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			MESSAGEMAN:Broadcast(pn.."ChartParsing")
			ParseChartInfo(steps, pn)
			self:queuecommand("Show")
		end
	end,
	OffCommand=function(self) self:linear(0.3):zoomx(0) end,
	ShowCommand=function(self)
		if GAMESTATE:GetCurrentSong() and
				GAMESTATE:GetCurrentSteps(player) then
			MESSAGEMAN:Broadcast(pn.."ChartParsed")
			self:queuecommand("Redraw")
		else
			self:queuecommand("Hide")
		end
	end
}

local af2 = af[#af]

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(9999):addy(135)
		self:rotationz(-5)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

-- The Peak NPS text
af2[#af2+1] = LoadFont("_eurostile normal")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
	local styletype = GAMESTATE:GetCurrentStyle():GetStyleType()
		self:horizalign(left):zoom(0.40)
		if player == PLAYER_1 then
			self:xy(60,157)
		else
			self:addx(44):addy(-17)
		end
		if styletype == "StyleType_OnePlayerTwoSides" then
			self:x(250)
			end
		-- We want black text in Rainbow mode except during HolidayCheer(), white otherwise.
		self:diffuse((ThemePrefs.Get("RainbowMode") and not HolidayCheer()) and {0, 0, 0, 1} or {1, 1, 1, 1})
	end,
	HideCommand=function(self)
		self:settext("Peak NPS:")
		self:visible(false)
	end,
	OffCommand=function(self) self:linear(0.3):zoomy(0) end,
	RedrawCommand=function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS * SL.Global.ActiveModifiers.MusicRate))
			self:visible(true)
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end
}

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)

	end,
	
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end,
	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#00762F")):zoomto(width, bgHeight):diffusealpha(0.5)
			self:x(99999)
		end
	},

	LoadFont("_eurostile normal")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
		local styletype = GAMESTATE:GetCurrentStyle():GetStyleType()
			local textZoom = 0.5
			self:maxwidth(200):zoom(textZoom)
			self:xy(10,132)
			if player == PLAYER_2 then self:xy(-5,-40) end
			if styletype == "StyleType_OnePlayerTwoSides" then
			self:x(200)
			end
		end,

		HideCommand=function(self)
			self:settext("")
		end,
		RedrawCommand=function(self)
			local textZoom = 0.8
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

af2[#af2+1] = Def.ActorFrame{
	Name="PatternInfo",
	InitCommand=function(self)
	local styletype = GAMESTATE:GetCurrentStyle():GetStyleType()
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		else

			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
			if styletype == "StyleType_OnePlayerTwoSides" then
			self:y(88 * (player == PLAYER_1 and 1 or -1))
			self:x(190)
			end
		self:visible(GAMESTATE:GetNumSidesJoined() == 1 or 2)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(0)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		self:visible(GAMESTATE:GetNumSidesJoined() == 1)
		if GAMESTATE:GetNumSidesJoined() == 2 then
			self:y(0)
		else
			self:y(88 * (player == PLAYER_1 and 1 or -1))
		end
	end,
	TogglePatternInfoCommand=function(self)
		self:visible(not self:GetVisible())
	end,
	
	-- Background for the additional chart info.
	-- Only shown in 1 Player mode
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#00762F")):zoomto(width, height)
			self:x(999999)
		end,
	}
}

local af3 = af2[#af2]

local layout = {
	{"Crossovers", "Footswitches"},
	{"Sideswitches", "Jacks"},
	{"Brackets", "Total Stream"},
}

local colSpacing = 75
local rowSpacing = 20

for i, row in ipairs(layout) do
	for j, col in pairs(row) do
		af3[#af3+1] = LoadFont("_eurostile normal")..{
			Text=col ~= "Total Stream" and "0" or "None (0.0%)",
			Name=col .. "Value",
			InitCommand=function(self)
				local textHeight = 9
				local textZoom = 0.3
				self:zoom(textZoom):horizalign(left)
				if col == "Total Stream" then
					self:maxwidth(120)
					
				end
				self:xy(-10,15)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
				self:zoom(0.5)
			end,
			OffCommand=function(self) self:linear(0.3):zoomy(0) end,
			HideCommand=function(self)
				if col ~= "Total Stream" then
					self:settext("0")
				else
					self:settext("None (0.0%)")
				end
				
			end,
			RedrawCommand=function(self)
				if col ~= "Total Stream" then
					self:settext(SL[pn].Streams[col])

				else
					local streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(pn)
					local totalMeasures = streamMeasures + breakMeasures
					if streamMeasures == 0 then
						self:settext("None (0.0%)")
					else
						self:settext(string.format("%d/%d (%0.1f%%)", streamMeasures, totalMeasures, streamMeasures/totalMeasures*100))
					end
				end
			end
		}

		af3[#af3+1] = LoadFont("_eurostile normal")..{
			Text=col,
			Name=col,
			InitCommand=function(self)
				local textHeight = 17
				local textZoom = 0.44
				self:maxwidth(width/textZoom):zoom(textZoom):horizalign(left)
				self:xy(-20,5)
				self:addx((j-1)*colSpacing)
				self:addy((i-1)*rowSpacing)
				
			end,
			OffCommand=function(self) self:linear(0.3):zoomy(0) end,
		}

	end
end

return af
