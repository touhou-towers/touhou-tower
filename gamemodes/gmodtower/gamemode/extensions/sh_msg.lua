

-----------------------------------------------------
local HSVToColor,MsgC = HSVToColor,MsgC
local ceil,max,concat = math.ceil,math.max,table.concat
local saturation = SERVER and 1 or 0.77

function MsgRainbow(...)
	local msg = concat({...})
	local nchars = #msg
	local shiftamt = max(ceil(360 / nchars), 10)
	local hue = 330
	for i = 1, nchars do
		MsgC(HSVToColor(hue,saturation,1), msg[i])
		hue = (hue + shiftamt) % 360
	end
	Msg('\n')
end