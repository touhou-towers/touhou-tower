
// global emotions for all pets
// emotions for specific pets are a combination of these plus their registered emotions

Pets.DefaultEmotions = 
{
	Invalid = { Name = "Invalid", Id = 0, String = "INVALID",
		Quotes = {
			"INVALID QUOTE!",
		},
		NumSounds = 0
	},
	
	Happy = { Name = "Happy", Id = 1, String = "^_^",
		Quotes = {
			"Whee!",
			"Whoo",
			"Yay!",
			"Weeeee",
			"I'm Happy!",
			"Arf!",
		},
		NumSounds = 0,
	},
	
	Sad = { Name = "Sad", Id = 2, String = ";_;",
		Quotes = {
			"Waaah",
		},
		NumSounds = 0,
	},
	
	Bored = { Name = "Bored", Id = 3, String = "-_-",
		Quotes = {
			"I'm bored...",
			"I wanna go somewhere...",
			"Play with me...",
			"Hey?... You there?",
		},
		NumSounds = 0,
	},
	
	Dead = { Name = "Dead", Id = 4, String = "x_x",
		Quotes = {
			"RIP...",
		},
		NumSounds = 0,
	},
	
	Rolling = { Name = "Rolling", Id = 5, String = ">_<",
		Quotes = {
			"Eeep!",
		},
		NumSounds = 0,
	},
	
	Dizzy = { Name = "Dizzy", Id = 6, String = "@_@",
		Quotes = {
			"Woaah",
			"Oh god",
			"*barfs*",
		},
		NumSounds = 0,
	},
	
	Angry = { Name = "Angry", Id = 7, String = "ò.ó",
		Quotes = {
			"Arrrr!",
		},
		NumSounds = 0,
	},
	
	Wink = { Name = "Wink", Id = 8, String = "^_~",
		Quotes = {
			"Hey there~",
			"Hey~",
			"Hi, cutie~",
			"Hot",
			"How are you?",
			"Good to see you!",
		},
		NumSounds = 0,
	},
	
	Dull = { Name = "Dull", Id = 9, String = "=.=",
		Quotes = {
			"*yawn*",
			"Sleepy...",
			"Zzzz",
		},
		NumSounds = 0,
	},
	
	What = { Name = "What", Id = 10, String = "._.",
		Quotes = {
			"What.",
		},
		NumSounds = 0,
	},
	
	Kiss = { Name = "Kiss", Id = 11, String = "^o^",
		Quotes = {
			"Chuu~",
			"Chu!!",
			"Mmm",
			"<3",
			"Ah..",
		},
		NumSounds = 0,
	},
	
	Rabbit = { Name = "Rabbit", Id = 12, String = "(\\_/)",
		Quotes = {
			"*squeek*",
			"I'm not a carrot!",
		},
		NumSounds = 0,
	},
	
	OwnerPoke = { Name = "OwnerPoke", Id = 13, String = "^_^",
		Quotes = {
			":D",
			"*giggles*",
			"I love you!",
			"You are my favorite owner!",
		},
		NumSounds = 0,
	},
	
	OtherPoke = { Name = "OtherPoke", Id = 14, String = "o.o",
		Quotes = {
			"Hai!",
			"Hello~",
			"Oh hai",
		},
		NumSounds = 0,
	},
			
	
	// support for sounds
	Spawning = { Name = "Spawning", Id = 100, String = "INVALID (SPAWNING)",
		Quotes = { },
		NumSounds = 0,
	},
	Deleted = { Name = "Deleted", Id = 101, String = "INVALID (DELETED)",
		Quotes = { },
		NumSounds = 0,
	},
	Teleporting = { Name = "Teleporting", Id = 102, String = "INVALID (TELEPORTING)",
		Quotes = { },
		NumSounds = 0,
	},
}