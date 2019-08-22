
GtowerLangush = {}
local Lang = 1

local LangTable = {}
local LangNames = {}


function GtowerLangush.AddLang(id, FullName)

    LangTable[id] = {}

    LangNames[id] = FullName

end


function GtowerLangush.AddWord(id, key, word)

    LangTable[id][ key ] = word

end

function GtowerLangush.SetLocalLanguage( Id )

	if LangTable[Id] then -- If we have a translation for it
		Lang = Id
	else
		Lang = 1 -- Default , English
	end

end


function GetTranslation(Name, ...)

	local arg = {...}

    local str = LangTable[ Lang ][ Name ]

    if str == nil then
        str = LangTable[ 1 ][ Name ] -- look for english

        if str == nil then

            Msg("Error: Translation of '".. Name .."' not  found!")
            return ""

        end
    end

    if #arg > 0 then

		str = string.gsub( str, "{(%d+)}",
			function(s) return arg[ tonumber(s) ] or "{"..s.."}" end
		)

    end

    return str

end
T = GetTranslation

do //Keep it off the global scope
	local LangFiles = {"english"}--, "french"}
	for _, v in pairs( LangFiles ) do

		if SERVER then
			AddCSLuaFile(  v ..".lua" )
		end

		include(  v ..".lua" )

	end
end
