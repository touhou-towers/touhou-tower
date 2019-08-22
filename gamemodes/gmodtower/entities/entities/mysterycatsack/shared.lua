AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Mystery Cat Sack"
ENT.LoadRoom	= true

ENT.Model		= Model( "models/gmod_tower/catbag.mdl")

ENT.Nyan 		= {
	Sound( "GModTower/lobby/catsack/nyan1.wav" ),
	Sound( "GModTower/lobby/catsack/nyan2.wav" ),
	Sound( "GModTower/lobby/catsack/nyan3.wav" )
}
ENT.Phrases = {
	"How mysterious~",
	"What an interesting conundrum!",
	"Hmm... wonder why?",
	"...Again?",
	"Time to use it!",
	"Science!",
	"It's an astronomical coincidence!",
	"How lame.",
	"This is amazing!",
}

function ENT:Initialize()

	if CLIENT then return end

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.Opened = false

end

function ENT:Use( ply )

	if CLIENT || self.Opened then return end

	--if not ply:IsRoomOwner( self ) then return end

	local Room = GtowerRooms.PositionInRoom( self:GetPos() )

	if Room then
		room = GtowerRooms.Get( Room )
		if room then
			if room.Owner != ply then return end
		end
	end

	local ItemID = GTowerItems.CreateMysteryItem(ply)
	local Item = GTowerItems:CreateById( ItemID )

	if !GTowerItems:NewItemSlot( ply ):Allow( Item, true ) || !Item then
		ply:MsgT( "RandomInvGiveFail" )
		return
	end

	ply:InvGiveItem( ItemID )

	local name = Item.Name
	local phrase = self.Phrases[math.random( 0, #self.Phrases )]

	if ( name && phrase ) then
		ply:MsgT( "RandomInvGive", name, phrase )
	end

	self.Opened = true

	self:EmitSoundInLocation( self.Nyan[math.random(1, #self.Nyan)] )
	ply:AddAchivement( ACHIVEMENTS.CURIOUSCAT, 1 )

	self:Remove()

end
