
local GTowerSound = {}
GTowerSound.SoundPath = "../sound"
GTowerSound.SoundFile = ""
GTowerSound.PageNum = 0
GTowerSound.SoundPlaying = {}

GTowerSound.AllowSound = CreateClientConVar("gmt_AllowSoundSpam", 2, true, false)

function GTowerSound:ShowList()

	if self.browser then self:Clear() end
	
	self.browser = {}
	self.browser.Panel = vgui.Create("DFrame")
	self.browser.Panel:SetPos(100, 100)
	self.browser.Panel:SetSize(350, 400)
	self.browser.Panel:SetTitle("Sound Browser")
	self.browser.Panel:SetVisible(true)
	self.browser.Panel:SetDraggable(true)
	self.browser.Panel:ShowCloseButton(true)
	self.browser.Panel:SetDeleteOnClose(true)
	self.browser.Panel:MakePopup()
	
	self.browser.Text = vgui.Create("DTextEntry", self.browser.Panel)
	self.browser.Text:SetPos(50, 30)
	self.browser.Text:SetSize(225, 20)
	self.browser.Text:SetEditable(false)
	
	self.browser.BackButton = vgui.Create("DSysButton", self.browser.Panel)
	self.browser.BackButton:SetPos(20, 25)
	self.browser.BackButton:SetSize(25, 25)
	self.browser.BackButton:SetType("left")
	self.browser.BackButton.DoClick = function()
		local backDir = string.Explode("/", self.SoundPath)
		if #backDir <= 2 then return end
		
		table.remove(backDir, #backDir)
		self.SoundPath = string.Implode("/", backDir)
		
		self:UpdateList(self.SoundPath) --Goes back a folder
	end
	
	self.browser.BackButton = vgui.Create("DSysButton", self.browser.Panel)
	self.browser.BackButton:SetPos(self.browser.Text:GetWide() + 60, 25)
	self.browser.BackButton:SetSize(25, 25)
	self.browser.BackButton:SetType("left")
	self.browser.BackButton.DoClick = function()
		if self.PageNum <= 0 then return end 
		self.PageNum = self.PageNum - 1
		self:UpdateList(self.SoundPath)
	end
	
	self.browser.BackButton = vgui.Create("DSysButton", self.browser.Panel)
	self.browser.BackButton:SetPos(self.browser.Text:GetWide() + 85, 25)
	self.browser.BackButton:SetSize(25, 25)
	self.browser.BackButton:SetType("right")
	self.browser.BackButton.DoClick = function()
		if self.PageNum >= self:PageNums() - 1 then return end
		self.PageNum = self.PageNum + 1
		self:UpdateList(self.SoundPath)
	end

	self.browser.PlayButton = vgui.Create("DButton", self.browser.Panel)
	self.browser.PlayButton:SetText("Play")
	self.browser.PlayButton:SetPos(20, self.browser.Panel:GetTall() - 35)
	self.browser.PlayButton:SetSize(50, 25)
	self.browser.PlayButton.DoClick = function ()
		self:Play(self.SoundFile, tonumber(self.browser.Pitch:GetValue()))
	end
	
	self.browser.PlayButton = vgui.Create("DButton", self.browser.Panel)
	self.browser.PlayButton:SetText("SPAM!!")
	self.browser.PlayButton:SetPos(80, self.browser.Panel:GetTall() - 35)
	self.browser.PlayButton:SetSize(50, 25)
	self.browser.PlayButton.DoClick = function ()
		RunConsoleCommand("gmt_emitsound", self.SoundFile, self.browser.Volume:GetValue() or 100, self.browser.Pitch:GetValue() or 100)
	end

	self.browser.Volume = vgui.Create("DTextEntry", self.browser.Panel)
	self.browser.Volume:SetPos(140, self.browser.Panel:GetTall() - 35)
	self.browser.Volume:SetSize(25, 25)
	self.browser.Volume:SetValue(100)
	self.browser.Volume:SetEnterAllowed(true)
	self.browser.Volume:SetEditable(true)
	
	self.browser.VolumeL = vgui.Create("Label", self.browser.Panel)
	self.browser.VolumeL:SetPos(140, self.browser.Panel:GetTall() - 55)
	self.browser.VolumeL:SetText("Volume")
	
	self.browser.Pitch = vgui.Create("DTextEntry", self.browser.Panel)
	self.browser.Pitch:SetPos(180, self.browser.Panel:GetTall() - 35)
	self.browser.Pitch:SetSize(25, 25)
	self.browser.Pitch:SetValue(100)
	self.browser.Pitch:SetEnterAllowed(true)
	self.browser.Pitch:SetEditable(true)
	
	self.browser.PitchL = vgui.Create("Label", self.browser.Panel)
	self.browser.PitchL:SetPos(180, self.browser.Panel:GetTall() - 55)
	self.browser.PitchL:SetText("Pitch")
	
	self.browser.CopyButton = vgui.Create("DButton", self.browser.Panel)
	self.browser.CopyButton:SetText("Set to Clipboard")
	self.browser.CopyButton:SetPos(240, self.browser.Panel:GetTall() - 35)
	self.browser.CopyButton:SetSize(100, 25)
	self.browser.CopyButton.DoClick = function ()
		SetClipboardText("gmt_emitsound \"" .. self.SoundFile .. "\" " .. self.browser.Volume:GetValue() .. " " .. self.browser.Pitch:GetValue())
	end
	
	self.browser.ListView = vgui.Create("DListView", self.browser.Panel)
	self.browser.ListView:SetPos(25, 50)
	self.browser.ListView:SetSize(self.browser.Panel:GetWide() - 50, self.browser.Panel:GetTall() - 100)
	self.browser.ListView:SetMultiSelect(false)
	self.browser.ListView:AddColumn("Sound")
	self.browser.ListView.OnClickLine = function(parent, line, isselected)
		local soundFile = line:GetValue(1)
		if self:IsFile( soundFile) then 
			if self.SoundFile !=  soundFile then self.SoundFile = string.gsub(self.SoundPath, "../sound/", "") .. "/" .. soundFile print(self.SoundFile) end
			return 
		end
		
		self.SoundPath = self.SoundPath .. "/" .. line:GetValue(1)
		self:UpdateList(self.SoundPath)
	end

	self:UpdateList(self.SoundPath)
	
end

concommand.Add("gmt_SoundBrowser", function(ply, cmd, args) 
		GTowerSound:ShowList()
	end)

function GTowerSound:IsFile(fileName)
	return table.HasValue({"wav", "mp3"}, string.GetExtensionFromFileName(fileName))
end

function GTowerSound:Play(soundPath, pitch)

	if !soundPath or !pitch then return end

	LocalPlayer():EmitSound(Sound(soundPath), 100, math.Clamp(pitch, 50, 255)) 

end

function GTowerSound:Stop()
	--if timer.Exists("SoundBrowser") then timer.Remove("SoundBrowser") end
	RunConsoleCommand("stopsounds")
end

function GTowerSound:UpdateList(dir)
	self.FileList = self:CreateList(dir)
	self.browser.ListView:Clear()
	
	if self.browser.Text then self.browser.Text:SetValue(dir) end
	
	if self.browser.ListView then
		local tbl = self:SetPage(self.PageNum)
		
		for _, v in pairs(tbl) do
			self.browser.ListView:AddLine(v)
		end
	end
end

function GTowerSound:Clear()
	self.SoundPath = "../sound"
	self.SoundFile = ""
	self.PageNum = 0
	if self.brower then self.browser.Panel:Close() end
	self.browser = nil
	self.FileList = nil
end
concommand.Add("gmt_ClearSoundBrowser", function(ply, cmd, args)
		GTowerSound:Clear()
	end)
	
function GTowerSound:CreateList(dir)
	local fileList = file.FindDir(dir .. "/*")
	
	for _, v in ipairs(file.Find(dir .. "/*")) do
		if self:IsFile(v) then table.insert(fileList, v) end
	end
	
	return fileList
end

function GTowerSound:SetPage(num)
	local tbl = {}
	
	for i = 0, 1000 do
		tbl[i] = self.FileList[i + (1000 * num)]
	end
	
	return tbl
end

function GTowerSound:PageNums()
	return math.ceil(#self.FileList / 1000)
end

usermessage.Hook("GMTSoundPlay", function(um)
		
		--if GTowerSound.AllowSound:GetInt() == 1 then GTowerSound.SoundPlaying = true end
		
		if GTowerSound.AllowSound:GetInt() <= 0 then return end
		
		local info = {}
		info.Ent = um:ReadEntity()
		info.Sound = Sound(um:ReadString())
		info.Volume = um:ReadShort()
		info.Pitch = um:ReadShort()
		
		if !IsValid(info.Ent) then return end
		
		if GTowerSound.AllowSound:GetInt() == 1 then
			if table.HasValue(GTowerSound.SoundPlaying, info.Ent:EntIndex()) then return end
			table.insert(GTowerSound.SoundPlaying, info.Ent:EntIndex())
		end
		
		info.Ent:EmitSound(info.Sound, info.Volume, info.Pitch)
		
		
		if GTowerSound.SoundPlaying then 
			local soundTime = math.ceil(SoundDuration(info.Sound) / (info.Pitch / 100))
			
			--Removes the entity from the list.
			timer.Simple(soundTime, function()
				for i, v in ipairs(GTowerSound.SoundPlaying) do
					if v == info.Ent:EntIndex() then
						table.remove(GTowerSound.SoundPlaying, i)
					end
				end
			end) 
		end

	end)
	
function ClearSoundList()
	table.Empty(GTowerSound.SoundPlaying)
end