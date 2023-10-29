local style = ThemePrefs.Get("ITG1") and "ITG1/" or ""
return Def.ActorFrame{
	OnCommand=function(self)
		self:ztest(1):addx(-420):sleep(0.35):linear(0.5):addx(420)
	end;
	OffCommand=function(s) s:linear(0.5):addx(-420) end;
	CancelMessageCommand=function(s) if GAMESTATE:Env()["WorkoutMode"] then s:linear(0.5):addx(-420) end end;
	
	
	LoadActor("WheelItems/"..style.."SectionCollapsed")..{
	OnCommand=function(self)
			self:diffuse(GetCurrentColor(true))
		end
	},
	---
	Def.BitmapText{
	Font="_eurostile normal", InitCommand=function(self)
		self:zoom(0.9):x(-30):maxwidth(300)
	end;
	SetMessageCommand=function(self,params)
	self:shadowlength(1)
	local Group = params.Text;
		if Group then
			self:settext(Group):diffuse(params.Color):diffuse(GetCurrentColor(true)):diffuse(Brightness({1,1,1,1},1))
		
			for pn in ivalues(PlayerNumber) do
				if Group == PROFILEMAN:GetProfile(pn):GetDisplayName() then
					self:settext(Group.."'s Songs")
					
				end
			end
			if params.HasFocus then
				GAMESTATE:Env()["CurrentGroupSelected"] = Group
			end
		end
	end
	},
};