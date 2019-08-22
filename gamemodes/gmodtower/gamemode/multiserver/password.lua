
function GTowerServers:GeneratePassword()

	local Lenght = math.random( 6, 14 ) 
	local Characters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"1","2","3","4","5","6","7","8","9","0"}
	
	local Password = ""

	for i=1, Lenght do
		Password = Password .. Characters[ math.random(1, #Characters) ]
	end
	
	return Password
	
end

function GTowerServers:SetRandomPassword()

	RunConsoleCommand("sv_password", "" )
	//RunConsoleCommand("sv_password", self:GeneratePassword() )
	
end