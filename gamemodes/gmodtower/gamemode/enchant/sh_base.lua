
module("enchantbase", package.seeall )

__index = getfenv()
_Type = ""

function _New( self, ply, shared )
	
	self._Hooks = {}
	self._IsValid = true
	self.Player = ply
	self._Id = -1
	
	if !ply._Enchantments then
		ply._Enchantments = { self }
	else
		table.insert( ply._Enchantments, self )
	end	
	
end

function Init( self, um )

end

function OnRemove( self, um )
	
end


function IsShared( self )
	return self._Id != -1
end

function IsValid( self )
	return self._IsValid && self.Player:IsValid()
end

function AddHook( self, Name, func )

	if !self._Hooks[ Name ] then
		self._Hooks[ Name ] = {}
	end
	
	self._Hooks[ Name ] = func
	
	//Make sure the  hook is there
	enchant._NewHook( Name, self )

end

function RemoveHook( self, Name )
	
	self._Hooks[ Name ] = nil
	
	enchant._RemoveHook( Name, self )
	
end

function GetPlayer( self )
	return self._Player
end

function Timeout( self, time )
	local DieTime = CurTime() + time

	if self:IsShared() then
		if SERVER then
			umsg.Start("enchant", self:GetRP() ) 
			umsg.Char( 3 )
			umsg.Short( self._Id )
			umsg.Float( DieTime )
			umsg.End()
		else
			Error("Can not create timeout on shared enchantment '".. self._Type .."'")
		end
	end

	self._DieTime = DieTime
	enchant._AddDieTimer( self )
	
end

function TimeLeft( self )
	return self._DieTime - CurTime()
end

function DestroyTimeout( self )
	self._DieTime = nil
	enchant._RemoveDieTimer( self )
end

function Destroy( self )

	if !self:IsValid() then
		ErrorNoHalt("Attetion! Attempting to destroy ,already destroyed, ".. self._Type )
		return
	end

	if self:IsShared() && CLIENT then
		Error("Can not remove client enchantment(".. self._Type ..")")
	end
	
	_Destroy( self )
	
end

function _Destroy( self )
	
	self._IsValid = false
	
	for k in pairs( self._Hooks ) do
		enchant._RemoveHook( k, self )
	end
	
	if SERVER && self.Player._EnchantmentList then
		self:_DestroyFromTables()
	end
	
	for k, v in pairs( self.Player._Enchantments ) do
		if v == self then
			self.Player._Enchantments[ k ] = nil
		end
	end
	
	self:DestroyTimeout()
	
	self._Hooks = nil
	
	enchant._Removed( self )
	
end

if CLIENT then

	function RecieveUmsg( self, um )
		
	end

end