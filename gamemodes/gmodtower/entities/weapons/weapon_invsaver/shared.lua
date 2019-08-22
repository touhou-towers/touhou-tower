
if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_viewscreen.lua")
else
	include("cl_viewscreen.lua")
end

SWEP.PrintName		= "Inventory saver"
SWEP.Category		= ""

SWEP.Base		= "weapon_base"
SWEP.HoldType		= "pistol"

SWEP.ViewModel			= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	if CLIENT then
		self.NextReloadUse = 0
	end
	
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Reload()
	
	if CLIENT && InventorySaver.Allow( self.Owner ) && CurTime() > self.NextReloadUse then
		
		GtowerMainGui:GtowerShowMenus()
		
		if LocalPlayer()._InvSaveName then
			
			Derma_Query( "Would you like to save it, or discart it?", "Question!",
				"SAVE", 	function() RunConsoleCommand("gmt_invsaveend" ) LocalPlayer()._InvSaveName = nil  end, 
				"DISCART", 	function() RunConsoleCommand("gmt_invsavename", nil ) LocalPlayer()._InvSaveName = nil  end,
				"Cancel", 	function() end
			)
		
		else
		
			Derma_StringRequest( "Question", 
				"Choose save name: (Enter blank name to stop)", 
				"", 
				function( strTextOut ) 
					if string.len( strTextOut ) < 1 then
						strTextOut = nil
					end
				
					RunConsoleCommand("gmt_invsavename", strTextOut ) 
					LocalPlayer()._InvSaveName = strTextOut
				end,
				function( strTextOut )  end,
				"Start saving", 
				"Cancel" 
			)
			
		end
		
		self.NextReloadUse = CurTime() + 2.0
		
		
	end
	
end


function SWEP:PrimaryAttack()	

	if SERVER && InventorySaver.CanSelect( self.Owner ) then
	
		local EyeTrace = self.Owner:GetEyeTrace()
		
		if IsValid( EyeTrace.Entity ) then
			InventorySaver.Select( self.Owner, EyeTrace.Entity )
		end
	
	end

end

function SWEP:SecondaryAttack()
	
	if SERVER && InventorySaver.CanSelect( self.Owner ) then
	
		local EyeTrace = self.Owner:GetEyeTrace()
		
		if IsValid( EyeTrace.Entity ) then
			InventorySaver.UnSelect( self.Owner, EyeTrace.Entity )
		end
	
	end

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

