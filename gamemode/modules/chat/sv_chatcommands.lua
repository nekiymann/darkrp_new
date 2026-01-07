-- ==========================================
-- 1. ROLL
-- ==========================================
-- local function Roll(ply)

--     local result = math.random(10, 100)
    
--     local colorTag = Color(162, 106, 204)
--     local colorNick = team.GetColor(ply:Team()) 
--     local colorSep = Color(255, 255, 255)    
--     local colorMsg = Color(55, 86, 240)     

--     DarkRP.talkToChat(
--     ply,
--         colorTag, "ROLL | ",
--         colorNick, ply:Nick(),
--         colorSep, ": выбросил кубик с числом: ",
--         colorMsg, result,       
--     ply)
        
--     return "" 
-- end
-- DarkRP.defineChatCommand("roll", Roll, 1.5)


-- local function CoinFp(ply)
--     -- Генерируем число 1 или 2
--     local side = math.random(1, 2)
--     local result = ""

--     -- Превращаем число в текст
--     if side == 1 then
--         result = "Орёл"
--     else
--         result = "Решка"
--     end

--     local colorTag = Color(55, 206, 240)
--     local colorNick = team.GetColor(ply:Team()) 
--     local colorSep = Color(255, 255, 255)    
--     local colorMsg = Color(55, 86, 240)     

--             DarkRP.talkToChat(
--                 ply,
--                 colorTag, "COIN | ",
--                 colorNick, ply:Nick(),
--                 colorSep, ": подбросил монетку и выпало: ",
--                 colorMsg, result,
--                 ply
--             )  
    
--     return "" 
-- end


-- DarkRP.defineChatCommand("coinflip", CoinFp, 1.5)

-- ==========================================
-- 2. TRY
-- ==========================================

-- local function Try(ply, args)
--         if args == "" then
--             DarkRP.notify(ply, 1, 4, "Напишите действие! Пример: /try взломал дверь")
--             return ""
--         end

--         local action = args
--         local isSuccess = math.random(0, 1) == 1 
        
--         local resultText = ""
--         local resultColor = Color(255, 255, 255)

--         if isSuccess then
--             resultText = "[Удачно]"
--             resultColor = Color(50, 200, 50) -- Зеленый
--         else
--             resultText = "[Неудачно]"
--             resultColor = Color(200, 50, 50) -- Красный
--         end

--         local chatText = action .. " | " .. resultText
        

--         DarkRP.talkToChat(
--             ply,
--             -- 1. ТЕГ (с пробелом в конце)
--             Color(50, 200, 50), "TRY | ",
--             -- 2. НИК
--             team.GetColor(ply:Team()), ply:Nick(),
--             -- 3. РАЗДЕЛИТЕЛЬ (двоеточие и пробел)
--             color_white, ": " .. args .. " ",
--             -- 4. ТЕКСТ РЕКЛАМЫ
--             resultColor, resultText,
--             ply
--         )

        
--         return ""
-- end
-- DarkRP.defineChatCommand("try", Try, 1.5)


--     -- ==========================================
--     -- 3. DO 
--     -- ==========================================
-- local function Do(ply, args)
--     if args == "" then
--         DarkRP.notify(ply, 1, 4, "Напишите описание! Пример: /do На столе лежит паспорт.")
--         return ""
--     end


--     local colorTag = Color(255, 150, 0)
--     local colorNick = team.GetColor(ply:Team()) 
--     local colorSep = Color(255, 255, 255)    
--     local colorMsg = Color(55, 86, 240)     

--     DarkRP.talkToChat(
--     ply,
--         colorTag, "DO | ",
--         colorSep, args,
--         colorSep, ": ",
--         colorNick, ply:Nick(),       
--     ply)

--     return ""
-- end
-- DarkRP.defineChatCommand("do", Do, 1.5)

--[[---------------------------------------------------------
Talking
 ---------------------------------------------------------]]
-- local function PM(ply, args)
--     local namepos = string.find(args, " ")
--     if not namepos then
--         DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
--         return ""
--     end

--     local name = string.sub(args, 1, namepos - 1)
--     local msg = string.sub(args, namepos + 1)

--     if msg == "" then
--         DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
--         return ""
--     end

--     local target = DarkRP.findPlayer(name)
--     if target == ply then return "" end

--     if target then

--         local colorTag = Color(55, 86, 240)
--         local colorNick = team.GetColor(ply:Team()) 
--         local colorSep = Color(255, 255, 255)    
--         local colorMsg = color_white

--         DarkRP.talkToChat(
--         target,
--             colorTag, "ЛС | ",
--             colorNick, ply:Nick(),
--             colorSep, ": ",
--             colorMsg, msg,       
--         ply)
--         DarkRP.talkToChat(
--         ply,
--             colorTag, "ЛС | ",
--             colorNick, ply:Nick(),
--             colorSep, ": ",
--             colorMsg, msg,       
--         ply)    
--     else
--         DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(name)))
--     end

--     return ""
-- end
-- DarkRP.defineChatCommand("pm", PM, 1.5)

-- local function Me(ply, args)
--     if args == "" then
--         DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
--         return ""
--     end

--     local DoSay = function(text)
--         if text == "" then
--             DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
--             return ""
--         end
--         local colorTag = Color(4, 209, 83)
--         local colorNick = team.GetColor(ply:Team()) 
--         local colorSep = Color(255, 255, 255)    
--         local colorMsg = Color(143, 105, 97)     

--         DarkRP.talkToChat(
--         ply,
--             colorTag, "ME | ",
--             colorNick, ply:Nick(),
--             colorSep, ": ",
--             colorMsg, text,       
--         ply)

--     end
--     return args, DoSay
-- end
-- DarkRP.defineChatCommand("me", Me, 1.5)

util.AddNetworkString("MayorBroadcast")

local function MayorBroadcast(ply, args)
    if not ply:isMayor() then return "" end

    local text = args
    if type(args) == "table" then
        text = table.concat(args, " ")
    end

    if not text or string.len(text) < 5 then
        DarkRP.notify(ply, 1, 4, "Сообщение слишком короткое.")
        return ""
    end
    
    -- if ply.BroadcastCooldown and ply.BroadcastCooldown > CurTime() then
    --     DarkRP.notify(ply, 1, 4, "Подождите перед следующим эфиром.")
    --     return ""
    -- end

    -- ply.BroadcastCooldown = CurTime() + 60

    net.Start("MayorBroadcast")
        net.WriteString(text)
    net.Broadcast()

    return ""
end
DarkRP.defineChatCommand("broadcast", MayorBroadcast, 1.5)
DarkRP.defineChatCommand("bc", MayorBroadcast, 1.5)
DarkRP.defineChatCommand("bbc", MayorBroadcast, 1.5)

