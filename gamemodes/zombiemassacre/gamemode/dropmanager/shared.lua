DropManager = {}

DropManager.COMMON = 0
DropManager.UNCOMMON = 1
DropManager.RARE = 2

DropManager.DEBUG = false

function DropManager.Debug( msg )

	if !DropManager.DEBUG then return end
	
	Msg( msg )
	
end