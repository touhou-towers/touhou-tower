

module( "table", package.seeall )



function RemoveValue( tbl, value )
	for k, v in ipairs( tbl ) do
		if ( v == value ) then
			table.remove( tbl, k )
		end
	end
end

