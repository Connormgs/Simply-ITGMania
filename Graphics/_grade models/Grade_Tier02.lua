return Def.ActorFrame{
	
	LoadActor("star.txt")..{
		 OnCommand=function(self)
			self:x(-25):y(20):zoom(0.5):wag():effectmagnitude(0,4,10)
		end
	},
	
	LoadActor("star.txt")..{
		 OnCommand=function(self)
			self:x(0):y(-20):zoom(0.5):wag():effectmagnitude(0,4,10)
		end
	},
	
	LoadActor("star.txt")..{
		 OnCommand=function(self)
			self:x(25):y(20):zoom(0.5):wag():effectmagnitude(0,4,10)
		end
	},
}