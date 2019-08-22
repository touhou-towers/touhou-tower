
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_waiting.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "gmt_jeo_table" )
	ent:SetPos( SpawnPos )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:UpdateModel()
	self.Entity:SetModel(self.Model)
end

function ENT:Initialize()
	self:UpdateModel()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
	
	self:ReloadOBBBounds()
	
	//self.Own = nil
	
	self:ResetAll()
	
	self.TargetName = "trivia1"	
	
	self:SharedInit()
end


function ENT:KeyValue( key, value ) 

	/*if key == "target" then
		
		if IsValid( self.Own ) && self.Own:GetClass() == "gmt_jeo_main" then
			self.Own:RemoveChild( self )
		end
		
		self.TargetName = value
		self.Think = self.LookingThink
		
	end*/

end

function ENT:NormalThink()
end


function ENT:LookingThink()
	
	if string.len( self.TargetName ) > 0 then
	
		local LookEnts = ents.FindByName( self.TargetName )
		
		if IsValid( LookEnts[1] ) && LookEnts[1]:GetClass() == "gmt_jeo_main" then
			
			LookEnts[1]:AddTable( self )
			self.Think = self.NormalThink
			
		end
	end
	
	self:NextThink( CurTime() + 1.0 )

	return true
end
ENT.Think = ENT.LookingThink

function ENT:ResetAll()
	self.Points = 0
	//self.Answer = 0
	//self.TotalAnswerTime = 0
	self:ResetPlayer()
	
	//self:SetNWInt("p", self.Points )
	//self:SetNWFloat("t", self.TotalAnswerTime )
	//self:SetNWInt("a", self.Answer )
	
	self.Points = 0
	self.AnswerTime = 0
	self.ChosenAnswer = 0
end

function ENT:AddPoints( points )
	self.Points = self.Points + points
	//self:SetNWInt("p", self.Points )
end

function ENT:AddAnswerTime( time )
	//self.TotalAnswerTime = self.TotalAnswerTime + time
	
	//self:SetNWFloat("t", self.TotalAnswerTime )
	self.AnswerTime = self.AnswerTime + time
end

function ENT:UpdateParent( ent )

	//self:SetOwner( ent )
	//self:SetNWEntity("own", ent )
	self.BoardOwner = ent
	
end

function ENT:GetPlayer()
	return self.Ply
end

function ENT:SetPlayer( ply )
	self.Ply = ply
	//self:SetNWEntity( "ply", ply )
end

function ENT:ResetPlayer()
	self:SetPlayer( Entity(0) )
	
	if self:GetBoard() then
		self:GetBoard():PlayerUpdated()
	end
end

function ENT:ResetAnswer()
	self:SetAnswer( 0 )
end

function ENT:GetAnswer()
	return self.ChosenAnswer
end

function ENT:SetAnswer( id )
	//self:SetNWInt("a", id )
	self.ChosenAnswer = id
end

function ENT:Use( ply )
	
	if !IsValid( self:GetBoard() ) then
		return
	end

	if ( self.LastAction or 0.0 ) > CurTime()  then
		return
	end
	self.LastAction = CurTime() + 0.4
	
	if self:GetBoard():InGame() then

		if self:GetPlayer() != ply || self:GetAnswer() != 0 || !self:GetBoard():CanAnswer() then
			return		
		end
		
		local AnswerId = self:GetAimButton( self:GetPlayer() )
		
		if AnswerId != 0 then
			
			self:AddAnswerTime( CurTime() - self:GetBoard().QuestionAskTime )
			
			self:SetAnswer( AnswerId )
			
			self:GetBoard():AnswersUpdate()
		end
		
		return
	end
	
	
	if self:GetBoard():CanChangePlayers() == false then
		return
	end

	if self:GetPlayer() == ply then
		self:ResetPlayer()
		
		return
	end
	
	if self:ValidPlayer() then
		//We already have an owner
		return
	end
	
	local PlayerBoardUse =  self:GetBoard():GetPlayerEnt( ply )
	
	if PlayerBoardUse != nil then
	
		//Remove old table
		//Set thise one as new table
		PlayerBoardUse:ResetPlayer()
	end

	// clear it to make sure, somehow points were left over from the previous games
	self:ResetAll()

	self:SetPlayer( ply )
	self:GetBoard():PlayerUpdated()
	
end

function ENT:OnRemove()

end

hook.Add( "Location", "GmtJeoLocation", function( ply, loc )

	for _, v in pairs( ents.FindByClass( "gmt_jeo_table" ) ) do
		if v:GetPlayer() == ply && ( location != 7 && location != 38 ) then
			
			v:ResetAll()
			
		end
	end
	
 end )

hook.Add( "PlayerDisconnected", "GmtJeoDisconnect", function(ply)

	for _, v in pairs( ents.FindByClass( "gmt_jeo_table" ) ) do
		if v:GetPlayer() == ply then
			
			v:ResetAll()
			
		end
	end

end )