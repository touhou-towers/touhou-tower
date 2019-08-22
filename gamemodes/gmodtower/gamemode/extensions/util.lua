


function SafeRemove( item )
	if IsValid( item ) then
		item:Remove()
	end
end

function ValidPlayer( ply )
	return ply and ply:IsValid() and ply:IsPlayer()
end

--Short for DEBUG, quick way to check into variables
function D( val )
	Msg("TYPE: ", type(val), "("..tostring(val)..")" )

	if type( val ) == "table" then
		PrintTable( val )
	end
end

function P()
	if SERVER then
		return player.GetAll()[1]
	else
		return LocalPlayer()
	end
end

function EYE()
	return P():GetEyeTrace()
end
