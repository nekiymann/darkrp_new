function DarkRP.hooks:canBuyShipment(ply, shipment)
    if not GAMEMODE:CustomObjFitsMap(shipment) then
        return false, false, "Custom object does not fit map"
    end

    if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
        return false, false, DarkRP.getPhrase("shipment_antispam_wait")
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buyshipment", "")
    end

    if shipment.customCheck and not shipment.customCheck(ply) then
        local message = isfunction(shipment.CustomCheckFailMsg) and shipment.CustomCheckFailMsg(ply, shipment) or
                shipment.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    local canbecome = false
    for _, b in pairs(shipment.allowed) do
        if ply:Team() == b then
            canbecome = true
            break
        end
    end

    if not canbecome then
        return false, false, DarkRP.getPhrase("incorrect_job", "/buyshipment")
    end

    local cost = shipment.getPrice and shipment.getPrice(ply, shipment.price) or shipment.price

    if not ply:canAfford(cost) then
        return false, false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("shipment"))
    end

    if not shipment.allowPurchaseWhileDead and not ply:Alive() then
        return false, false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("buy_x", DarkRP.getPhrase("shipments")))
    end

    return true
end

local function BuyShipment(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    local found, foundKey = DarkRP.getShipmentByName(args)
    if not found or found.noship or not GAMEMODE:CustomObjFitsMap(found) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("shipment")))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyShipment", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local crate = ents.Create(found.shipmentClass or "spawned_shipment")
    crate.SID = ply.SID
    crate:Setowning_ent(ply)
    crate:SetContents(foundKey, found.amount)

    crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
    crate.nodupe = true
    crate.ammoadd = found.spareammo
    crate.clip1 = found.clip1
    crate.clip2 = found.clip2
    crate:Spawn()
    crate:SetPlayer(ply)

    DarkRP.placeEntity(crate, tr, ply)

    local phys = crate:GetPhysicsObject()
    phys:Wake()
    if found.weight then
        phys:SetMass(found.weight)
    end

    if CustomShipments[foundKey].onBought then
        CustomShipments[foundKey].onBought(ply, CustomShipments[foundKey], crate)
    end
    hook.Call("playerBoughtShipment", nil, ply, CustomShipments[foundKey], crate, cost)

    if IsValid(crate) then
        ply:addMoney(-cost)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", args, DarkRP.formatMoney(cost)))
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/buyshipment", arg))
    end

    ply.LastShipmentSpawn = CurTime()

    return ""
end
DarkRP.defineChatCommand("buyshipment", BuyShipment)

function DarkRP.hooks:canBuyAmmo(ply, ammo)
    if not GAMEMODE:CustomObjFitsMap(ammo) then
        return false, false, "Custom object does not fit map"
    end

    if ply:isArrested() then
        return false, false, DarkRP.getPhrase("unable", "/buyammo", "")
    end

    if ammo.allowed and not table.HasValue(ammo.allowed, ply:Team()) then
        return false, false, DarkRP.getPhrase("incorrect_job", "/buyammo")
    end

    if ammo.customCheck and not ammo.customCheck(ply) then
        local message = isfunction(ammo.CustomCheckFailMsg) and ammo.CustomCheckFailMsg(ply, ammo) or
            ammo.CustomCheckFailMsg or
            DarkRP.getPhrase("not_allowed_to_purchase")
        return false, false, message
    end

    local cost = ammo.getPrice and ammo.getPrice(ply, ammo.price) or ammo.price
    if not ply:canAfford(cost) then
        return false, false, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("ammo"))
    end

    return true
end

local function BuyAmmo(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return ""
    end

    if GAMEMODE.Config.noguns then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", DarkRP.getPhrase("ammo"), ""))
        return ""
    end

    local found
    local num = tonumber(args)
    if num and GAMEMODE.AmmoTypes[num] then
        found = GAMEMODE.AmmoTypes[num]
    else
        for _, v in pairs(GAMEMODE.AmmoTypes) do
            if v.ammoType ~= args then continue end

            found = v
            break
        end
    end

    if not found then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unavailable", DarkRP.getPhrase("ammo")))
        return ""
    end

    local canbuy, suppress, message, price = hook.Call("canBuyAmmo", DarkRP.hooks, ply, found)

    if not canbuy then
        message = message or DarkRP.getPhrase("incorrect_job", "/buy")
        if not suppress then DarkRP.notify(ply, 1, 4, message) end
        return ""
    end

    local cost = price or found.getPrice and found.getPrice(ply, found.price) or found.price

    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", found.name, DarkRP.formatMoney(cost)))
    ply:addMoney(-cost)

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    local ammo = ents.Create("spawned_ammo")
    ammo:SetModel(found.model)
    ammo:SetPos(tr.HitPos)
    ammo.nodupe = true
    ammo.amountGiven, ammo.ammoType = found.amountGiven, found.ammoType
    ammo:Spawn()

    DarkRP.placeEntity(ammo, tr, ply)

    hook.Call("playerBoughtAmmo", nil, ply, found, ammo, cost)

    return ""
end
DarkRP.defineChatCommand("buyammo", BuyAmmo, 1)
