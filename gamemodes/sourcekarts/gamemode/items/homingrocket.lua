
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Homing Rocket"
ITEM.Model = "models/gmod_tower/sourcekarts/ballionrocket.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/homingrocket" )
ITEM.Entity = "sk_item_homingrocket"
ITEM.MaxUses = 1

ITEM.Battle = false
ITEM.Chance = items.UNCOMMON
ITEM.MaxPos = 2

ITEM.Radius = 2048

function ITEM:CanStart( ply, kart )
	return ply:CheckShootItem( kart )
end

function ITEM:Start( ply, kart )

	local target = nil

	// Get target
	if ply.ItemDir == 1 then

		// Let's just find the player ahead of this one... if possible
		local forward = ply:GetPosition() - 1
		local forwardplayer = nil

		for _, ply2 in pairs( player.GetAll() ) do
			if ply2:GetPosition() == forward then
				forwardplayer = ply2
			end
		end

		if IsValid( forwardplayer ) then
			target = forwardplayer
		end

		//MsgN( target )

		// Radius based. This is good, but not always good. Always kinda unneeded.
		/*local dist = self.Radius

		for k, ent in ipairs( ents.FindInSphere( kart:GetPos(), self.Radius ) ) do

			if ent:GetClass() != "sk_kart" then continue end
			if ent == kart then continue end
			if !util.InFront( ent:GetPos(), kart ) then continue end

			local compare = ent:GetPos():Distance( kart:GetPos() )

			if compare < dist then //&& self:Trace( target ) then
				target = ent
				dist = compare
			end

		end*/

	end

	ply:ShootItem( self.Entity, nil, target )

end

items.Register( ITEM )