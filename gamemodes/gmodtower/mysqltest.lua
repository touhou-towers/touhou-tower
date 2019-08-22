
a = '5\0b'
print ( a, string.len( a ) )

tmysql.query("SELECT '" .. a .. "' ", function(a,b,c)
	
	if b!=1 then
		Error(c)
	end
	
	PrintTable( a )

end )