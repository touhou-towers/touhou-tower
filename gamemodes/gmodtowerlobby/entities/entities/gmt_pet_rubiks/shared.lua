if !Pets then
	SQLLog( 'error', "Pets module not loaded, pet entity will not load!\n" )
	return
end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Rubiks Cube Pet"
ENT.Author			= "GMT Krew~"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Model			= "models/gmod_tower/rubikscube.mdl"

GtowerPrecacheModel( ENT.Model )

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0 , "PetName" )
end

Pets.Register(

	// pet name
	"rubik",

	// strings
	{

		Wink = {

			"Twist my sides~",

			"You're scrambling me!",

			"Only you can solve me.",

			"You complete me.",

			"Let's rub stickers~",

			"I only date solved cubes."

		},



		Bored = {

			"*unsolves itself*",

		},

	}

)

function ENT:SharedInit()

	RegisterNWTable( self, {
		{ "Emotion", 0, NWTYPE_CHAR, REPL_EVERYONE },
	} )

end
