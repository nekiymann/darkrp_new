--[[---------------------------------------------------------------------------
The fonts that DarkRP uses
---------------------------------------------------------------------------]]
local function loadFonts()
    surface.CreateFont("DarkRPHUD1", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = true,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("DarkRPHUD2", {
        size = 23,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("Roboto20", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("Trebuchet24", {
        size = 24,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS",
        extended = true,
    })

    surface.CreateFont("HUDNumber5", {
        size = 30,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana",
        extended = true,
    })
end

loadFonts()
