
local ENCHANT = {}
local DEBUG = false
local TotalTime = 7.5

function ENCHANT:Init( um )
	if SERVER then
		self:Timeout( TotalTime )
		self:StayAlive( self.Player )
	else
	
		self.ClonePlayer = um:ReadEntity()
		self:AddHook("Think", self.Think )
		
		if DEBUG then
			print("Recieve Sending: ", self.ClonePlayer )
		end
	end
	
	
	
	self.Player:Freeze( true )
	self.Player:EmitSound("GModTower/misc/smith_clone_begin.mp3", 50, math.random( 75, 125 ) )
	
	if DEBUG then
		print("Clone init: ", self.Player )
	end
end

function ENCHANT:SetClone( ply )
	self.ClonePlayer = ply
	
	self:StayAlive( self.ClonePlayer )
	
	ply:Freeze( true )
	//ply:EmitSound("vo/npc/Barney/ba_pain08.wav", 120)
	
	if DEBUG then
		print("Clone set clone: ", ply )
	end
end

function ENCHANT:Think()
	
	if IsValid( self.ClonePlayer ) then
		local Color = 255 - self:TimeLeft() / TotalTime * 255
	
		self.ClonePlayer:SetColor( Color, Color, Color, 255 )
	end
	
end

function ENCHANT:OnRemove()
	
	if IsValid( self.ClonePlayer ) then
		
		//self.ClonePlayer:EmitSound("vo/npc/Barney/ba_laugh02.wav", 120)
		
		if IsValid( self.Player ) && self.ClonePlayer:Alive() && self.Player:Alive() then
			self.ClonePlayer:SetModel( self.Player:GetModel() )
			self.ClonePlayer:SetSkin( self.Player:GetSkin() )
			if SERVER then
				self.ClonePlayer:StripWeapons()
			end
		end
		
		self.ClonePlayer:SetColor( 255, 255, 255, 255 )
		self.ClonePlayer:Freeze(false)
		
	end
	
	if IsValid( self.Player ) then
		self.Player:Freeze(false)
		self.Player:EmitSound("ambient/energy/whiteflash.wav", 50, math.random( 75, 125 ) )
	end
	
	if DEBUG then
		print("Clone remove: ", self.ClonePlayer, self.Player )
	end

end

if SERVER then
	
	function ENCHANT:ExtraInfo()
		umsg.Entity( self.ClonePlayer or NULL )	
		
		if DEBUG then
			print("Clone Sending: ", self.ClonePlayer )
		end
	end
	
end

enchant.Register("cloneplayer", ENCHANT )