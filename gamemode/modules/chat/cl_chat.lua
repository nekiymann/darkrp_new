--[[---------------------------------------------------------------------------
Gamemode function
---------------------------------------------------------------------------]]
function GM:OnPlayerChat()
end

--[[---------------------------------------------------------------------------
Add a message to chat
---------------------------------------------------------------------------]]
local function AddToChat(bits)
    local col1 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))

    local prefixText = net.ReadString()
    local ply = net.ReadEntity()
    ply = IsValid(ply) and ply or LocalPlayer()

    if not IsValid(ply) then return end

    if prefixText == "" or not prefixText then
        prefixText = ply:Nick()
        prefixText = prefixText ~= "" and prefixText or ply:SteamName()
    end

    local col2 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))

    local text = net.ReadString()
    local shouldShow
    if text and text ~= "" then
        if IsValid(ply) then
            shouldShow = hook.Call("OnPlayerChat", GAMEMODE, ply, text, false, not ply:Alive(), prefixText, col1, col2)
        end

        if shouldShow ~= true then
            chat.AddNonParsedText(col1, prefixText, col2, ": " .. text)
        end
    else
        shouldShow = hook.Call("ChatText", GAMEMODE, "0", prefixText, prefixText, "darkrp")

        if shouldShow ~= true then
            chat.AddNonParsedText(col1, prefixText)
        end
    end
    chat.PlaySound()
end
net.Receive("DarkRP_Chat", AddToChat)



local function AddTalkChat(bits)
    -- ЧИТАЕМ БЛОК 1
    local col1 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
    local text1 = net.ReadString()

    -- ЧИТАЕМ БЛОК 2
    local col2 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
    local text2 = net.ReadString()

    -- ЧИТАЕМ БЛОК 3
    local col3 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
    local text3 = net.ReadString()

    -- ЧИТАЕМ БЛОК 4
    local col4 = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
    local text4 = net.ReadString()

    local ply = net.ReadEntity()

    local chatArgs = {}

    -- Сборка таблицы для chat.AddText
    if text1 and text1 ~= "" then
        table.insert(chatArgs, col1)
        table.insert(chatArgs, text1)
    end

    if text2 and text2 ~= "" then
        table.insert(chatArgs, col2)
        table.insert(chatArgs, text2)
    end

    if text3 and text3 ~= "" then
        table.insert(chatArgs, col3)
        table.insert(chatArgs, text3)
    end

    if text4 and text4 ~= "" then
        table.insert(chatArgs, col4)
        table.insert(chatArgs, text4)
    end

    if #chatArgs > 0 then
        chat.AddText(unpack(chatArgs))
    end
    
    chat.PlaySound()
end
net.Receive("DarkRP_talktochat", AddTalkChat)



local activeBroadcast = nil

net.Receive("MayorBroadcast", function()
    local text = net.ReadString()

    if IsValid(activeBroadcast) then activeBroadcast:Remove() end

    local w, h = ScrW(), ScrH()
    
    local pnl = vgui.Create("Panel")
    pnl:SetSize(w, PIXEL.Scale(40))
    pnl:SetPos(0, -PIXEL.Scale(40))
    
    pnl:MoveTo(0, 0, 0.5, 0, 0.2)
    
    pnl.Paint = function(s, w, h)
        surface.SetDrawColor(PIXEL.Colors.Header)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(de.colors.base)
        surface.DrawRect(0, h - 2, w, 2)
    end
    
    local lbl = vgui.Create("DLabel", pnl)
    lbl:SetText("ОПОВЕЩЕНИЕ МЭРА: " .. text)
    lbl:SetFont("defont40")
    lbl:SetTextColor(PIXEL.Colors.PrimaryText)
    lbl:SizeToContents()
    lbl:SetPos(w, (PIXEL.Scale(40) - lbl:GetTall()) / 2)
    
    local textWidth = lbl:GetWide()
    local endPos = -textWidth
    local speed = 100 
    local duration = (w + textWidth) / speed
    
    lbl:MoveTo(endPos, lbl.y, duration, 0, -1, function()
        if IsValid(pnl) then
            pnl:MoveTo(0, -PIXEL.Scale(40), 0.5, 0, -1, function()
                if IsValid(pnl) then pnl:Remove() end
            end)
        end
    end)
    
    surface.PlaySound("ambient/alarms/klaxon1.wav")
    
    activeBroadcast = pnl
end)