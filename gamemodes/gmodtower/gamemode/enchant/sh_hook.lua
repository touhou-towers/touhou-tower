
module("enchant", package.seeall )

_ItemHookList = {}
_ItemTimers = {}

local function RemoveHook( Name, id )
	
	_ItemHookList[ Name ][ id ] = nil

	if table.Count( _ItemHookList[ Name ] ) == 0 then
		_ItemHookList[ Name ] = nil
		hook.Remove( Name, "_enchanthook" .. Name )
	end
	
end	

local function CreateHook( Name )
	
	hook.Add( Name, "_enchanthook" .. Name, function( ... )
		
		for k, v in pairs( _ItemHookList[ Name ] ) do
			
			if v._IsValid then
				
				if v._Hooks[ Name ] then
					SafeCall( v._Hooks[ Name ], v, ... )
				end
				
			else
			
				RemoveHook( Name, k )
				
			end
		
		end
		
	end )

end

function _NewHook( Name, item )

	if !_ItemHookList[ Name ] then
		_ItemHookList[ Name ] = {}
	end
	
	if !table.HasValue(_ItemHookList[ Name ], item ) then
		table.insert( _ItemHookList[ Name ], item )
	end
	
	CreateHook( Name )

end

function _RemoveHook( Name, item )

	if !_ItemHookList[ Name ] then
		return
	end
	
	for k, v in pairs( _ItemHookList[ Name ] ) do
	
		if v == item then
			RemoveHook( Name, k )
			return
		end
		
	end	
	
end

hook.Add("Think", "CheckEnchantmentsDie", function()
	local Time = CurTime()
	
	for k, v in pairs( _ItemTimers ) do
		
		if Time > v._DieTime then
			v:Destroy()
		end
		
	end
	
end )

function _AddDieTimer( item )
	
	if !table.HasValue( _ItemTimers, item ) then
		table.insert( _ItemTimers, item )
	end	
	
end

function _RemoveDieTimer( item )
	
	table.RemoveValue( _ItemTimers, item )
	
end
