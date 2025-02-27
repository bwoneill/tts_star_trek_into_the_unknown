--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

-- Constants

shipSize = {
    small = {
        width = 1,
        length = 1.5,
        forwardOffset = -1,
        sideOffset = 5.6
    },
    medium = {
        width = 1.25,
        length = 2,
        forwardOffset = -1.29,
        sideOffset = 5.6
    },
    large = {
        width = 1.5,
        length = 2.75,
        forwardOffset = -1.71,
        sideOffset = 5.6
    }
}
rulerScale = 12/18.330303

-- Spawn functions

function spawnRuler()
    local token_param = {
        image = "https://steamusercontent-a.akamaihd.net/ugc/2178114146521158142/F80ED8E2A7D73712BDCF91587EA249D1B2E5B164/",
        thickness = 0.1
    }
    local obj = spawnObject({type = "Custom_Token", scale = {rulerScale, 1, rulerScale}})
    obj.setCustomObject(token_param)
    return obj
end