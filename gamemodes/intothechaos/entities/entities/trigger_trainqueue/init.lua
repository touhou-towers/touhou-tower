ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch( ply )
	if !ply:IsPlayer() || !IsValid(ply) then return end

	local nums = {}

	for k,v in pairs( ents.FindByClass("func_tracktrain") ) do
		if v.Going || v.IsFull || !v.QueueNum then continue end

		local num = tonumber(v.QueueNum)

		if num > 0 && num < 7 then
			table.insert(nums,{num,v})
		end

	end

	table.sort(nums,function(a,b) return a[1] < b[1] end)

	if !nums or #nums == 0 then
		ply:Msg2("There are currently no carts available, please wait.")
		return
	end

	local ent = nums[1][2]

	if !IsValid(ent) then
		ply:Msg2("There are currently no carts available, please wait.")
		return
	end

	local vehicles = {}

	local vehicle

	for k,v in pairs( ents.FindByClass("prop_vehicle_prisoner_pod") ) do
		if v:GetParent() == ent then
			table.insert( vehicles, v )
		end
	end

	for k,v in pairs( vehicles ) do
		if !IsValid(v:GetPassenger(1)) then
			vehicle = v
		end
	end

	if !IsValid(vehicle) then return end

	ply:EnterVehicle( vehicle )

	hook.Run("TrainEnter",ply,vehicle)

end
