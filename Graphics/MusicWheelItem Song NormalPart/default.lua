-- the MusicWheelItem for CourseMode contains the basic colored Quads
-- use that as a common base, and add in a Sprite for "Has Edit"
local af = LoadActor("../MusicWheelItem Course NormalPart.lua")

local stepstype = GAMESTATE:GetCurrentStyle():GetStepsType()

local IsNotWide = (GetScreenAspectRatio() < 16/9)
local style = ThemePrefs.Get("ITG1") and "ITG1/" or ""
-- using a png in a Sprite ties the visual to a specific rasterized font (currently Miso),
-- but Sprites are cheaper than BitmapTexts, so we should use them where dynamic text is not needed


for player in ivalues(PlayerNumber) do
	

	-- Add ITL EX scores to the song wheel as well.
	-- It will be centered to the item if only one player is enabled, and stacked otherwise.
	af[#af+1] = Def.BitmapText{
		Font=ThemePrefs.Get("ThemeFont") == "Common" and "Wendy/_wendy small" or "Mega/_mega font",
		Text="",
		InitCommand=function(self)
			self:visible(false)
			self:zoom(0.2)
			self:x(800)
			self:diffuse(SL.JudgmentColors["FA+"][player == "PlayerNumber_P1" and 1 or 2])
		end,
		-- Both players actors are always visible now
		-- PlayerJoinedMessageCommand=function(self)
		-- 	--self:visible(GAMESTATE:IsPlayerEnabled(player))
		-- end,
		-- PlayerUnjoinedMessageCommand=function(self)
		-- 	--self:visible(GAMESTATE:IsPlayerEnabled(player))
		-- end,
		SetCommand=function(self, params)
			-- Only display EX score if a profile is found for an enabled player.
			-- in 1 player mode, it will show the details for the opposite player
			local otherplayer = player == PLAYER_1 and PLAYER_2 or PLAYER_1
			local pn = ToEnumShortString(player)

			if GAMESTATE:GetNumSidesJoined() == 1 then
				if PROFILEMAN:IsPersistentProfile(player) or PROFILEMAN:IsPersistentProfile(otherplayer) then
					self:visible(true)
					if PROFILEMAN:IsPersistentProfile(otherplayer) then 
						pn = pn == "P1" and "P2" or "P1"
					end
				end
			else
				self:visible(PROFILEMAN:IsPersistentProfile(player))
			end

			if player == PLAYER_1 then
				self:y(-7)
			else
				self:y(7)
			end
			
			if params.Song ~= nil then
				local song = params.Song
				local song_dir = song:GetSongDir()
				if song_dir ~= nil and #song_dir ~= 0 then
					if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
						local hash = SL[pn].ITLData["pathMap"][song_dir]
						if SL[pn].ITLData["hashMap"][hash] ~= nil then
							self:settext(tostring(("%.2f"):format(SL[pn].ITLData["hashMap"][hash]["ex"] / 100)))
							 if (GAMESTATE:GetNumSidesJoined() == 1 and PROFILEMAN:IsPersistentProfile(player)) then 
							 	self:settext(SL[pn].ITLData["hashMap"][hash]["points"])
							 end
							self:visible(true)
							return
						end
					end
				end
			end
			self:visible(false)
		end,
	}
	af[#af+1] = Def.ActorFrame{
		Name="SongContents",
		SetMessageCommand=function(self,params)
			self:shadowlength(1)
			local song = params.Song;
			if song then
				self:GetChild("Title"):diffuse(Color.White )
				:settext(song:GetDisplayMainTitle())
				self:GetChild("SubTitle"):diffuse( params.Color )
				:settext(song:GetDisplaySubTitle()):zoom(0)
				if string.len( song:GetDisplaySubTitle() ) > 2 then
					self:GetChild("SubTitle"):zoom(0.6)
					self:GetChild("Title"):zoom(0.8):y(-7)
				else
					self:GetChild("Title"):zoom(0.85):y(0)
				end
			end
		end,

LoadActor("../WheelItems/"..style.."WheelSong NormalPart")..{
		 OnCommand=function(self)
			self:diffuse(GetCurrentColor(true))
		end
	},

			Def.BitmapText{
			Font="_eurostile normal",
			Name="Title",
			InitCommand=function(self)
				self:x(95):maxwidth(320):halign(1):shadowlength(1)
			end
		},

	

		Def.BitmapText{
			Font="_eurostile normal",
			Name="SubTitle",
			InitCommand=function(self)
				self:xy(95,8):maxwidth(460):halign(1):shadowlength(1)
			end
		}

		}

af[#af+1] = LoadActor("GetLamp.lua", player)
	af[#af+1] = LoadActor("Favorites.lua", player)
	
	-- Song Rank
	af[#af+1] = Def.BitmapText{
		Font=ThemePrefs.Get("ThemeFont") == "Common" and "Wendy/_wendy small" or "Mega/_mega font",
		Text="",
		InitCommand=function(self)
			self:visible(false)			
			if IsNotWide then 
				self:zoom(0.2)
			else
				self:zoom(0.3)
			end
			
		end,
		PlayerJoinedMessageCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(player))
		end,
		PlayerUnjoinedMessageCommand=function(self)
			self:visible(GAMESTATE:IsPlayerEnabled(player))
		end,
		SetCommand=function(self, params)
			-- Only display EX score if a profile is found for an enabled player.
			if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
				self:visible(false)
				return
			end

			local pn = ToEnumShortString(player)
		
			self:x(THEME:GetMetric("MusicWheelItem", "GradeP"..(pn == "P1" and 2 or 1).."X")-WideScale(28,33))

			if params.Song ~= nil and GAMESTATE:GetNumSidesJoined() == 1 then
				local song = params.Song
				local song_dir = song:GetSongDir()
				if song_dir ~= nil and #song_dir ~= 0 then
					if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
						local hash = SL[pn].ITLData["pathMap"][song_dir]
						if SL[pn].ITLData["hashMap"][hash] ~= nil then
							if SL[pn].ITLData["hashMap"][hash]["rank"] ~= nil then 
								if SL[pn].ITLData["hashMap"][hash]["rank"] ~= nil then
									local rank = SL[pn].ITLData["hashMap"][hash]["rank"]
									
									self:settext(tostring(rank))
									local style = GAMESTATE:GetCurrentStyle():GetName()
									if 		rank <=	(style == "single" and 10 or 5) 	then self:diffuse(SL.JudgmentColors["FA+"][1])
									elseif	rank <= (style == "single" and 25 or 20)	then self:diffuse(SL.JudgmentColors["FA+"][2])
									elseif	rank <= (style == "single" and 50 or 40) 	then self:diffuse(SL.JudgmentColors["FA+"][3])
									elseif	rank <= (style == "single" and 75 or 50) 	then self:diffuse(SL.JudgmentColors["FA+"][4])
									elseif	rank <= (style == "single" and 85 or 55)	then self:diffuse(SL.JudgmentColors["FA+"][5])
									else self:diffuse(Color.Red)
									end
								end
							end
							self:visible(true)
							return
						end
					end
				end
			end
			self:visible(false)
		end,
	}
		
end

return af