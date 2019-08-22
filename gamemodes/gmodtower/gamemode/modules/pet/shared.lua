
Pets = {}
Pets.Emotions = {}


include( "emotions.lua" )
if SERVER then AddCSLuaFile( "emotions.lua" ) end


local function ValidPet( petType, func )
	local isValid = ( Pets.Emotions[ petType ] != nil )
	
	if !isValid && func && SERVER then
		SQLLog( 'error', tostring( func ) .. " was called for an invalid pet: \"" .. tostring( petType ) .. "\"\n" )
	end
	
	return isValid
end

// this assumes petType is valid, and emotion is a string
local function ValidPetEmotion( petType, emotion, func )
	local isValid = ( Pets.Emotions[ petType ][ emotion ] != nil )
	
	if !isValid && func && SERVER then
		SQLLog( 'error', tostring( func ) .. " was called for an invalid pet (\"" .. tostring( petType ) .. "\") emotion: " .. tostring( emotion ) .. "\n" )
	end
	
	return isValid
end


// Pets.GetIDFromEmotion( "Happy" ) == 1
function Pets.GetIDFromEmotion( emotion )

	local emoteTable = Pets.DefaultEmotions[ emotion ]
	
	if !emoteTable then
		return 0
	end
	
	return emoteTable.Id or 0
end

// Pets.GetEmotionFromID( 1 ) == "Happy"
function Pets.GetEmotionFromID( id )

	for k, v in pairs( Pets.DefaultEmotions ) do
		if ( v.Id == id ) then
			return v.Name
		end
	end
	
	return "Invalid"
end

// Pets.GetEmotionString( 1 ) == "^_^"
// Pets.GetEmotionString( "Happy" ) == "^_^"
function Pets.GetEmotionString( emotion )

	local emoteId = emotion or "Invalid"
	
	if ( type( emotion ) == "number" ) then
		emoteId = Pets.GetEmotionFromID( emotion )
	end
	
	local emoteTable = Pets.DefaultEmotions[ emoteId ]
	
	if !emoteTable then
		return "#_#" // error face
	end
	
	return emoteTable.String or "#_#"
	
end


// Pets.GetRandomQuoteIndex( "melon", "Happy" ) == #
// Pets.GetRandomQuoteIndex( "melon", 1 ) == #
function Pets.GetRandomQuoteIndex( petType, emotion )
	
	if !ValidPet( petType, "Pets.GetRandomQuoteIndex" ) then
		return -1
	end
	
	if ( type( emotion ) == "number" ) then
		emotion = Pets.GetEmotionFromID( emotion )
	end
	
	if !ValidPetEmotion( petType, emotion, "Pets.GetRandomQuoteIndex" ) then
		return -1
	end
	
	local quoteTable = Pets.Emotions[ petType ][ emotion ].Quotes
	
	return math.random( 1, #quoteTable ) or -1
end

// Pets.GetQuote( "melon", "Happy", 1 ) == "Whee!"
// Pets.GetQuote( "melon", 1, 1 ) == "Whee!"
function Pets.GetQuote( petType, emotion, index )

	if !ValidPet( petType, "Pets.GetQuote" ) then return end
	
	if ( type( emotion ) == "number" ) then
		emotion = Pets.GetEmotionFromID( emotion )
	end
	
	if !ValidPetEmotion( petType, emotion, "Pets.GetQuote" ) then return end
	
	local quoteTable = Pets.Emotions[ petType ][ emotion ].Quotes
	
	return quoteTable[ index ]
	
end

// Pets.GetSound( "melon", "Happy", 1 ) == "gmodtower/lobby/pets/melon/happy1.wav"
// Pets.GetSound( "melon", 1, 1 ) == "gmodtower/lobby/pets/melon/happy1.wav"
function Pets.GetSound( petType, emotion, index )

	if !ValidPet( petType, "Pets.GetSound" ) then return end
	
	if ( type( emotion ) == "number" ) then
		emotion = Pets.GetEmotionFromID( emotion )
	end
	
	if !ValidPetEmotion( petType, emotion, "Pets.GetSound" ) then return end
	
	return "gmodtower/lobby/pets/" .. petType .. "/" .. emotion .. tostring( index ) .. ".wav"
end

// Pets.GetRandomSoundIndex( "melon", "Happy" ) == #
// Pets.GetRandomSoundIndex( "melon", 1 ) == #
function Pets.GetRandomSoundIndex( petType, emotion )

	if !ValidPet( petType, "Pets.GetRandomSoundIndex" ) then
		return -1
	end
	
	if ( type( emotion ) == "number" ) then
		emotion = Pets.GetEmotionFromID( emotion )
	end
	
	if !ValidPetEmotion( petType, emotion, "Pets.GetRandomSoundIndex" ) then
		return -1
	end
	
	local numSounds = Pets.Emotions[ petType ][ emotion ].NumSounds
	
	if numSounds == 0 then
		return -1
	end
	
	return math.random( 1, numSounds )
	
end


function Pets.Register( petType, additionalEmotes, additionalSounds )

	Pets.Emotions[ petType ] = Pets.DefaultEmotions
	
	if additionalEmotes then 
		Pets.AddEmotions( petType, additionalEmotes )
	end
	
	if additionalSounds then
		Pets.SetSounds( petType, additionalSounds )
	end
end

// precondition: petType is valid
local function AddEmotion( petType, emotion, emotionTable )

	local petTable = Pets.Emotions[ petType ]
	
	if !ValidPetEmotion( petType, emotion, "AddEmotion" ) then return end
	
	for _, v in ipairs( emotionTable ) do
		table.insert( petTable[ emotion ].Quotes, v )
	end
end

// precondition: petType is valid
local function SetNumSounds( petType, emotion, numSounds )

	local petTable = Pets.Emotions[ petType ]
	
	if !ValidPetEmotion( petType, emotion, "SetNumSounds" ) then return end
	
	petTable[ emotion ].NumSounds = numSounds
	
end

/* Example:
Pets.AddEmotions( "melon", {
	Happy = {
		"String",
		"Another string",
	},
	Sad = {
		"Blarg",
	},
} )
*/
function Pets.AddEmotions( petType, emotion )
	
	if !ValidPet( petType, "Pets.AddEmotions" ) then return end
	
	for k, v in pairs( emotion ) do
		AddEmotion( petType, k, v )
	end
	
end

/* Example:
Pets.SetSounds( "melon", {
	Happy = 4, // 4 happy sounds
	Sad = 2,
} )
*/
function Pets.SetSounds( petType, soundTable )

	if !ValidPet( petType, "Pets.SetSounds" ) then return end
	
	for k, v in pairs( soundTable ) do
		SetNumSounds( petType, k, v )
	end
	
end
