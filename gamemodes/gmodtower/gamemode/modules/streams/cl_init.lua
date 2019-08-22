
net.Receive("gmt_startstream", function()
	print("STREAM STARTED")
	local URL = net.ReadString()
	local Emitter = net.ReadString()
	print(URL)
	Msg2(Emitter.." has started a music stream.")
	
	sound.PlayURL(tostring(URL),"", function(s)
		if IsValid(s) then s:Play() end
		--s:Play()
	end)
	
end)