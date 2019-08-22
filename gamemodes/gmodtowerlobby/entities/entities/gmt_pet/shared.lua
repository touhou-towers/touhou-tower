if !Pets then
	SQLLog( 'error', "Pets module not loaded, pet entity will not load!\n" )
	return
end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Pet"
ENT.Author			= "GMT Krew~"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Model			= "models/props_junk/watermelon01.mdl"

GtowerPrecacheModel( ENT.Model )

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0 , "PetName" )
end

Pets.Register( 

	// pet name
	"melon", 
	
	// strings
	{
		Wink = {
			"Nice seeds, wanna photosynthesize?",
			"Strip off your rhine, baby",
			"Let me have a taste of your melon juice",
		},
		
		Bored = {
			"*twiddles seeds*",
		},
	},
	
	// number of sounds
	{
		Spawning = 3,
		Deleted = 5,
		Teleporting = 1,
		
		Bored = 6,
		Dizzy = 5,
		Dull = 5,
		Wink = 5,
		Rolling = 5,
		Kiss = 3,
	}
)

function ENT:SharedInit()

	RegisterNWTable( self, {  
		{ "Emotion", 0, NWTYPE_CHAR, REPL_EVERYONE },
	} )
	
end
