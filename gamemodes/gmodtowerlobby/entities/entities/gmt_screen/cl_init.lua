local tdui = include("tdui.lua")
local p = tdui.Create()

include("shared.lua")

surface.CreateFont( "OswaldSmall", {
	font = "Oswald",
	size = 64,
	weight = 100,
	antialias = true,
} )
surface.CreateFont( "OswaldNormal", {
	font = "Oswald",
	size = 76,
	weight = 300,
	antialias = true,
} )
surface.CreateFont( "ArialSmall", {
	font = "Arial Rounded MT Bold",
	size = 32,
	weight = 100,
	antialias = true,
} )
surface.CreateFont( "ArialNormal", {
	font = "Arial Rounded MT Bold",
	size = 38,
	weight = 200,
	antialias = true,
} )

local Colors = {

  ["Red"]=Color(125,25,25,250),
  ["Green"]=Color(25,75,25,250),
  ["Blue"]=Color(25,50,100,250),
  ["Black"]=Color(25,25,25,250),
  ["White"]=Color(255,255,255,255),

}

function ENT:Initialize()
  timer.Simple(2,function()
    self.SafeLoaded = true --If we don't do this it will load network vars without them being loaded in time.
  end)
	timer.Create("RetrieveUpdates",1,0,function()
		UpperTitle = self:GetNWString("UpperText")
		CenterText = self:GetNWString("CenterText")
		UnderTitle = self:GetNWString("UnderText")
		TextColorUpper = Colors[self:GetNWString("UpperColor")]
		BackgroundColor = Colors[self:GetNWString("BGColor")]
		TextColorCenter = Colors[self:GetNWString("CenterColor")]
		FontUpper = self:GetNWString("UpperFont")
		FontCenter = self:GetNWString("CenterFont")
	end)
end

function ENT:Draw()

  self:DrawModel()

	local dx = Vector(-42.5,66,2) -- position offset
	local da = Angle(0,0,0) -- angle offset
	local scale = 0.25 -- scale
	if (LocalPlayer():GetPos():Distance(self:GetPos()) > 1880) then return end
	cam.Start3D2D(self:LocalToWorld(dx), self:LocalToWorldAngles(da), scale)
		if !self.SafeLoaded then
			surface.SetDrawColor(Color(25,25,25,250))
			surface.DrawRect(0,0,85/scale,100/scale)
			draw.DrawText("WELCOME","OswaldNormal",42.5/scale,0,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Loading...","ArialNormal",42.5/scale,100/scale/2,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Please Wait","ArialSmall",42.5/scale,350,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		else
			surface.SetDrawColor(BackgroundColor)
			surface.DrawRect(0,0,85/scale,100/scale)
    	draw.DrawText(UpperTitle,FontUpper,42.5/scale,0,TextColorUpper,TEXT_ALIGN_CENTER)
    	draw.DrawText(CenterText,FontCenter,42.5/scale,100/scale/2,TextColorCenter,TEXT_ALIGN_CENTER)
    	draw.DrawText(UnderTitle,"ArialSmall",42.5/scale,350,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end

	cam.End3D2D()

	  if !self.SafeLoaded then return end

      if bDrawingDepth then return end

      local dx = Vector(0,25,-2) -- position offset
      local da = Angle(-90,-90,0) -- angle offset
      local scale = 0.1 -- scale

      p:Cursor()

      p:Rect(-120, 88.5, 240, 45, Color(25, 25, 25,200), Color(25, 25, 25))

      p:Text("Control Panel", "!Roboto@75", 0, 10)

      if self:GetNWBool("Unlocked") then
        p:Text("UNLOCKED", "!Roboto@50", 0, 85)
        p:Text("Welcome, "..self:GetNWString("CurUser").."!", "!Roboto@25", 0, 140)
        if self:GetNWInt("CurPage") >= 1 and self:GetNWInt("CurPage") <= 3 then
        p:Text("Page "..self:GetNWInt("CurPage").." of 3", "!Roboto@25", 0, 550)
        end

        if p:Button("HOME", "DermaLarge", 25, 175, 175, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
						net.Start("OpenPage")
            net.WriteEntity(self)
						net.WriteFloat(1)
            net.SendToServer()
        end

				if p:Button("LOCK", "DermaLarge", -200, 175, 175, 50) then
						if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
						net.Start("LockPanel")
						net.WriteEntity(self)
						net.WriteBool(true)
						net.SendToServer()
				end

        if self:GetNWInt("CurPage") == 1 then

        if p:Button("SET UPPER TITLE", "DermaLarge", -200, 275, 400, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            Derma_StringRequest(
            	"GMTC Screen",
            	"Type your text for the upper title.",
            	"",
            	function( text )
                net.Start("SetTextUpper")
                net.WriteEntity(self)
                net.WriteString(text)
                net.SendToServer()
              end,
            	function( text )
                net.Start("SetTextUpper")
                net.WriteEntity(self)
                net.WriteString(" ")
                net.SendToServer()
              end,
              "Set Text",
              "Make Empty"
             )
        end

        if p:Button("SET CENTER TEXT", "DermaLarge", -200, 375, 400, 50) then
          if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
          Derma_StringRequest(
            "GMTC Screen",
            "Type your text for the upper title.",
            "",
            function( text )
              net.Start("SetTextCenter")
              net.WriteEntity(self)
              net.WriteString(text)
              net.SendToServer()
            end,
            function( text )
              net.Start("SetTextCenter")
              net.WriteEntity(self)
              net.WriteString(" ")
              net.SendToServer()
            end,
            "Set Text",
            "Make Empty"
           )
        end

        if p:Button("SET UNDER TITLE", "DermaLarge", -200, 475, 400, 50) then
          if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
          Derma_StringRequest(
            "GMTC Screen",
            "Type your text for the upper title.",
            "",
            function( text )
              net.Start("SetTextUnder")
              net.WriteEntity(self)
              net.WriteString(text)
              net.SendToServer()
            end,
            function( text )
              net.Start("SetTextUnder")
              net.WriteEntity(self)
              net.WriteString(" ")
              net.SendToServer()
            end,
            "Set Text",
            "Make Empty"
           )
        end

        if p:Button(">", "DermaLarge", 225, 275, 25, 250) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            net.Start("NextPage")
            net.WriteEntity(self)
            net.SendToServer()
        end

        elseif self:GetNWInt("CurPage") == 2 then

          if p:Button(">", "DermaLarge", 225, 275, 25, 250) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("NextPage")
              net.WriteEntity(self)
              net.SendToServer()
          end

          if p:Button("UPPER TEXT COLOR", "DermaLarge", -200, 275, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("OpenPage")
              net.WriteEntity(self)
              net.WriteFloat(6)
              net.SendToServer()
          end

          if p:Button("CENTER TEXT COLOR", "DermaLarge", -200, 375, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("OpenPage")
              net.WriteEntity(self)
              net.WriteFloat(5)
              net.SendToServer()
          end

          if p:Button("BACKGROUND COLOR", "DermaLarge", -200, 475, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("OpenPage")
              net.WriteEntity(self)
              net.WriteFloat(4)
              net.SendToServer()
          end

          if p:Button("<", "DermaLarge", -250, 275, 25, 250) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("PrevPage")
              net.WriteEntity(self)
              net.SendToServer()
          end

        elseif self:GetNWInt("CurPage") == 3 then

          if p:Button("<", "DermaLarge", -250, 275, 25, 250) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("PrevPage")
              net.WriteEntity(self)
              net.SendToServer()
          end

          if p:Button("UPPER TEXT FONT", "DermaLarge", -200, 275, 400, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            net.Start("OpenPage")
            net.WriteEntity(self)
            net.WriteFloat(8)
            net.SendToServer()
          end

          if p:Button("CENTER TEXT FONT", "DermaLarge", -200, 375, 400, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            net.Start("OpenPage")
            net.WriteEntity(self)
            net.WriteFloat(7)
            net.SendToServer()
          end

          if p:Button("START COUNTDOWN", "DermaLarge", -200, 475, 400, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            Derma_StringRequest(
              "GMTC Screen",
              "Please enter the number of minutes to count down to.",
              "",
              function( text )
								Derma_StringRequest(
									"GMTC Screen",
									"What text should the screen display when it finishes?",
									"",
									function( text2 )
										net.Start("StartCountdown")
										net.WriteEntity(self)
										net.WriteFloat(tonumber(text))
										net.WriteString(text2)
										net.SendToServer()
									end,
									function( text )
									end,
									"Set Text"
								 )
              end,
              function( text )
              end,
              "Set Time"
             )
          end

        elseif self:GetNWInt("CurPage") == 4 then

          if p:Button("RED", "DermaLarge", -200, 275, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Red")
							net.WriteFloat(1)
              net.SendToServer()
          end

          if p:Button("GREEN", "DermaLarge", -200, 375, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Green")
							net.WriteFloat(1)
              net.SendToServer()
          end

          if p:Button("BLUE", "DermaLarge", -200, 475, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Blue")
							net.WriteFloat(1)
              net.SendToServer()
          end

          if p:Button("BLACK", "DermaLarge", -200, 575, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Black")
							net.WriteFloat(1)
              net.SendToServer()
          end

        elseif self:GetNWInt("CurPage") == 5 then

          if p:Button("RED", "DermaLarge", -200, 275, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Red")
							net.WriteFloat(2)
              net.SendToServer()
          end

          if p:Button("GREEN", "DermaLarge", -200, 375, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Green")
							net.WriteFloat(2)
              net.SendToServer()
          end

          if p:Button("BLUE", "DermaLarge", -200, 475, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Blue")
							net.WriteFloat(2)
              net.SendToServer()
          end

          if p:Button("WHITE", "DermaLarge", -200, 575, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("White")
							net.WriteFloat(2)
              net.SendToServer()
          end

        elseif self:GetNWInt("CurPage") == 6 then

          if p:Button("RED", "DermaLarge", -200, 275, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Red")
							net.WriteFloat(3)
              net.SendToServer()
          end

          if p:Button("GREEN", "DermaLarge", -200, 375, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Green")
							net.WriteFloat(3)
              net.SendToServer()
          end

          if p:Button("BLUE", "DermaLarge", -200, 475, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("Blue")
							net.WriteFloat(3)
              net.SendToServer()
          end

          if p:Button("WHITE", "DermaLarge", -200, 575, 400, 50) then
              if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
              net.Start("SetColor")
              net.WriteEntity(self)
              net.WriteString("White")
							net.WriteFloat(3)
              net.SendToServer()
          end
          elseif self:GetNWInt("CurPage") == 7 then

              if p:Button("ARIAL BOLD", "DermaLarge", -200, 275, 400, 50) then
                  if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
                  net.Start("SetFontCenter")
                  net.WriteEntity(self)
                  net.WriteString("ArialNormal")
                  net.SendToServer()
              end

              if p:Button("OSWALD", "DermaLarge", -200, 375, 400, 50) then
                if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
                net.Start("SetFontCenter")
                net.WriteEntity(self)
                net.WriteString("OswaldNormal")
                net.SendToServer()
              end
            elseif self:GetNWInt("CurPage") == 8 then

                if p:Button("ARIAL BOLD", "DermaLarge", -200, 275, 400, 50) then
                    if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
                    net.Start("SetFontUpper")
                    net.WriteEntity(self)
                    net.WriteString("ArialNormal")
                    net.SendToServer()
                end

                if p:Button("OSWALD", "DermaLarge", -200, 375, 400, 50) then
                  if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
                  net.Start("SetFontUpper")
                  net.WriteEntity(self)
                  net.WriteString("OswaldNormal")
                  net.SendToServer()
                end

      end

      else
        p:Text("LOCKED", "!Roboto@50", 0, 85)

        if p:Button("UNLOCK", "DermaLarge", -100, 175, 200, 50) then
            if !LocalPlayer():IsAdmin() then self:UiSound("buttons/weapon_cant_buy.wav",true) return else self:UiSound("ui/buttonclick.wav",false) end
            net.Start("LockPanel")
            net.WriteEntity(self)
						net.WriteBool(false)
            net.SendToServer()
						net.Start("SetCurUser")
						net.WriteEntity(self)
						net.WriteString(LocalPlayer():Name())
						net.SendToServer()
        end

      end

      p:Render(self:LocalToWorld(dx), self:LocalToWorldAngles(da), scale)

end

function ENT:UiSound(snd, LocalSnd)
  if self.SoundWait then return end
  self.SoundWait = true
  timer.Simple(0.5,function()
    self.SoundWait = false
  end)
  if !LocalSnd then
    self:EmitSound(snd,75)
  else
    surface.PlaySound(snd)
  end
end

function ENT:OnRemove()
    if timer.Exists("RetrieveUpdates") then
			timer.Destroy("RetrieveUpdates")
		end
end
