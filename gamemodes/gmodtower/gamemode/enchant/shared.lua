
module("enchant", package.seeall )

DEBUG = false

List = {}

function _New( Name, ply )
	
	if !List[ Name ] then
		Error("Could not find enchantment '" .. tostring(Name) .. "'")
	end
	
	if !IsValid( ply ) then
		Error("Invalid player '".. tostring(ply) .."' on hook '" .. Name .. "'")
	end
	
	local NewItem = {}
	
	setmetatable( NewItem, List[ Name ] )
	
	NewItem:_New( ply )
	
	if DEBUG then
		Msg("Created new enchatment '".. NewItem._Type .. "'\n")
	end
	
	return NewItem
	
end

function Register( Name, tbl, baseName )
	
	if List[ Name ] then
		ErrorNoHalt("Attetion! Attempting to create two '" .. Name .. "' enchantments!")
	end
	
	local Base = enchantbase
	
	if baseName then
		if List[ baseName ] then
			Base = List[ baseName ]
		else
			ErrorNoHalt("Could not find base '".. tostring(baseName) .."' for '"..Name.."'")
		end
	end
	
	setmetatable( tbl, Base )
	
	tbl.__index = tbl
	tbl._Type = Name
	tbl.BaseClass = Base
	
	List[ Name ] = tbl
	
end


do
	local ENCHANT = {}
	
	function ENCHANT:Init()
		print("Enchantment init!")
		self.Var = "Hell!"
		self:Timeout( 5 )
		self:AddHook("Think", self.Think )
	end
	
	function ENCHANT:Think()
		
	end
	
	function ENCHANT:OnRemove()
		print("Enchatment removed!" .. self.Var)
	end
	
	Register("debug", ENCHANT )
	
	local ENCHANT = {}
	
	function ENCHANT:Init()
		self.Var = "Minions!"
		
		if SERVER then
			self:Timeout( 5 )
			self:EnableShared( true )
			self:AddHook("Think", self.Think )
		end
		
		self.EndThink = CurTime() + 1.0
	end
	
	function ENCHANT:Think()
		if CurTime() > self.EndThink  then
			Msg("Hook removed!\n")
			self:RemoveHook("Think")
			
			self:StartNW()
			umsg.Char(55)
			self:EndNW()
		end
	end
	
	function ENCHANT:RecieveUmsg( um )
		Msg("Recieved um: " .. um:ReadChar() .. " (".. self._Id ..")\n")
	end
	
	function ENCHANT:OnRemove()

	end
	
	Register("sh_debug", ENCHANT )
	
	if SERVER then 
		concommand.Add("gmt_testenchant1_s", function( ply )
			if !DEBUG then return end
			local A = New( "debug", ply, false )
		end )
		
		concommand.Add("gmt_testenchant2_s", function( ply )
			if !DEBUG then return end
			local A = New( "sh_debug", ply )
		end )
	else
		concommand.Add("gmt_testenchant1", function( ply )
			if !DEBUG then return end
			local A = New( "debug", ply, false )
		end )
	end
end