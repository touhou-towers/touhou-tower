
include("shared.lua")



module("adverts", package.seeall )


usermessage.Hook("Advert", function( um )
	
	while true do
	
		local Id = um:ReadLong()
		
		if DEBUG then
			Msg("Got message hook!" .. Id .. "\n")
		end
		
		if Id <= 0 then
			return
		end
		
		local BaseName = um:ReadString()
		local Name = um:ReadString()
		
		local NewMat = CreateMaterial("Advert"..BaseName, "UnlitGeneric", {
			["$basetexture"] = MaterialBaseFolder .. Id .. BaseName,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1
		} )
		
		AdvertData[ Id ] = {
			Id = Id,
			Name = Name,
			BaseName = BaseName,
			Material = NewMat,
		}
	
	end

end )