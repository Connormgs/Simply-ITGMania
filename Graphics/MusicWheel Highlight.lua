local style = ThemePrefs.Get("ITG1") and "ITG1/" or ""
local IsNotWide = (GetScreenAspectRatio() < 16 / 9)
return Def.ActorFrame{
	InitCommand=function(self)
		self:fov(58):ztest(1):addx(-500):sleep(0.4):linear(0.45):addx(500)
	end;
	CancelMessageCommand=function(s) if GAMESTATE:Env()["WorkoutMode"] then s:linear(0.5):addx(-500) end end;
	
	LoadActor("WheelItems/"..style.."Wheel highlight")..{
		 OnCommand=function(self)
			self:x(-110):zoomx(1.16):zoomy(1.4):y(-6):diffuseshift():effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.3):effectperiod(1.0):effectoffset(0.2):effectclock("beat"):ztest(1)
			if IsNotWide then self:zoomx(1.28) end
		end
	},
}