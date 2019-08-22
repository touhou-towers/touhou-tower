----------------------------------------------------- module( "WebMat", package.seeall ) local DEBUG = CreateClientConVar( "webmat_debug", 0, false, false ) local List = {} local Downloading = {} local NumDownloading = 0 local NextUpdate = 0 local timeout = 5 local function Download() if NumDownloading < 1 then return end if NextUpdate > RealTime() then return end for i = 1, math.Clamp( #Downloading, 1, 2 ) do local uri = Downloading[ i ] local mat = List[ uri ] if !mat then continue end if (RealTime() - mat.time) < timeout or mat.html:IsLoading() then mat.html:UpdateHTMLTexture() mat.mat = mat.html:GetHTMLMaterial() else mat.html:UpdateHTMLTexture() mat.mat = mat.html:GetHTMLMaterial() mat.html:Remove() mat.html = nil mat.js = nil mat.time = nil mat.finished = true if isfunction( mat.callback ) then local status, err = pcall( mat.callback, mat.mat, uri ) if !status then print( "WebMat Callback Error:\n" .. tostring(err) ) end List[ uri ].callback = nil end table.remove( Downloading, i ) NumDownloading = NumDownloading - 1 end end NextUpdate = RealTime() + 0.1 end hook.Add( "Think", "DownloadWebMaterials", Download ) local function QueueDownload( uri ) if DEBUG:GetBool() then print( "WebMat: Downloading '" .. uri .. "'" ) end table.insert( Downloading, uri ) NumDownloading = NumDownloading + 1 end function IsDownloaded( uri ) return List[ uri ] and List[ uri ].finished or false end function Get( uri, callback, width, height ) if !isstring( uri ) then return end if !List[ uri ] then local html = vgui.Create( "DHTML" ) html:SetSize( width or 256, height or 256 ) html:SetPaintedManually( true ) html:SetKeyBoardInputEnabled( false ) html:SetMouseInputEnabled( false ) html:SetAllowLua( true ) html:OpenURL( uri ) html:UpdateHTMLTexture() html:AddFunction( "webmat", "GetSize", function( w, h ) --html:SetSize( w, h ) List[ uri ].w = w List[ uri ].h = h List[ uri ].time = List[ uri ].time - (timeout - 2) end ) html:QueueJavascript( [[ document.body.style.cssText = "margin: 0;overflow: hidden !important;"; var img = document.getElementsByTagName('img')[0]; webmat.GetSize( img.width, img.height ); ]] ) List[ uri ] = { html = html, js = true, time = RealTime(), w = width or 256, h = height or 256, mat = html:GetHTMLMaterial(), callback = callback } QueueDownload( uri ) elseif isfunction(callback) then if IsDownloaded( uri ) then local status, err = pcall( callback, GetMaterial( uri ), uri ) if !status then print( "WebMat Callback Error:\n" .. tostring(err) ) end else List[ uri ].callback = callback end end end function GetMaterial( uri ) return List[ uri ] and List[ uri ].mat or Material('error') end function GetSize( uri ) if List[ uri ] then return List[ uri ].w, List[ uri ].h end return 256, 256 end function Draw( uri, w, h ) local mat = GetMaterial( uri ) local mw, mh = GetSize( uri ) -- Fix for non-power-of-two html panel size w = ( w * math.CeilPower2(mw) ) / mw h = ( h * math.CeilPower2(mh) ) / mh surface.SetDrawColor( color_white ) surface.SetMaterial( mat ) surface.DrawTexturedRect( 0, 0, w, h ) end-----------------------------------------------------
module( "WebMat", package.seeall )



local DEBUG = CreateClientConVar( "webmat_debug", 0, false, false )



local List = {}

local Downloading = {}

local NumDownloading = 0

local NextUpdate = 0

local timeout = 5



local function Download()



	if NumDownloading < 1 then return end

	if NextUpdate > RealTime() then return end



	for i = 1, math.Clamp( #Downloading, 1, 2 ) do

		

		local uri = Downloading[ i ]

		local mat = List[ uri ]



		if !mat then continue end



		if (RealTime() - mat.time) < timeout or mat.html:IsLoading() then



			mat.html:UpdateHTMLTexture()

			mat.mat = mat.html:GetHTMLMaterial()



		else



			mat.html:UpdateHTMLTexture()

			mat.mat = mat.html:GetHTMLMaterial()



			mat.html:Remove()

			mat.html = nil

			mat.js = nil

			mat.time = nil

			mat.finished = true



			if isfunction( mat.callback ) then

				local status, err = pcall( mat.callback, mat.mat, uri )

				if !status then

					print( "WebMat Callback Error:\n" .. tostring(err) )

				end

				List[ uri ].callback = nil

			end



			table.remove( Downloading, i )

			NumDownloading = NumDownloading - 1



		end



	end



	NextUpdate = RealTime() + 0.1



end

hook.Add( "Think", "DownloadWebMaterials", Download )



local function QueueDownload( uri )



	if DEBUG:GetBool() then

		print( "WebMat: Downloading '" .. uri .. "'" )

	end

	

	table.insert( Downloading, uri )

	NumDownloading = NumDownloading + 1



end



function IsDownloaded( uri )

	return List[ uri ] and List[ uri ].finished or false

end



function Get( uri, callback, width, height )



	if !isstring( uri ) then return end



	if !List[ uri ] then

		

		local html = vgui.Create( "DHTML" )

		html:SetSize( width or 256, height or 256 )

		html:SetPaintedManually( true )

		html:SetKeyBoardInputEnabled( false )

		html:SetMouseInputEnabled( false )

		html:SetAllowLua( true )

		html:OpenURL( uri )



		html:UpdateHTMLTexture()



		html:AddFunction( "webmat", "GetSize", function( w, h )

			--html:SetSize( w, h )

			List[ uri ].w = w

			List[ uri ].h = h

			List[ uri ].time = List[ uri ].time - (timeout - 2)

		end )



		html:QueueJavascript( [[

			document.body.style.cssText = "margin: 0;overflow: hidden !important;";

			var img = document.getElementsByTagName('img')[0];

			webmat.GetSize( img.width, img.height );

		]] )



		List[ uri ] = {

			html = html,

			js = true,

			time = RealTime(),

			w = width or 256,

			h = height or 256,

			mat = html:GetHTMLMaterial(),

			callback = callback

		}



		QueueDownload( uri )



	elseif isfunction(callback) then



		if IsDownloaded( uri ) then

			local status, err = pcall( callback, GetMaterial( uri ), uri )

			if !status then

				print( "WebMat Callback Error:\n" .. tostring(err) )

			end

		else

			List[ uri ].callback = callback

		end



	end



end



function GetMaterial( uri )

	return List[ uri ] and List[ uri ].mat or Material('error')

end



function GetSize( uri )



	if List[ uri ] then

		return List[ uri ].w, List[ uri ].h

	end



	return 256, 256



end



function Draw( uri, w, h )



	local mat = GetMaterial( uri )

	local mw, mh = GetSize( uri )



	-- Fix for non-power-of-two html panel size

	w = ( w * math.CeilPower2(mw) ) / mw

	h = ( h * math.CeilPower2(mh) ) / mh



	surface.SetDrawColor( color_white )

	surface.SetMaterial( mat )

	surface.DrawTexturedRect( 0, 0, w, h )



end