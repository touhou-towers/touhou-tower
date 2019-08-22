

-----------------------------------------------------
ENT.Base			= "gmt_instrument_base_drum"
ENT.Type			= "anim"
ENT.PrintName		= "Drum Set"
ENT.Spawnable		= true
ENT.AdminSpawnable 	= true

ENT.Model		= Model( "models/map_detail/music_drumset.mdl" )
ENT.ChairModel	= Model( "models/map_detail/music_drumset_stool.mdl" )
ENT.SoundDir	= "GModTower/lobby/instruments/drums/"
ENT.RenderGroup 	= RENDERGROUP_BOTH

local darker = Color( 100, 100, 100, 150 )
ENT.Keys = {
	[KEY_G] =
	{
		Sound = "snare2", Label = "snare"
	},
	[KEY_SPACE] =
	{
		Sound = "kick", Label = "kick"
	},
	[KEY_R] =
	{
		Sound = "tom1", Label = "tom"
	},
	[KEY_I] =
	{
		Sound = "tom2", Label = "tom"
	},

	[KEY_J] =
	{
		Sound = "tom3", Label = "tom"
	},
	[KEY_E] =
	{
		Sound = "hat", Label = "tom", Vars = 3
	},

	[KEY_O] =
	{
		Sound = "crash", Label = "tom"
	},
}

function ENT:GetSound( snd )

	if ( snd == nil || snd == "" ) then
		return nil
	end

	for _, keyData in pairs( self.Keys ) do
		if keyData.Sound == snd then
			local vars = keyData.Vars
			if vars then
				return self.SoundDir .. snd .. math.random(1, 1) .. self.SoundExt
			end
		end
		if keyData.Shift && keyData.Shift.Sound == snd then
			local vars = keyData.Shift.Vars
			if vars then
				return self.SoundDir .. snd .. math.random(1, 1) .. self.SoundExt
			end
		end
	end

	return self.SoundDir .. snd .. self.SoundExt
end
