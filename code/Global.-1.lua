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

-- Constants: DO NOT MODIFY

shipSize = {
    small = {
        warpAttachment = Vector(0.4, 0, 0.75),
        toolAttachment = {
            fore = {pos = Vector(-1.5, 0 , 0), rot = 0},
            aft = {pos = Vector(1.5, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1), rot = 270},
            starboard = {pos = Vector(0, 0, 1), rot = 90}
        },
        arcOffsets = {bow = Vector(-0.6, 0, 0), stern = Vector(0.6, 0, 0)}
    },
    medium = {
        warpAttachment = Vector(0.45, 0, 1),
        toolAttachment = {
            fore = {pos = Vector(-2, 0 , 0), rot = 0},
            aft = {pos = Vector(2, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.25), rot = 270},
            starboard = {pos = Vector(0, 0, 1.25), rot = 90}
        },
        arcOffsets = {bow = Vector(-0.8, 0, 0), stern = Vector(0.8, 0, 0)}
    },
    large = {
        warpAttachment = Vector(0.45, 0, 1.25),
        toolAttachment = {
            fore = {pos = Vector(-2.75, 0 , 0), rot = 0},
            aft = {pos = Vector(2.75, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.5), rot = 270},
            starboard = {pos = Vector(0, 0, 1.5), rot = 90}
        },
        arcOffsets = {bow = Vector(-1.25, 0, 0), stern = Vector(1.25, 0, 0)}
    }
}

ARCS = { -- aft = 0, left handed coords
    fore = {90, 270},
    aft = {-90, 90},
    starboard = {180, 360},
    port = {0, 180},
    all = {0, 360},
    bow = {135, 225},
    stern = {-45, 45},
    fore_starboard = {180, 270},
    aft_starboard = {270, 360},
    fore_port = {90, 180},
    aft_port = {0, 90}
}

rulerScale = 12/18.330303

-- Ship scripts

SHIP_BOARD_SCRIPT = "-- test"

-- Ship UI

SHIP_BOARD_XML = "<Button \n id=\"setUpBtn\" \n onClick=\"setUp\" \n fontSize=\"20\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"200\" \n height=\"50\" \n rectAlignment=\"UpperLeft\" \n position=\"350 0 -2\"\n rotation=\"0 0 180\">\n Deploy\n</Button>\n\n<Button \n active=\"false\"\n id=\"alertUpBtn\" \n onClick=\"alertUp\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"-480 -50 -2\"\n rotation=\"0 0 180\">\n Raise Alert\n</Button>\n<Button \n active=\"false\"\n id=\"alertDownBtn\" \n onClick=\"alertDown\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"-480 40 -2\"\n rotation=\"0 0 180\">\n Lower Alert\n</Button>\n\n<Button \n active=\"false\"\n id=\"powerUpBtn\" \n onClick=\"powerUp\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"10 -400 -2\"\n rotation=\"0 0 180\">\n Add Power\n</Button>\n<Button \n active=\"false\"\n id=\"powerDownBtn\" \n onClick=\"powerDown\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"10 -370 -2\"\n rotation=\"0 0 180\">\n Spend Power\n</Button>\n\n<Button \n active=\"false\"\n id=\"healthUpBtn\" \n onClick=\"hullUp\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"500 -320 -2\"\n rotation=\"0 0 180\">\n Repair\n</Button>\n \n<Button \n active=\"false\"\n id=\"healthDownBtn\" \n onClick=\"hullDown\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"500 -200 -2\"\n rotation=\"0 0 180\">\n Damage\n</Button>\n\n<Button \n active=\"false\"\n id=\"crewUpBtn\" \n onClick=\"crewUp\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"500 -90 -2\"\n rotation=\"0 0 180\">\n Boost Moral\n</Button>\n\n<Button \n active=\"false\"\n id=\"crewDownBtn\" \n onClick=\"crewDown\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"30\" \n rectAlignment=\"UpperLeft\" \n position=\"500 55 -2\"\n rotation=\"0 0 180\">\n Lose Moral\n</Button>\n\n\n\n<Button \n active=\"false\"\n id=\"phaserBtn\" \n onClick=\"firePhaser\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"40\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"205 195 -2\"\n rotation=\"0 0 180\">\n Fire\n</Button>\n<Button \n active=\"false\"\n id=\"torpedoBtnF\" \n onClick=\"fireTorpedoFore\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"40\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"205 245 -2\"\n rotation=\"0 0 180\">\n Fore\n</Button>\n\n<Button \n active=\"false\"\n id=\"torpedoBtnA\" \n onClick=\"fireTorpedoAft\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"40\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"205 270 -2\"\n rotation=\"0 0 180\">\n Aft\n</Button>\n\n<Button \n active=\"false\"\n id=\"warpBtn\" \n onClick=\"placeWarpTemplate\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"40\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-25 -300 -2\"\n rotation=\"0 0 180\">\n Warp\n</Button>\n\n\n<Button \n active=\"false\"\n id=\"moveBtnLeft\" \n onClick=\"impulseMoveStart\" \n fontSize=\"12\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"70\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-110 -225 -2\"\n rotation=\"0 0 180\">\n Impulse\n</Button>\n\n\n<Button \n active=\"false\"\n id=\"scanBtn\" \n onClick=\"scanCheck\" \n fontSize=\"10\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"50\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-120 155 -2\"\n rotation=\"0 0 180\">\n Sensors\n</Button>\n\n<Button \n active=\"false\"\n id=\"commsBtn\" \n onClick=\"hailCheck\" \n fontSize=\"10\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"50\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-120 185 -2\"\n rotation=\"0 0 180\">\n Comms\n</Button>\n\n<Button\n active=\"false\"\n id=\"clear\"\n onClick=\"clearArc\"\n fontSize=\"10\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"50\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-120 125 -2\"\n rotation=\"0 0 180\">\n Clear\n</Button>\n\n<Button \n active=\"false\"\n id=\"scanJammed\" \n onClick=\"sensorsJammed\" \n fontSize=\"10\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-370 155 -2\"\n rotation=\"0 0 180\">\n Senosrs Jammed\n</Button>\n\n<Button \n active=\"false\"\n id=\"commsJammed\" \n onClick=\"commsJammed\" \n fontSize=\"10\" \n color=\"#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)\" \n width=\"100\" \n height=\"20\" \n rectAlignment=\"UpperLeft\" \n position=\"-370 185 -2\"\n rotation=\"0 0 180\">\n Comms Jammed\n</Button>"

-- Assets

ASSET_ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/main/assets/"
ASSETS = {
    ruler_12in = {
        object = {type = "Custom_Token", scale = {12/18.330303, 1, 12/18.330303}},
        custom = {image = "https://steamusercontent-a.akamaihd.net/ugc/2178114146521158142/F80ED8E2A7D73712BDCF91587EA249D1B2E5B164/", thickness = 0.1},
        tag = "ruler",
    },
    turning_tool = {
        object = {type = "Custom_Model"},
        custom = {
            mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526034505/A88863F87EC4E8E6A3B66EC813FC3E459700BBFD/",
            diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2325615279340409003/08D9A7248BAC7E73E539F58552FCF7B7F7B86ED5/",
            collider = "https://steamusercontent-a.akamaihd.net/ugc/53580341274765070/1C959D9EA91D01CE2228CBE23C78E55F68F8F48F/"
        },
        script = [[-- empty, for now]]
    },
    constellation = {
        size = shipSize.medium,
        ship_board = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2262559176062618179/35F33C0A721FAB6A0779303FE6636B8412016B20/",
                diffuse = ASSET_ROOT .. "constellation_class/ship_board.png",
                material = 3
            },
            script = SHIP_BOARD_SCRIPT,
            xml = SHIP_BOARD_XML
        },
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
                material = 3
            }
        },
        instruments = {2, 3, 2, 1, 1, 0},
        sensors = {all = 4, bow = 4, instruments = {bow = true}},
        comms = {all = 6, bow = 6, instruments = {bow = true}},
        weapons = {fore_port = 6, fore_starboard = 6, stern = 6}
    },
    defiant = {
        size = shipSize.small,
        alert_dial = {
            object = {type = "Custom_Token", scale = {1.25, 1, 1.25}},
            custom = {image = ASSET_ROOT .. "defiant_class/alert_dial.png", thickness = 0.1}
        },
        power_dial = {
            object = {type = "Custom_Token", scale = {0.63, 1, 0.63}},
            custom = {image = ASSET_ROOT .. "defiant_class/power_dial.png", thickness = 0.1}
        },
        crew_dial = {
            object = {type = "Custom_Token", scale = {0.85, 1, 0.85}},
            custom = {image = ASSET_ROOT .. "defiant_class/crew_dial.png", thickness = 0.1}
        },
        hull_dial = {
            object = {type = "Custom_Token", scale = {0.62, 1, 0.62}},
            custom = {image = ASSET_ROOT .. "defiant_class/hull_dial.png", thickness = 0.1}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526168410/1D30F105B400ED2488C1815A197CDB74DD0B003D/",
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830561221/92A4C7D84320E3002E5F41EED58C3F1D8A310DF1/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830361122/0D155F737B97557FAC954E588EBB5D83C5DEA1E9/",
            }
        },
        instruments = {2, 2, 1, 1, 0},
        sensors = {all = 2, bow = 4, instruments = {bow = true}},
        comms = {all = 2, bow = 6, instruments = {bow = true}},
        weapons = {all = 6, fore = 6, fore_port = 6, fore_starboard = 6, aft = 6}
    },
    galaxy = {
        size = shipSize.large,
        alert_dial = {
            object = {type = "Custom_Token", scale = {1.25, 1, 1.25}},
            custom = {image = ASSET_ROOT .. "defiant_class/alert_dial.png", thickness = 0.1}
        },
        power_dial = {
            object = {type = "Custom_Token", scale = {0.63, 1, 0.63}},
            custom = {image = ASSET_ROOT .. "defiant_class/power_dial.png", thickness = 0.1}
        },
        crew_dial = {
            object = {type = "Custom_Token", scale = {0.85, 1, 0.85}},
            custom = {image = ASSET_ROOT .. "defiant_class/crew_dial.png", thickness = 0.1}
        },
        hull_dial = {
            object = {type = "Custom_Token", scale = {0.62, 1, 0.62}},
            custom = {image = ASSET_ROOT .. "defiant_class/hull_dial.png", thickness = 0.1}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526201424/05511C65238C1083F43AA10418A752B9A8F7AA6C/",
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        model = {
            object = {type = "Custom_Model", scale = {1.4, 1.4, 1.4}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830060931/7542060AA53D11BA98D698C22DA05B311CDF643C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2098172801144611875/56E14416EBAFD15A8AD905B26C5A61B5801F570E/",
            }
        },
        instruments = {3, 3, 2, 2, 1, 1, 0}
    }
}

-- Spawn functions

function spawnAsset(param)
    local obj = spawnObject(param.object)
    if param.xml then
        obj.UI.setXml(param.xml)
    end
    if param.script then
        obj.setLuaScript(param.script)
    end
    if param.custom then
        obj.setCustomObject(param.custom)
    end
    if param.color then
        obj.setColorTint(param.color)
    end
    return obj
end

function spawnModel(param)
    local base = spawnAsset(param.base)
    local model = spawnAsset(param.model)
    base.addAttachment(model)
    base.addTag("Ship")
    return base
end

function spawnRuler() return spawnAsset(ASSETS.ruler_12in) end

function spawnTurningTool() return spawnAsset(ASSETS.turning_tool) end