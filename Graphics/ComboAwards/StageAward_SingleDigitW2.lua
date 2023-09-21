local t = Def.ActorFrame{}

t[#t+1] = Def.Model{
    Meshes="_award models/plaque meshes.txt",
    Materials="_award models/plaque materials silver.txt",
    Bones="_award models/bones.txt",
    OnCommand=function(self)
    	self:zoom(0.6):wag():effectmagnitude(0,15,0):effectperiod(8):x(110):y(-25):zoom(1/1.8)
    end;
};

t[#t+1] = Def.BitmapText{
    Text=THEME:GetString("PerDifficultyAward","SingleDigitW2"),
    File="_eurostile normal";
    OnCommand=function(self)
    	self:horizalign(right):zoom(0.5):y(12):x(135):shadowlength(2)
    end;
};

return t;