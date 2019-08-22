
--[[
 	Post-Processing Event Handlers

	by PackRat ( packrat (at) plebsquad (dot) com )

	Version 1.0, 19th Feb 2007

	Because PostMan is entirely clientside,
	the server does not have direct access
	to the postman library. Post Events
	allow preset post-processing effects
	to be created and triggered by the
	server, similar to util.Effect.
]]--



postEvents = {}


-- Add a post event to the client
function AddPostEvent( Name, func )

	if ( !Name || Name == "" ) then return end
	postEvents[Name] = func

end


-- Remove a post event from the client
function RemovePostEvent( Name )

	postEvents[Name] = nil

end


-- Let the client trigger post events
-- if they really want to.
function PostEvent( Name, mul, time )

	if ( !Name || !postEvents[Name] ) then return end
	postEvents[Name]( mul, time )

end


-- Catch post events from the server
local function postEventHook( Name, mul, time )

	if ( !Name || !postEvents[Name] ) then return end

	postEvents[Name]( mul, time )

end
net.Receive( "postevent", function()

	local Name = net.ReadString()
	local mul = net.ReadFloat() or 0
	local time  = net.ReadFloat() or 1

	postEventHook(Name, mul, time)
end)
--usermessage.Hook( "postevent", postEventHook )
