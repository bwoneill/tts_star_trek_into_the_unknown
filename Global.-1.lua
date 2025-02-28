--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

require("vscode/console")

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

-- Assets

ASSET_ROOT = "https://github.com/bwoneill/tts_star_trek_into_the_unknown/blob/60812eb9f5fb33a44275bdd17105492a20e0f629/assets/"
ASSETS = {
    ruler_12in = {
        object = {type = "Custom_Token", scale = {12/18.330303, 1, 12/18.330303}},
        custom = {image = "https://steamusercontent-a.akamaihd.net/ugc/2178114146521158142/F80ED8E2A7D73712BDCF91587EA249D1B2E5B164/", thickness = 0.1}
    },
    turning_tool = {
        object = {type = "Custom_Model"},
        custom = {
            mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526034505/A88863F87EC4E8E6A3B66EC813FC3E459700BBFD/",
            diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2325615279340409003/08D9A7248BAC7E73E539F58552FCF7B7F7B86ED5/",
            collider = "https://steamusercontent-a.akamaihd.net/ugc/53580341274765070/1C959D9EA91D01CE2228CBE23C78E55F68F8F48F/"
        }
    },
    constellation = {
        alert_dial = {
            object = {type = "Custom_Token", scale = {1.25, 1, 1.25}},
            custom = {image = ASSET_ROOT .. "constellation_class/alert_dial.png?raw=true", thickness = 0.1}
        }
    }
}

-- Spawn functions

function spawnAsset(param)
    local obj = spawnObject(param.object)
    obj.setCustomObject(param.custom)
    return obj
end

function spawnRuler() return spawnAsset(ASSETS.ruler_12in) end

function spawnTurningTool() return spawnAsset(ASSETS.turning_tool) end