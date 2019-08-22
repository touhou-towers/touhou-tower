
if ( SERVER ) then AddCSLuaFile( "shared.lua" ) end

//From the makers of "KeyRinger" comes a revolutionary new product!
//Never lose your furries again!

SWEP.PrintName  = "Furry Finder (patent pending)"
SWEP.Base   	= "weapon_base"

SWEP.ViewModel  = ""
SWEP.WorldModel  = ""

SWEP.HoldType = "normal"
SWEP.WeaponSafe = true

//The sleek portable design easily fits right into your pocket!
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

//That's right, no effort required!
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end

function SWEP:Deploy() return true end
function SWEP:Holster() return true end

//  f'ing big babies

/*local thinkDelay = 1
local lastThink = CurTime()

//The device will think for its own!
function SWEP:Think()

	local diff = CurTime() - lastThink
	if diff < thinkDelay then return end
	lastThink = CurTime()
 
	for _, v in ipairs( player.GetAll() ) do
		self:Damage( v )
	end
 
	return true
 
end

//With a distance of over 512 units!  That's more than 8 football fields!  (actual distance is more like 32ft, football fields are around 360ft - BUT WHO WENT TO MATH CLASS ANYWAYS!)
local damageDistance = 512

//Even comes with a damaging layer of awesome!
function SWEP:Damage( ply )

	if CLIENT || !IsValid( ply ) || !ply:IsFurry() || ply:IsAdmin() then return end
 	if self.Owner:GetPos():Distance( ply:GetPos() ) > damageDistance then return end
 
	//ply:Ignite( 1, 0 )  //BURN, BABY BURN!

end*/