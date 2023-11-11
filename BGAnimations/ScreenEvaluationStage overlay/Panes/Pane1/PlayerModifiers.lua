if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)

-- grab the song options from this PlayerState
local PlayerOptions = GAMESTATE:GetPlayerState(player):GetPlayerOptionsArray("ModsLevel_Preferred")
-- start with an empty string...
local optionslist = ""

-- if the player used an XMod of 1x, it won't be in PlayerOptions list
-- so check here, and add it in manually if necessary
if SL[pn].ActiveModifiers.SpeedModType == "X" and SL[pn].ActiveModifiers.SpeedMod == 1 then
	optionslist = "1x, "
end

--  ...and append options to that string as needed
for i,option in ipairs(PlayerOptions) do

	-- these don't need to show up in the mods list
	if option ~= "FailAtEnd" and option ~= "FailImmediateContinue" and option ~= "FailImmediate" and not option:match("No (W[1-5]/?)") then
		-- 100% Mini will be in the PlayerOptions as just "Mini" so use the value from the SL table instead
		if option:match("Mini") then
			option = SL[pn].ActiveModifiers.Mini .. " Mini"
		end

		if option:match("Cover") then
			option = THEME:GetString("OptionNames", "Cover")
		end

		if #optionslist > 0 then
			optionslist = optionslist..", "
		end
		optionslist = optionslist..option
	end
end

-- Display TimingWindowScale as a modifier if it's set to anything other than 1
local TimingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
if TimingWindowScale ~= 1 then
	optionslist = optionslist .. ", " .. (ScreenString("TimingWindowScale")):format(TimingWindowScale*100)
end

local font_zoom = 0.7
local width = THEME:GetMetric("GraphDisplay", "BodyWidth")

return Def.ActorFrame{
	OnCommand=function(self) self:y(_screen.cy+200.5) end,



	LoadFont("_eurostile normal")..{
		Text=optionslist,
		InitCommand=function(self) self:xy(-230,-260):zoom(0.5):wrapwidthpixels(400) 
		if player == PLAYER_1 then
			self:x(-30)
		else
			self:x(-10)
		end
		end
	}
}