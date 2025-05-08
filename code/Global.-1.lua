--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end
 
function onObjectDrop(player_color, dropped_object)
    local type = isType(dropped_object, {"overture", "situation", "complication"})
    if type then
        local zone = getObjectFromGUID(zoneGUIDS[type]) -- get corresponding zone
        if zone then
            local objs = zone.getObjects()  -- get all objects in that zone
            if #objs == 1 then
                local obj = objs[1]
                if obj == dropped_object then
                    log(type .. " placed in " .. type .. " zone")
                    if type == "overture" then
                        local setup = isType(dropped_object, {"solitary", "helix", "trinary"})
                        if setup then
                            spawnSystemMarkers(setup)
                        end
                    end
                    local sit_zone = getObjectFromGUID(zoneGUIDS.situation)
                    local ovr_zone = getObjectFromGUID(zoneGUIDS.overture)
                    local situations, overtures = sit_zone.getObjects(), ovr_zone.getObjects()
                    if #situations == 1 and #overtures == 1 and (dropped_object == situations[1] or dropped_object == overtures[1]) then
                        local types = {isType(situations[1], complication_types), isType(overtures[1], complication_types)}
                        getComplications(types)
                    end
                end
            elseif #objs > 2 then
                log("too many " .. type .. "s in zone")
            end
        end
    end
end

function isType(obj, list)
    local value = false
    for _, type in pairs(list) do
        value = value or (obj.hasTag(type) and type)
    end
    return value
end

function getComplications(list)
    local objs = getObjectsWithTag("complication")
    local i = 0
    for _, obj in pairs(objs) do
        if obj.type == "Deck" then
            local deck = obj.getObjects()
            local indices = {}
            for i, card in pairs(deck) do
                if overlap(list, card.tags) then
                    table.insert(indices, card.index)
                end
            end
            table.sort(indices, function(a, b) return a > b end)
            for _, index in pairs(indices) do
                local card_obj = obj.takeObject({position = {i, 2 + 0.01 * i, -i}, index = index, flip = true})
                i = i + 1
            end
        else
            if isType(obj, list) then
                obj.setPosition({i, 2 + 0.01 * i, -i})
                i = i + 1
            end
        end
    end
end

function overlap(l1, l2)
    local result = false
    for _, o1 in pairs(l1) do
        for _, o2 in pairs(l2) do
            result = result or (string.lower(o1) == string.lower(o2))
        end
    end
    return result
end

require("vscode/console")

-- Constants: DO NOT MODIFY

zoneGUIDS = {overture = "737129", situation = "da2ad6", complication = "5860dd"}

complication_types = {"battle", "intrigue", "mystery", "politics", "study", "threat"}

ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/v1.0_fully_functional/"
ASSET_ROOT =  ROOT .. "assets/"
CODE_ROOT = ROOT .. "code/"

-- Assets

ASSETS = {
    tokens = {
        projectile ={
            class1 = {
                data = {
                    Name = "Custom_Tile", Tags = {"Projectile"},
                    Transform = {scaleX = 0.4329358, scaleY = 1, scaleZ = 0.4329358, rotY = 90},
                    CustomImage = {
                        ImageURL = ASSET_ROOT .. "tokens/proj_probe_blue_tile.png",
                        ImageSecondaryURL = ASSET_ROOT .. "tokens/proj_probe_orange_tile.png",
                        CustomTile = {Type = 1, Stretch = false, Thickness = 0.1}
                    }
                }
            },
            photon = {
                data = {
                    Name = "Custom_Tile", Tags = {"Projectile"},
                    Transform = {scaleX = 0.4329358, scaleY = 1, scaleZ = 0.4329358, rotY = 90},
                    CustomImage = {
                        ImageURL = ASSET_ROOT .. "tokens/proj_photon_blue_tile.png",
                        ImageSecondaryURL = ASSET_ROOT .. "tokens/proj_photon_orange_tile.png",
                        CustomTile = {Type = 1, Stretch = false, Thickness = 0.1}
                    }
                }
            },
            quantum = {
                data = {
                    Name = "Custom_Tile", Tags = {"Projectile"},
                    Transform = {scaleX = 0.4329358, scaleY = 1, scaleZ = 0.4329358, rotY = 90},
                    CustomImage = {
                        ImageURL = ASSET_ROOT .. "tokens/proj_quantum_blue_tile.png",
                        ImageSecondaryURL = ASSET_ROOT .. "tokens/proj_quantum_orange_tile.png",
                        CustomTile = {Type = 1, Stretch = false, Thickness = 0.1}
                    }
                }
            },
            escape = {
                data = {
                    Name = "Custom_Tile", Tags = {"Projectile"},
                    Transform = {scaleX = 0.4329358, scaleY = 1, scaleZ = 0.4329358, rotY = 90},
                    CustomImage = {
                        ImageURL = ASSET_ROOT .. "tokens/proj_escape_pod_blue_tile.png",
                        ImageSecondaryURL = ASSET_ROOT .. "tokens/proj_escape_pod_orange_tile.png",
                        CustomTile = {Type = 1, Stretch = false, Thickness = 0.1}
                    }
                }
            }
        }
    },
    tools = {
        tracker = {
            data = {
                Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1},
                CustomMesh = {
                    MeshURL = ASSET_ROOT .. "tokens/tracker.obj",
                    DiffuseURL = ASSET_ROOT .. "tokens/tracker.png",
                    ColliderURL = ASSET_ROOT .. "misc/no_collide.obj"
                }
            }
        },
        ruler_12in = {
            data = {
                Name = "Custom_Token", Tags = {"Ruler"},
                Transform = {scaleX = 0.654653668, scaleY = 1, scaleZ = 0.654653668},
                ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.586},
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "tools/ruler/ruler_12.png",
                    CustomToken = {Thickness = 0.1}
                }
            }
        },
        ruler_6in = {
            data = {
                Name = "Custom_Token", Tags = {"Ruler"},
                Transform = {scaleX = 0.4625709, scaleY = 1, scaleZ = 0.4625709},
                ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.586},
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "tools/ruler/ruler_06.png",
                    CustomToken = {Thickness = 0.1}
                }
            }
        },
        turning_tool = {
            data = {
                Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1},
                CustomMesh = {
                    MeshURL = ASSET_ROOT .. "tools/turning_tool/turning_tool_mesh.obj",
                    DiffuseURL = ASSET_ROOT .. "tools/turning_tool/turning_tool_diffuse.png",
                    ColliderURL = ASSET_ROOT .. "tools/turning_tool/turning_tool_collider.obj"
                }
            }
        }
    },
    setup = {
        systems = {
            solitary = {
                centers = {Vector(0, 0, 0)}, radius = {13},
                borders = {{0, 45, 90, 135, 180, 225, 270, 315}},
                deployment = {
                    ruler_12in = {
                        {pos = Vector(-11.75, 1, -12), rot = Vector(0, 270, 0)},
                        {pos = Vector(11.75, 1, 12), rot = Vector(0, 90, 0)}
                    },
                    ruler_6in = {
                        {pos = Vector(-15, 1, -5.75), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, 5.75), rot = Vector(0, 0, 0)}
                    }
                }
            },
            helix = {
                centers = {Vector(-5, 0, 17), Vector(5, 0, -17)}, radius = {13, 13},
                borders = {{25, 75, 285, 335}, {105, 155, 205, 255}},
                deployment = {
                    ruler_12in = {
                        {pos = Vector(-11.75, 1, -12), rot = Vector(0, 270, 0)},
                        {pos = Vector(11.75, 1, 12), rot = Vector(0, 90, 0)}
                    },
                    ruler_6in = {
                        {pos = Vector(-15, 1, -5.75), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, 5.75), rot = Vector(0, 0, 0)}
                    }
                }
            },
            trinary = {
                centers = {Vector(-17, 0, -17), Vector(17, 0, -17), Vector(0, 0, 14)},radius = {13, 13, 13},
                borders = {{200, 250}, {110, 160}, {30, 90, 270, 330}},
                deployment = {
                    ruler_12in = {
                        {pos = Vector(-11.75, 1, 3), rot = Vector(0, 270, 0)},
                        {pos = Vector(11.75, 1, 3), rot = Vector(0, 90, 0)}
                    },
                    ruler_6in = {
                        {pos = Vector(-15, 1, -3.25), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, 9.25), rot = Vector(0, 0, 0)},
                        {pos = Vector(-15, 1, 9.25), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, -3.25), rot = Vector(0, 0, 0)}
                    }
                }
            }
        },
        system_marker = {
            data = {
                Name = "Custom_Tile", Tags = {"Marker", "System"},
                Transform = {scaleX = 1.009268, scaleY = 1, scaleZ = 1.009268},
                ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.7},
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "markers/system_marker_1.png",
                    CustomTile = {Type = 2, Stretch = false, Thickness = 0.1}
                },
                States = {
                    ["2"] = {
                        Name = "Custom_Tile", Tags = {"Marker", "System"},
                        Transform = {scaleX = 1.009268, scaleY = 1, scaleZ = 1.009268},
                        ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.7},
                        CustomImage = {
                            ImageURL = ASSET_ROOT .. "markers/system_marker_2.png",
                            CustomTile = {Type = 2, Stretch = false, Thickness = 0.1}
                        }
                    },
                    ["3"] = {
                        Name = "Custom_Tile", Tags = {"Marker", "System"},
                        Transform = {scaleX = 1.009268, scaleY = 1, scaleZ = 1.009268},
                        ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.7},
                        CustomImage = {
                            ImageURL = ASSET_ROOT .. "markers/system_marker_3.png",
                            CustomTile = {Type = 2, Stretch = false, Thickness = 0.1}
                        }
                    }
                }
            }
        },
        system_border = {
            data = {
                Name = "Custom_Token", Tags = {"Marker"},
                Transform = {scaleX = 0.4790743, scaleY = 1, scaleZ = 0.4790743},
                ColorDiffuse = {r = 1, g = 1, b = 1, a = 0.7},
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "markers/system_border.png",
                    CustomToken = {Thickness = 0.1}
                }
            }
        }
    },
    factions = {
        dominion = {
            displayName = "Dominion", playable = true,
            officers = {
                {name = "Eris", subtitle = "Manipulative Agent", unique = true, roles = {command = true, ops = true}, cp = 8, fp = 4},
                {name = "Founder", roles = {command = true, ops = true, science = true}, cp = 9, fp = 6},
                {name = "Hanok", subtitle = "Santimonious Minister", sway = {"ferengi"}, unique = true, roles = {ops = true, science = true}, cp = 9, fp = 3},
                {name = "JemHadar First", roles = {ops = true}, cp = 8, fp = 3},
                {name = "JemHadar Second", roles = {ops = true}, cp = 7, fp = 2},
                {name = "Karemma Researcher", roles = {science = true}, cp = 7, fp = 3},
                {name = "Ometiklan", subtitle = "Loyal First", unique = true, roles = {ops = true}, cp = 11, fp = 4},
                {name = "Talaktalan", subtitle = "Menacing Third", unique = true, roles = {ops = true}, cp = 9, fp = 3},
                {name = "The Female Changeling", subtitle = "Divine Ruler", unique = true, roles = {command = true, ops = true, science = true}, cp = 10, fp = 3},
                {name = "Vorta Diplomat", roles = {command = true}, cp = 6, fp = 3},
                {name = "Vorta Supervisor", line_officer = true, roles = {command = true}, cp = 0, fp = 2},
                {name = "Weyoun 4", subtitle = "Unctuous Envoy", unique = true, roles = {command = true}, cp = 9, fp = 3}
            },
            ships = {
                battlecruiser = {
                    name = "Jem'Hadar Battle Cruiser", role = "capital", size = "large", crit_deck_size = 6,
                    faction = "dominion", folder = "ships", type = "battlecruiser",
                    dials = {alert = {min = 0, max = 5}, power = {min = 0, max = 8}, crew = {min = -2, max = 5}, hull = {min = 0, max = 9}},
                    model_transform = {scaleX = 1.3}, instruments = {2, 3, 2, 2, 1, 0},
                    sensors = {all = 4, fore = 4, instruments = {fore = true}},
                    comms = {all = 6, fore = 6, instruments = {fore = true}},
                    weapons = {fore = 6, aft = 6}
                },
                fighter = {
                    name = "Jem'Hadar Fighter", role = "scout", size = "small", crit_deck_size = 4,
                    faction = "dominion", folder = "ships", type = "fighter",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 7}, crew = {min = -2, max = 4}, hull = {min = 0, max = 6}},
                    model_transform = {scaleX = 1.3}, instruments = {1, 2, 2, 1, 0},
                    sensors = {all = 4, fore = 4, instruments = {fore = true}},
                    comms = {all = 4, fore = 4, instruments = {fore = true}},
                    weapons = {fore = 6, aft = 6}
                }
            },
            directives = {
                combat = {{front = "Tactful Approach", back = "Make an Example"}},
                diplomacy = {{front = "Spread the Founders Influence", back = "Seed Doubt"}},
                exploration = {
                    {front = "Test Local Powers", back = "Seize Control", teams = {
                        alpha = {front = "diplomatic_a", back = "assault_a"},
                        beta = {front = "diplomatic_b", back = "assault_b"},
                        gamma = {front = "damage_c", back = "assault_c"}
                    }}
                }
            }
        },
        federation = {
            displayName = "United Federation of Planets", playable = true,
            officers = {
                {name = "Benjamin Sisko", subtitle = "Reluctant Emissary",  sway = {"bajoran"}, unique = true, roles = {command = true, ops = true}, cp = 11, fp = 4},
                {name = "Daring First Officer",  roles = {command = true, ops = true}, cp = 6, fp = 3},
                {name = "Geordi LaForge", subtitle = "Inquisitive Engineer",  unique = true, roles = {ops = true, science = true}, cp = 11, fp = 4},
                {name = "Intrepid Captain",  roles = {command = true}, cp = 7, fp = 4},
                {name = "Jadzia Dax", subtitle = "Vivacious Host", sway = {"ferengi", "klingon"}, unique = true, roles = {ops = true, science = true}, cp = 10, fp = 4},
                {name = "Jean-Luc Picard", subtitle = "Principled Captain", unique = true,  roles = {command = true, ops = true, science = true}, cp = 14, fp = 6},
                {name = "Julian Bashir", subtitle = "Inquisitive Doctor",  unique = true, roles = {science = true}, cp = 9, fp = 3},
                {name = "Kira Nerys", subtitle = "Bajoran Hero", factions = {"bajoran"}, sway = {"bajoran", "bajoran", "federation"}, unique = true, roles = {command = true, ops = true}, cp = 10, fp = 4},
                {name = "Miles OBrien", subtitle = "Chief of Operations", unique = true, roles = {ops = true}, cp = 12, fp = 5},
                {name = "Odo", subtitle = "Stern Constable", factions = {"bajoran"}, sway = {"bajoran", "cardasian"}, unique = true, roles = {ops = true}, cp = 10, fp = 5},
                {name = "Redoubtable Engineer",  roles = {ops = true, science = true}, cp = 6, fp = 3},
                {name = "Reliable Commander",  line_officer = true, roles = {command = true}, cp = 0, fp = 3},
                {name = "Scholarly Doctor",  roles = {science = true}, cp = 6, fp = 3},
                {name = "Vigilant Security Chief",  roles = {ops = true}, cp = 6, fp = 2},
                {name = "Worf", subtitle = "Son of Mogh", factions = {"klingon"}, sway = {"klingon", "federation"}, unique = true, roles = {command = true, ops = true}, cp = 11, fp = 3}
            },
            ships = {
                constellation = {
                    name = "Constellation-Class Starship", role = "support", size = "medium", crit_deck_size = 5, fp = -3,
                    faction = "federation", folder = "ships", type = "constellation",
                    dials = {alert = {min = 0, max = 5}, power = {min = 0, max = 7}, crew = {min = -2, max = 4}, hull = {min = 0, max = 8}},
                    model_transform = {scaleX = 1.25}, instruments = {2, 3, 2, 1, 1, 0},
                    sensors = {all = 4, bow = 4, instruments = {bow = true}},
                    comms = {all = 6, bow = 6, instruments = {bow = true}},
                    weapons = {fore_port = 6, fore_starboard = 6, stern = 6},
                    titles = {{name = "Hathaway", fp = 3}}
                },
                defiant = {
                    name = "Defiant-Class Escort", role = "scout", size = "small", crit_deck_size = 5, fp = 3,
                    faction = "federation", folder = "ships", type = "defiant",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 6}, crew = {min = -2, max = 4}, hull = {min = 0, max = 7}},
                    model_transform = {scaleX = 1.3}, instruments = {2, 2, 1, 1, 0},
                    sensors = {all = 2, bow = 4, instruments = {bow = true}},
                    comms = {all = 2, bow = 6, instruments = {bow = true}},
                    weapons = {all = 6, fore = 6, fore_port = 4, fore_starboard = 4, aft = 6},
                    titles = {{name = "Defiant", fp = 3}}
                },
                galaxy = {
                    name = "Galaxy-Class Starship", role = "capital", size = "large", crit_deck_size = 6,
                    faction = "federation", folder = "ships", type = "galaxy",
                    dials = {alert = {min = 0, max = 6}, power = {min = 0, max = 8}, crew = {min = -2, max = 5}, hull = {min = 0, max = 9}},
                    model_transform = {scaleX = 1.4}, instruments = {3, 3, 2, 2, 1, 1, 0},
                    sensors = {all = 4, bow = 4, instruments = {bow = true}},
                    comms = {all = 6, bow = 6, instruments = {bow = true}},
                    weapons = {fore = 6, aft = 6},
                    titles = {{name = "Enterprise D", fp = 2}},
                    alternate = {
                        name = "Galaxy-Class Stardrive", role = "capital", size = "large",
                        faction = "federation", folder = "ships", type = "galaxy",
                        dials = {alert = {min = 1, max = 5}, power = {min = 0, max = 8}, crew = {min = 2, max = 5}, hull = {min = 0, max = 9}},
                        ship_board = {
                            data = {
                                Name = "Custom_Tile", Transform = {scaleX = 2.1, scaleY = 1, scaleZ = 2.1},
                                CustomImage = {
                                    ImageURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_card.png",
                                    ImageSecondaryURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_card_back.png",
                                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                                }
                            }
                        },
                        model = {ChildObjects = {{CustomMesh = {MeshURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_mesh.obj"}}}},
                        sensors = {all = 2, bow = 4, instruments = {bow = true}},
                        comms = {all = 2, bow = 4, instruments = {bow = true}}
                    },
                    auxiliary = {
                        name = "Galaxy-Class Saucer", role = "auxiliary", size = "medium",
                        faction = "federation", folder = "ships", type = "galaxy",
                        ship_board = {
                            data = {
                                Name = "Custom_Tile", Transform = {scaleX = 2.1, scaleY = 1, scaleZ = 2.1},
                                CustomImage = {
                                    ImageURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_card.png",
                                    ImageSecondaryURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_card_back.png",
                                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                                }
                            }
                        },
                        model = {ChildObjects = {{CustomMesh = {MeshURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_mesh.obj"}}}},
                        sensors = {all = 4, bow = 6}, comms = {all = 6, bow = 8}, weapons = {fore = 6},
                        direction = "fore"
                    }
                },
            },
            auxiliary = {
                runabout = {
                    name = "Danube-Class Runabout", size = "shuttle",
                    faction = "federation", folder = "auxiliary", type = "runabout",
                    model_transform = {posY = 0.25, rotY = 90, scaleX = 0.25},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
                },
                type6 = {
                    name = "Type 6 Shuttle", size = "shuttle",
                    faction = "federation", folder = "auxiliary", type = "type6",
                    model_transform = {posY = 0.5},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
                }
            },
            directives = {
                combat = {{front = "We Come In Peace", back = "Proportionate Response"}},
                diplomacy = {{front = "Seek Out New Life and Civilizations", back = "Protect Federation Interests"}},
                exploration = {
                    {front = "Explore Strange New Worlds", back = "Right to Self-Determination", teams = {
                        alpha = {front = "survey_a", back = "security_a"},
                        beta = {front = "survey_b", back = "security_b"},
                        gamma = {front = "engineering_c", back = "security_c"}
                    }}
                }
            }
        },
        klingon = {
            displayName = "Klingon Empire", playable = false
        },
        neutral = {
            ships = {
                raider = {
                    name = "Hostile Raider", size = "medium",
                    faction = "neutral", folder = "ships", type = "raider",
                    model_transform = {posY = 0.6, rotY = 270, scaleX = 0.325},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
                },
                tinman = {
                    class = "Inscrutable Entity", size = "medium",
                    faction = "neutral", folder = "ships", type = "tinman",
                    model_transform = {posY = 0.9},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
                },
            }
        }
    },
    equipment = {
        {name = "Class 1 Probes", fp = 5, card = {front = "probe_class_1.png", back = "pod_escape.png"}},
        {name = "Escape Pods", fp = 3, card = {front = "pod_escape.png", back = "probe_class_1.png"}},
        {name = "Personnel Transponders", fp = 6, factions = {dominion = true}},
        {name = "Quantum Torpedoes Reload", fp = 6, factions = {dominion = true, federation = true},
            card = {front = "torpedo_quantum.png", back = "torpedo_photon.png"}},
        {name = "Runabout Berth", fp = 3, factions = {federation = true}}
    }
}


-- Spawn functions

function spawnSystemMarkers(name)
    local system = ASSETS.setup.systems[name]
    local board = getBoard()
    local markers = getObjectsWithAnyTags({"Marker", "Ruler"})
    for _, marker in pairs(markers) do
        local pos = marker.getPosition()
        if onBoard(pos) then
            marker.destroy()
        end
    end
    if board then
        if system then
            local pos = board.getPosition() + Vector(0, 0.001, 0)
            for i, center in ipairs(system.centers) do
                local marker = spawnObjectData(ASSETS.setup.system_marker)
                marker.setPosition(pos + center)
                if i ~= marker.getStateId() then
                    marker = marker.setState(i)
                end
                marker.lock()
                for _, angle in pairs(system.borders[i]) do
                    local offset = Vector(0, 0.05, 0.37142565 - system.radius[i]):rotateOver("y", angle) -- radius - half width of border marker
                    local border = spawnObjectData(ASSETS.setup.system_border)
                    border.setPosition(pos + center + offset)
                    border.setRotation(Vector(0, angle, 0))
                    border.lock()
                end
            end
            for type, list in pairs(system.deployment) do
                for _, entry in pairs(list) do
                    ruler = spawnObjectData(ASSETS.tools[type])
                    ruler.setPosition(entry.pos)
                    ruler.setRotation(entry.rot)
                    ruler.lock()
                end
            end
        end
    else
        log("Wrong number of boards")
    end
end

function spawnSolitary() spawnSystemMarkers("solitary") end
function spawnHelix() spawnSystemMarkers("helix") end
function spawnTrinary() spawnSystemMarkers("trinary") end

function drawFeatureRange()
    local features = getObjectsWithTag("Feature")
    for _, feature in pairs(features) do
        local pos = feature.getPosition()
        if onBoard(pos) then
            local lines = {}
            local p2, p4, p6 = {}, {}, {}
            local v = Vector(1, 0.01, 0) - feature.getBoundsNormalized().offset
            local scale = feature.getScale().x
            local scale2, scale4, scale6 = 2.625 / scale, 4.625 / scale, 6.625 / scale
            for theta = 0, 360 do
                table.insert(p2, v:copy():scale(Vector(scale2, 1, scale2)))
                table.insert(p4, v:copy():scale(Vector(scale4, 1, scale4)))
                table.insert(p6, v:copy():scale(Vector(scale6, 1, scale6)))
                v:rotateOver("y", 1)    
            end
            table.insert(lines, {points = p2, color = "Red", thickness = 0.05})
            table.insert(lines, {points = p4, color = "Yellow", thickness = 0.05})
            table.insert(lines, {points = p6, color = "Green", thickness = 0.05})
            feature.setVectorLines(lines)
        end
    end
end

function drawSystemBorders()
    local systems = getObjectsWithTag("System")
    for _, s in pairs(systems) do
        local pos = s.getPosition()
        if onBoard(pos) then
            local lines = {}
            local points = {}
            local v = Vector(13, 0.1, 0)
            for theta = 0, 360 do
                p = clampToBoard(pos + v) - pos
                table.insert(points, p:scale(Vector(1 / s.getScale().x, 1, 1/s.getScale().z)))
                v:rotateOver("y", 1)
            end
            table.insert(lines, {points = points, color = "White", thickness = 0.04})
            table.insert(lines, {points = points, color = "Black", thickness = 0.02})
            s.setVectorLines(lines)
        end
    end
end

function clearSystemBorders()
    local systems = getObjectsWithTag("System")
    for _, s in pairs(systems) do
        s.setVectorLines({})
    end
end

function clearFeatureRange()
    local features = getObjectsWithAnyTags({"Feature", "System"})
    for _, feature in pairs(features) do
        feature.setVectorLines({})
    end
end

function scaleFeatures()
    local features = getObjectsWithTag("Feature")
    for _, feature in pairs(features) do
        local size = feature.getBounds().size.x
        local scale = feature.getScale()
        scale:scale(1.25 / size)
        scale.y = 1
        feature.setScale(scale)
    end
end

function onBoard(pos)
    local board = getBoard()
    local result = false
    if board then
        local diff = pos - board.getPosition()
        result = math.abs(diff.x) <= 18 and math.abs(diff.z) <= 18
    end
    return result
end

function clampToBoard(pos)
    local board = getBoard()
    local result = nil
    if board then
        local diff = pos - board.getPosition()
        for i, d in pairs(diff) do
            diff[i] = d >= 18 and 18 or d <= -18 and -18 or d
        end
        result = diff + board.getPosition()
    end
    return result
end

function getBoard()
    local boards = getObjectsWithTag("Board")
    if #boards == 1 then
        return boards[1]
    else
        log("Wrong number of boards")
    end
end