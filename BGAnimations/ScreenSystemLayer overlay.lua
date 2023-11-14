local function CreditsText( pn )
	local text = LoadFont(Var "LoadingScreen","credits") .. {
		InitCommand=function(self)
			self:name("Credits" .. PlayerNumberToString(pn))
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen")
		end,
		UpdateTextCommand=function(self)
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn)
			MESSAGEMAN:Broadcast("SYSTEMUpdateText")
			self:settext(str)
		end,
		UpdateVisibleCommand=function(self)
			local screen = SCREENMAN:GetTopScreen()
			local bShow = true
			if screen then
				local sClass = screen:GetName()
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" )
			end
			self:visible( bShow )
		end
	}
	return text
end

local t = Def.ActorFrame {}
	-- Aux
t[#t+1] = LoadActor(THEME:GetPathB("ScreenSystemLayer","aux"))
	-- Credits
t[#t+1] = Def.ActorFrame {
 	CreditsText( PLAYER_1 ),
	CreditsText( PLAYER_2 )
}

-- MemoryCard management
local cardpos = {
	["PlayerNumber_P1"] = {WideScale(18,18),SCREEN_BOTTOM-14},
	["PlayerNumber_P2"] = {SCREEN_RIGHT-WideScale(18,18),SCREEN_BOTTOM-14},
}
for player in ivalues(PlayerNumber) do
	local shortplr = ToEnumShortString(player)
	t[#t+1] = Def.Sprite{
		Texture=THEME:GetPathG("MemoryCardDisplay ready", shortplr ),
		InitCommand=function(s) s:xy( cardpos[player][1] ,cardpos[player][2]-2 ):visible(true) end,
		SYSTEMUpdateTextMessageCommand=function(self)
			self:visible(false)
			-- Based on what the player contains, update the sprite accordingly.
			local status = {
				["ready"] = THEME:GetPathG("MemoryCardDisplay ready", shortplr ),
				["checking"] = THEME:GetPathG("MemoryCardDisplay checking", shortplr ),
				["late"] = THEME:GetPathG("MemoryCardDisplay late", shortplr ),
				["error"] = THEME:GetPathG("MemoryCardDisplay error", shortplr ),
				["removed"] = THEME:GetPathG("MemoryCardDisplay removed", shortplr ),
			}
			local CardStatus = ToEnumShortString(MEMCARDMAN:GetCardState(player))
			if CardStatus ~= "none" then
				self:visible(true):Load( status[ CardStatus ] )
			end
		end
	}
end

	-- Text
t[#t+1] = Def.ActorFrame {
	Def.Quad {
		InitCommand=function(self)
			self:zoomtowidth(SCREEN_WIDTH):zoomtoheight(30):align(0,0):diffuse(color("0,0,0,0"))
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(0.85)
		end,
		OffCommand=function(self)
			self:sleep(3):linear(0.5):diffusealpha(0)
		end
	},
	Def.BitmapText{
		Font="Common Normal",
		Name="Text",
		InitCommand=function(self)
			self:maxwidth(750):align(0,0):xy(10,10):shadowlength(1):diffusealpha(0)
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(1):zoom(0.5)
		end,
		OffCommand=function(self)
			self:sleep(3):linear(0.5):diffusealpha(0)
		end
	},
	SystemMessageMessageCommand = function(self, params)
		self:GetChild("Text"):settext( params.Message )
		self:playcommand( "On" )
		if params.NoAnimate then
			self:finishtweening()
		end
		self:playcommand( "Off" )
	end,
	HideSystemMessageMessageCommand = function(self) self:finishtweening() end
}
local function LoadModules()
	-- A table that contains a [ScreenName] -> Table of Actors mapping.
	-- Each entry will then be converted to an ActorFrame with the actors as children.
	local modules = {}
	local files = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."Modules/")
	for file in ivalues(files) do
		-- Get the file extension (everything past the last period).
		local filetype = file:match("[^.]+$"):lower()
		if filetype == "lua" then
			local full_path = THEME:GetCurrentThemeDirectory().."Modules/"..file
			Trace("Loading module: "..full_path)

			-- Load the Lua file as proper lua.
			local loaded_module, error = loadfile(full_path)
			if loaded_module then
				local status, ret = pcall(loaded_module)
				if status then
					if ret ~= nil then
						for screenName, actor in pairs(ret) do
							if modules[screenName] == nil then
								modules[screenName] = {}
							end
							modules[screenName][#modules[screenName]+1] = actor
						end
					end
				else
					lua.ReportScriptError("Error executing module: "..full_path.." with error:\n    "..ret)
				end
			else
				lua.ReportScriptError("Error loading module: "..full_path.." with error:\n    "..error)
			end
		end
	end

	for screenName, table_of_actors in pairs(modules) do
		local module_af = Def.ActorFrame {
			ScreenChangedMessageCommand=function(self)
				local screen = SCREENMAN:GetTopScreen()
				if screen then
					local name = screen:GetName()
					if name == screenName then
						self:visible(true)
						self:queuecommand("Module")
					else
						self:visible(false)
					end
				else
					self:visible(false)
				end
			end,
		}
		for actor in ivalues(table_of_actors) do
			module_af[#module_af+1] = actor
		end
		t[#t+1] = module_af
	end
end

LoadModules()
-- -----------------------------------------------------------------------
-- The GrooveStats service info pane.
-- We put this in ScreenSystemLayer because if people move through the menus too fast,
-- it's possible that the available services won't be updated before one starts the set.
-- This allows us to set available services "in the background" as we're moving
-- through the menus.

local NewSessionRequestProcessor = function(res, gsInfo)
	if gsInfo == nil then return end
	
	local groovestats = gsInfo:GetChild("GrooveStats")
	local service1 = gsInfo:GetChild("Service1")
	local service2 = gsInfo:GetChild("Service2")
	local service3 = gsInfo:GetChild("Service3")

	service1:visible(false)
	service2:visible(false)
	service3:visible(false)

	SL.GrooveStats.IsConnected = false
	if res.error or res.statusCode ~= 200 then
		local error = res.error and ToEnumShortString(res.error) or nil
		if error == "Timeout" then
			groovestats:settext("Timed Out")
		elseif error or (res.statusCode ~= nil and res.statusCode ~= 200) then
			local text = ""
			if error == "Blocked" then
				text = "Access to GrooveStats Host Blocked"
			elseif error == "CannotConnect" then
				text = "Machine Offline"
			elseif error == "Timeout" then
				text = "Request Timed Out"
			else
				text = "Failed to Load 😞"
			end
			service1:settext(text):visible(true)


			-- These default to false, but may have changed throughout the game's lifetime.
			-- It doesn't hurt to explicitly set them to false.
			SL.GrooveStats.GetScores = false
			SL.GrooveStats.Leaderboard = false
			SL.GrooveStats.AutoSubmit = false
			groovestats:settext("❌ GrooveStats")

			DiffuseEmojis(service1:ClearAttributes())
		end
		DiffuseEmojis(groovestats:ClearAttributes())
		return
	end

	local data = JsonDecode(res.body)
	if data == nil then return end

	local services = data["servicesAllowed"]
	if services ~= nil then
		local serviceCount = 1

		if services["playerScores"] ~= nil then
			if services["playerScores"] then
				SL.GrooveStats.GetScores = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Get Scores"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.GetScores = false
			end
		end

		if services["playerLeaderboards"] ~= nil then
			if services["playerLeaderboards"] then
				SL.GrooveStats.Leaderboard = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Leaderboard"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.Leaderboard = false
			end
		end

		if services["scoreSubmit"] ~= nil then
			if services["scoreSubmit"] then
				SL.GrooveStats.AutoSubmit = true
			else
				local curServiceText = gsInfo:GetChild("Service"..serviceCount)
				curServiceText:settext("❌ Auto-Submit"):visible(true)
				serviceCount = serviceCount + 1
				SL.GrooveStats.AutoSubmit = false
			end
		end
	end

	local events = data["activeEvents"]
	local easter_eggs = PREFSMAN:GetPreference("EasterEggs")
	local game = GAMESTATE:GetCurrentGame():GetName()
	local style = ThemePrefs.Get("VisualStyle")
	if events ~= nil and easter_eggs and game == "dance" then
		local last_active_event = ThemePrefs.Get("LastActiveEvent")

		for event in ivalues(events) do
			if event["shortName"] == "SRPG7" then
				-- If we're already on the SRPG7 theme, then set the last_active_event
				-- if it's not already set to SRPG so that we don't bring up the prompt.
				if last_active_event ~= "SRPG7" and style == "SRPG7" then
					ThemePrefs.Set("LastActiveEvent", "SRPG7")
					last_active_event = "SRPG7"
				end
			
				if last_active_event ~= "SRPG7" then
					local top_screen = SCREENMAN:GetTopScreen()
					top_screen:SetNextScreenName("ScreenPromptToSetSrpgVisualStyle"):StartTransitioningScreen("SM_GoToNextScreen")
					break
				end
			end
		end
	end

-- All services are enabled, display a green check.
	if SL.GrooveStats.GetScores and SL.GrooveStats.Leaderboard and SL.GrooveStats.AutoSubmit then
		if ThemePrefs.Get("EnableBoogieStats") then
			if string.find(PREFSMAN:GetPreference("HttpAllowHosts"), "boogiestats.andr.host") then
				groovestats:settext("✔ BoogieStats")
			else
				groovestats:settext("✔ GrooveStats (BoogieStats host not in allow list)")
			end
		else
			groovestats:settext("✔ GrooveStats")
		end
		SL.GrooveStats.IsConnected = true
	-- All services are disabled, display a red X.
	elseif not SL.GrooveStats.GetScores and not SL.GrooveStats.Leaderboard and not SL.GrooveStats.AutoSubmit then
		groovestats:settext("❌ GrooveStats")
		-- We would've displayed the individual failed services, but if they're all down then hide the group.
		service1:visible(false)
		service2:visible(false)
		service3:visible(false)
	-- Some combination of the two, we display a caution symbol.
	else
		groovestats:settext("⚠ GrooveStats")
		SL.GrooveStats.IsConnected = true
	end

	DiffuseEmojis(groovestats:ClearAttributes())
	DiffuseEmojis(service1:ClearAttributes())
	DiffuseEmojis(service2:ClearAttributes())
	DiffuseEmojis(service3:ClearAttributes())
end

local function DiffuseText(bmt)
	local textColor = Color.White
	local shadowLength = 0
	if ThemePrefs.Get("RainbowMode") and not HolidayCheer() then
		textColor = Color.Black
	end
	if ThemePrefs.Get("VisualStyle") == "SRPG7" then
		textColor = color(SL.SRPG7.TextColor)
		shadowLength = 0.4
	end

	bmt:diffuse(textColor):shadowlength(shadowLength)
end

t[#t+1] = Def.ActorFrame{
	Name="GrooveStatsInfo",
	InitCommand=function(self)
		-- Put the info in the top right corner.
		self:zoom(0.8):x(10):y(15)
	end,
	ScreenChangedMessageCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen:GetName() == "ScreenTitleMenu" or screen:GetName() == "ScreenTitleJoin" then
			self:queuecommand("Reset")
			self:diffusealpha(0):sleep(0.2):linear(0.4):diffusealpha(1):visible(true)
			self:queuecommand("SendRequest")
		else
			self:visible(false)
		end
	end,

	LoadFont("Common Normal")..{
		Name="GrooveStats",
		Text="     GrooveStats",
		InitCommand=function(self)
			self:visible(ThemePrefs.Get("EnableGrooveStats"))
			self:horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self)
			self:visible(ThemePrefs.Get("EnableGrooveStats"))
			self:settext("     GrooveStats")
		end
	},

	LoadFont("Common Normal")..{
		Name="Service1",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(18):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	LoadFont("Common Normal")..{
		Name="Service2",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(36):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	LoadFont("Common Normal")..{
		Name="Service3",
		Text="",
		InitCommand=function(self)
			self:visible(true):addy(54):horizalign(left)
			DiffuseText(self)
		end,
		VisualStyleSelectedMessageCommand=function(self) DiffuseText(self) end,
		ResetCommand=function(self) self:settext("") end
	},

	RequestResponseActor(5, 0)..{
		SendRequestCommand=function(self)
			if ThemePrefs.Get("EnableGrooveStats") then
				-- These default to false, but may have changed throughout the game's lifetime.
				-- Reset these variable before making a request.
				SL.GrooveStats.GetScores = false
				SL.GrooveStats.Leaderboard = false
				SL.GrooveStats.AutoSubmit = false
				self:playcommand("MakeGrooveStatsRequest", {
					endpoint="new-session.php?chartHashVersion="..SL.GrooveStats.ChartHashVersion,
					method="GET",
					timeout=10,
					callback=NewSessionRequestProcessor,
					args=self:GetParent()
				})
			end
		end
	}
}
-- -----------------------------------------------------------------------
-- Loads the UnlocksCache from disk for SRPG unlocks.
LoadUnlocksCache()

-- -----------------------------------------------------------------------
-- SystemMessage stuff.
-- Put it on top of everything
-- this is what appears when someone uses SCREENMAN:SystemMessage(text)
-- or MESSAGEMAN:Broadcast("SystemMessage", {text})
-- or SM(text)

local bmt = nil

-- SystemMessage ActorFrame
t[#t+1] = Def.ActorFrame {
	SystemMessageMessageCommand=function(self, params)
		bmt:settext( params.Message )

		self:playcommand( "On" )
		if params.NoAnimate then
			self:finishtweening()
		end
		self:playcommand( "Off", params )
	end,
	HideSystemMessageMessageCommand=function(self) self:finishtweening() end,

	-- background quad behind the SystemMessage
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(_screen.w, 30)
			self:horizalign(left):vertalign(top)
			self:diffuse(0,0,0,0)
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(0.85)
			self:zoomto(_screen.w, (bmt:GetHeight() + 16) * SL_WideScale(0.8, 1) )
		end,
		OffCommand=function(self, params)
			-- use 3.33 seconds as a default duration if none was provided as the second arg in SM()
			self:sleep(type(params.Duration)=="number" and params.Duration or 3.33):linear(0.25):diffusealpha(0)
		end,
	},

	-- BitmapText for the SystemMessage
	LoadFont("Common Normal")..{
		Name="Text",
		InitCommand=function(self)
			bmt = self

			self:maxwidth(_screen.w-20)
			self:horizalign(left):vertalign(top):xy(10, 10)
			self:diffusealpha(0):zoom(SL_WideScale(0.8, 1))
		end,
		OnCommand=function(self)
			self:finishtweening():diffusealpha(1)
		end,
		OffCommand=function(self, params)
			-- use 3 seconds as a default duration if none was provided as the second arg in SM()
			self:sleep(type(params.Duration)=="number" and params.Duration or 3):linear(0.5):diffusealpha(0)
		end,
	}
}
-- -----------------------------------------------------------------------
return t
