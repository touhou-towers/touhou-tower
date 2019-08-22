include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self:SetNotSolid( true )
	self:SetParent( self:GetOwner() )
	self:SetPos( self:GetOwner():GetPos() )

	self:DrawShadow( false )

end

function ENT:SendModel( mdl )
	
	if mdl == nil then

		umsg.Start( "SetItem" )
			umsg.Entity( self )
			umsg.String( "" )
		umsg.End()
		
		return
		
	end

	umsg.Start( "SetItem" )
		umsg.Entity( self )
		umsg.String( mdl )
	umsg.End()

	self:SetModel( mdl )
	
end

/*function ENT:Strip()

	if !IsValid( self:GetOwner() ) then return end

	local ent = ents.Create( "item_zm_event" )
		ent:SetPos( self:GetOwner():GetPos() )
		ent.Model = self:GetModel()
	ent:Spawn()

	self:Remove()

end*/