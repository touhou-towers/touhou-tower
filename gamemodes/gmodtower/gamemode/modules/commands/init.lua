
AddCSLuaFile( "cl_init.lua" )

// chat commands module, allows easy registration of commands like /sit, /tetris, etc
ChatCommands = {}
ChatCommands.Cmds = {}


function ChatCommands.Register( cmd, time, func )

	ChatCommands.Cmds[ cmd ] = {}

	ChatCommands.Cmds[ cmd ].Time = time
	ChatCommands.Cmds[ cmd ].Func = func

end

function ChatCommands.Unregister( cmd )

	ChatCommands.Cmds[ cmd ] = nil

end

hook.Add( "GTCommands", "GChatCommands", function( ply, chat )

	if ( ply.CmdTime == nil ) then ply.CmdTime = {} end

	if !ChatCommands.Cmds[ chat ] then return end

	local sayFunc = ChatCommands.Cmds[ chat ].Func
	local funcDelay = ChatCommands.Cmds[ chat ].Time or 1

	if !sayFunc then return end

	local cmdTime = ply.CmdTime[ chat ]

	if ( !cmdTime || cmdTime < CurTime() ) then

		ply.CmdTime[ chat ] = CurTime() + funcDelay

		local b, ret = pcall( sayFunc, ply )

		if !b then
			SQLLog( 'error', "chat function failed for '" .. chat .. "': " .. ret .. "\n" )
			return ""
		end

	else

		ply:Msg2( "Slow down!" )

	end

	return ""

end )
