
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


local StoreTableName = "RoomTicTable"

function ENT:UpdateModel()
	self.Entity:SetModel( self.Model )
end

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	
	self.Use = EmptyFunction
end

function ENT:Think()
	/*
	self.RoomId = GtowerRooms.ClosestRoom( self:GetPos() )
	
	if self.RoomId then
		local Owner = GtowerRooms:RoomOwner( room )
		
		if IsValid( Owner ) then
			self:CheckLevel( Owner )
		end	
	end
	*/
end

function ENT:CheckLevel( ply )

	local StoreTableId = self:GetStoreId()

	if !StoreTableId then
		return
	end

	self.Level = ply:GetLevel( StoreTableId ) 
	self:SetLevel( self.Level )

end

function ENT:SetLevel( lv )

	if lv == 2 then
		self.Use = self.BaseClass.Use
		
	else //If all fails, default it 
		self.Use = EmptyFunction
		
	end
	
end