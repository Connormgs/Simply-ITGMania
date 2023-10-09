-- tables of rgba values
local dark  = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.ActorFrame{
	Name="Header",

	
	LoadFont("_eurostile red glow")..{
		Name="HeaderText",
		Text=ScreenString("HeaderText"),
		InitCommand=function(self) self:diffusealpha(0):horizalign(left):xy(10, 15):zoom( SL_WideScale(0.5,0.6) ) end,
		OnCommand=function(self) self:sleep(0.1):decelerate(0.33):diffusealpha(1) end,
		OffCommand=function(self) self:accelerate(0.33):diffusealpha(0) end,
		SetHeaderTextMessageCommand=function(self, params)
			self:settext(params.Text)
		end,
		ResetHeaderTextMessageCommand=function(self)
			self:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), "HeaderText"))
		end
	}
}
