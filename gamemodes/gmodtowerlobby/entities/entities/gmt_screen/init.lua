util.AddNetworkString("LockPanel")
util.AddNetworkString("NextPage")
util.AddNetworkString("PrevPage")
util.AddNetworkString("OpenPage")
util.AddNetworkString("SetColor")
util.AddNetworkString("SetTextUpper")
util.AddNetworkString("SetTextCenter")
util.AddNetworkString("SetTextUnder")
util.AddNetworkString("SetFontCenter")
util.AddNetworkString("SetFontUpper")
util.AddNetworkString("StartCountdown")
util.AddNetworkString("SetCurUser")


AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("tdui.lua")

include("shared.lua")

function ENT:Initialize()

	self:SetNWInt("CurPage",1)
	self:SetNWString("BGColor","Black")
	self:SetNWString("CenterColor","White")
	self:SetNWString("UpperColor","White")
	self:SetNWString("UpperText","GMTC Screen")
	self:SetNWString("CenterText","Configure me!")
	self:SetNWString("UnderText","© Bumpy Screens")
	self:SetNWString("UpperFont","OswaldSmall")
	self:SetNWString("CenterFont","ArialNormal")
	self:SetNWString("CurUser","LOADING...")

	self:SetModel("models/hunter/plates/plate2x3.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	constraint.Keepupright( self, phys:GetAngles(), 0, 999999 )

	self:SetTrigger(true)

	self:SetAngles(self:GetAngles() + Angle(0,0,90))
	self:SetPos(self:GetPos() + Vector(0,0,50))

	self:DrawShadow(false)

	self:SetMaterial("phoenix_storms/fender_white")

	net.Receive("LockPanel",function()
		if net.ReadEntity() != self then return end
		if net.ReadBool() then
		self:SetNWBool("Unlocked",false)
		else
		self:SetNWBool("Unlocked",true)
		end
	end)
	net.Receive("NextPage",function()
		if net.ReadEntity() != self then return end
		self:SetNWInt("CurPage",self:GetNWInt("CurPage")+1)
	end)
	net.Receive("PrevPage",function()
		if net.ReadEntity() != self then return end
		self:SetNWInt("CurPage",self:GetNWInt("CurPage")-1)
	end)
	net.Receive("OpenPage",function()
		if net.ReadEntity() != self then return end
		self:SetNWInt("CurPage",net:ReadFloat())
	end)
	net.Receive("SetColor",function()
		if net.ReadEntity() != self then return end
		local NextColor = net.ReadString()
		local Object = net.ReadFloat()
		if Object == 1 then
			self:SetNWString("BGColor",NextColor)
		elseif Object == 2 then
			self:SetNWString("CenterColor",NextColor)
		elseif Object == 3 then
			self:SetNWString("UpperColor",NextColor)
		end
		self:SetNWInt("CurPage",2)
	end)

	net.Receive("SetTextUpper",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("UpperText",net:ReadString())
		self:SetNWInt("CurPage",1)
	end)
	net.Receive("SetTextCenter",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("CenterText",net:ReadString())
		self:SetNWInt("CurPage",1)
	end)
	net.Receive("SetTextUnder",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("UnderText",net:ReadString())
		self:SetNWInt("CurPage",1)
	end)
	net.Receive("SetFontUpper",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("UpperFont",net:ReadString())
		self:SetNWInt("CurPage",3)
	end)
	net.Receive("SetFontCenter",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("CenterFont",net:ReadString())
		self:SetNWInt("CurPage",3)
	end)
	net.Receive("SetFontUpper",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("UpperFont",net:ReadString())
		self:SetNWInt("CurPage",3)
	end)
	net.Receive("SetCurUser",function()
		if net.ReadEntity() != self then return end
		self:SetNWString("CurUser",net:ReadString())
	end)
	net.Receive("StartCountdown",function()
		if net.ReadEntity() != self then return end
		local SecondsLeft = net.ReadFloat() * 60
		local EndText = net.ReadString()
		timer.Create("Counter",1,SecondsLeft,function()
			self:SetNWString("CenterText",string.NiceTime(SecondsLeft).." left...")
			SecondsLeft = SecondsLeft - 1
		end)
		timer.Simple(SecondsLeft+1,function()
			self:SetNWString("CenterText",EndText)
		end)
	end)

end

function ENT:Think()

end
