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

ASSET_ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/v0.14_purple_data/assets/"

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
                mesh = ASSET_ROOT .. "ships/bases/shuttle_base.obj"
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
                mesh = ASSET_ROOT .. "ships/bases/small_base.obj"
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
                mesh = ASSET_ROOT .. "ships/bases/medium_base.obj"
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
                mesh = ASSET_ROOT .. "ships/bases/large_base.obj"
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
    height="32" 
    rectAlignment="UpperLeft" 
    position="0 -51 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="13 42 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="-26 -45 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="-26 -57 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="13 13 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="13 27 -19"
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
    height="13" 
    rectAlignment="UpperLeft" 
    position="13 76 -19"
    rotation="0 0 180">
    Clear
</Button>]]

-- Assets

ASSETS = {
    ruler_12in = {
        object = {type = "Custom_Token", scale = {12/18.330303, 1, 12/18.330303}},
        custom = {image = ASSET_ROOT .. "tools/ruler/ruler_12.png", thickness = 0.1},
        tag = "ruler",
    },
    turning_tool = {
        object = {type = "Custom_Model"},
        custom = {
            mesh = ASSET_ROOT .. "tools/turning_tool/turning_tool_mesh.obj",
            diffuse = ASSET_ROOT .. "tools/turning_tool/turning_tool_diffuse.png",
            collider = ASSET_ROOT .. "tools/turning_tool/turning_tool_collider.obj"
        },
        script = [[-- empty, for now]]
    },
    constellation = {
        class = "constellation",
        size = shipSize.medium,
        ship_board = {
            object = {type = "Custom_Model"},
            custom = {
                mesh = ASSET_ROOT .. "ships/shig_board.obj",
                diffuse = ASSET_ROOT .. "ships/constellation_class/ship_board.png",
                material = 3
            },
            script = SHIP_BOARD_SCRIPT,
            xml = SHIP_BOARD_XML
        },
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "ships/constellation_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 5, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "ships/constellation_class/power_dial.png", thickness = 0.1},
                min = 0, max = 7, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "ships/constellation_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "ships/constellation_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.25, 1.25, 1.25}},
            custom = {
                mesh = ASSET_ROOT .. "ships/constellation_class/constellation_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/constellation_class/constellation_skin.png",
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
                custom = {image = ASSET_ROOT .. "ships/defiant_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 4, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "ships/defiant_class/power_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "ships/defiant_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "ships/defiant_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 7, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = ASSET_ROOT .. "ships/defiant_class/defiant_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/defiant_class/defiant_skin.png",
                collider = ASSET_ROOT .. "no_collide.obj",
                material = 3
            }
        },
        instruments = {2, 2, 1, 1, 0},
        sensors = {all = 2, bow = 4, instruments = {bow = true}},
        comms = {all = 2, bow = 6, instruments = {bow = true}},
        weapons = {all = 6, fore = 6, fore_port = 4, fore_starboard = 4, aft = 6}
    },
    galaxy = {
        class = "galaxy",
        size = shipSize.large,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "ships/galaxy_class/alert_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "ships/galaxy_class/power_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "ships/galaxy_class/crew_dial.png", thickness = 0.1},
                min = -2, max = 5, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "ships/galaxy_class/hull_dial.png", thickness = 0.1},
                min = 0, max = 9, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.4, 1.4, 1.4}},
            custom = {
                mesh = ASSET_ROOT .. "ships/galaxy_class/galaxy_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/galaxy_class/galaxy_skin.png",
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
                    mesh = ASSET_ROOT .. "ships/galaxy_class/stardrive_mesh.obj",
                    diffuse = ASSET_ROOT .. "ships/galaxy_class/galaxy_skin.png",
                    collider = ASSET_ROOT .. "no_collide.obj",
                    material = 3
                }
            },
            sensors = {all = 2, bow = 4, instruments = {bow = true}},
            comms = {all = 2, bow = 4, instruments = {bow = true}}
        },
        alt_card = {
            data = {
                Name = "Custom_Tile",
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "ships/galaxy_class/stardrive_card.png",
                    ImageSecondaryURL = ASSET_ROOT .. "ships/galaxy_class/stardrive_card_back.png",
                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                }
            },
            scale = {2.1, 1, 2.1}
        },
        auxiliary = {
            size = shipSize.medium,
            model = {
                object = {type = "Custom_Model", scale = {1.4, 1.4, 1.4}},
                custom = {
                    mesh = ASSET_ROOT .. "ships/galaxy_class/saucer_mesh.obj",
                    diffuse = ASSET_ROOT .. "ships/galaxy_class/galaxy_skin.png",
                    collider = ASSET_ROOT .. "no_collide.obj",
                    material = 3
                }
            },
            sensors = {all = 4, bow = 6},
            comms = {all = 6, bow = 8},
            weapons = {fore = 6},
            direction = "fore"
        },
        aux_card = {
            data = {
                Name = "Custom_Tile",
                XmlUI = saucerXml,
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "ships/galaxy_class/saucer_card.png",
                    ImageSecondaryURL = ASSET_ROOT .. "ships/galaxy_class/saucer_card_back.png",
                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                }
            },
            scale = {2.1, 1, 2.1}
        }
    },
    jh_fighter = {
        class = "jh_fighter",
        size = shipSize.small,
        dials = {
            alert = {
                object = {type = "Custom_Token", scale = alertDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_fighter/alert_dial.png", thickness = 0.1},
                min = 0, max = 4, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_fighter/power_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_fighter/crew_dial.png", thickness = 0.1},
                min = -2, max = 4, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_fighter/hull_dial.png", thickness = 0.1},
                min = 0, max = 6, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = ASSET_ROOT .. "ships/jh_fighter/fighter_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/jh_fighter/fighter_skin.png",
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
                custom = {image = ASSET_ROOT .. "ships/jh_battlecruiser/alert_dial.png", thickness = 0.1},
                min = 0, max = 5, rot = alertDialRot, pos = alertDialPos
            },
            power = {
                object = {type = "Custom_Token", scale = powerDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_battlecruiser/power_dial.png", thickness = 0.1},
                min = 0, max = 8, rot = powerDialRot, pos = powerDialPos
            },
            crew = {
                object = {type = "Custom_Token", scale = crewDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_battlecruiser/crew_dial.png", thickness = 0.1},
                min = -2, max = 5, rot = crewDialRot, pos = crewDialPos
            },
            hull = {
                object = {type = "Custom_Token", scale = hullDialScale},
                custom = {image = ASSET_ROOT .. "ships/jh_battlecruiser/hull_dial.png", thickness = 0.1},
                min = 0, max = 9, rot = hullDialRot, pos = hullDialPos
            }
        },
        model = {
            object = {type = "Custom_Model", scale = {1.3, 1.3, 1.3}},
            custom = {
                mesh = ASSET_ROOT .. "ships/jh_battlecruiser/battlecruiser_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/jh_battlecruiser/battlecruiser_skin.png",
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
                mesh = ASSET_ROOT .. "ships/raider/raider_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/raider/raider_skin.png",
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
                mesh = ASSET_ROOT .. "ships/tinman/tinman_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/tinman/tinman_skin.png",
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
                mesh = ASSET_ROOT .. "ships/type6/type6_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/type6/type6_skin.png",
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
                mesh = ASSET_ROOT .. "ships/runabout/runabout_mesh.obj",
                diffuse = ASSET_ROOT .. "ships/runabout/runabout_skin.png",
                material = 3
            }
        },
        sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
    }
}

-- Spawn functions

function spawnAsset(param)
    if param.data then
        param.data.Transform = {scaleX = 1, scaleY = 1, scaleZ = 1}
        return spawnObjectData(param)
    end
    local obj = spawnObject(param.object)
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