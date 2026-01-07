local Laws = {}
local function addLaw(inLaw)
    local law = DarkRP.textWrap(inLaw, "Roboto20", 522)

    local lawNumber = table.insert(Laws, law)
    hook.Run("addLaw", lawNumber, inLaw)
end

local function umAddLaw(um)
    local law = um:ReadString()
    timer.Simple(0, fn.Curry(addLaw, 2)(law))
end
usermessage.Hook("DRP_AddLaw", umAddLaw)

local function umRemoveLaw(um)
    local i = um:ReadShort()

    local removed = table.remove(Laws, i)
    hook.Run("removeLaw", i, removed)
end
usermessage.Hook("DRP_RemoveLaw", umRemoveLaw)

local function umResetLaws(um)
    Laws = {}
    fn.Foldl(function(val,v) addLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
    hook.Run("resetLaws")
end
usermessage.Hook("DRP_ResetLaws", umResetLaws)

function DarkRP.getLaws()
    return Laws
end

timer.Simple(0, function()
    fn.Foldl(function(val,v) addLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
end)


local function DisplayNotify()
    local txt = net.ReadString()
    local typed, time = net.ReadInt(8), net.ReadFloat()
    GAMEMODE:AddNotify(txt, typed, time)
    surface.PlaySound("sup/notify.wav")
end
net.Receive("_Notify", DisplayNotify)

local plyMeta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Show a black screen
---------------------------------------------------------------------------]]
local function blackScreen(um)
    local toggle = um:ReadBool()
    if toggle then
        local black = color_black
        local w, h = ScrW(), ScrH()
        hook.Add("HUDPaintBackground", "BlackScreen", function()
            surface.SetDrawColor(black)
            surface.DrawRect(0, 0, w, h)
        end)
    else
        hook.Remove("HUDPaintBackground", "BlackScreen")
    end
end
usermessage.Hook("blackScreen", blackScreen)

--[[---------------------------------------------------------------------------
Wrap strings to not become wider than the given amount of pixels
---------------------------------------------------------------------------]]
local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function DarkRP.textWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen
            return '\n' .. word
        end)

    return text
end

--[[---------------------------------------------------------------------------
Decides whether a given player is in the same room as the local player
note: uses a heuristic
---------------------------------------------------------------------------]]
function plyMeta:isInRoom()
    local tracedata = {}
    tracedata.start = LocalPlayer():GetShootPos()
    tracedata.endpos = self:GetShootPos()
    local trace = util.TraceLine(tracedata)

    return not trace.HitWorld
end

--[[---------------------------------------------------------------------------
Key name to key int mapping
---------------------------------------------------------------------------]]
local keyNames
function input.KeyNameToNumber(str)
    if not keyNames then
        keyNames = {}
        for i = 1, 107, 1 do
            keyNames[input.GetKeyName(i)] = i
        end
    end

    return keyNames[str]
end
