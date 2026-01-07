DarkRP.declareChatCommand{
    command = "rpname",
    description = "Set your RP name",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "name",
    description = "Set your RP name",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "nick",
    description = "Set your RP name",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "buyshipment",
    description = "Buy a shipment",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "buyammo",
    description = "Purchase ammo",
    delay = 1.5,
    condition = fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noguns"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}
