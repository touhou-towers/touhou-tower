
//------------------------------------------------------------
// The main icons for each player
// Show health, avatar, and name
//-------------------------------------------------------------
local PANEL = {}

function PANEL:Init()

	self.Player = nil
	self.IsOwner = false

	self.Avatar = vgui.Create( "AvatarImage", self )

	self.PlayerName = Label("", self)
	self.PlayerName:SetFont("SCPlyGroupName")
	self.PlayerName:SetTextColor( Scoreboard.Customization.ColorFont )

	self.LocationName = Label("", self)
	self.LocationName:SetFont("SCPlyGroupLocName")
	self.LocationName:SetTextColor( Scoreboard.Customization.ColorFont )

	self.NextCheck = 0.0

end

function PANEL:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorNormal )
	surface.DrawRect( 0, 0, self:GetSize() )

end

function PANEL:Think()

	if self.NextCheck < CurTime() then
		self.NextCheck = CurTime() + 0.1

		if not IsValid( self.Player ) then
			self:GroupRemove()
			return
		end

		local ply = self:GetPlayer()
		self.LocationName:SetText( string.upper( GTowerLocation:GetName( GTowerLocation:FindPlacePos( ply:GetPos() ) ) or "UNKNOWN" ) )
		self.LocationName:SizeToContents()
	end

end

function PANEL:GroupRemove()

	//Do not remove gui here because it might cause conflict
	//self.Player._GroupUI = nil
	self:Remove()

	GTowerGroup:RefreshGui()

end

function PANEL:SetPlayer( ply )

	self.Player = ply
	self.Avatar:SetPlayer( ply )

end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:SetIsOwner( state )
	self.IsOwner = state
end

function PANEL:PerformLayout()

	local ply = self:GetPlayer()

	if !IsValid( ply ) then
		self:GroupRemove()
		return
	end

	self.PlayerName:SetText( ply:Name() )
	--self.LocationName:SetText( string.upper( GTowerLocation:GetName( GTowerLocation:FindPlacePos( ply:GetPos() ) ) ) )

	self.Avatar:SetPos( 0, 0 )
	self.Avatar:SetSize( GTowerGroup.AvatarSize, GTowerGroup.AvatarSize )

	self.PlayerName:SizeToContents()
	self.PlayerName:AlignLeft( self.Avatar:GetWide() + 2 )

	self.LocationName:SizeToContents()
	self.LocationName:AlignLeft( self.Avatar:GetWide() + 2 )
	self.LocationName:AlignTop( self.PlayerName:GetTall() - 5 )

	self:SetTall( self.Avatar:GetTall() )

end

vgui.Register("GtowerGroupPlayer", PANEL, "Panel")
