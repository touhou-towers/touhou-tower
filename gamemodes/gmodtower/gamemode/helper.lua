

function AdvRound( val, d )
    d = d or 0
    return math.Round( val * (10 ^ d) ) / (10 ^ d)
end 
/*
function ConvertType( value, typ )
    if typ == "number" then return tonumber(value) end
    if typ == "string" then return tonstring(value) end
    if typ == "table" then 
        if type(value) != "table" then
            return {value}
        end
    
        return value 
    end
    
    if typ == "boolean" then return tobool( value ) end
    
    Msg("ERROR: Converting unkown type?")
    
    return values
end
*/

function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)

	local d = vX:DotProduct(vp)
	if (d <= 0.0) then return end

	local vt = vOrigin - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end

	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end

	return Vector(u / d, v / d, 0)
end

function IsPlayer( ply )
	return ply && ply:IsValid() && ply:IsPlayer()
end