
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()

	self.NegativeX = 0
	self.PositiveY = 0

	self:SetRenderBounds( Vector(-256,-256,-256), Vector(256,256,256) )

end

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:DrawTranslucent()

	// Aim the screen forward
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() + ang:Up() * ( math.sin( CurTime() ) * 2 + 64 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	if (LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then
		ang:RotateAroundAxis( ang:Right(), 180 )
	end

	// Start the fun
	cam.Start3D2D( pos, ang, 0.1 )

		surface.SetFont( "GTowerSkyMsg" )
		surface.SetTextColor( 255, 255, 255, 255 )

		local w,h = surface.GetTextSize( "Name Change" )

		surface.SetTextPos( -w / 2, -h )
		surface.DrawText( "Name Change" )

	cam.End3D2D()

end

net.Receive("gmt_sendnamelist",function()
	local table = net.ReadTable()
	local string = string.Implode("\n",table)
	SetClipboardText(string)
end)

local function fnEnter( text )
		local Lenght = string.len( text )

		if Lenght > 250 then
			Msg2("Name is too long - 250 charcter limit")
			return
		end

		if Lenght > 2 then
			RunConsoleCommand("gmt_namesuggestion", text )
		end
end

function ENT:ReceiveUmsg()

	if LocalPlayer():IsAdmin() then
		GtowerNPCChat:StartChat({
			Entity = GtowerRooms.NPCClassname,
			Text = "Hi there fellow admin, would you like to see the name list so far or would you like to request something yourself?",
			Responses = {
				{
					Response = "Show me the name list.",
					//Text = GetTranslation("RoomGet"),
					Text = "The name list has been pasted to your clipboard.",
					Func = function() RunConsoleCommand("gmt_copysuggestions") end
				},
				{
					Response = "I want to suggest a name.",
					Func = function()
						local Message = [[There is the possibility of changing our name.
					What name would you think would fit us?
					Your suggestions will help us in coming up with a new name we all can be proud of.

					Please DO NOT include the words "GMod Tower", "Tower", or any username/admin that you know of.

					(You may only submit one suggestion, choose wisely. Bonus points if it would still match 'G.M.T.C')]]

						Derma_StringRequest( "GMod Tower Name Change", Message, "", fnEnter, nil, nil, nil )
					end
				},
				{
					Response = "No thanks.",
					--Text = "Aight"
				},
			}
		})
		return
	end

	local Message = [[There is the possibility of changing our name.
What name would you think would fit us?
Your suggestions will help us in coming up with a new name we all can be proud of.

Please DO NOT include the words "GMod Tower", "Tower", or any username/admin that you know of.

(You may only submit one suggestion, choose wisely. Bonus points if it would still match 'G.M.T.C')]]

	Derma_StringRequest( "GMod Tower Name Change", Message, "", fnEnter, nil, nil, nil )

end
