
-----------------------------------------------------
module( "Cards", package.seeall )

ChipCost = 10

DEAL = 1
RAISE = 2
CALL = 3
FOLD = 4

e_position = {
	TOP = 0,
	BOTTOM = 1,
	RANDOM = 2,
}

e_suit = {
	DIAMONDS = 1,
	HEARTS = 2,
	CLUBS = 3,
	SPADES = 4,
}

e_card = {
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	JACK = 11,
	QUEEN = 12,
	KING = 13,
	ACE = 14,
}

e_handranks = {
	HIGH_CARD = 1,
	ONE_PAIR = 2,
	TWO_PAIR = 3,
	THREE_OF_A_KIND = 4,
	STRAIGHT = 5,
	FLUSH = 6,
	FULL_HOUSE = 7,
	FOUR_OF_A_KIND = 8,
	STRAIGHT_FLUSH = 9, --also can be a royal flush if ace is high (14)
	MAX = 10,
	ROYAL_FLUSH = 11,
}
-- UnpackValues( table cards ); returns table of values of all cards in given table
local function UnpackValues( tab )
	local unpacked = {}
	for k, v in pairs( tab ) do
		if type( v ) == number then unpacked[k] = v continue end
		unpacked[k] = v.value
	end
	return unpacked
end
Debug = false
f_rankfuncs = {}

function fixString(str)
	local t = string.ToTable(str)
	local out = ""
	local mc = true
	for _, v in pairs(t) do
		if not mc then v = string.lower(v) end mc = false
		if v == "_" then v = " " mc = true end
		out = out .. v
	end
	return out
end

function reverseLookupTable(src) 
	local dst = {}
	for k,v in pairs(src) do dst[v] = fixString(k) end 
	return dst
end

function transferTab(a,index,b)
	local v = a[index]
	table.remove(a,index)
	table.insert(b, v)
end

--High Card, score is highest card, always valid
f_rankfuncs[e_handranks.HIGH_CARD] = function(cards, wincards)
	local score = cards[#cards].value

	transferTab(cards, #cards, wincards)

	return true, score
end

--Pair, score is highest paired card
f_rankfuncs[e_handranks.ONE_PAIR] = function(cards, wincards)
	local score = 0
	local n = #cards

	while n > 1 do
		if cards[n] == cards[n-1] then
			score = cards[n].value
			transferTab(cards,n,wincards)
			transferTab(cards,n-1,wincards)
			return true, score
		end
		n = n - 1
	end

	return false
end

--Two Pair, score is highest paired card
f_rankfuncs[e_handranks.TWO_PAIR] = function(cards, wincards)
	local score = 0
	local n = #cards

	while n > 1 do
		if cards[n] == cards[n-1] then
			score = cards[n].value
			transferTab(cards,n,wincards)
			transferTab(cards,n-1,wincards)
			n = n - 2

			while n > 1 do
				if cards[n] == cards[n-1] then
					table.insert(wincards, cards[n])
					table.insert(wincards, cards[n-1])
					return true, score
				end
				n = n - 1
			end
		end
		n = n - 1
	end

	return false
end

--Three of a kind, score is first in set
f_rankfuncs[e_handranks.THREE_OF_A_KIND] = function(cards, wincards)
	local score = 0
	local n = #cards

	while n > 2 do
		if cards[n] == cards[n-1] and cards[n-1] == cards[n-2] then
			score = cards[n].value
			transferTab(cards,n,wincards)
			transferTab(cards,n-1,wincards)
			transferTab(cards,n-2,wincards)
			return true, score
		end
		n = n - 1
	end

	return false
end

--Straight, score is highest card
f_rankfuncs[e_handranks.STRAIGHT] = function(cards, wincards)
	local score, matched, wins

	for i = #cards, 1, -1 do
		
		local run = cards[i].value
		matched = 0
		wins = {}
		local n = #cards

		score = run

		while n > 0 and matched < 5 do
			if cards[n].value == run then
				matched = matched + 1
				run = run - 1
				table.insert( wins, cards[n] )
			end
			n = n - 1
		end
		if matched == 5 then break end

	end
	for i = 1, #wins do transferTab( wins, 1, wincards ) end

	return matched == 5, score
end

--Flush, score is highest card
f_rankfuncs[e_handranks.FLUSH] = function(cards, wincards)
	local score = 0
	local n = #cards
	local run = cards[n].suit

	for i=1, 4 do
		local suitmatch = {}
		for j=1, n do
			if cards[j].suit == i then
				table.insert(suitmatch, cards[j])
			end
		end
		if #suitmatch >= 5 then
			score = math.max( unpack( UnpackValues( suitmatch ) ) )
			for i=1, #suitmatch do
				table.insert(wincards, suitmatch[i])
			end
			return true, score
		else
			suitmatch = {}
		end
	end

	return false
end

--Full House, score is card from highest rank
f_rankfuncs[e_handranks.FULL_HOUSE] = function(cards, wincards)
	local score = 0
	local n = #cards

	--Find three of a kind first
	while n > 2 do
		if cards[n] == cards[n-1] and cards[n-1] == cards[n-2] then
			score = cards[n].value
			transferTab(cards,n,wincards)
			transferTab(cards,n-1,wincards)
			transferTab(cards,n-2,wincards)
			break
		end
		n = n - 1
	end

	if score == 0 then return false end
	n = #cards

	--Find two of a kind next
	while n >= 2 do
		if cards[n] == cards[n-1] then
			table.insert(wincards, cards[n])
			table.insert(wincards, cards[n-1])
			return true, score
		end
		n = n - 1
	end

	return false
end

--Four of a kind, score is first in set
f_rankfuncs[e_handranks.FOUR_OF_A_KIND] = function(cards, wincards)
	local score = 0
	local n = #cards

	while n > 3 do
		if cards[n] == cards[n-1] and cards[n-1] == cards[n-2] and cards[n-2] == cards[n-3] then
			score = cards[n].value
			transferTab(cards,n,wincards)
			transferTab(cards,n-1,wincards)
			transferTab(cards,n-2,wincards)
			transferTab(cards,n-3,wincards)
			return true, score
		end
		n = n - 1
	end

	return false
end

--Straight flush, score is highest card
f_rankfuncs[e_handranks.STRAIGHT_FLUSH] = function(cards, wincards)

	local score, matched, suitsmatched, wins

	for i = #cards, 1, -1 do
		
		local run = cards[i].value
		matched = 0
		suitsmatched = {}
		wins = {}
		local n = #cards

		score = run

		while n > 0 and matched < 5 and #suitsmatched < 5 do
			if cards[n].value == run then
				matched = matched + 1
				if #suitsmatched == 0 or cards[n].suit == suitsmatched[1].suit then
					table.insert( suitsmatched, cards[n] )
				end

				run = run - 1
				table.insert( wins, cards[n] )
				// transferTab(cards,n,wins)
			end
			n = n - 1
		end
		if matched == 5 and #suitsmatched >= 5 then break end

	end
	for i = 1, #wins do
		transferTab( wins, 1, wincards )
	end
	return matched == 5 and #suitsmatched == 5, score

	/*
	local score = 0
	local n = #cards

	for i=1, 4 do
		local run = -1
		local suitmatch = {}
		for j=n, 1, -1 do
			if cards[j].suit == i then
				if run == -1 then run = cards[j].value score = run end
				if cards[j].value == run then
					run = run - 1
					if #suitmatch < 5 then
						table.insert(suitmatch, cards[j])
					end
				end
			end
		end

		if #suitmatch >= 5 then
			for i=1, #suitmatch do
				table.insert(wincards, suitmatch[i])
			end
			return true, suitmatch[1].value
		end
	end
	*/
end

local function aceLow(cards)
	for i=1, #cards do
		if cards[i].value == 14 then cards[i].value = 1 end
	end return cards
end

local function runRankFunction(rank, cards)
	local f = f_rankfuncs[rank]
	if f == nil then return nil, false end

	if printdebug then MsgN("Testing Rank Function " .. rankstrings[rank] .. "...") end

	local fcards = table.Copy(cards)
	table.sort(fcards)

	local winningHand = {}
	local b,status,score = pcall(f, fcards, winningHand)
	if not b then MsgN(status) return nil end

	if status then
		if printdebug then MsgN("Rank Succeeds: " .. rankstrings[rank] .. " : score : " .. score) end
	else
		if printdebug then MsgN("Rank Fails: " .. rankstrings[rank]) end
		
		--If the ranking fails (and rank is some sort of straight), try it with ace being low
		if rank == e_handranks.STRAIGHT_FLUSH or
		   rank == e_handranks.STRAIGHT then

			local fcards = aceLow( table.Copy(cards) )
			table.sort(fcards)

			winningHand = {}
			b,status,score = pcall(f, fcards, winningHand)
			if not b then MsgN(status) return nil end
		end
	end
	table.sort( winningHand )
	local n_w = #winningHand
	local n_f = #fcards
	local should = 5 - n_w
	for i = 1, math.max( 0, n_f - should ) do
		table.remove( fcards, 1 )
	end

	return fcards, status, score, winningHand
end

suitstrings = reverseLookupTable(e_suit)
cardstrings = reverseLookupTable(e_card)
cardstrings[1] = "Ace"
rankstrings = reverseLookupTable(e_handranks)

DeckT = {}
CardT = {}
HandT = {}

function Deck(empty)
	DeckT.__index = DeckT
	return setmetatable({ cards = {} },DeckT):Init(empty)
end

function Card(value, suit)
	CardT.__index = CardT
	return setmetatable({suit = suit, value=value},CardT)
end

function Hand()
	HandT.__index = HandT
	return setmetatable({ cards = {}, evaluated = false },HandT)
end

function CardT.__tostring(self)
	local strValue = cardstrings[self.value]
	if self.value < e_card.JACK and self.value > 1 then
		strValue = tostring(self.value)
	end
	return strValue .. " of " .. suitstrings[self.suit]
end

function CardT:ToInt()
	local suit = self.suit - 1
	local value = self.value - 1
	return bit.bor(suit, bit.lshift(value, 2))
end

function CardT:FromInt(i)
	local suit = bit.band(i, 0x03)
	local value = bit.rshift(i, 2)
	self.suit = suit + 1
	self.value = value + 1
	return self
end

function CardT.__eq(a,b) return a.value == b.value end
function CardT.__lt(a,b) return a.value < b.value end
function CardT.__gt(a,b) return a.value > b.value end

function DeckT:Init(empty)
	if empty then return self end
	for _, suit in pairs(e_suit) do
		for _, card in pairs(e_card) do
			table.insert(self.cards, Card(card,suit))
		end
	end
	return self
end

function DeckT:Shuffle()
	local stack = {}
	for _, card in pairs(self.cards) do
		table.insert(stack, card)
	end

	self.cards = {}

	while #stack > 0 do
		local index = math.random(1,#stack)
		local card = stack[index];
		table.insert(self.cards, card)
		table.remove(stack, index)
	end
end

function DeckT:GetCard()
	local n = #self.cards
	if n > 0 then
		local card = self.cards[n]
		table.remove(self.cards, n)
		return card
	else
		return nil
	end
end

function DeckT:GetCards()
	return self.cards
end

function DeckT:PutCardBack(card, position)
	position = position or e_position.BOTTOM
	if position == e_position.TOP then
		table.insert(self.cards, card)
	elseif position == e_position.BOTTOM then
		table.insert(self.cards, 1, card)
	elseif position == e_position.RANDOM then
		table.insert(self.cards, math.random(1,#self.cards), card)
	end
end

function DeckT:AddToHand(hand, n)
	if #self:GetCards() == 0 then return end

	for i=1, n do
		table.insert(hand.cards, self:GetCard())
	end
	table.sort(hand.cards)
	hand.evaluated = false
end

function DeckT:GetHand(n)
	if #self:GetCards() == 0 then return nil end

	n = n or 5
	local h = Hand()
	self:AddToHand(h, n)
	return h
end

function DeckT:DumpHand(hand, position)
	while #hand.cards > 0 do
		self:PutCardBack(hand.cards[1], position)
		table.remove(hand.cards, 1)
	end
end

function HandT:Evaluate()
	if self.evaluated then return self end

	if Debug then MsgN("Testing All Rank Functions(" .. e_handranks.MAX-1 .. ")...") end
	local handKickers = nil
	local bestHand = nil
	local handScore = 0
	local winHand = nil
	for i=1, e_handranks.MAX-1 do
		local kickers, status, score, winningHand = runRankFunction(i, self.cards)
		if status then 
			bestHand = i 
			handScore = score
			handKickers = kickers
			winHand = winningHand
		end
	end
	table.sort(handKickers)

	if bestHand == e_handranks.STRAIGHT_FLUSH and handScore == 14 then
		bestHand = e_handranks.ROYAL_FLUSH
	end

	if Debug then
		MsgN("------------------------")
		MsgN("Best Hand Was " .. rankstrings[bestHand] .. " Score: " .. handScore)
		MsgN("Kickers: ")
		for k,v in pairs(handKickers) do
			MsgN(" -" .. tostring(v))
		end
	end

	self.hand = bestHand
	self.score = handScore
	self.kickers = handKickers
	self.winningHand = winHand
	self.evaluated = true
	return self
end

function HandT.__eq(a,b)
	a:Evaluate()
	b:Evaluate()
	if a.hand ~= b.hand then return false end
	if a.score ~= b.score then return false end
	local n = #a.kickers
	while n > 0 do
		if a.kickers[n] ~= b.kickers[n] then return false end
		n = n - 1
	end
	return true
end

function HandT.__lt(a,b)
	a:Evaluate()
	b:Evaluate()
	if a.hand ~= b.hand then return a.hand < b.hand end
	if a.score ~= b.score then return a.score < b.score end
	local n = #a.kickers
	while n > 0 do
		if a.kickers[n] ~= b.kickers[n] then
			return a.kickers[n] < b.kickers[n]
		end
		n = n - 1
	end
	return false
end

function HandT:ToInt()
	local i = 0
	local n = #self.cards
	for b=0, n-1 do
		local c = self.cards[b+1]:ToInt()
		i = bit.bor(i, bit.lshift(c, 6 * b))
	end
	return i
end

function HandT:FromInt(i)
	self.evaluated = false
	self.cards = {}

	for b=0, 4 do
		local c = bit.band(i, 0x3F)
		if c ~= 0 then
			self.cards[b+1] = Card():FromInt(c)
			i = bit.rshift(i, 6)
		else
			return self
		end
	end
	return self
end

function HandT.__tostring(self)
	local n = #self.cards
	local buff = ""

	buff = buff .. "____________________________________ RANK / SCORE\n|\n"
	if self.evaluated then
		buff = buff .. "|   [" .. rankstrings[self.hand] .. "] : " .. cardstrings[self.score] .. " high     \n"
		buff = buff .. "\\___________________________________ BEST HAND\n |\n"
		for i=1, #self.winningHand do
			buff = buff .. " |  " .. tostring(self.winningHand[i]) .. "\n"
		end
		buff = buff .. " \\__________________________________ HAND\n  |\n"
	end

	for i=1, n do
		local str = tostring(self.cards[i])
		local strn = string.len(str)
		local m = 18 - strn
		buff = buff .. "  |  " .. str .. "\n"
	end

	return buff
end