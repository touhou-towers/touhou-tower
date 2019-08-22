
GTowerIcons = {}

if CLIENT then
	GTowerIcons.Icons = {}
end

function GTowerIcons:AddIcon(fileName, Name, width, height, actw, acth )

	if SERVER then return end

    local tbl = {}

    tbl.Name = Name
	tbl.fileplace = 'icons/' .. fileName
    tbl.img = surface.GetTextureID( tbl.fileplace )
    tbl.x = width
    tbl.y = height
	tbl.actx = actw or width
	tbl.acty = acth or height

    self.Icons[ Name ] = tbl
end


GTowerIcons:AddIcon('playermenu_icons_pm', 'pm',         25, 25)
GTowerIcons:AddIcon('playermenu_icons_trade', 'trade',       25, 25 )
GTowerIcons:AddIcon('playermenu_icons_information', 'information',    25, 25 )
GTowerIcons:AddIcon('playermenu_icons_group', 'group',      24, 24 )
GTowerIcons:AddIcon('playermenu_icons_admin', 'admin',      25, 25 )

GTowerIcons:AddIcon('X_close', 'X_close',  16,  16, 8, 10 )

GTowerIcons:AddIcon('checkmark', 'checkmark',  16,  16, 16, 16 )
GTowerIcons:AddIcon('cancel', 'cancel',  16,  16 , 16, 16 )

GTowerIcons:AddIcon('big_arrow_down', 'big_arrow_down',  64, 64 )
GTowerIcons:AddIcon('big_arrow_up', 'big_arrow_up',  64, 64 )