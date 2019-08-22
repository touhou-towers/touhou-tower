
local IsValidEntity = IsValid // fix for isvalid calls

module("inventory.baseitem", package.seeall )

//MetaTable = {
//	__index = getfenv()
//}

Name = "Unknown"
Description = "Nothing"
MysqlId = -1
ValidItem = true //Do not change - Set to false when the entity is removed from inventory
Model = nil
Tradable = true	//Can the player trade it with another players
AllowEntBackup = true //Allow the id to saved on the entity table so it does not have be looked at many times
AllowEntBreak = false //Allow the ent to break with bullets or when someone walks over it, like empty bottle
CanEntCreate = true //Allows the entity to the spawned in the real world
WeaponSafe = false //Allow the player to equip the weapon at any time?
NoBank = false //Hide item from admin bank?
BankAdminOnly = false //Only admins can create this from the bank
EnablePhyiscs = false //Should the physics be enabled when the ent is created?

/*====*/
ModelItem = false //Is the inventory item allows the player to be a player model? - YOU PROBALLY SHOULD HAVE CanEntCreate SET TO FALSE IF THIS IS TRUE
ModelName = "" //The Name of the model on the modelist
ModelSkinId = nil //The skin id of the model


/*====*/
Equippable = false //Can equip at the weapon slots?
//If the item can only equip once in the weapon slots, and a unique indifier
UniqueEquippable = false
EquipType = "none"

EquippableEntity = false //Should an entity be created from CreateEquipEntity ?
RemoveOnDeath = false //Should the item not exist on death?
RemoveOnTheater = false //Item should not exist in the theater
RemoveOnNarnia = false //Item should not exist in Narnia

//WARNING! -
//When this is set to true, and the player equips it, all other equippable entities will be removed, and only this one will be allowed to exist
//A.K.A. Ballrace ball
OnlyEquippable = false

//Long live the paradoxes,
//Override the OnlyEquippable, if the item should be equppied anyway
OverrideOnlyEquippable = false

// This lets you always drop an inventory item, for things like fireworks!
AllowAnywhereDrop = false



CanRemove = true //If it the ent can be removed trough inventory,  on the sub menu
CanUse = false //If it usable and can call :OnUse()

function OnCreate( self, info ) end //This will be called everytime this object is loaded or grabed
function GetDescription( self ) return self.Description end
function IsWeapon( self ) return false end
function OnRemove( self ) end
function IsValid( self ) return true end

function IsMyEnt( self, ent )
	if !self.ClassName then
		return string.lower( ent:GetModel() or "" ) == self.ComparableModel
	end

	return ent:GetClass() == self.ClassName
end

function IsMyItem( self, Item )
	return Item.MysqlId == self.MysqlId
end

function SellPrice( self )
	if self.BuyPrice then
		return self.BuyPrice
	end

	if self.StorePrice then
		return math.floor( self.StorePrice / 2 )
	end

	return 0
end

function PlayMoveSound( self )

	if ( !self.Ply || self.Ply == "room" )  then return end

	if !self.MoveSound then
		self.Ply:EmitSound(GTowerItems.Sounds.Move[ "default" ], 50, math.random( 90, 110 ) )
		return
	end

	local snd = GTowerItems.Sounds.Move[ self.MoveSound ]

	// Maybe it's just a direct path?
	if !snd then
		snd = self.MoveSound
	end

	if snd then
		self.Ply:EmitSound( snd, 50, math.random( 90, 110 ) )
	end

end

if SERVER then
	function GetSaveData( self ) return "" end //Return some info you might want to save on the database with it...
	function OnUse( self ) return true end
	function OnDrop( self ) //Called when items is dropped by player

		local Ent

		if !self.ClassName then
			Ent = ents.Create("prop_physics_multiplayer")
			Ent:SetModel(self.Model)

			if self.ModelSkinId then
				Ent:SetSkin( self.ModelSkinId )
			end

			if self.ModelColor then
				Ent:SetColor( self.ModelColor )
			end
		else
			Ent = ents.Create( self.ClassName )
		end

		Ent:DrawShadow( false )
		Ent._GTInvSQLId = self.MysqlId

		return Ent
	end
	function OnMove( self, Slot )
	end
	function GetSlot( self )
		return GTowerItems:NewItemSlot( self.Ply, self.Slot )
	end
	function ItemChanged( self )
		local Slot = self:GetSlot()
		Slot:ItemChanged()
	end

	//Called when an equipable entity should be created
	//Should return the entity created
	function CreateEquipEntity( self )
		print("PETPET2")
	end

	function IsEquiped( self )
		return self:GetSlot():IsEquipSlot()
	end

	function AllowEquipEntity( self )

		if !string.StartWith( game.GetMap(), "gmt_build" ) then
			return false
		end

		if self.RemoveOnDeath == true && self.Ply:Alive() == false then
			return false
		end

		if Location then
			if self.RemoveOnTheater == true && Location.IsTheater( GTowerLocation:FindPlacePos(self.Ply:GetPos()) ) then
				return false
			elseif self.RemoveOnNarnia == true && GTowerLocation:FindPlacePos(self.Ply:GetPos() ) == 51 then
				return false
			end
		end
		return true

	end

	function GetEquipEntity( self )
		return self._EquipEntity
	end

	function RemoveEquipEntity( self )
		if self._EquipEntity and IsValid(self._EquipEntity) then
			if self._EquipEntity == NULL then
				self._EquipEntity = nil
				return
			end
			self._EquipEntity:Remove()
			self._EquipEntity = nil
		end
	end

	function CheckEquipEntity( self )

		if self:AllowEquipEntity() then

			if !self._EquipEntity then
				self._EquipEntity = self:CreateEquipEntity()
			end

		else
			self:RemoveEquipEntity()
		end

	end

else
	function GetRenderPos( self, ent )
		local RenderMin, RenderMax = ent:GetRenderBounds()

		return (RenderMin+RenderMax) / 2 , RenderMax * 2
	end
end
