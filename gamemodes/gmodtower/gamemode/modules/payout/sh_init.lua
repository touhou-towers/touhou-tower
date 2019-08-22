
module( "payout", package.seeall )
Payouts = {}
function Register( id, data )
	// Gather data
	data.ID = id
	data.Name = data.Name or "Unknown"
	data.Desc = data.Desc or "N/A"
	data.GMC = data.GMC or 0
	data.Diff = data.Diff or 0
	table.insert( Payouts, data )
end
function Get( id )
	return Payouts[id]
end
function GetByName( name )
	for id, payout in pairs( Payouts ) do
		if payout.ID == name then
			return id, payout.GMC
		end
	end
end
