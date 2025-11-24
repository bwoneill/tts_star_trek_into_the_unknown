require("utilities/classes")

--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
    buildLibrary()
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
                    missionSetup(type, dropped_object)
                    -- log(type .. " placed in " .. type .. " zone")
                end
            elseif #objs > 2 then
                log("too many " .. type .. "s in zone")
            end
        end
    end
end

function missionSetup(type, object)
    if type == "overture" then
        local setup = isType(object, {"solitary", "helix", "trinary"})
        if setup then
            spawnSystemMarkers(setup)
        end
    end
    local sit_zone = getObjectFromGUID(zoneGUIDS.situation)
    local ovr_zone = getObjectFromGUID(zoneGUIDS.overture)
    local situations, overtures = sit_zone.getObjects(), ovr_zone.getObjects()
    if #situations == 1 and #overtures == 1 and (object == situations[1] or object == overtures[1]) then
        local types = {isType(situations[1], complication_types), isType(overtures[1], complication_types)}
        getComplications(types)
    end
    local mission = ASSETS.missions[type][object.getName()]
    if type == "overture" or type == "situation" then
        local j = type == "situation" and 2 or 0
        for i, x in pairs({"feature", "objective"}) do
            for f, data in pairs(ASSETS.tokens[x]) do
                local feature = mission[f]
                if feature then
                    if f == "anomalies" then
                        data.data = anomalies_data(feature.name, feature.description)
                        data.position = Vector(10.25 + 1.25 * i, 1, -19 - 1.25 * j)
                        j = j + 1
                        spawnObjectData(data)
                    else
                        for i = 1, feature.quantity do
                            data.position = Vector(10.25 + 1.25 * i, 1, -19 - 1.25 * j)
                            local obj = spawnObjectData(data)
                            obj.setName(feature.name)
                            obj.setDescription(feature.description)
                        end
                        j = j + 1
                    end
                end
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
                local card_obj = obj.takeObject({position = {i, 2 + 0.02 * i, -i}, index = index, flip = obj.is_face_down})
                i = i + 1
            end
        else
            if isType(obj, list) then
                obj.setPosition({i, 2 + 0.02 * i, -i})
                if obj.is_face_down then
                    obj.flip()
                end
                i = i + 1
            else
                if not obj.is_face_down then
                    obj.flip()
                end
                obj.setPosition(Vector(6.5, 1, -20.5))
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

ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/v1.1.0/"
ASSET_ROOT =  ROOT .. "assets/"
CODE_ROOT = ROOT .. "code/"
FILE_CACHE = {}
LIBRARY = {}

turning_tool_script = [[function onDrop()
    local rulers = getObjectsWithTag("Ruler")
    local closest = nil
    local dist = 12
    local pos = self.getPosition()
    for _, ruler in pairs(rulers) do
        local d = (pos - ruler.getPosition()):magnitude()
        if d < dist then
            d = dist
            closest = ruler
        end
    end
    if closest then
        local rot = closest.getRotation().y
        local d = (pos - closest.getPosition()):rotateOver("y", -rot)
        if d.z > 0 then
            d.z = 1.3
            self.setRotation(Vector(0, rot - 90, 0))
        else
            d.z = -1.3
            self.setRotation(Vector(0, rot + 90, 0))
        end
        d:rotateOver("y", rot)
        self.setPosition(d + closest.getPosition())
    end
end]]

range_script = [[-- geometry/ranges.lua
function toggleRanges(player, value, id)
    if active then
        self.setVectorLines({})
        active = false
    else
        local lines = {}
        local points = {}
        local scale = self.getScale().x
        local scales = {}
        for pair in value:gmatch("[^;]+") do
            local color, range = pair:match("%s*([%S]+)%s*=%s*([%S]+)")
            scales[color] = range / scale
            points[color] = {}
        end
        for _, g in ipairs(geometry) do
            local v = Vector(1, 0.05, 0):rotateOver("y", g.start)
            local focal_point = g.focal_point and g.focal_point:copy():scale(1 / scale) or Vector(0, 0, 0)
            local radius = g.radius and g.radius / scale or 0
            for theta = g.start, g.stop do
                for color, s in pairs(scales) do
                    table.insert(points[color], v:copy():scale(Vector(s + radius, 1, s + radius)) + focal_point)
                end
                v:rotateOver("y", 1)
            end
        end
        for color, p in pairs(points) do
            table.insert(lines, {points = p, color = color, thickness = 0.05})
        end
        self.setVectorLines(lines)
        active = true
    end
end]]

proj_geometry = [[geometry = {
    {start = 0, stop = 30, focal_point = Vector(0.43, 0, 0)},
    {start = 30, stop = 90, focal_point = Vector(0.43, 0, 0):rotateOver("y",60)},
    {start = 90, stop = 150, focal_point = Vector(0.43, 0, 0):rotateOver("y",120)},
    {start = 150, stop = 210, focal_point = Vector(0.43, 0, 0):rotateOver("y",180)},
    {start = 210, stop = 270, focal_point = Vector(0.43, 0, 0):rotateOver("y",240)},
    {start = 270, stop = 330, focal_point = Vector(0.43, 0, 0):rotateOver("y",300)},
    {start = 330, stop = 360, focal_point = Vector(0.43, 0, 0)}
}
]]

feat_geometry = [[geometry = {{start = 0, stop = 360, focal_point = Vector(), radius = 0.625}}
]]

probe_xml = [[<Button height = "50" width = "150" position = "0 0 -11" rotation = "0 0 90" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=2;Yellow=4)" fontSize = "28">Range</Button>
<Button height = "50" width = "150" position = "0 0 1" rotation = "180 0 270" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=2;Yellow=4)" fontSize = "28">Range</Button>]]

torpedo_xml = [[<Button height = "50" width = "150" position = "0 0 -11" rotation = "0 0 90" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=1;Yellow=4)" fontSize = "28">Range</Button>
<Button height = "50" width = "150" position = "0 0 1" rotation = "180 0 270" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=1;Yellow=4)" fontSize = "28">Range</Button>]]

escape_xml = [[<Button height = "50" width = "150" position = "0 0 -11" rotation = "0 0 90" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=2)" fontSize = "28">Range</Button>
<Button height = "50" width = "150" position = "0 0 1" rotation = "180 0 270" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=2)" fontSize = "28">Range</Button>]]

feat_xml = [[<Button height = "25" width = "75" position = "0 -35 -11" rotation = "0 0 0" color = "rgba(1,1,1,0.25)"
    onClick = "toggleRanges(Red=2;Yellow=4;Green=6)">Range</Button>]]


function feature_data(name, diffuse)
    local result = {
        Name = "Custom_Model", Nickname = name, Transform = {scaleX = 1, scaleY = 1, scaleZ = 1},
        CustomMesh = {
            MeshURL = ASSET_ROOT .. "tokens/features/feature_mesh.obj",
            ColliderURL = ASSET_ROOT .. "tokens/features/feature_collider.obj",
            DiffuseURL = ASSET_ROOT .. "tokens/features/" .. diffuse
        },
        LuaScript = feat_geometry .. range_script,
        XmlUI = feat_xml
    }
    return result
end

function anomalies_data(name, description)
    local data = {
        Name = "Custom_Model_Bag", Nickname = "Anomalies Bag",
        Transform = {scaleX = 1, scaleY = 1, scaleZ = 1},
        CustomMesh = {
            MeshURL = ASSET_ROOT .. "tokens/features/feature_mesh.obj",
            ColliderURL = ASSET_ROOT .. "tokens/features/feature_mesh.obj",
            DiffuseURL = ASSET_ROOT .. "tokens/features/anomalies.png",
            TypeIndex = 6
        },
        Bag = {Order = 2},
        ContainedObjects = {}
    }
    for i = 1, 8 do 
        data.ContainedObjects[i] = feature_data(name, "anomaly_" .. i .. ".png")
        data.ContainedObjects[i].Description = description
    end
    return data
end

function spawnMission(mission, pos, rot)
    local obj = spawnObject({
        type = "CardCustom", position = pos or Vector(0, 0, 0),
        scale = Vector(1.474092, 1, 1.474092), rotation = rot or Vector(0, 0, 0),
        sound = false
    })
    local m_type = string.lower(mission.tags[1])
    local filename = string.gsub(mission.name, " ", "_") .. ".png"
    obj.setCustomObject({
        face = ASSET_ROOT .. "cards/" .. m_type .. "/" .. filename,
        back = ASSET_ROOT .. "cards/" .. m_type .. "/back.png"
    })
    obj.setName(mission.name)
    obj.setTags(mission.tags)
    return obj
end

function spawnMissionDecks()
    local objs = getObjectsWithAnyTags({"overture", "situation", "complication"})
    for _, obj in pairs(objs) do
        local o_type = obj.getData().Name
        if o_type == "CardCustom" or o_type == "Deck" then
            destroyObject(obj)
        end
    end
    local pos = {
        overture = Vector(-10, 1, -20.5),
        situation = Vector(-1.75, 1, -20.5),
        complication = Vector(6.5, 1, -20.5)
    }
    for m_type, missions in pairs(ASSETS.missions) do
        for name, mission in pairs(missions) do
            local obj = spawnMission(mission, pos[m_type], Vector(0, 180, 180))
            if m_type == "complication" then
                obj.setSnapPoints({
                    {position = {-0.6, -0.2,  0.45}},
                    {position = { 0.6, -0.2,  0.45}},
                    {position = { 0.0, -0.2, -0.35}}
                })
            end
        end
    end
end

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
                    },
                    LuaScript = proj_geometry .. range_script,
                    XmlUI = probe_xml
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
                    },
                    LuaScript = proj_geometry .. range_script,
                    XmlUI = torpedo_xml
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
                    },
                    LuaScript = proj_geometry .. range_script,
                    XmlUI = torpedo_xml
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
                    },
                    LuaScript = proj_geometry .. range_script,
                    XmlUI = escape_xml
                }
            }
        },
        commodore = {
            data = {
                Name = "Custom_Tile",
                Transform = {scaleX = 0.427587271, scaleY = 1, scaleZ = 0.427587271},
                CustomImage = {
                    ImageURL = ASSET_ROOT .. "tokens/commodore_blue.png",
                    ImageSecondaryURL = ASSET_ROOT .. "tokens/commodore_orange.png",
                    CustomTile = {Type = 2, Thickness = 0.1, Stretch = true}
                }
            }
        },
        feature = {
            anomalies = {},
            cloud = {data = feature_data("Cloud", "feature_cloud.png")},
            comet = {data = feature_data("Comet", "feature_comet.png")},
            rift = {data = feature_data("Rift", "feature_rift.png")},
            stellar = {data = feature_data("Stellar", "feature_stellar.png")},
            wormhole = {data = feature_data("Wormhole", "feature_wormhole.png")},
            wreck = {data = feature_data("Wreck", "feature_wrek.png")}
        },
        objective = {
            solid = {data = feature_data("Solid Objective", "objective_solid.png")},
            ping = {data = feature_data("Ping Objective", "objective_ping.png")}
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
                },
                LuaScript = turning_tool_script
            }
        },
        wake_tracker = {
            data = {
                Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1},
                CustomMesh = {
                    MeshURL = ASSET_ROOT .. "tools/wake_tracker/wake_tracker.obj",
                    DiffuseURL = ASSET_ROOT .. "tools/wake_tracker/wake_texture.png",
                    ColliderURL = ASSET_ROOT .. "tools/wake_tracker/wake_tracker.obj"
                }
            },
            script_path = CODE_ROOT .. "/tools/wake_tracker.lua",
            xml_path = CODE_ROOT .. "/tools/wake_tracker.xml"
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
                centers = {Vector(5, 0, -17), Vector(-5, 0, 17)}, radius = {13, 13},
                borders = {{105, 155, 205, 255}, {25, 75, 285, 335} },
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
                centers = {Vector(17, 0, 17), Vector(-17, 0, 17), Vector(0, 0, -14)},radius = {13, 13, 13},
                borders = {{20, 70}, {290, 340}, {90, 150, 210, 270}},
                deployment = {
                    ruler_12in = {
                        {pos = Vector(-11.75, 1, -3), rot = Vector(0, 270, 0)},
                        {pos = Vector(11.75, 1, -3), rot = Vector(0, 90, 0)}
                    },
                    ruler_6in = {
                        {pos = Vector(-15, 1, -9.25), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, 3.25), rot = Vector(0, 0, 0)},
                        {pos = Vector(-15, 1, 3.25), rot = Vector(0, 180, 0)},
                        {pos = Vector(15, 1, -9.25), rot = Vector(0, 0, 0)}
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
                {name = "Eris", subtitle = "Manipulative Agent", factions = {dominion = true}, unique = true, roles = {command = true, ops = true}, cp = 8, fp = 4},
                {name = "Founder", factions = {dominion = true}, roles = {command = true, ops = true, science = true}, cp = 9, fp = 6},
                {name = "Hanok", subtitle = "Sanctimonious Minister", factions = {dominion = true}, sway = {ferengi = 1}, unique = true, roles = {ops = true, science = true}, cp = 9, fp = 3},
                {name = "Jem'Hadar First", factions = {dominion = true}, roles = {ops = true}, cp = 8, fp = 3},
                {name = "Jem'Hadar Second", factions = {dominion = true}, roles = {ops = true}, cp = 7, fp = 2},
                {name = "Karemma Researcher", factions = {dominion = true}, roles = {science = true}, cp = 7, fp = 3},
                {name = "Omet'iklan", subtitle = "Loyal First", factions = {dominion = true}, unique = true, roles = {ops = true}, cp = 11, fp = 4},
                {name = "Talak'talan", subtitle = "Menacing Third", factions = {dominion = true}, unique = true, roles = {ops = true}, cp = 9, fp = 3},
                {name = "The Female Changeling", subtitle = "Divine Ruler", factions = {dominion = true}, unique = true, roles = {command = true, ops = true, science = true}, cp = 10, fp = 3},
                {name = "Vorta Diplomat", factions = {dominion = true}, roles = {command = true}, cp = 6, fp = 3},
                {name = "Vorta Supervisor", factions = {dominion = true}, line_officer = true, roles = {command = true}, cp = 0, fp = 2},
                {name = "Weyoun 4", subtitle = "Unctuous Envoy", factions = {dominion = true}, unique = true, roles = {command = true}, cp = 9, fp = 3}
            },
            ships = {
                battlecruiser = {
                    name = "Jem'Hadar Battle Cruiser", role = "capital", size = "large", crit_deck_size = 6,
                    faction = "dominion", folder = "ships", type = "battlecruiser",
                    dials = {alert = {min = 0, max = 5}, power = {min = 0, max = 8}, crew = {min = -2, max = 5}, hull = {min = 0, max = 9}},
                    model_transform = {scaleX = 1.698, rotY = -90}, instruments = {2, 3, 2, 2, 1, 0},
                    sensors = {all = 4, fore = 4, instruments = {fore = true}},
                    comms = {all = 6, fore = 6, instruments = {fore = true}},
                    weapons = {fore = 6, aft = 6}
                },
                fighter = {
                    name = "Jem'Hadar Fighter", role = "scout", size = "small", crit_deck_size = 4,
                    faction = "dominion", folder = "ships", type = "fighter",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 7}, crew = {min = -2, max = 4}, hull = {min = 0, max = 6}},
                    model_transform = {scaleX = 1.548, posY = 0.25, rotY = -90}, instruments = {1, 2, 2, 1, 0},
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
                {name = "Benjamin Sisko", subtitle = "Reluctant Emissary", factions = {federation = true},  sway = {bajoran = 1}, unique = true, roles = {command = true, ops = true}, cp = 11, fp = 4},
                {name = "Daring First Officer", factions = {federation = true}, roles = {command = true, ops = true}, cp = 6, fp = 3},
                {name = "Geordi LaForge", subtitle = "Inquisitive Engineer", factions = {federation = true}, sway = {},  unique = true, roles = {ops = true, science = true}, cp = 11, fp = 4}, -- incomplete sway
                {name = "Intrepid Captain", factions = {federation = true}, roles = {command = true}, cp = 7, fp = 4},
                {name = "Jadzia Dax", subtitle = "Vivacious Host", factions = {federation = true}, sway = {ferengi = 1, klingon = 1}, unique = true, roles = {ops = true, science = true}, cp = 10, fp = 4},
                {name = "Jean-Luc Picard", subtitle = "Principled Captain", factions = {federation = true}, unique = true,  roles = {command = true, ops = true, science = true}, cp = 14, fp = 6},
                {name = "Julian Bashir", subtitle = "Inquisitive Doctor", factions = {federation = true},  unique = true, roles = {science = true}, cp = 9, fp = 3},
                {name = "Kira Nerys", subtitle = "Bajoran Hero", factions = {federation = true, bajoran = true}, sway = {bajoran = 2, federation = 1}, unique = true, roles = {command = true, ops = true}, cp = 10, fp = 4},
                {name = "Miles OBrien", subtitle = "Chief of Operations", factions = {federation = true}, unique = true, roles = {ops = true}, cp = 12, fp = 5},
                {name = "Odo", subtitle = "Stern Constable", factions = {federation = true, bajoran = true}, sway = {bajoran = 1, cardasian = 1}, unique = true, roles = {ops = true}, cp = 10, fp = 5},
                {name = "Redoubtable Engineer", factions = {federation = true},  roles = {ops = true, science = true}, cp = 6, fp = 3},
                {name = "Reliable Commander",  factions = {federation = true}, line_officer = true, roles = {command = true}, cp = 0, fp = 3},
                {name = "Scholarly Doctor",  factions = {federation = true}, roles = {science = true}, cp = 6, fp = 3},
                {name = "Vigilant Security Chief", factions = {federation = true},  roles = {ops = true}, cp = 6, fp = 2},
                {name = "Worf", subtitle = "Son of Mogh", factions = {federation = true, klingon = true}, sway = {klingon = true, federation = true}, unique = true, roles = {command = true, ops = true}, cp = 11, fp = 3},
                {name = "Beverly Crusher", subtitle = "Expert Physician", factions = {federation = true}, sway = {}, unique = true, roles = {command = true, science = true}, cp = 9, fp = 4}, -- incomplete sway
                {name = "Data", subtitle = "Positronic Prodigy", factions = {federation = true}, unique = true, roles = {ops = true, science = true}, cp = 15, fp = 6},
                {name = "Deanna Troi", subtitle = "Insightful Counsellor", factions = {federation = true}, sway = {}, unique = true, roles = {science = true}, cp = 9, fp = 3}, -- incomplete sway
                {name = "William Riker", subtitle = "Dashing Commander", factions = {federation = true}, unique = true, roles = {command = true, ops = true}, cp = 12, fp = 6}
            },
            ships = {
                constellation = {
                    name = "Constellation-Class Starship", role = "support", size = "medium", crit_deck_size = 5, fp = -3,
                    faction = "federation", folder = "ships", type = "constellation",
                    dials = {alert = {min = 0, max = 5}, power = {min = 0, max = 7}, crew = {min = -2, max = 4}, hull = {min = 0, max = 8}},
                    model_transform = {scaleX = 1.388, rotY = -90}, instruments = {2, 3, 2, 1, 1, 0},
                    sensors = {all = 4, bow = 4, instruments = {bow = true}},
                    comms = {all = 6, bow = 6, instruments = {bow = true}},
                    weapons = {fore_port = 6, fore_starboard = 6, stern = 6},
                    titles = {{name = "Hathaway", fp = 3}}
                },
                defiant = {
                    name = "Defiant-Class Escort", role = "scout", size = "small", crit_deck_size = 5, fp = 3,
                    faction = "federation", folder = "ships", type = "defiant",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 6}, crew = {min = -2, max = 4}, hull = {min = 0, max = 7}},
                    model_transform = {scaleX = 1.52, posY = 0.35, rotY = -90}, instruments = {2, 2, 1, 1, 0},
                    sensors = {all = 2, bow = 4, instruments = {bow = true}},
                    comms = {all = 2, bow = 6, instruments = {bow = true}},
                    weapons = {all = 6, fore = 6, fore_port = 4, fore_starboard = 4, aft = 6},
                    titles = {{name = "Defiant", fp = 3}, {name = "Valiant", fp = 3}}
                },
                galaxy = {
                    name = "Galaxy-Class Starship", role = "capital", size = "large", crit_deck_size = 6,
                    faction = "federation", folder = "ships", type = "galaxy",
                    dials = {alert = {min = 0, max = 6}, power = {min = 0, max = 8}, crew = {min = -2, max = 5}, hull = {min = 0, max = 9}},
                    model_transform = {scaleX = 1.416, rotY = 270}, instruments = {3, 3, 2, 2, 1, 1, 0},
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
                                Name = "Custom_Tile", Transform = {scaleX = 2.1, scaleY = 1, scaleZ = 2.1, rotY = 270},
                                CustomImage = {
                                    ImageURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_card.png",
                                    ImageSecondaryURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_card_back.png",
                                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                                }
                            }
                        },
                        model = {ChildObjects = {{Transform = {rotY = 270},
                            CustomMesh = {MeshURL = ASSET_ROOT .. "factions/federation/ships/galaxy/stardrive_mesh.obj"}}}},
                        sensors = {all = 2, bow = 4, instruments = {bow = true}},
                        comms = {all = 2, bow = 4, instruments = {bow = true}}
                    },
                    auxiliary = {
                        name = "Galaxy-Class Saucer", role = "auxiliary", size = "medium",
                        faction = "federation", folder = "ships", type = "galaxy",
                        ship_board = {
                            data = {
                                Name = "Custom_Tile", Transform = {scaleX = 2.1, scaleY = 1, scaleZ = 2.1, rotY = 270},
                                CustomImage = {
                                    ImageURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_card.png",
                                    ImageSecondaryURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_card_back.png",
                                    CustomTile = {Type = 3, Stretch = true, Thickness = 0.01}
                                }
                            }
                        },
                        model = {ChildObjects = {{Transform = {rotY = 270},
                            CustomMesh = {MeshURL = ASSET_ROOT .. "factions/federation/ships/galaxy/saucer_mesh.obj"}}}},
                        sensors = {all = 4, bow = 6}, comms = {all = 6, bow = 8}, weapons = {fore = 6},
                        direction = "fore"
                    }
                },
                miranda = {
                    name = "Miranda-Class Starship", role = "support", size = "small", crit_deck_size = 5, fp = -2,
                    faction = "federation", folder = "ships", type = "miranda",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 7}, crew = {min = -2, max = 4}, hull = {min = 0, max = 7}},
                    model_transform = {scaleX = 1.695, posY = 0.75}, instruments = {2, 2, 1, 0, 0},
                    sensors = {all = 3, bow = 3, instruments = {bow = true}},
                    comms = {all = 4, bow = 4, instruments = {bow = true}},
                    weapons = {bow = 4, fore_port = 6, fore_starboard = 6, aft = 6},
                    titles = {{name = "Trial", pf = 1}}
                }
            },
            auxiliary = {
                runabout = {
                    name = "Danube-Class Runabout", size = "shuttle",
                    faction = "federation", folder = "auxiliary", type = "runabout",
                    model_transform = {posY = 0.25, scaleX = 0.25},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4}
                },
                type6 = {
                    name = "Type 6 Shuttle", size = "shuttle",
                    faction = "federation", folder = "auxiliary", type = "type6",
                    model_transform = {posY = 0.5, rotY = -90},
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
            displayName = "Klingon Empire", playable = true,
            officers = {
                {name = "Cunning Weapons Officer", factions = {klingon = true}, roles = {ops = true}, cp = 7, fp = 3},
                {name = "Gowron", subtitle = "Canny Chancellor", factions = {klingon = true}, unique = true, roles = {command = true}, cp = 15, fp = 4},
                {name = "Grilka", subtitle = "Indomitable Leader", factions = {klingon = true}, sway = {ferengi = 2}, unique = true, roles = {command = true}, cp = 12, fp = 3},
                {name = "K'Ehleyr", subtitle = "Ambassador of Two Worlds", factions = {klingon = true, federation = true}, sway = {klingon = 1, federation = 1}, unique = true, roles = {ops = true, science = true}, cp = 9, fp = 5},
                {name = "Kurn", subtitle = "Steadfast Supporter", factions = {klingon = true}, unique = true, roles = {command = true, ops = true}, cp = 12, fp = 4},
                {name = "Loyal Commander", line_officer = true, factions = {klingon = true}, roles = {command = true}, cp = 0, fp = 3},
                {name = "Proud Captain", factions = {klingon = true}, roles = {command = true}, cp = 8, fp = 3},
                {name = "Restless First Officer", factions = {klingon = true}, roles = {ops = true}, cp = 8, fp = 3},
                {name = "Savvy Engineer", factions = {klingon = true}, roles = {ops = true, science = ture}, cp = 8, fp = 3},
                {name = "Wary Science Officer", factions = {klingon = true}, roles = {science = true}, cp = 7, fp = 2},
                {name = "Duras", subtitle = "Son of Jarod", factions = {klingon = true}, sway = {romulan = 2}, unique = true, roles = {command = true}, cp = 10, fp = 2}
            },
            ships = {
                brel = {
                    name = "B'rel-Class Bird-of-Prey", role = "scout", size = "small", crit_deck_size = 5, fp = -1,
                    faction = "klingon", folder = "ships", type = "brel",
                    dials = {alert = {min = 0, max = 4}, power = {min = 0, max = 6}, crew = {min = -2, max = 4}, hull = {min = 0, max = 6}},
                    model_transform = {scaleX = 0.989, posX = 0.35, posY = 0.88, posZ = 0.75, rotY = -90}, instruments = {1, 2, 1, 0, 0}, -- Need to adjust position
                    sensors = {all = 2, bow = 4, instruments = {bow = true}},
                    comms = {all = 2, bow = 4, instruments = {bow = true}},
                    weapons = {fore_port = 4, fore_starboard = 4},
                    titles = {{name = "Buruk", fp = 2}}
                },
                vorcha = {
                    name = "Vor'cha-Class Attack Cruiser", role = "support", size = "large", crit_deck_size = 6, fp = 1,
                    faction = "klingon", folder = "ships", type = "vorcha",
                    dials = {alert = {min = 0, max = 5}, power = {min = 0, max = 7}, crew = {min = -2, max = 5}, hull = {min = 0, max = 8}},
                    model_transform = {scaleX = 2.505, posY = 0.75, rotY = 90}, instruments = {2, 3, 2, 1, 1, 0},
                    sensors = {all = 4, bow = 4, instruments = {bow = true}},
                    comms = {all = 6, bow = 6, instruments = {bow = true}},
                    weapons = {bow = 6, fore_port = 4, fore_starboard = 4},
                    titles = {{name = "Bortas", fp = 3}}
                }
            },
            auxiliary = {
                toron = {
                    name = "Toron-Class", size = "shuttle",
                    faction = "klingon", folder = "auxiliary", type = "toron",
                    model_transform = {posY = 0.5, rotY = 270}, -- scale TBD
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 3}
                }
            },
            directives = {
                combat = {{front = "Uphold the Empires Oaths", back = "It is a Good Day to Die"}},
                diplomacy = {{front = "Boisterous Demeanor", back = "Actions Surpass Words"}},
                exploration = {
                    {front = "Glory Awaits", back = "Deeds Worthy of Song", teams = {
                        alpha = {front = "honor_guard_a", back = "boarding_a"},
                        beta = {front = "honor_guard_b", back = "boarding_b"},
                        gamma = {front = "honor_guard_c", back = "repair_c"}
                    }}}
            }
        },
        romulan = {
            displayName = "Romulan Star Empire", playable = true,
            officers = {
                {name = "T'Rul", subtitle = "Acerbic Subcommander", factions = {romulan = true, federation = true}, unique = true, roles = {science = true}, cp = 8, fp = 4}
            }
        },
        neutral = {
            auxiliary = {
                raider = {
                    name = "Hostile Raider", size = "medium",
                    faction = "neutral", folder = "ships", type = "raider",
                    model_transform = {posY = 0.6, rotY = 180, scaleX = 0.325},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
                },
                tinman = {
                    name = "Inscrutable Entity", size = "medium",
                    faction = "neutral", folder = "ships", type = "tinman",
                    model_transform = {posY = 0.9, rotY = 270},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {all = 4, fore = 4}
                },
                artifact = {
                    name = "Artifact Ship", size = "medium",
                    faction = "neutral", folder = "ships", type = "artifact",
                    model_transform = {posY = 0.6, scaleX = 1.8},
                    color_transform = {r = 0.62, g = 0.71, b = 1, a = 1},
                    sensors = {all = 6}, comms = {all = 6}, weapons = {fore_port = 5, fore_starboard = 5}
                },
                supply = {
                    name = "Supply Ship", size = "medium",
                    faction = "neutral", folder = "ships", type = "supply",
                    model_transform = {posY = 0.6, scaleX = 1.8},
                    sensors = {all = 3}, comms = {all = 3}, weapons = {}
                }
            }
        }
    },
    equipment = {
        {name = "Class 1 Probes", fp = 5, card = {front = "probe_class_1.png", back = "pod_escape.png"}},
        {name = "Escape Pods", fp = 3, card = {front = "pod_escape.png", back = "probe_class_1.png"}},
        {name = "Personnel Transponders", fp = 6, factions = {dominion = true}},
        {name = "Quantum Torpedoes Reload", fp = 6, factions = {dominion = true, federation = true},
            card = {front = "torpedo_quantum.png", back = "torpedo_photon.png"}},
        {name = "Runabout Berth", fp = 3, factions = {federation = true}},
        {name = "Modernized Drive System", fp = 2, factions = {federation = true}},
        {name = "Relic Armory", fp = 2, factions = {klingon = true}},
        {name = "Romulan Cloaking Device", fp = 0, factions = {federation = true}},
        {name = "Toron Class Shuttle Berth", fp = 2, factions = {klingon = true}}
    },
    missions = {
        overture = {
            ["Battlefield Rescue"] = {
                name = "Battlefield Rescue",
                tags = {"Overture", "Battle", "Solitary"},
                solid = {
                    quantity = 4,
                    name = "Wreckage drift",
                    description = "Capacity 2\nUnstable 1"
                }
            },
            ["Show the Flag"] = {
                name = "Show the Flag",
                tags = {"Overture", "Battle", "Helix"},
                solid = {
                    quantity = 4,
                    name = "Rally point",
                    description = "Capacity 2"
                }
            },
            ["Unstable Discovery"] = {
                name = "Unstable Discovery",
                tags = {"Overture", "Study", "Solitary"},
                ping = {
                    quantity = 6,
                    name = "Unusual readings",
                    description = "Treacherous 2"
                }
            },
            ["Neutral Zone Survey"] = {
                name = "Neutral Zone Survey",
                tags = {"Overture", "Politics", "Helix"},
                ping = {
                    quantity = 6,
                    name = "Signal"
                }
            },
            ["Missing Survey Teams"] = {
                name = "Missing Survey Teams",
                tags = {"Overture", "Politics", "Helix"},
                solid = {
                    quantity = 3,
                    name = "Scouting point",
                    description = "Capacity 3\nMassive 1"
                },
                ping = {
                    quantity = 3,
                    name = "Suspicous readings",
                    description = "Treacherous 2\nUnstable 2"
                }
            },
            ["Distress Call"] = {
                name = "Distress Call",
                tags = {"Overture", "Study", "Trinary"},
                solid = {
                    quantity = 6,
                    name = "Signal location",
                    description = "Capacity 3\nUnstable 2"
                }
            },
            ["Critcal Supply Drop"] = {
                name = "Critical Supply Drop",
                tags = {"Overture", "Politics", "Trinary"},
                solid = {
                    quantity = 3,
                    name = "Outpost",
                    description = "Capacity 2"
                },
                supply = 2
            }
        },
        situation = {
            ["Anomalous Objects"] = {
                name = "Anomalous Objects",
                tags = {"Situation", "Mystery"},
                anomalies = {
                    name = "Strange beacon", quantity = 6,
                    description = "Capacity 2"
                }
            },
            ["Disruptive Ion Storms"] = {
                name = "Disruptive Ion Storms",
                tags = {"Situation", "Threat"},
                cloud = {
                    name = "Ion cloud", quantity = 4,
                    description = "Obscuring 1\nTreacherous 3"
                }
            },
            ["Gamma Quadrant Anomalies"] = {
                name = "Gamma Quadrant Anomalies",
                tags = {"Situation", "Threat"},
                anomalies = {
                    name = "Anomalous readings", quantity = 6
                }
            },
            ["Delicate Treaty"] = {
                name = "Delicate Treaty",
                tags = {"Situation", "Intrigue"},
                rift = {
                    name = "Gravity rift", quantity = 2,
                    description = "Massive 1\nTreacherous 3"
                },
                anomalies = {
                    name = "Warning bouy", quanity = 4
                }
            },
            ["Hostile Raiders"] = {
                name = "Hostile Raiders",
                tags = {"Situation", "Intrigue"},
                cloud = {
                    name = "Nebula", quantity = 2,
                    description = "Obscuring 1"
                },
                anmomalies = {
                    name = "Distress bouy", quantity = 4,
                    description = "Treacherous 2"
                },
                raider = 1
            },
            ["Unexplained Biosigns"] = {
                name = "Unexplained Biosigns",
                tags = {"Situation", "Mystery"},
                anomalies = {
                    name = "Phantom life signs", quantity = 6
                }
            }
        },
        complication = {
            ["Cloak and Dagger"] = {
                name = "Cloak and Dagger",
                tags = {"Complication", "Politics", "Intrigue"},
                solid = {
                    name = "Secret base", quantity = 8,
                    add_description = "Capacity 3"
                }
            },
            ["Missing Crew"] = {
                name = "Missing Crew",
                tags = {"Complication", "Politics", "Mystery"},
                ping = {
                    name = "Cryptic signal", quantity = 4,
                    description = "Treacherous 3\nUnstable 2"
                }
            },
            ["Inscrutable Entity"] = {
                name = "Inscrutable Entity",
                tags = {"Complication", "Study", "Threat", "Mystery"},
                ping = {
                    name = "Clue", quantity = 4
                },
                tinman = 1
            },
            ["Contested Territory"] = {
                name = "Contested Territory",
                tags = {"Complication", "Battle", "Politics", "Intrigue"},
                solid = {
                    name = "Strategic holding",
                    add_description = "Capacity 3"
                }
            },
            ["Tactical Extraction"] = {
                name = "Tactical Extraction",
                tags = {"Complication", "Battle", "Threat"},
                solid = {
                    name = "Embedded base", quantity = 6,
                    add_description = "Capacity 2"
                }
            },
            ["Infection"] = {
                name = "Infection",
                tags = {"Complication", "Study", "Battle", "Threat"},
                solid = {
                    name = "Infection origin", quantity = 6,
                    add_description = "Capacity 3"
                }
            },
            ["Race for Knowledge"] = {
                name = "Race for Knowledge",
                tags = {"Complication", "Study", "Intrigue", "Mystery"},
                solid = {
                    name = "Archealogical site", quantity = 8,
                    add_description = "Capacity 3\nUnstable 2"
                }
            },
            ["On the Tide of Ages"] = {
                name = "On the Tide of Ages",
                tags = {"Complication", "Politic", "Study", "Mystery"},
                solid = {
                    name = "Ancient Ports", quantity = 3,
                    add_description = "Capacity 3"
                }
            },
            ["Surface Strikes"] = {
                name = "Surface Strikes",
                tags = {"Complication", "Battle", "Politics", "Intrigue"},
                solid = {
                    name = "Entrenched Base", quantity = 6,
                    add_description = "Capacity 2"
                },
                artifact = 1
            }
        }
    }
}


-- Spawn functions

function spawnSystemMarkers(name)
    local system = ASSETS.setup.systems[name]
    local board = getBoard()
    local markers = getObjectsWithAnyTags({"Marker", "Setup"})
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
                    ruler.setTags({"Setup"})
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

function getFile(path)
    if not FILE_CACHE[path] then
        local request = WebRequest.get(path)
        repeat until request.is_done
        if request.is_error or request.text == "404: Not Found" then
            log("Error downloading " .. path)
        else
            FILE_CACHE[path] = request.text
        end
    end
    return FILE_CACHE[path]
end

function buildLibrary()
    for f in pairs(ASSETS.factions) do
        if ASSETS.factions[f].officers then
            for i, o in ipairs(ASSETS.factions[f].officers) do
                table.insert(LIBRARY, o)
                LIBRARY[#LIBRARY].otype = "officer"
            end
        end
        if ASSETS.factions[f].ships then
            for _, s in pairs(ASSETS.factions[f].ships) do
                table.insert(LIBRARY, s)
                LIBRARY[#LIBRARY].otype = "ship"
            end
        end
        if ASSETS.factions[f].auxiliary then
            for _, a in pairs(ASSETS.factions[f].auxiliary) do
                table.insert(LIBRARY, a)
                LIBRARY[#LIBRARY].otype = "auxiliary"
            end 
        end
    end
    for i, e in ipairs(ASSETS.equipment) do
        table.insert(LIBRARY, e)
        LIBRARY[#LIBRARY].otype = "equipment"
    end
    LIBRARY = table.sort(LIBRARY, function(a,b)
        local fullNameA = a.name .. (a.subtitle and ", " .. a.subtitle or "")
        local fullNameB = b.name .. (b.subtitle and ", " .. b.subtitle or "")
        return fullNameA:lower() < fullNameB:lower()
    end)
end