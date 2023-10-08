local path = "/"..THEME:GetCurrentThemeDirectory().."Graphics/_FallbackBanners/"..ThemePrefs.Get("VisualStyle")
local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

local banner = {
	directory = (FILEMAN:DoesFileExist(path) and path or THEME:GetPathG("","_FallbackBanners/Arrows")),

}

-- the Quad containing the bpm and music rate doesn't appear in Casual mode
-- so nudge the song title and banner down a bit when in Casual
local y_offset = SL.Global.GameMode=="Casual" and 50 or 46


local af = Def.ActorFrame{ InitCommand=function(self) self:xy(_screen.cx, y_offset) end }



-- quad behind the song/course title text


-- song/course title text
af[#af+1] = LoadFont("_eurostile normal")..{
	InitCommand=function(self)
		local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
		if songtitle then self:settext(songtitle):maxwidth(banner.width*banner.zoom)
		self:y(-10)
		zoom(.2)
		end
	end
}

return af