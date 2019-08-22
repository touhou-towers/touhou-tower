
include("shared.lua")
include("load.lua")
include("cl_scoregui.lua")
include("cl_smallachigui.lua")

GtowerAchivements.NextUpdate = 0

local DEBUG = false

function GtowerAchivements:GetValue( id )

	local Achivement = self.Achivements[ id ]

	if Achivement == nil then
		Msg("ACHIVEMENT: Attemping to get value of " .. id .. ", a nonexistance achivement.")
		return
	end

	local Value = Achivement.PlyVal or 0 //or cookie.GetNumber("GTachivement" .. id, 0 )

	if Achivement.GetValue then
		return Achivement.GetValue( Value )
	end

	return Value

end

function GtowerAchivements:RequestUpdate()

	if self.NextUpdate > CurTime() then
		return
	end

	self.NextUpdate = CurTime() + 3

	RunConsoleCommand("gmt_reqachi")
end

function GtowerAchivements:NumUnlocked()

	local completed = 0

	for id, achivement in pairs( GtowerAchivements.Achivements ) do

		local value = GtowerAchivements:GetValue( id )
		local maxValue = nil

		if achivement.GetMaxValue then
			maxValue = achivement.GetMaxValue()
		end

		if maxValue then
			if value == maxValue then
				completed = completed + 1
			end
			continue
		end

		if tobool( value ) then
			completed = completed + 1
		end

	end

	return completed
end

function GtowerAchivements:RecieveMessage( um )

	while true do

		local Id = um:ReadShort()
		if !Id || Id == 0 then break end

		local Item = self:Get( Id )
		if Item then
		Item.PlyVal = um[ "Read" .. Item._NWInfo[1] ]( um )
		Item.HasRecieved = true

		if Item._NWInfo[3] then
			Item.PlyVal = Item.PlyVal + Item._NWInfo[3]
		end
		end

	end

	hook.Call("AchivementUpdate", GAMEMODE )

end

usermessage.Hook("GTAch", function( um )
	GtowerAchivements:RecieveMessage( um )
end)

usermessage.Hook("GTAchWin", function( um )
	local Id = um:ReadShort()

	local Achivement = GtowerAchivements:Get( Id )

	if Achivement then
		local Message = Msg2(T("AchievementsGot", Achivement.Name))
		Message:SetColor(Color( 255, 200, 14 ))
		Message:SetTextColor(Color(0,0,0))
		Message:SetIcon("trophy")
	end
end)

usermessage.Hook("GTAchRest", function( um )

	local Count = um:ReadChar()

	Msg2( Count .. " trophies were deposited in your bank.")

end )

/*
concommand.Add("gmt_resetachivement", function()
	Msg("Clearing client-side achivement cookies!\n")
	sql.Query("DELETE FROM cookies WHERE key='GTachivement%'")

	for _, v in pairs( GtowerAchivements.Achivements ) do
		if v.HasRecieved != true then
			v.PlyVal = 0
		end
	end
end )
*/
