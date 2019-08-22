

-----------------------------------------------------
module("time", package.seeall)

function IsNew( createdTime )
	if createdTime == 0 then return false end

	local currentTime = os.time()
    local elapsed = os.difftime(currentTime-createdTime)

    local futureTime = (60*60) * 24 * 15 -- 15 days in the future

    return elapsed < futureTime
end

function IsChristmas()
	local date = os.date( "*t" )
	return date.day >= 1 && date.month == 12
end

function IsNewYears()
	local date = os.date( "*t" )
	return date.day >= 30 && date.month == 12
end

function IsHalloween()
	local date = os.date( "*t" )
	return ( date.day >= 1 && date.month == 10 )-- or ( date.day >= 1 && date.day <= 20 && date.month == 11 )
end

function IsIndepedenceDay()
	local date = os.date( "*t" )
	return date.day >= 2 && date.day <= 5 && date.month == 7
end

function IsThanksgiving()
	local date = os.date( "*t" )
	return date.day >= 7 && date.day <= 28 && date.month == 11
end

function IsHoliday()
	return IsChristmas() || IsHalloween() || IsIndepedenceDay() || IsThanksgiving() || IsNewYears()
end

concommand.Add( "gmt_gettime", function()
	MsgN( os.time() )
end )
