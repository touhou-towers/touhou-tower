
include("shared.lua")

local function UMsgT( target, trans, ... )

	umsg.Start("t7", target)
		umsg.String( trans )
		umsg.Char( select('#', ...) )

		for _, v in ipairs( {...} ) do
			umsg.String( v )
		end

	umsg.End()

end

function MsgT( trans, ... )
	UMsgT( nil, trans, ... )
end

local meta = FindMetaTable( "Player" )

if !meta then
    Msg("ALERT! Could not hook Player Meta Table\n")
    return
end

function meta:Msg2( str )
	if !str || type(str) != "string" then return end

	if #str > 251 then
		SQLLog('error', "Tried to send a message that would overflow umsg [" .. str .. "]")
		return
	end

	umsg.Start("t6", self)
		umsg.String( str )
	umsg.End()

end

meta.MsgT = UMsgT
