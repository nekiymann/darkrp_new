local function LicenseQuery(choice, ply, target, price)
    if choice ~= 1 then
        DarkRP.notify(ply, 1, 4, target:Nick() .. " отказался покупать лицензию.")
        return
    end

    if not IsValid(target) or not IsValid(ply) then return end

    if not target:canAfford(price) then
        DarkRP.notify(ply, 1, 4, "У " .. target:Nick() .. " недостаточно средств!")
        DarkRP.notify(target, 1, 4, "У вас недостаточно средств для покупки лицензии.")
        return
    end

    target:addMoney(-price)
    ply:addMoney(price)

    target:setDarkRPVar("HasGunlicense", true)

    DarkRP.notify(ply, 0, 4, "Вы продали лицензию " .. target:Nick() .. " за " .. DarkRP.formatMoney(price))
    DarkRP.notify(target, 0, 4, "Вы приобрели лицензию у Мэра за " .. DarkRP.formatMoney(price))
end

DarkRP.defineChatCommand("givelicense", function(ply, args)
    if not ply:isMayor() then
        DarkRP.notify(ply, 1, 4, "Доступно только Мэру.")
        return ""
    end

    local target = ply:GetEyeTrace().Entity
    if not IsValid(target) or not target:IsPlayer() then
        DarkRP.notify(ply, 1, 4, "Вы должны смотреть на игрока!")
        return ""
    end

    if ply:GetPos():DistToSqr(target:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, "Игрок слишком далеко.")
        return ""
    end

    if target:getDarkRPVar("HasGunlicense") then
        DarkRP.notify(ply, 1, 4, "У этого игрока уже есть лицензия.")
        return ""
    end

    local price = tonumber(args[1]) or 0
    if price < 0 then
        DarkRP.notify(ply, 1, 4, "Сумма не может быть отрицательной.")
        return ""
    end

    if price == 0 then
        target:setDarkRPVar("HasGunlicense", true)
        DarkRP.notify(ply, 0, 4, "Вы выдали бесплатную лицензию " .. target:Nick())
        DarkRP.notify(target, 0, 4, "Мэр выдал вам лицензию бесплатно.")
        return ""
    end

    DarkRP.createQuestion(
        "Мэр предлагает вам купить лицензию за " .. DarkRP.formatMoney(price) .. ".\nВы согласны?",
        "MayorLicense_" .. ply:EntIndex(),
        target,
        20,
        LicenseQuery,
        ply,
        target,
        price
    )

    DarkRP.notify(ply, 0, 4, "Предложение о покупке отправлено " .. target:Nick())
    return ""
end)

DarkRP.defineChatCommand("removelicense", function(ply)
    if not ply:isMayor() then return "" end

    local target = ply:GetEyeTrace().Entity
    if not IsValid(target) or not target:IsPlayer() then
        DarkRP.notify(ply, 1, 4, "Вы должны смотреть на игрока!")
        return ""
    end

    if ply:GetPos():DistToSqr(target:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, "Игрок слишком далеко.")
        return ""
    end

    if not target:getDarkRPVar("HasGunlicense") then
        DarkRP.notify(ply, 1, 4, "У этого игрока нет лицензии.")
        return ""
    end

    target:setDarkRPVar("HasGunlicense", nil)
    
    DarkRP.notify(ply, 0, 4, "Вы аннулировали лицензию у " .. target:Nick())
    DarkRP.notify(target, 1, 4, "Мэр аннулировал вашу лицензию на оружие!")
    
    return ""
end)

DarkRP.defineChatCommand("audit", function(ply)
    if not ply:isMayor() then return "" end

    local target = ply:GetEyeTrace().Entity
    if not IsValid(target) or not target:IsPlayer() then
        DarkRP.notify(ply, 1, 4, "Смотрите на гражданина для проверки.")
        return ""
    end

    if ply.AuditCooldown and ply.AuditCooldown > CurTime() then
        local timeleft = math.ceil(ply.AuditCooldown - CurTime())
        DarkRP.notify(ply, 1, 4, "Следующая проверка доступна через " .. timeleft .. " сек.")
        return ""
    end

    if ply:GetPos():DistToSqr(target:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, "Игрок слишком далеко для проверки документов.")
        return ""
    end

    local wallet = target:getDarkRPVar("money") or 0
    
    DarkRP.notify(ply, 2, 6, "[АУДИТ] Гражданин: " .. target:Nick())
    DarkRP.notify(ply, 2, 6, "[АУДИТ] Наличные средства: " .. DarkRP.formatMoney(wallet))
    
    DarkRP.notify(target, 1, 5, "Мэр проводит проверку ваших финансов...")
    target:EmitSound("buttons/combine_button5.wav")

    ply.AuditCooldown = CurTime() + 60
    return ""
end)

