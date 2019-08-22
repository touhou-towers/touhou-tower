
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
include("sql.lua")

local DEBUG = false

function PvpBattle:SendToClient( ply, ShouldOpen )

	if !ply._PVPBattleData then
		return
	end

	umsg.Start("PvpB", ply )
		umsg.Char( 1 )
		umsg.Bool( ShouldOpen or false )
		
		umsg.Char( table.Count( ply._PVPBattleData ) )
		
		if self.DEBUG then
			Msg("PVPBATTLE: Sendint to ", ply ,": \n")
			PrintTable( ply._PVPBattleData )
		end
		
		for k, v in pairs( ply._PVPBattleData ) do
		
			umsg.Char( k )
			umsg.Short( v - 32768 )
		
		end
		
		local discount = GTowerStore.Discount[self.StoreId] or 0
		umsg.Float(discount)
	umsg.End()
	
	if ShouldOpen then
		GTowerStore:SendItemsOfStore( ply, self.StoreId )
	end

end

function PvpBattle:GiveWeapons( ply )

	if !ply._PVPBattleData then
		return nil
	end

	local Weapons = {}

	for _, v in pairs( ply._PVPBattleData ) do	
		local Weapon = PvpBattle.WeaponsIds[ v ]
	
		if Weapon then		
			ply:Give( Weapon )
			table.insert( Weapons, Weapon )
		end
	end

	return Weapons
end

function PvpBattle:GetData( ply )

	if !ply._PVPBattleData  then
		return
	end
	
	if DEBUG then
		Msg("WRITING PVPBattle of " , ply, "\n")
		PrintTable( ply._PVPBattleData )
		Msg("\n")
	end

	local Data = Hex()
	
	for k, v in pairs( ply._PVPBattleData ) do
		Data:SafeWrite( k )
		Data:SafeWrite( v )
	end
	
	return Data:Get()

end


function PvpBattle:LoadDefault( ply )
	if self.DEBUG then Msg("Loading default data for ", ply ,"\n") end
	ply._PVPBattleData = table.Copy( PvpBattle.DefaultWeapons )
end

function PvpBattle:Load( ply, val )
	
	local Table = {}
	local Data = Hex( val )
	
	while Data:CanRead() do
		local Id = Data:SafeRead()
		local Value = Data:SafeRead()
		
		if PvpBattle.WeaponsIds[ Value ] then
			Table[ Id ] = Value	
		end
	end
	
	if DEBUG then
		Msg("Reading PVPBattle of " , ply, "\n")
		PrintTable( Table )
		Msg("\n")
	end
	
	ply._PVPBattleData = Table
	
end

//Only set the weapons that are not seted after the levels are loaded
hook.Add("SQLConnect", "CheckPVPWeapons", function( ply )
	
	for k, weplist in pairs( PvpBattle.WeaponList ) do
		if ply._PVPBattleData == nil then continue end
		if ply:GetLevel( ply._PVPBattleData[ k ] ) != 1 then
			ply._PVPBattleData[ k ] = nil
		end
		
		if !ply._PVPBattleData[ k ] then
			
			for _, wep in pairs( weplist ) do
				
				if ply:GetLevel( wep ) == 1 then
					ply._PVPBattleData[ k ] = GTowerStore:GetItemByName( wep )
					break
				end
				
			end
			
		end
		
	end

end )
