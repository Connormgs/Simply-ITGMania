local bmt_actor
local ses_actor

-- -----------------------------------------------------------------------

local hours, mins, secs
local hmmss = "%d:%02d:%02d"

-- prefer the engine's SecondsToHMMSS()
-- but define it ourselves if it isn't provided by this version of SM5
local SecondsToHMMSS = SecondsToHMMSS or function(s)
	-- native floor division sounds nice but isn't available in Lua 5.1
	hours = math.floor(s/3600)
	mins  = math.floor((s % 3600) / 60)
	secs  = s - (hours * 3600) - (mins * 60)
	return hmmss:format(hours, mins, secs)
end

local UpdateTimer = function(af, dt)
	local seconds = GetTimeSinceStart() - SL.Global.TimeAtSessionStart
	local totalTime = 0
	local anyPlayer = "P1"
	if #SL["P1"].Stages.Stats == 0 then anyPlayer = "P2" end
	for i,stats in pairs( SL[anyPlayer].Stages.Stats ) do
		totalTime = totalTime + (stats and stats.duration or 0)
	end

	-- if this game session is less than 1 hour in duration so far
	if seconds < 3600 then
		bmt_actor:settext( SecondsToMMSS(seconds) )

	-- somewhere between 1 and 10 hours
	elseif seconds >= 3600 and seconds < 36000 then
		bmt_actor:settext( SecondsToHMMSS(seconds) )

	-- in it for the long haul
	else
		bmt_actor:settext( SecondsToHHMMSS(seconds) )
	end
	
	if totalTime ~= nil then
		-- if this game session is less than 1 hour in duration so far
		if totalTime < 3600 then
			ses_actor:settext( SecondsToMMSS(totalTime) )

		-- somewhere between 1 and 10 hours
		elseif totalTime >= 3600 and totalTime < 36000 then
			ses_actor:settext( SecondsToHMMSS(totalTime) )

		-- in it for the long haul
		else
			ses_actor:settext( SecondsToHHMMSS(totalTime) )
		end
	end
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{ OffCommand=function(self) self:linear(0.1):diffusealpha(0) end }

-- only add this InitCommand to the main ActorFrame in EventMode
if PREFSMAN:GetPreference("EventMode") then
	af.InitCommand=function(self)
		-- TimeAtSessionStart will be reset to nil between game sessions
		-- thus, if it's currently nil, we're loading ScreenSelectMusic
		-- for the first time this particular game session
		if SL.Global.TimeAtSessionStart == nil then
			SL.Global.TimeAtSessionStart = GetTimeSinceStart()
		end

		self:SetUpdateFunction( UpdateTimer )
	end
end


-- generic header elements (background Def.Quad, left-aligned screen name)


-- centered text
-- session timer in EventMode
if PREFSMAN:GetPreference("EventMode") then

	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
		Name="Session Timer",
		InitCommand=function(self)
			bmt_actor = self
			self:zoom(.6) 
			self:y(10) 
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}
	
	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
		Name="Play Timer",
		InitCommand=function(self)
			ses_actor = self
			self:zoom( SL_WideScale(0.3, 0.36) )
			self:y( SL_WideScale(3.15, 3.5) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx + 200)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

-- stage number when not EventMode
else

	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Header")..{
		Name="Stage Number",
		Text=SSM_Header_StageText(),
		InitCommand=function(self)
			self:zoom( SL_WideScale(0.5, 0.6) )
			self:y( SL_WideScale(7.5, 9) / self:GetZoom() )
			self:diffusealpha(0):x(_screen.cx)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	}

end




return af