return Def.ActorFrame{
	OnCommand=function(self)
		self:xy(35,38)
	end,

LoadFont("_eurostile white glow")..{
		Text="OPTIONS MENU",
		InitCommand=function(self) self:x(self:GetWidth()/2) end,
		OnCommand=function(self)
			self:diffuse(GetCurrentColor(true)):zoomx(0):zoomy(6):sleep(0.3):bounceend(.3):zoom(1)
			MESSAGEMAN:Broadcast("UpdateColoring")
		end,
		OffCommand=function(self)
			self:accelerate(.2):zoomx(2):zoomy(0):diffusealpha(0)
			
		end,
		CancelMessageCommand=function(self)
			self:accelerate(.2):zoomx(2):zoomy(0):diffusealpha(0)
		end
	},
	LoadFont("_eurostile normal")..{
		Text="OPTIONS MENU",
		InitCommand=function(self) self:x(self:GetWidth()/2) end,
		OnCommand=function(self)
			self:zoomx(0):zoomy(6):sleep(0.3):bounceend(.3):zoom(1)
			MESSAGEMAN:Broadcast("UpdateColoring")
		end,
		OffCommand=function(self)
			self:accelerate(.2):zoomx(2):zoomy(0):diffusealpha(0)
			
		end,
		CancelMessageCommand=function(self)
			self:accelerate(.2):zoomx(2):zoomy(0):diffusealpha(0)
		end
	}
}