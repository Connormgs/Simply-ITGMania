local MusicWheel, SelectedType
local group_durations = LoadActor("./GroupDurations.lua")

-- width of background quad
local _w = IsUsingWideScreen() and 320 or 310

local af = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(_screen.cx - (IsUsingWideScreen() and 170 or 165), _screen.cy - 55)
	end,

	CurrentSongChangedMessageCommand=function(self)    self:playcommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self)  self:playcommand("Set") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,
}


-- ActorFrame for Artist, BPM, and Song length
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(-110,-6) end,


	-- ----------------------------------------



	-- ----------------------------------------


	-- Song Duration Value
	LoadFont("_eurostile normal")..{
		InitCommand=function(self) self:align(0,0):xy(430,20) end,
		OnCommand=function(s) s:shadowlength(2):zoom(0.6):diffusealpha(0.5) end,
		SetCommand=function(self)
			if MusicWheel == nil then MusicWheel = SCREENMAN:GetTopScreen():GetMusicWheel() end

			SelectedType = MusicWheel:GetSelectedType()
			local seconds

			if SelectedType == "WheelItemDataType_Song" then
				-- GAMESTATE:GetCurrentSong() can return nil here if we're in pay mode on round 2 (or later)
				-- and we're returning to SSM to find that the song we'd just played is no longer available
				-- because it exceeds the 2-round or 3-round time limit cutoff.
				local song = GAMESTATE:GetCurrentSong()
				if song then
					seconds = song:MusicLengthSeconds()
				end

			elseif SelectedType == "WheelItemDataType_Section" then
				-- MusicWheel:GetSelectedSection() will return a string for the text of the currently active WheelItem
				-- use it here to look up the overall duration of this group from our precalculated table of group durations
				seconds = group_durations[MusicWheel:GetSelectedSection()]

			elseif SelectedType == "WheelItemDataType_Course" then
				-- is it possible for 2 Trails within the same Course to have differing durations?
				-- I can't think of a scenario where that would happen, but hey, this is StepMania.
				-- In any case, I'm opting to display the duration of the MPN's current trail.
				local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
				if trail then
					seconds = TrailUtil.GetTotalSeconds(trail)
				end
			end

			-- r21 lol
			if seconds == 105.0 then self:settext(THEME:GetString("SongDescription", "r21")); return end

			if seconds then
				seconds = seconds / SL.Global.ActiveModifiers.MusicRate

				-- longer than 1 hour in length
				if seconds > 3600 then
					-- format to display as H:MM:SS
					self:settext(math.floor(seconds/3600) .. ":" .. SecondsToMMSS(seconds%3600))
				else
					-- format to display as M:SS
					self:settext(SecondsToMSS(seconds))
				end
			else
				self:settext("")
			end
		end
	}
}

if not GAMESTATE:IsEventMode() then

	-- long/marathon version bubble graphic and text
	af[#af+1] = Def.ActorFrame{
		InitCommand=function(self)
			self:x( IsUsingWideScreen() and 98 or 92 )
			self:y(-12)
		end,
		SetCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			self:visible( song and (song:IsLong() or song:IsMarathon()) or false )
		end,


		Def.ActorMultiVertex{
			InitCommand=function(self)
				-- these coordinates aren't neat and tidy, but they do create three triangles
				-- that fit together to approximate hurtpiggypig's original png asset
				local verts = {
					--   x   y  z    r,g,b,a
					{{-113, -15, 0}, {1,1,1,1}},
					{{ 113, -15, 0}, {1,1,1,1}},
					{{ 113, 16, 0}, {1,1,1,1}},

					{{ 113, 16, 0}, {1,1,1,1}},
					{{-113, 16, 0}, {1,1,1,1}},
					{{-113, -15, 0}, {1,1,1,1}},

					{{ -98, 16, 0}, {1,1,1,1}},
					{{ -78, 16, 0}, {1,1,1,1}},
					{{ -88, 29, 0}, {1,1,1,1}},
				}
				self:SetDrawState({Mode="DrawMode_Triangles"}):SetVertices(verts)
				self:diffuse(GetCurrentColor())
				self:xy(0,0):zoom(0.5)
			end
		},

		LoadFont("Common Normal")..{
			InitCommand=function(self) self:diffuse(Color.Black):zoom(0.8) end,
			SetCommand=function(self)
				local song = GAMESTATE:GetCurrentSong()
				if not song then self:settext(""); return end

				if song:IsMarathon() then
					self:settext(THEME:GetString("SongDescription", "IsMarathon"))
				elseif song:IsLong() then
					self:settext(THEME:GetString("SongDescription", "IsLong"))
				else
					self:settext("")
				end
			end
		}
	}
end

return af
