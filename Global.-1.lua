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

ASSET_ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/main/assets/"
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
        size = shipSize.medium,
        alert_dial = {
            object = {type = "Custom_Token", scale = {1.25, 1, 1.25}},
            custom = {image = ASSET_ROOT .. "constellation_class/alert_dial.png", thickness = 0.1}
        },
        power_dial = {
            object = {type = "Custom_Token", scale = {0.63, 1, 0.63}},
            custom = {image = ASSET_ROOT .. "constellation_class/power_dial.png", thickness = 0.1}
        },
        crew_dial = {
            object = {type = "Custom_Token", scale = {0.85, 1, 0.85}},
            custom = {image = ASSET_ROOT .. "constellation_class/crew_dial.png", thickness = 0.1}
        },
        hull_dial = {
            object = {type = "Custom_Token", scale = {0.62, 1, 0.62}},
            custom = {image = ASSET_ROOT .. "constellation_class/hull_dial.png", thickness = 0.1}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526127504/10DB471BCAF7B08573B2933027CA095215F12ED8/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2178114146519128557/E1C0525B323F2052C54CBF7321D9EFA0F884CF5F/"
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        model = {
            object = {type = "Custom_Model", scale = {1.25, 1.25, 1.25}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830218443/6B037F5D0D41284BA00A8660016D803C6626F14C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554821411536/6186F9132EF7FD4AC45FB72EFB59B223F6B16D45/",
            }
        }
    }
}

-- Spawn functions

function spawnAsset(param)
    local obj = spawnObject(param.object)
    obj.setCustomObject(param.custom)
    if param.color then
        log(param.color)
        obj.setColorTint(param.color)
    end
    return obj
end

function spawnRuler() return spawnAsset(ASSETS.ruler_12in) end

function spawnTurningTool() return spawnAsset(ASSETS.turning_tool) end