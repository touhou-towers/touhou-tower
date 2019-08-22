
ITEM.MaxUses = 15
ITEM.Name = "Beer Case ("..ITEM.MaxUses..")"
ITEM.Description = "Get extra drunk."
ITEM.Model = "models/props/CS_militia/caseofbeer01.mdl"
ITEM.ClassName = "gmt_beercase"
ITEM.UniqueInventory = false
ITEM.DrawModel = true
ITEM.CanUse = true

ITEM.StoreId = GTowerItems.BarStoreId
ITEM.StorePrice = 100

function ITEM:OnCreate( data )
	self.UsesLeft = tonumber( data ) or self.MaxUses
	
	if CLIENT then 
		self:UpdateString()
	end
end

if SERVER then	
	function ITEM:OnUse()
		if IsValid( self.Ply ) && self.Ply:IsPlayer() then
			self.Ply:Drink()
			
			self.UsesLeft = self.UsesLeft - 1
			if self:CheckUses() then
				self:ItemChanged()
			end
		end
		return self
	end
	
	function ITEM:CheckUses()
		if self.UsesLeft <= 0 then
			local Slot = self:GetSlot()
			
			if Slot:IsValid() then
				Slot:Remove()
				return false
			end
		end
		
		return true
	end
	
	function ITEM:CustomNW()
		umsg.Char( self.UsesLeft )
	end
	
	function ITEM:GetSaveData()
		return self.UsesLeft
	end
else
	function ITEM:CreateFromNW( um )
		self.UsesLeft = um:ReadChar()
		self:UpdateString()
	end
	
	function ITEM:UpdateString()
		self.UsesLeftString = tostring( self.UsesLeft ) .. "/" .. self.MaxUses 
	end
	
	function ITEM:PaintOver()
		surface.SetFont("Default")
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 2, 2 )
		surface.DrawText( self.UsesLeftString )
	end
end