
GtowerNPCChat = {}
GtowerNPCChat.MainChat = nil
GtowerNPCChat.OpenTime = 0

GtowerNPCChat.TalkingLady = nil
GtowerNPCChat.NPCMaxTalkDistance = 512

include("cl_question.lua")

/*
	tbl = {
		Text = "Hello.",
		Responses = {
			1 = {
				Response = "Hello.",
				Text = "How is it going?",
				Responses = {
					1 = {
						Response = "Fine.",
						data = "I Is Fine.",
						Func = function( data ) Msg( data ) end					
					},
					2 = {
						Response = "Bye."
					}
					3 = {
						data = nil
						Response = function(data) return "I don't like you" end
					}
			
			},
			2 = {
				Response = "Go Away."	
			}
		}	
	}
*/

function GtowerNPCChat:StartChat( tbl )

	if IsValid( GtowerNPCChat.MainChat ) then
		GtowerNPCChat.MainChat:DisperseSelf()
		GtowerNPCChat.MainChat = nil
	end
	
	GtowerNPCChat.TalkingLady = tbl.Entity
	GtowerNPCChat.NPCMaxTalkDistance = tbl.NPCMaxTalkDistance or 512
	
	GtowerNPCChat.MainChat = vgui.Create("GtowerChatQuestion")
	GtowerNPCChat.MainChat:SetupQuestion( tbl )
	GtowerNPCChat.MainChat:SetVisible( true )	
	
	GtowerMainGui:GtowerShowMenus()
	
	GtowerNPCChat.OpenTime = SysTime()
	
end


function GtowerNPCChat:CloseChat()
	if IsValid( GtowerNPCChat.MainChat ) then
		GtowerNPCChat.MainChat:DisperseSelf()
	end
	
	GtowerNPCChat.MainChat = nil
	
	GtowerMainGui:GtowerHideMenus()
	
end

function GtowerNPCChat:Test()

	GtowerNPCChat:StartChat( {
		Text = "Hello!? This is an extremely lenght string that i need to check if garry is cliiping it right. No questions asked.",
		Responses = {
			{
				Response = "Answer #1.",
				Text = "I love cheese and you know it.",
				Responses = {
					{
						Response = "Another response",
					},
					{
						Response = "A third one response",
					}
				}
			},
			{
				Response = "Answer #2.",
			},
			{
				Response = "Answer #3.",
			}		
		}

	} )

end