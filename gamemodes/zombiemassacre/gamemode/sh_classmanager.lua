module("classmanager", package.seeall)

ClassesFolder = string.sub(GM.Folder, 11) .. "/gamemode/classes/"

List = {}

MaxDuplicateClasses = 3

local function IsLua(name)
	return string.sub(name, -4) == ".lua"
end

local function ValidName(name)
	return name ~= "." and name ~= ".." and name ~= ".svn"
end

function LoadClasses()
	local fileList = file.Find(ClassesFolder .. "*.lua", "LUA")

	for _, name in pairs(fileList) do
		local loadName = "classes/" .. name

		if IsLua(loadName) and ValidName(loadName) then
			if SERVER then
				AddCSLuaFile(loadName)
			end

			include(loadName)
		end
	end
end

function Register(name, class)
	class.LastItem = 0
	List[name] = class
end

function Get(name)
	return List[name]
end

function GetRandom()
	local class

	repeat
		class = table.Random(List)
	until not IsFull(class.Name)

	return class
end

function FindByClass(classname)
	local plys = {}

	for _, ply in pairs(player.GetAll()) do
		if ply:GetNWString("ClassName") and IsClass(ply, classname) then
			table.insert(plys, ply)
		end
	end

	return plys
end

function IsClass(ply, classname)
	if not classname or not IsValid(ply) or not ply:GetNWString("ClassName") then
		return false
	end

	return string.lower(classname) == string.lower(ply:GetNWString("ClassName"))
end

function IsFull(classname)
	local classes = FindByClass(classname)

	return #classes >= 2
end

classmanager.LoadClasses()

if SERVER then
	concommand.Add(
		"zm_power",
		function(ply, cmd, args)
			if not IsValid(ply) or not ply:Alive() then
				return
			end
			ply:PowerStart()
		end
	)

	concommand.Add(
		"zm_specialitem",
		function(ply, cmd, args)
			if not IsValid(ply) or not ply:Alive() or GAMEMODE:GetState() ~= STATE_PLAYING then
				return
			end
			ply:UseItem()
		end
	)

	concommand.Add(
		"zm_setclass",
		function(ply, cmd, args)
			if GAMEMODE:GetState() ~= STATE_UPGRADING and not ply:IsAdmin() then
				return
			end
			local class = args[1] or "survivor"
			if not IsFull(class) then
				local getclass = classmanager.Get(class)

				if getclass then
					ply.Class = getclass
					ply.Class:Setup(ply)
					ply:SetNWString("ClassName", ply.Class.Name)
				end
			else
				Msg("Class is full!\n")
			end
		end
	)
end
