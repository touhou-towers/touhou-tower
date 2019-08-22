
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.RadioPriority = 2

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	local Owner = self:GetOwner()

	if IsValid( Owner ) && Owner:IsPlayer() && Owner:Alive() then 
		self:EmitNotes()
	end

end

function ENT:EmitNotes()
	local edata = EffectData()
	edata:SetOrigin( self:GetPos() )
	edata:SetEntity( self )

	util.Effect("musicnotes", edata, true, true)
end

function ENT:_SetSong( str )
	if IsValid( self ) then
		self:SetNWString( "CurChan", str )
	end
end

function ENT:LoadSong( str )
	
	timer.Simple( 0.1, self._SetSong, self, str )
	
	return true
end


function ENT:Use( ply )

	if ply:IsPlayer() then
		
		umsg.Start("emitselect", ply )
			umsg.Long( self:EntIndex() )
		umsg.End()
		
	end

end

local function Allow( ply, Ent )
	
	if ( ply:GetSetting( "GTAllowEmitStream" ) ) then
		return true
	end
	
	return ply:HasControl( Ent )
	
end

concommand.Add("gmt_emitset", function( ply, cmd, args )
	
	local EntId = tonumber( args[1] )
	
	if !EntId then
		return
	end
	
	local Ent = ents.GetByIndex( EntId )
	
	
	print("Emit: ", ply, Ent, args[2] )
	
	if IsValid( Ent ) && type( Ent.LoadSong ) == "function" then
	
		if !Allow( ply, Ent ) then 
			return 
		end
		
		if hook.Call("PlayStream", GAMEMODE, ply, args[2], Ent ) != false then
			Ent:LoadSong( args[2] )
		end
		
	end

end )