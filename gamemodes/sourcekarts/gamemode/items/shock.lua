
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Shock"
ITEM.Model = "models/gmod_tower/sourcekarts/stomp.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/shock" )
ITEM.Entity = nil
ITEM.Distance = 400

ITEM.Battle = true
ITEM.Chance = items.RARE
ITEM.MaxPos = 1

function ITEM:Start( ply, kart )

	local pos = kart:GetPos()

	kart:EmitSound( table.Random( SOUND_EXPLOSIONS ), 400, 150 )
	kart:EmitSound( SOUND_SHOCK, 400, 150 )

	// Thumper
	for i=1, 15 do

		local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			effectdata:SetNormal( pos:GetNormal() )
			effectdata:SetMagnitude( 15 )
			effectdata:SetScale( 150 )
			effectdata:SetRadius( 50 )
		util.Effect( "ThumperDust", effectdata, true, true )

		local effectdata = EffectData()
			effectdata:SetStart( pos )
			effectdata:SetOrigin( pos )
			effectdata:SetScale( 10 )
			effectdata:SetMagnitude( 10 )
			effectdata:SetEntity( kart )
		util.Effect( "TeslaHitBoxes", effectdata, true, true )

	end

	// Find all entites around
	for _, ent in pairs( ents.FindByClass( "sk_*" ) ) do

		if ply2 == ply then continue end
		if ent == kart then continue end

		local entpos = ent:GetPos()
		if entpos:Distance( pos ) < self.Distance then

			if ent:GetClass() == "sk_kart" and !ent:IsSpinning() then

				if ent:GetIsInvincible() || ent:GetOwner():IsGhost() then
					ent:EmitSound( SOUND_REFLECT, 80 )
					return
				end

				if GAMEMODE:IsBattle() then
					ent:GetOwner():TakeBattleDamage( ply )
				end

				ent:Spin( ply )
				net.Start( "HUDMessage" )
					net.WriteString( "YOU HIT "..string.upper( ent:GetOwner():Name() ) )
				net.Send( ply )
				ply:AddAchivement( ACHIVEMENTS.SKSHOCK, 1 )
			end

			/*if ent.Base == "sk_item_base_ground" || ent.Base == "sk_item_base_homing" || ent.Base == "sk_item_base" then
				ent:Reflected()
			end*/

		end

	end

end

items.Register( ITEM )
