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
    shuttle = {
        bounds = Vector(1.5, 0, 0.75), arcHeight = 0.01,
        warpAttachment = Vector(0.26, 0, 0.26),
        toolAttachment = {
            fore = {pos = Vector(-1.125, 0 , 0), rot = 0},
            aft = {pos = Vector(1.125, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -0.75), rot = 270},
            starboard = {pos = Vector(0, 0, 0.75), rot = 90}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526307309/9D1EED059774E729E68F7FD44622D28361B4B800/"
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        }
    },
    small = {
        warpAttachment = Vector(0.4, 0, 0.75),
        toolAttachment = {
            fore = {pos = Vector(-1.5, 0 , 0), rot = 0},
            aft = {pos = Vector(1.5, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1), rot = 270},
            starboard = {pos = Vector(0, 0, 1), rot = 90}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526168410/1D30F105B400ED2488C1815A197CDB74DD0B003D/"
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        arcOffsets = {bow = Vector(-0.6, 0, 0), stern = Vector(0.6, 0, 0)}, arcHeight = 0.01,
        bounds = Vector(2.125, 0, 1.5)
    },
    medium = {
        warpAttachment = Vector(0.45, 0, 1),
        toolAttachment = {
            fore = {pos = Vector(-2, 0 , 0), rot = 0},
            aft = {pos = Vector(2, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.25), rot = 270},
            starboard = {pos = Vector(0, 0, 1.25), rot = 90}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526127504/10DB471BCAF7B08573B2933027CA095215F12ED8/"
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        arcOffsets = {bow = Vector(-0.8, 0, 0), stern = Vector(0.8, 0, 0)}, arcHeight = 0,
        bounds = Vector(3.5, 0, 2)
    },
    large = {
        warpAttachment = Vector(0.45, 0, 1.25),
        toolAttachment = {
            fore = {pos = Vector(-2.75, 0 , 0), rot = 0},
            aft = {pos = Vector(2.75, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.5), rot = 270},
            starboard = {pos = Vector(0, 0, 1.5), rot = 90}
        },
        base = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526201424/05511C65238C1083F43AA10418A752B9A8F7AA6C/"
            },
            color = {r = 0.6666667, g = 0.6666667, b = 0.6666667}
        },
        arcOffsets = {bow = Vector(-1.25, 0, 0), stern = Vector(1.25, 0, 0)}, arcHeight = 0.01,
        bounds = Vector(5, 0, 2.5)
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

alertDialPos = Vector(-2.7, -0.1, 0.2)
alertDialRot = -40
alertDialScale = {1.25, 1, 1.25}
powerDialPos = Vector(0.6, -0.1, -2.9)
powerDialRot = 40
powerDialScale = {0.63, 1, 0.63}
crewDialPos = Vector(3.4, -0.1, 0.2)
crewDialRot = 40
crewDialScale = {0.85, 1, 0.85}
hullDialPos = Vector(3.8, -0.1, -2.6)
hullDialRot = 36
hullDialScale = {0.62, 1, 0.62}

rulerScale = 12/18.330303

saucerXml = [[<Button 
    id="setUpBtn" 
    onClick="auxiliarySetup" 
    fontSize="20" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="100" 
    height="50" 
    rectAlignment="UpperLeft" 
    position="0 -80 -30"
    rotation="0 0 180">
    Deploy
</Button>


<Button  
    active="false"
    id="phaserBtn" 
    onClick="firePhaser" 
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="50" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="20 66 -30"
    rotation="0 0 180">
    Fire
</Button>


<Button  
    active="false"
    id="warpBtn" 
    onClick="placeWarpTemplate" 
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="40" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="-20 -70 -30"
    rotation="0 0 180">
    Warp
</Button>

<Button  
    active="false"
    id="impulsBtn" 
    onClick="impulseMoveStart" 
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="50" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="-20 -90 -30"
    rotation="0 0 180">
    Impulse
</Button>

<Button  
    active="false"
    id="scanBtn" 
    onClick="scanCheck" 
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="50" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="20 20 -30"
    rotation="0 0 180">
    Sensors
</Button>

<Button  
    active="false"
    id="commsBtn" 
    onClick="hailCheck" 
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="50" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="20 43 -30"
    rotation="0 0 180">
    Comms
</Button>

<Button
    active="false"
    id="clear"
    onClick="clearArc"
    fontSize="10" 
    color="#FFFFFF|White|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" 
    width="40" 
    height="20" 
    rectAlignment="UpperLeft" 
    position="20 120 -30"
    rotation="0 0 180">
    Clear
</Button>]]

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
        class = "constellation",
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
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "constellation_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 5, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "constellation_class/power_dial.png", thickness = 0.1},
                min = 0, max = 7, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "constellation_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "constellation_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.25, 1.25, 1.25}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830218443/6B037F5D0D41284BA00A8660016D803C6626F14C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554821411536/6186F9132EF7FD4AC45FB72EFB59B223F6B16D45/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {2, 3, 2, 1, 1, 0},
        sensors = {all = 4, bow = 4, instruments = {bow = true}},
        comms = {all = 6, bow = 6, instruments = {bow = true}},
        weapons = {fore_port = 6, fore_starboard = 6, stern = 6}
    },
    defiant = {
        class = "defiant",
        size = shipSize.small,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "defiant_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 4, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "defiant_class/power_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "defiant_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "defiant_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 7, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830561221/92A4C7D84320E3002E5F41EED58C3F1D8A310DF1/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830361122/0D155F737B97557FAC954E588EBB5D83C5DEA1E9/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {2, 2, 1, 1, 0},
        sensors = {all = 2, bow = 4, instruments = {bow = true}},
        comms = {all = 2, bow = 6, instruments = {bow = true}},
        weapons = {all = 6, fore = 6, fore_port = 6, fore_starboard = 6, aft = 6}
    },
    galaxy = {
        class = "galaxy",
        size = shipSize.large,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "galaxy_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "galaxy_class/power_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "galaxy_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 5, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "galaxy_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 9, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.4, 1.4, 1.4}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830060931/7542060AA53D11BA98D698C22DA05B311CDF643C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2098172801144611875/56E14416EBAFD15A8AD905B26C5A61B5801F570E/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {3, 3, 2, 2, 1, 1, 0},
        sensors = {all = 4, bow = 4, instruments = {bow = true}},
        comms = {all = 6, bow = 6, instruments = {bow = true}},
        weapons = {fore = 6, aft = 6},
        alternate = {
            dials = {alert = {min = 1, max = 5}, crew = {min = 2, max = 5}},
            model = {
                custom = {
                    mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830159870/13CCD3CD564237EBFC610A34D84A548C81B60DCF/",
                    diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2098172801144611875/56E14416EBAFD15A8AD905B26C5A61B5801F570E/",
                    collider = ASSET_ROOT .. "no_collide.obj",
                    material = 3
                }
            },
            sensors = {all = 2, bow = 4, instruments = {bow = true}},
            comms = {all = 2, bow = 4, instruments = {bow = true}}
        },
        alt_card = {
            object = {type = "CardCustom", scale = {1.4, 0, 1.4}},
            custom = {
                type = 0, sideways = true,
                face = "https://steamusercontent-a.akamaihd.net/ugc/53575902106857057/D2C95DA140FA61C59D2DCD00F1B4E7B9425BB85F/",
                back = "https://steamusercontent-a.akamaihd.net/ugc/53575902106857266/33AF0CFA558C411F3B1A36435D245447704D1E36/"
            }
        },
        auxiliary = {
            size = shipSize.medium,
            model = {
                object = {type = "Custom_Model", scale = {1.4, 1.4, 1.4}},
                custom = {
                    mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554830188072/006E5758D4D2FE12D925278A4B827420882B85EA/",
                    diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2098172801144611875/56E14416EBAFD15A8AD905B26C5A61B5801F570E/",
                    collider = ASSET_ROOT .. "no_collide.obj",
                    material = 3
                }
            },
            sensors = {all = 4, bow = 6},
            comms = {all = 6, bow = 8},
            weapons = {fore = 6}
        },
        aux_card = {
            object = {type = "CardCustom", scale = {1.4, 0, 1.4}},
            custom = {
                type = 0, sideways = true,
                face = "https://steamusercontent-a.akamaihd.net/ugc/53575902106856618/1495F8282200AD1EA5BE70DE49C75DDF4AEB54F1/",
                back = "https://steamusercontent-a.akamaihd.net/ugc/53575902106856804/D79E78023113838A1EFC4960E56833C88523850A/"
            },
            xml = saucerXml
        }
    },
    jh_fighter = {
        class = "jh_fighter",
        size = shipSize.small,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "jh_fighter/alert_dial.png", thickness = 0.1},
                min = 0, max = 4, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "jh_fighter/power_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "jh_fighter/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "jh_fighter/hull_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554832153651/3BBBBF57829D54A40507584F1977D249A9DFF35C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554832154232/39A8AF0518F0ADF46E51E7E8F4552505C0CDEEF5/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {1, 2, 2, 1, 0},
        sensors = {all = 4, fore = 4, instruments = {fore = true}},
        comms = {all = 4, fore = 4, instruments = {fore = true}},
        weapons = {fore = 6, aft = 6}
    },
    jh_battlecruiser = {
        class = "jh_battlecruiser",
        size = shipSize.large,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "jh_battlecruiser/alert_dial.png", thickness = 0.1},
                min = 0, max = 5, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "jh_battlecruiser/power_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "jh_battlecruiser/crew_dial.png", thickness = 0.1},
                min = -2, max = 5, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "jh_battlecruiser/hull_dial.png", thickness = 0.1},
                min = 0, max = 9, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/2494520554832150950/69C412DC1B298B496AE1A6684A3CFDD0617B84D5/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2494520554832146710/47D4CF19DDD2F7F8E87415CFBE1EC428EE69477E/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {2, 3, 2, 2, 1, 0},
        sensors = {all = 4, fore = 4, instruments = {fore = true}},
        comms = {all = 6, fore = 6, instruments = {fore = true}},
        weapons = {fore = 6, aft = 6}
    },
    raider = {
        class = "raider",
        size = shipSize.medium,
        model = {
            object = {type = "Custom_Model", scale = {0.325, 0.325, 0.325}, rotation = Vector(0, 270, 0), position = Vector(0, 0.6, 0)},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53577344279444585/E56B677AB6878EC0D3BD2ADED937605A8905F4C3/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/53577344279442944/BE82D9B7034C40CCADF25A7A7F417529E61EADA4/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
    },
    tinman = {
        class = "tinman",
        size = shipSize.medium,
        model = {
            object = {type = "Custom_Model", position = Vector(0, 0.9, 0)},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526329081/C729B852A790FCE7F01B760E7CD7FB17ED7B97F8/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/53576717526329354/A2DD2DF77F339B7333BB592FD91994828CBC5414/",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
    },
    type6 = {
        class = "type6",
        size = shipSize.shuttle,
        model = {
            object = {type = "Custom_Model", position = Vector(0, 0.5, 0)},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526297170/7FC0CE312347706553961DDFCF6C09715F79B166/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/266097180323590983/EA286E18C1A7A2CD610F1A3B7902851A4241E4FA/",
                material = 3
            }
        },
        sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
    },
    runabout = {
        class = "runabout",
        size = shipSize.shuttle,
        model = {
            object = {type = "Custom_Model", position = Vector(0, 0.25, 0), rotation = Vector(0, 90, 0), scale = Vector(0.25, 0.25, 0.25)},
            custom = {
                mesh = "https://steamusercontent-a.akamaihd.net/ugc/53576717526304134/DB1ADB191E99797F900FD3A1228B151D239D5D4C/",
                diffuse = "https://steamusercontent-a.akamaihd.net/ugc/53576717520828632/E49B298BE4BC446C9EFA549A40C6383E5EE6F80F/",
                material = 3
            }
        },
        sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
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
    local base = spawnAsset(param.size.base)
    if param.model.object.position then
        param.model.object.position = base.getPosition() + param.model.object.position
    end
    local model = spawnAsset(param.model)
    model.addTag("Ship")
    base.addAttachment(model)
    base.addTag("Ship")
    return base
end

function spawnRuler() return spawnAsset(ASSETS.ruler_12in) end

function spawnTurningTool() return spawnAsset(ASSETS.turning_tool) end