ITEM.Name = "Miku Clock"
ITEM.Description = "Collectable Hatsune Miku working clock."
ITEM.Model = "models/gmod_tower/mikuclock.mdl"
ITEM.ClassName = "gmt_mikuclock"
ITEM.UniqueInventory = false
ITEM.DrawModel = true
ITEM.Tradable = false

if SERVER then
	ITEM.Songs = {"GModTower/lobby/mikuclock/mikuclock_song|.mp3", 18}
	local tbl, str, strSong = {}, string.Explode("|", ITEM.Songs[1])

	local function convertNum(num)
		if num >= 0 and num <= 9 then return tostring(0 .. num) end
		return num
	end

	for i = 1, ITEM.Songs[2] do
		strSong = "sound/" .. str[1] .. convertNum(i) .. str[2]
		table.insert(tbl, strSong)
		resource.AddFile(strSong)
		//mikuPrecacheSound(strSong)
		//print("Caching sound file: " .. strSong)
	end
	--resource.AddFile("models/gmod_tower/mikuclock.mdl")
	--resource.AddFile("materials/models/gmod_tower/mikuclock.vmt")
end
