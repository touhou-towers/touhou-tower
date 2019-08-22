

hook.Add("LoadAchivements","AchiSeats", function () 
	GtowerAchivements:Add( ACHIVEMENTS.LONGSEATGETALIFE, {
		Name = "Get a Life",
		Description = "Sit for more than 5 hours.", 
		Value = 5 * 60
		}
	)
end )