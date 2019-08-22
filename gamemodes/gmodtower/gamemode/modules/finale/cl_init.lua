
surface.CreateFont( "MonospacedTimer", {
	font = "Monospace",
	size = 144,
	weight = 500,
	antialias = true,
	additive = false
} )

net.Receive("gmt_killgmtc",function()

// BPM of the countdown song, in our case 135.
local SongBPM = 135

// Site to display after booomm.
local FinalSiteURL = "http://74.91.116.176/finale/"

// How long should the countdown last for?
local CountDownTime = (4*60)+29 -- 4:29

local CountDownEnd = CurTime() + CountDownTime

local BlinkDot = false

timer.Create("BlinkDots",0.5,0,function()
  BlinkDot = !BlinkDot
end)

// Refurbished AFK timer.
local function AfkTimerThink()



	if !ValidPanel( DermaPanel ) then return end



	local TimeLeft = CountDownEnd - CurTime()
	local Sine = math.sin( math.fmod( TimeLeft, 1 ) * math.pi ) * 200

  local timestring = string.FormattedTime( TimeLeft, "%02i:%02i.%02i" )

  if !BlinkDot then
    timestring = string.FormattedTime( TimeLeft, "%02i %02i %02i" )
  end

  // Stay at 00:00.00 when we reach the end.
  if TimeLeft < 0 and !BlinkDot then
    timestring = ""
  elseif TimeLeft < 0 then
    timestring = "00:00.00"
  end

	DermaPanel.WarningLabel:SetColor( Color( 255, 0, 0, 255 ) )

	DermaPanel.WarningLabel:SetText( timestring )



	DermaPanel.WarningLabel:SizeToContents()

	DermaPanel.WarningLabel:Center()


  // Background gray numbers.
  DermaPanel.WarningLabel2:SetColor( Color( 25,25,25,125 ) )
  DermaPanel.WarningLabel2:SetText( "88:88.88" )

  DermaPanel.WarningLabel2:SizeToContents()
  DermaPanel.WarningLabel2:Center()



end



local function AfkTimerPaint( panel )


	local TimeLeft = CountDownEnd - CurTime()
	local W, H = panel:GetSize()


  // Used to calculate the bar width to match the time of the countdown.
  local BarTimeLeft = math.Clamp( ( ( CountDownEnd or 0 ) - CurTime() ) / CountDownTime , 0, 1 )

	local BarWidth = BarTimeLeft * W


  // A "percentage" of how far the bar is, but up to 255% so we can use it for RGB manipulation.
  local Percentage = (CountDownTime-TimeLeft) / CountDownTime * 255

  // Actual lenght of the beats per second, times 2.5 to compensate for sinus and pi.
  local beat_length = 60/SongBPM*2.5

  local bpmwave = math.sin(CurTime() * beat_length * 2 * math.pi)

  // Invert the number under 0 so we basically have a cosine wave and can keep up with the song.
  if bpmwave < 0 then
    bpmwave = -bpmwave
  end

	surface.SetDrawColor( 25,25,25,125 )

	surface.DrawRect( 0, 0, W, H )


  // Red starts at 0 which gets the percentage added on top, meanwhile it retracts from green's 255 value.
  // This makes the timer turn from green to red depending on how much time is left.
	surface.SetDrawColor( 0 + Percentage, 255 - Percentage, 0, math.Clamp(255 - bpmwave*255,50,255) )

	surface.DrawRect( 0, 0, W - BarWidth, H )



end


local function RemoveWarning()



	if ValidPanel( DermaPanel ) then

		DermaPanel:Remove()

	end



end


local function CreateWarning()



	RemoveWarning()



	DermaPanel = vgui.Create("DPanel")


  DermaPanel.WarningLabel2 = Label( "88:88.88", DermaPanel )
  DermaPanel.WarningLabel2:SetFont( "MonospacedTimer" )

	DermaPanel.WarningLabel = Label( T("AfkTimer", 30.0), DermaPanel )

	DermaPanel.WarningLabel:SetFont( "MonospacedTimer" )

	DermaPanel:SetMouseInputEnabled( false )

	DermaPanel:SetKeyBoardInputEnabled( false )



	DermaPanel.Think = AfkTimerThink

	DermaPanel.Paint = AfkTimerPaint



	AfkTimerThink()



	DermaPanel:SetAlpha( 200 )

	DermaPanel:SetSize( DermaPanel.WarningLabel:GetWide() * 1.5, DermaPanel.WarningLabel:GetTall() * 1.25 )

	DermaPanel:CenterVertical( 0.1 )

	DermaPanel:CenterHorizontal( 0.5 )



	AfkTimerThink()



end


// Function to replace single characters in strings.
local function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

// Random characters for the Skymsg glitch effect.
local manglebet = {
	"q","$","%","^","&","*","d","g","j","l","x","v","n",
  "1","2","3","4","5","6","7","8","9","0","!","@","#",
  "[","]","-","=","/","<",">"
}

local NextThink = 0

CreateWarning()

local BloomActive = false
local SiteUp = false

// Plays our song.
sound.PlayURL ( "https://dl.dropbox.com/s/6iqokg9y4j6z2cj/Untitled.mp3", "", function( station )
	station:Play()
end )

hook.Add("Think","GMTCountDownThink",function()

  local TimeLeft = CountDownEnd - CurTime()

  // Bloom-fades the screen after 5 seconds left on the clock.
  if TimeLeft < 5 and !BloomActive then
    BloomActive = true
    local layer = postman.NewColorLayer()

	 layer.addr = -0.1

	 layer.addg = -0.1

	 layer.addb = 0.25

	 layer.mulr = 0.2

	 layer.mulg = 0.2

	 layer.mulb = 0.2

	 layer.color = 0.1

	 layer.contrast = 1.1

	 layer.brightness = 0.1

  postman.FadeColorIn( "countdown_layer", layer, 5 )



	 layer = postman.NewBloomLayer()

	 layer.sizex = 10

	 layer.sizey = 10

	 layer.multiply = 1
	 layer.color = 0.2

	 layer.passes = 2

	 postman.FadeBloomIn( "countdown_layer", layer, 5 )

  end

  // Opens the finale site 3 seconds after the timer ended.
  if TimeLeft < -3 and !SiteUp then
    SiteUp = true

  	Donation = vgui.Create("DFrame")
  	Donation:SetSize(ScrW(), ScrH())
  	Donation:Center()
  	Donation:SetDraggable(false)
  	Donation:MakePopup()
  	Donation:SetTitle("Thank you for playing...")

  	Donation.btnMaxim:Hide()
  	Donation.btnMinim:Hide()
  	Donation.Paint = function(self, w, h)
  	draw.RoundedBox(0,0,0,w,h,Color(0,80,161))
  	draw.RoundedBox(0,0,0,w,25,Color(0,65,129))
  	end

  	local OpenDonation = vgui.Create("DHTML", Donation)
  	OpenDonation:Center()
  	OpenDonation:Dock( FILL )
  	function OpenDonation:ConsoleMessage( msg ) end

  	local ctrls = vgui.Create( "DHTMLControls", Donation ) -- Navigation controls
  	ctrls:SetWide( 750 )
  	ctrls:SetPos( 0, -50 )
  	ctrls:SetHTML( OpenDonation ) -- Links the controls to the DHTML window
  	ctrls.AddressBar:SetText(FinalSiteURL) -- Address bar isn't updated automatically
  	OpenDonation:MoveBelow( ctrls ) -- Align the window to sit below the controls
  	OpenDonation:OpenURL(FinalSiteURL)
  end

  // Makes our text glitch faster the closer the timer is to 0.
  if CurTime() < NextThink then return end
  NextThink = CurTime() + (TimeLeft/CountDownTime*1)/2

  local DefaultText = {}

  for k,v in pairs( ents.FindByClass("gmt_skymsg") ) do
    DefaultText[v] = tostring(v:GetNWString("DefaultText"))
  end

  // This glitches our text, the faster you call it, the more it get's glitched.
  for k,v in pairs( ents.FindByClass("gmt_skymsg") ) do
    if v.StrText == "" or v.StrText == nil then return end
    local num = math.random( 1, string.len(v.StrText) )
    v.StrText = replace_char( num , v.StrText, manglebet[ math.random(1, #manglebet ) ] )
    if TimeLeft < 5 then continue end
    timer.Simple(0.05,function()
      v.StrText = replace_char( num , v.StrText, string.sub(tostring(DefaultText[v]),num,num) )
    end)
  end

end)

// Default crap.
local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 1,
	["$pp_colour_mulg"] = 1,
	["$pp_colour_mulb"] = 1
}

hook.Add("RenderScreenspaceEffects", "CountDownScreenEffects", function()local pl = LocalPlayer()
	local maxtime = CountDownTime
	local time = CountDownEnd - CurTime()

  // Number that goes from 1 to 0 depending on how much time is left, using this
  // as the RGB values of the screen, making it fade to black and white.
	local mul = math.Clamp(time/maxtime*1,0,1)

	tab["$pp_colour_colour"] = mul
  tab["$pp_colour_mulr"] = mul
  tab["$pp_colour_mulg"] = mul
  tab["$pp_colour_mulb"] = mul

  // On the last moment, cut out the contrast completely, thus making your screen black.
  if time < 0.1 then
    tab["$pp_colour_contrast"] = 0
  end

	DrawColorModify(tab)
end)

end)
