
-----------------------------------------------------
module( "marquee", package.seeall )

local MARQUEE = {}
function MARQUEE:SetPos( x, y )

	self.x = x
	self.y = y

end
function MARQUEE:Draw( text )

	draw.DrawText( text, "Default", self.x, self.y, Color( 255, 255, 255 ) )

end
function MARQUEE:SetUpdate( time )

	self.Update = time

end
function MARQUEE:GetData()

	return self.Data

end
function MARQUEE:SetData( data )

	self.Data = data

end
function MARQUEE:Reset()

	self.CurText = ""
	self.AllText = ""
	self.SubFrom = 1
	self.SubTo = 0

end
function marquee.New( length, update )

	MARQUEE.__index = MARQUEE
	return setmetatable( {
		Update = update or 0.25,
		Data = {},
		CurText = "",
		AllText = "",
		SubFrom = 1,
		SubTo = 1 + ( length or 10 ),
		Length = length or 10,
		Index = 0,
		LastUpdate = 0,
		x = 0,
		y = 0
	}, MARQUEE )

end
function marquee.Draw( mar )

	if !mar then return end

	if !mar.Data[ mar.Index ] and mar.Index > 0 and #mar.Data > 0 then

		mar.Index = math.Clamp( mar.Index, 1, #mar.Data )

	end

	if mar.AllText then

		if mar.SubTo >= #mar.AllText then // ended

			mar.Index = mar.Index + 1
			if !mar.Data[ mar.Index ] then mar.Index = 1 end
			mar:Reset()

		else

			if RealTime() > mar.LastUpdate + mar.Update then // scroll

				mar.LastUpdate = RealTime()
				mar.SubFrom = mar.SubFrom + 1
				mar.SubTo = mar.SubFrom + mar.Length - 1
				mar.CurText = string.sub( mar.AllText, mar.SubFrom, mar.SubTo )

			end

			mar:Draw( mar.CurText, mar.x, mar.y )

			return

		end

	end

	// we don't have anything to draw
	if mar.Data[ mar.Index ] then

		mar.AllText = string.rep( " ", mar.Length ) .. mar.Data[ mar.Index ] .. string.rep( " ", mar.Length )
		mar.CurText = string.rep( " ", mar.Length )
		mar.SubFrom = 1
		mar.SubTo = mar.Length
		mar.LastUpdate = RealTime() - mar.Update

	end
	mar:Draw( string.rep( " ", mar.Length ), mar.x, mar.y )

end
