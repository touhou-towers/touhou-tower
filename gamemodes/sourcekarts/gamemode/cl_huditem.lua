
-----------------------------------------------------
--resource.AddFile( "materials/card.vmt" )
--resource.AddFile( "materials/card.vtf" )

local colors = {
	Color(255,100,100),
	Color(100,255,100),
	Color(100,100,255),
	Color(0,255,255),
	Color(255,0,255)
}

local maxCardSlots = 5
local cardParticles = {}
local cardSlots = {}
local cardStack = {}
local nextStreak = 0
local scaleOff = 15
local cardState = { state = "idle" }
local cardReady = false

local function DrawCard( id, x, y, angle, scale, alpha )

	/*local col = colors[id]
	surface.SetDrawColor( col.r, col.g, col.b, 255 * alpha )*/

	local item = items.Get( id )
	if !item then return end

	local color = Color( 255, 255, 255, 255 )
	if cardReady && !LocalPlayer():CanUseItem() then
		color = Color( 255, 255, 255, 150 )
	end

	surface.SetDrawColor( color.r, color.g, color.b, color.a * alpha )
	surface.SetMaterial( item.Material )

	surface.DrawTexturedRectRotated( x, y, 256 * scale, 512 * scale, angle )

end

local function PlaceCard( last, id )

	local card = {}
	card.x = math.random( -20, 20 )
	card.y = math.random( -20, 20 )
	card.angle = math.random( -20, 20 )
	card.id = id
	card.time = RealTime()
	card.last = last

	if last then
		card.x = 0
		card.y = 0
		card.angle = 0
		card.id = cardState.pick
	end

	surface.PlaySound( "GModTower/casino/cards/cardflip" .. math.random( 1, 5 ) .. ".wav" )

	table.insert( cardStack, card )

end

local function DrawSlots()

	local scale = 1 + cardState.maxCards / scaleOff
	local width = #cardSlots * 30
	for i=#cardSlots, 1, -1  do
		local card = cardSlots[i]
		local slotX = ( ( ScrW() - 150 ) + card.slot * 20 ) - ( width / 2 )
		local slotY = ScrH() - 150
		
		DrawCard( card.id, card.x, card.y, card.angle, scale * .3, 1 )

		card.x = card.x + (slotX - card.x) * .1
		card.y = card.y + (slotY - card.y) * .1
	end
end

local function DrawParticles()

	local scale = 1 + cardState.maxCards / scaleOff
	local dt = FrameTime() * 2
	local i = 1
	while i <= #cardParticles do
		local card = cardParticles[i]
		if card then
			card.x = card.x + card.vx * dt
			card.y = card.y + card.vy * dt
			card.vy = card.vy + dt * 800
			DrawCard( card.id, card.x, card.y, card.angle, scale * .3, 1 )
			if card.y > ScrH() + 400 then
				table.remove(cardParticles, i)
			else
				i = i + 1
			end
		end
	end
end

local function InsertToSlot( card )
	local cp = table.Copy( card )
	table.insert( cardSlots, 1, cp )

	for k,v in pairs(cardSlots) do
		v.slot = k
	end
end

local function ForceAdd( item )
	local card = {}
	card.x = 0
	card.y = 0
	card.angle = 0
	card.id = item or math.random(1,#items.List)
	card.time = CurTime()

	InsertToSlot( card )
end

local function ClearCards()

	for k,v in pairs( cardSlots ) do
		v.vx = math.random(-200, 200)
		v.vy = -1000
		table.insert(cardParticles, v)
	end

	cardSlots = {}

end

local function Draw()

	if !LocalPlayer():GetKart() then
		ClearCards()
	end

	// Where the card ends up
	local cy = ScrH() - 150
	local cx = ScrW() - 150

	// Offset the card comes from
	local ox = 0
	local oy = 100

	local t = RealTime()
	if cardState.state == "picking" then
		if cardState.nextPlace < t then
			if cardState.dealt < cardState.maxCards then
				local last = cardState.dealt == cardState.maxCards - 1
				PlaceCard( last, math.random(1, #items.List) )
				cardState.dealt = cardState.dealt + 1
			end
			local deltaDealt = math.pow( cardState.dealt / cardState.maxCards, 10 )
			cardState.nextPlace = t + .08 + deltaDealt / 2
		end
	end

	DrawSlots()
	DrawParticles()

	if cardState.state == "idle" then
		return
	end

	local n = #cardStack
	for k,v in pairs( cardStack ) do

		if n - k < 20 then
			local dt = (t - v.time)
			local scale = 1 + k / scaleOff
			local card_x = v.x
			local card_y = v.y
			local alpha = 1
			if dt < .05 then
				scale = scale + (.05 - dt) * 5
			end

			if not v.last and cardState.state == "translast" then
				local tdt = math.max( 1 - (t - cardState.transtime) * 2, 0 )
				alpha = tdt
				card_x = card_x * ( 1 + (1 - tdt) * 2)
				card_y = card_y * ( 1 + (1 - tdt) * 2)
			end

			if dt < .3 then
				local dtx = (.3 - dt) * 3.3
				dtx = math.pow( dtx, 5 )
				local mcx = card_x
				local mcy = card_y
				local dmcx = ((mcx - ox) * dtx)
				local dmcy = ((mcy - oy) * dtx)

				card_x = card_x - dmcx * 10
				card_y = card_y - dmcy * 10

				for i=1, 4 do

					DrawCard( v.id, cx + card_x, cy + card_y, v.angle, scale * .3, .5 )

					card_x = card_x + dmcx * 1
					card_y = card_y + dmcy * 1

				end
			end

			if v.last and dt > .1 then
				local pulse = math.fmod( (dt - .1) * 2, 1 )
				if dt < .6 then
					scale = scale + (.6 - dt)
				end

				DrawCard( v.id, cx + card_x, cy + card_y, v.angle, scale * .3 + pulse / 6, 1 - pulse )

				if dt > .5 and cardState.state == "picking" then
					cardState.state = "translast"
					cardState.transtime = t
					cardState.pickCard = v
				end
			end

			DrawCard( v.id, cx + card_x, cy + card_y, v.angle, scale * .3, alpha )
		end

	end

	if cardState.state == "translast" then

		if (t - cardState.transtime) > 1 then

			cardState.state = "idle"
			cardState.start = t
			cardState.pickCard.x = cx
			cardState.pickCard.y = cy
			cardStack = {}

			// Get item uses
			local itemData = items.Get( cardState.pick )
			local n = itemData.MaxUses or 1

			for i=1, n do
				if #cardSlots < maxCardSlots then
					InsertToSlot( cardState.pickCard )
				else
					cardState.pickCard.vx = math.random(-100, 100)
					cardState.pickCard.vy = -400
					table.insert(cardParticles, cardState.pickCard)
					break
				end
			end

			// Tell the server the client is ready
			//timer.Simple( .5, function()
				net.Start("ItemReady")
				net.SendToServer()
				cardReady = true
				LocalPlayer():EmitSound( "GModTower/casino/slots/winner.wav", 40, 120 )
			//end )

		end

	end

end
hook.Add( "HUDPaint", "HUDDrawItems", Draw )

cardState.maxCards = 20


local function PickCard( item )

	cardState.state = "picking"
	cardState.nextPlace = 0
	cardState.dealt = 0
	cardState.maxCards = 20
	cardState.pick = item or math.random(1,#items.List)
	cardReady = false

end

net.Receive( "ItemGet", function( len, ply )

	local item = net.ReadInt( 8 )
	PickCard( item )

end )


local function UseCard()

	local card = cardSlots[1]

	if card then

		table.remove(cardSlots, 1)
		for k,v in pairs(cardSlots) do
			v.slot = k
		end

		card.vx = math.random(-100, 100)
		card.vy = -400
		table.insert(cardParticles, card)

		//print("USED CARD: " .. card.id)

	end

end

net.Receive( "ItemUse", function( len, ply )
	UseCard()
	LocalPlayer().ItemUse = CurTime()
end )

net.Receive( "ItemClear", function( len, ply )
	ClearCards()
end )