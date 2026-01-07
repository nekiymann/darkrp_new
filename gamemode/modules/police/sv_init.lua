local plyMeta = FindMetaTable("Player")
local finishWarrantRequest
local arrestedPlayers = {}

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function plyMeta:warrant(warranter, reason)
    if self.warranted then return end
    local suppressMsg = hook.Call("playerWarranted", GAMEMODE, self, warranter, reason)

    self.warranted = true
    timer.Simple(GAMEMODE.Config.searchtime, function()
        if not IsValid(self) then return end
        self:unWarrant(warranter)
    end)

    if suppressMsg then return end

    local warranterNick = IsValid(warranter) and warranter:Nick() or DarkRP.getPhrase("disconnected_player")
    local centerMessage = DarkRP.getPhrase("warrant_approved", self:Nick(), reason, warranterNick)
    local printMessage = DarkRP.getPhrase("warrant_ordered", warranterNick, self:Nick(), reason)

    for _, b in ipairs(player.GetAll()) do
        b:PrintMessage(HUD_PRINTCENTER, centerMessage)
        b:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end

    DarkRP.notify(warranter, 0, 4, DarkRP.getPhrase("warrant_approved2"))
end

function plyMeta:unWarrant(unwarranter)
    if not self.warranted then return end

    local suppressMsg = hook.Call("playerUnWarranted", GAMEMODE, self, unwarranter)

    self.warranted = false

    if suppressMsg then return end

    DarkRP.notify(unwarranter, 2, 4, DarkRP.getPhrase("warrant_expired", self:Nick()))
end

function plyMeta:requestWarrant(suspect, actor, reason)
    local question = DarkRP.getPhrase("warrant_request", actor:Nick(), suspect:Nick(), reason)
    DarkRP.createQuestion(question, suspect:EntIndex() .. "warrant", self, 40, finishWarrantRequest, actor, suspect, reason)
end

function plyMeta:wanted(actor, reason, time)
    local suppressMsg = hook.Call("playerWanted", DarkRP.hooks, self, actor, reason)

    self:setDarkRPVar("wanted", true)
    self:setDarkRPVar("wantedReason", reason)

    if time and time > 0 or GAMEMODE.Config.wantedtime > 0 then
        timer.Create(self:SteamID64() .. " wantedtimer", time or GAMEMODE.Config.wantedtime, 1, function()
            if not IsValid(self) then return end
            self:unWanted()
        end)
    end

    if suppressMsg then return end

    local actorNick = IsValid(actor) and actor:Nick() or DarkRP.getPhrase("disconnected_player")
    local centerMessage = DarkRP.getPhrase("wanted_by_police", self:Nick(), reason, actorNick)
    local printMessage = DarkRP.getPhrase("wanted_by_police_print", actorNick, self:Nick(), reason)

    for _, ply in ipairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCENTER, centerMessage)
        ply:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end
end

function plyMeta:unWanted(actor)
    local suppressMsg = hook.Call("playerUnWanted", GAMEMODE, self, actor)
    self:setDarkRPVar("wanted", nil)
    self:setDarkRPVar("wantedReason", nil)

    timer.Remove(self:SteamID64() .. " wantedtimer")

    if suppressMsg then return end

    local expiredMessage = IsValid(actor) and DarkRP.getPhrase("wanted_revoked", self:Nick(), actor:Nick() or "") or DarkRP.getPhrase("wanted_expired", self:Nick())

    for _, ply in ipairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCENTER, expiredMessage)
        ply:PrintMessage(HUD_PRINTCONSOLE, expiredMessage)
    end
end

function plyMeta:arrest(time, arrester)
    time = time or GAMEMODE.Config.jailtimer or 120

    hook.Call("playerArrested", DarkRP.hooks, self, time, arrester)
    if self:InVehicle() then self:ExitVehicle() end
    self:setDarkRPVar("Arrested", true)
    arrestedPlayers[self:SteamID()] = true

    -- Always get sent to jail when Arrest() is called, even when already under arrest
    if GAMEMODE.Config.teletojail and DarkRP.jailPosCount() ~= 0 then
        self:Spawn()
    end
end

function plyMeta:unArrest(unarrester, teleportOverride)
    if not self:isArrested() then return end

    self:setDarkRPVar("Arrested", nil)
    arrestedPlayers[self:SteamID()] = nil
    hook.Call("playerUnArrested", DarkRP.hooks, self, unarrester, teleportOverride)
end

function DarkRP.iterateArrestedPlayers()
    local index = nil
    local function iterator()
        local found_player = nil
        index = next(arrestedPlayers, index)

        if index == nil then return end

        found_player = player.GetBySteamID(index)
        -- player.GetBySteamID returns false when the player is not in the
        -- server. In that case, skip the player.
        if not found_player then return iterator() end

        return found_player
    end
    return iterator
end

function DarkRP.arrestedPlayers()
    local result = {}
    for ply in DarkRP.iterateArrestedPlayers() do
        table.insert(result, ply)
    end

    return result
end


function DarkRP.arrestedPlayerCount()
    local count = 0

    for _ in DarkRP.iterateArrestedPlayers() do count = count + 1 end

    return count
end


local cfg = {}
cfg.MinLen = 3
cfg.MaxLen = 20
cfg.AllowedPattern = "^[А-Яа-я0-9%s%-%.]+$"

local function containsOnlyRussianSymbols(text)
    local rusSimvols = "абвгдеёжзийкльмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛЬМНОПРСТФЦЧШЩЪЫЭЮЯ.,:?!1234567890 "
    
    for i = 1, #text do
        local char = text:sub(i, i)
        if char == ' ' then continue end
        if not rusSimvols:find(char, 1, true) then
            return false
        end
    end
    
    return true
end
local function IsValidReason(text)
    if not text then return false, "Укажите причину!" end
    
    -- local len = utf8.len(text)
    -- if len < cfg.MinLen or len > cfg.MaxLen then
    --     return false, "Причина должна быть от " .. cfg.MinLen .. " до " .. cfg.MaxLen .. " символов."
    -- end

    if containsOnlyRussianSymbols(text) then
        return "Причина должна состоять из русских символов!"
    end

    return true
end

local function NotifyPolica(msg)
    for _, v in ipairs(player.GetAll()) do
        if v:isCP() then
            DarkRP.notify(v, 1, 4, "[ПОЛИЦИЯ] " .. msg)
            v:EmitSound("npc/metropolice/vo/on1.wav", 50, 100)
        end
    end
end

local function PerformWarrant(ply, target, reason)
    target:setDarkRPVar("warrant", true)
    target:setDarkRPVar("warrantReason", reason)
    target.WarrantBy = ply

    NotifyPolica("ВНИМАНИЕ! Выдан ордер на обыск: " .. target:Nick())

    timer.Create("RemoveWarrant_" .. target:SteamID64(), 180, 1, function()
        if IsValid(target) then
            target:unWarrant()
        end
    end)

    hook.Call("playerWarranted", DarkRP.hooks, target, ply, reason)
end

local function finishWarrantRequest(choice, ply, target, reason)
    if choice ~= 1 then
        DarkRP.notify(ply, 1, 4, "Мэр отклонил запрос на ордер.")
        return
    end
    
    PerformWarrant(ply, target, reason)
end
DarkRP.defineChatCommand("wanted", function(ply, args)
    local target = DarkRP.findPlayer(args[1])
    local reason = table.concat(args, " ", 2)

    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return ""
    end

    local canWanted, message = hook.Call("canWanted", DarkRP.hooks, target, ply, reason)
    if not canWanted then
        if message then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    if target == ply then
        DarkRP.notify(ply, 1, 4, "Нельзя объявить себя в розыск.")
        return ""
    end

    if target:isWanted() then
        DarkRP.notify(ply, 1, 4, "Игрок уже в розыске.")
        return ""
    end

    local valid, err = IsValidReason(reason)
    if not valid then
        DarkRP.notify(ply, 1, 4, err)
        return ""
    end

    target:setDarkRPVar("wanted", true)
    target:setDarkRPVar("wantedReason", reason)
    target.WantedBy = ply 

    NotifyPolica(ply:Nick() .. " объявил " .. target:Nick() .. " в розыск. Причина: " .. reason)
    
    timer.Create("RemoveWanted_" .. target:SteamID64(), 300, 1, function()
        if IsValid(target) then
            target:unWanted()
        end
    end)

    hook.Call("playerWanted", DarkRP.hooks, target, ply, reason)
    sendPopup("Городские новости", target:Nick().." разыскивается по причине: "..reason..". Выдал розыск: "..ply:Nick())

    return ""
end)

DarkRP.defineChatCommand("unwanted", function(ply, args)
    local target = DarkRP.findPlayer(args[1])

    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return ""
    end

    local canUnwant, message = hook.Call("canUnwant", DarkRP.hooks, target, ply)
    if not canUnwant then
        if message then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    if not target:isWanted() then
        DarkRP.notify(ply, 1, 4, "Игрок не в розыске.")
        return ""
    end

    local isBoss = ply:isMayor() or ply:isChief()
    if target.WantedBy ~= ply and not isBoss then
        DarkRP.notify(ply, 1, 4, "Снять розыск может только тот, кто его выдал, или начальник!")
        return ""
    end

    target:setDarkRPVar("wanted", nil)
    target:setDarkRPVar("wantedReason", nil)
    target.WantedBy = nil
    
    timer.Remove("RemoveWanted_" .. target:SteamID64())

    NotifyPolica(target:Nick() .. " больше не разыскивается.")
    sendPopup("Городские новости", target:Nick().." больше не разыскивается","")
    
    hook.Call("playerUnWanted", DarkRP.hooks, target, ply)

    return ""
end)
DarkRP.defineChatCommand("warrant", function(ply, args)
    local target = DarkRP.findPlayer(args[1])
    local reason = table.concat(args, " ", 2)

    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return ""
    end

    local canRequest, message = hook.Call("canRequestWarrant", DarkRP.hooks, target, ply, reason)
    if not canRequest then
        if message then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    if target == ply then
        DarkRP.notify(ply, 1, 4, "Нельзя выписать ордер на себя.")
        return ""
    end

    local valid, err = IsValidReason(reason)
    if not valid then
        DarkRP.notify(ply, 1, 4, err)
        return ""
    end

    local mayors = {}
    for k, v in pairs(player.GetAll()) do
        if RPExtraTeams[v:Team()] and RPExtraTeams[v:Team()].mayor then
            table.insert(mayors, v)
        end
    end

    if #mayors > 0 then
        local mayor = table.Random(mayors)
        local question = DarkRP.getPhrase("warrant_request", ply:Nick(), target:Nick(), reason)
        DarkRP.createQuestion(question, target:EntIndex() .. "warrant", mayor, 40, finishWarrantRequest, ply, target, reason)
        DarkRP.notify(ply, 0, 4, "Запрос отправлен мэру на рассмотрение.")
    else
        PerformWarrant(ply, target, reason)
    end

    return ""
end)

DarkRP.defineChatCommand("unwarrant", function(ply, args)
    local target = DarkRP.findPlayer(args[1])
    
    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return ""
    end
    
    local canRemove, message = hook.Call("canRemoveWarrant", DarkRP.hooks, target, ply)
    if not canRemove then
        if message then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local isBoss = ply:isMayor() or ply:isChief()
    if target.WarrantBy ~= ply and not isBoss then
        DarkRP.notify(ply, 1, 4, "Ордер может отозвать только автор или начальник!")
        return ""
    end

    target:setDarkRPVar("warrant", nil)
    target:setDarkRPVar("warrantReason", nil)
    target.WarrantBy = nil
    
    timer.Remove("RemoveWarrant_" .. target:SteamID64())

    NotifyPolica("Ордер на " .. target:Nick() .. " был отозван.")
    
    hook.Call("playerUnWarranted", DarkRP.hooks, target, ply)

    return ""
end)

-- WANTED и UNWANTED остаются из предыдущего ответа, так как там не требуется запрос мэру.

--[[---------------------------------------------------------------------------
Admin commands
---------------------------------------------------------------------------]]
local function ccArrest(ply, args)
    if DarkRP.jailPosCount() == 0 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_jail_pos"))
        return
    end

    local targets = DarkRP.findPlayers(args[1])

    if not targets then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
        return
    end

    for _, target in pairs(targets) do
        local length = tonumber(args[2])
        if length then
            target:arrest(length, ply)
        else
            target:arrest(nil, ply)
        end
    end
end
DarkRP.definePrivilegedChatCommand("arrest", "DarkRP_AdminCommands", ccArrest)

local function ccUnarrest(ply, args)
    local targets = DarkRP.findPlayers(args[1])

    if not targets then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
        return
    end

    for _, target in pairs(targets) do
        target:unArrest(ply)
        if not target:Alive() then target:Spawn() end
    end
end
DarkRP.definePrivilegedChatCommand("unarrest", "DarkRP_AdminCommands", ccUnarrest)

--[[---------------------------------------------------------------------------
Callback functions
---------------------------------------------------------------------------]]
function finishWarrantRequest(choice, mayor, initiator, suspect, reason)
    if not tobool(choice) then
        DarkRP.notify(initiator, 1, 4, DarkRP.getPhrase("warrant_denied", mayor:Nick()))
        return
    end
    if IsValid(suspect) then
        suspect:warrant(initiator, reason)
    end
end

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]

function DarkRP.hooks:canArrest(arrester, arrestee)
    if IsValid(arrestee) and arrestee:IsPlayer() and arrestee:isCP() and not GAMEMODE.Config.cpcanarrestcp then
        return false, DarkRP.getPhrase("cant_arrest_other_cp")
    end

    if not GAMEMODE.Config.npcarrest and arrestee:IsNPC() then
        return false, DarkRP.getPhrase("unable", "arrest", "NPC")
    end

    if GAMEMODE.Config.needwantedforarrest and not arrestee:IsNPC() and not arrestee:getDarkRPVar("wanted") then
        return false, DarkRP.getPhrase("must_be_wanted_for_arrest")
    end

    if arrestee:IsPlayer() and arrestee.FAdmin_GetGlobal and arrestee:FAdmin_GetGlobal("fadmin_jailed") then
        return false, DarkRP.getPhrase("cant_arrest_fadmin_jailed")
    end

    local jpc = DarkRP.jailPosCount()

    if not jpc or jpc == 0 then
        return false, DarkRP.getPhrase("cant_arrest_no_jail_pos")
    end

    if arrestee.Babygod then
        return false, DarkRP.getPhrase("cant_arrest_spawning_players")
    end

    return true
end

function DarkRP.hooks:playerArrested(ply, time, arrester)
    if ply:isWanted() then ply:unWanted(arrester) end
    local job = RPExtraTeams[ply:Team()]
    if not job or not job.hasLicense then
        ply:setDarkRPVar("HasGunlicense", nil)
    end

    ply:StripWeapons()
    ply:StripAmmo()

    if ply:isArrested() then return end -- hasn't been arrested before

    -- ply:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("youre_arrested", time))

    -- local phrase = DarkRP.getPhrase("hes_arrested", ply:Nick(), time)
    -- for _, v in ipairs(player.GetAll()) do
    --     if v == ply then continue end
    --     v:PrintMessage(HUD_PRINTCENTER, phrase)
    -- end

    local steamID = ply:SteamID()
    timer.Create(ply:SteamID64() .. "jailtimer", time, 1, function()
        if IsValid(ply) then ply:unArrest() end
        arrestedPlayers[steamID] = nil
    end)
end

function DarkRP.hooks:playerUnArrested(ply, actor, teleportOverride)
    if ply:InVehicle() then ply:ExitVehicle() end

    if ply.Sleeping then
        DarkRP.toggleSleep(ply, "force")
    end

    if not ply:Alive() and not GAMEMODE.Config.respawninjail then
        ply.NextSpawnTime = CurTime()
    end

    gamemode.Call("PlayerLoadout", ply)
    -- teleportOverride can either be nil, false, or a vector. Nil means "do not
    -- modify behavior", false means "do not teleport", and a vector means
    -- "teleport to this place instead"
    if (GAMEMODE.Config.telefromjail or teleportOverride ~= nil) and teleportOverride ~= false then
        local pos
        if isvector(teleportOverride) then
            pos = teleportOverride
        else
            local ent
            ent, pos = hook.Call("PlayerSelectSpawn", GAMEMODE, ply)
            pos = pos or ent:GetPos()
        end
        -- workaround for SetPos in weapon event bug
        timer.Simple(0, function() if IsValid(ply) then ply:SetPos(pos) end end)
    end

    timer.Remove(ply:SteamID64() .. "jailtimer")
    DarkRP.notifyAll(0, 4, DarkRP.getPhrase("hes_unarrested", ply:Nick()))
end

hook.Add("PlayerInitialSpawn", "Arrested", function(ply)
    if not arrestedPlayers[ply:SteamID()] then return end
    local time = GAMEMODE.Config.jailtimer
    -- Delay the actual arrest by a single frame to allow
    -- the player to initialise
    timer.Simple(0, function()
        -- In case the timer ended right this tick
        if not IsValid(ply) or not arrestedPlayers[ply:SteamID()] then return end

        ply:arrest(time)
    end)
    DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("jail_punishment", time))
end)

function DarkRP.hooks:canGiveLicense(ply, target)
    -- Mayors can hand out licenses
    if ply:isMayor() then return true end

    local reason = DarkRP.getPhrase("incorrect_job", "/givelicense")

    local players = player.GetAll()
    -- Chiefs can if there is no mayor
    local mayorExists = #fn.Filter(plyMeta.isMayor, players) > 0
    if mayorExists then return false, reason end

    if ply:isChief() then return true end

    -- CPs can if there are no chiefs nor mayors
    local chiefExists = #fn.Filter(plyMeta.isChief, players) > 0
    if chiefExists then return false, reason end

    if ply:isCP() then return true end

    return false, reason
end
