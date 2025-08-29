-- Basic ship script
-- Usage:
-- default = Global.getTable("ASSETS").factions.<faction>.ships.<ship_class>
-- require("ship")

ignore_save = false -- set to true for updates on data in Global

saveData = {thickness = 0.02}

ASSET_ROOT = Global.getVar("ASSET_ROOT")

TOOLS = Global.getTable("ASSETS").tools

DIAL_CONST = {
    alert = {pos = Vector(-2.7, -0.1, 0.2), rot = -40, scale = 1.25},
    crew = {pos = Vector(3.4, -0.1, 0.2), rot = 40, scale = 0.85},
    hull = {pos = Vector(3.8, -0.1, -2.6), rot = 36, scale = 0.62},
    power = {pos = Vector(0.6, -0.1, -2.9), rot = 40, scale = 0.63}
}

BASE_CONST = {
    shuttle = {
        warpAttachment = Vector(0.319, 0, 0.38),
        toolAttachment = {
            fore = {pos = Vector(-1.14, 0 , 0), rot = 0},
            aft = {pos = Vector(1.14, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -0.765), rot = 270},
            starboard = {pos = Vector(0, 0, 0.765), rot = 90}
        },
        arcs = {
            all = {
                {point = Vector( 0.735, 0,  0.293), start = 0, stop = 0},
                {point = Vector( 0.735, 0, -0.293), start = 0, stop = 64},
                {point = Vector( 0.577, 0, -0.380), start = 64, stop = 90},
                {point = Vector(-0.577, 0, -0.380), start = 90, stop = 116},
                {point = Vector(-0.735, 0, -0.293), start = 116, stop = 180},
                {point = Vector(-0.735, 0,  0.293), start = 180, stop = 244},
                {point = Vector(-0.557, 0,  0.380), start = 244, stop = 270},
                {point = Vector( 0.577, 0,  0.380), start = 270, stop = 296},
                {point = Vector( 0.735, 0,  0.293), start = 296, stop = 360}
            },
        }
    },
    small = {
        warpAttachment = Vector(0.404, 0, 0.77),
        toolAttachment = {
            fore = {pos = Vector(-1.41, 0 , 0), rot = 0},
            aft = {pos = Vector(1.41, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.065), rot = 270},
            starboard = {pos = Vector(0, 0, 1.065), rot = 90}
        },
        arcs = {
            aft_port = {
                {point = Vector( 1.070, 0,  0.000), start = 0, stop = 0},
                {point = Vector( 1.070, 0, -0.367), start = 0, stop = 27},
                {point = Vector( 0.920, 0, -0.661), start = 27, stop = 47},
                {point = Vector( 0.804, 0, -0.770), start = 47, stop = 90},
                {point = Vector( 0.000, 0, -0.770), start = 90, stop = 90}
            },
            fore_port = {
                {point = Vector( 0.000, 0, -0.770), start = 90, stop = 90},
                {point = Vector(-0.804, 0, -0.770), start = 90, stop = 133},
                {point = Vector(-0.920, 0, -0.661), start = 133, stop = 153},
                {point = Vector(-1.070, 0, -0.367), start = 153, stop = 180},
                {point = Vector(-1.070, 0,  0.000), start = 180, stop = 180},
            },
            fore_starboard = {
                {point = Vector(-1.070, 0,  0.000), start = 180, stop = 180},
                {point = Vector(-1.070, 0,  0.367), start = 180, stop = 207},
                {point = Vector(-0.920, 0,  0.661), start = 207, stop = 227},
                {point = Vector(-0.804, 0,  0.770), start = 227, stop = 270},
                {point = Vector( 0.000, 0,  0.770), start = 270, stop = 270},
            },
            aft_starboard = {
                {point = Vector( 0.000, 0,  0.770), start = 270, stop = 270},
                {point = Vector( 0.804, 0,  0.770), start = 270, stop = 313},
                {point = Vector( 0.920, 0,  0.661), start = 313, stop = 333},
                {point = Vector( 1.070, 0,  0.367), start = 333, stop = 360},
                {point = Vector( 1.070, 0,  0.000), start = 0, stop = 0},
            },
            stern = {
                {point = Vector( 1.032, 0,  0.442), start = 315, stop = 333},
                {point = Vector( 1.070, 0,  0.367), start = 333, stop = 360},
                {point = Vector( 1.070, 0, -0.367), start = 0, stop = 27},
                {point = Vector( 1.032, 0, -0.442), start = 27, stop = 45}
            },
            bow = {
                {point = Vector(-1.032, 0, -0.442), start = 135, stop = 153},
                {point = Vector(-1.070, 0, -0.367), start = 153, stop = 180},
                {point = Vector(-1.070, 0,  0.367), start = 180, stop = 207},
                {point = Vector(-1.032, 0,  0.442), start = 207, stop = 225}
            }
        }
    },
    medium = {
        warpAttachment = Vector(0.427, 0, 1.03),
        toolAttachment = {
            fore = {pos = Vector(-2.065, 0 , 0), rot = 0},
            aft = {pos = Vector(2.065, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.29), rot = 270},
            starboard = {pos = Vector(0, 0, 1.29), rot = 90}
        },
        arcs = {
            aft_port = {
                {point = Vector( 1.740, 0,  0.000), start = 0, stop = 0},
                {point = Vector( 1.740, 0, -0.380), start = 0, stop = 10},
                {point = Vector( 1.707, 0, -0.567), start = 10, stop = 27},
                {point = Vector( 1.471, 0, -1.030), start = 27, stop = 90},
                {point = Vector( 0.000, 0, -1.030), start = 90, stop = 90}
            },
            fore_port = {
                {point = Vector( 0.000, 0, -1.030), start = 90, stop = 90},
                {point = Vector(-1.471, 0, -1.030), start = 90, stop = 153},
                {point = Vector(-1.707, 0, -0.567), start = 153, stop = 170},
                {point = Vector(-1.740, 0, -0.380), start = 170, stop = 180},
                {point = Vector(-1.740, 0, -0.000), start = 180, stop = 180},
            },
            fore_starboard = {
                {point = Vector(-1.740, 0,  0.000), start = 180, stop = 180},
                {point = Vector(-1.740, 0,  0.380), start = 180, stop = 190},
                {point = Vector(-1.707, 0,  0.567), start = 190, stop = 207},
                {point = Vector(-1.471, 0,  1.030), start = 207, stop = 270},
                {point = Vector( 0.000, 0,  1.030), start = 270, stop = 270}
            },
            aft_starboard = {
                {point = Vector( 0.000, 0,  1.030), start = 270, stop = 270},
                {point = Vector( 1.471, 0,  1.030), start = 270, stop = 333},
                {point = Vector( 1.707, 0,  0.567), start = 333, stop = 350},
                {point = Vector( 1.740, 0,  0.380), start = 350, stop = 360},
                {point = Vector( 1.740, 0,  0.000), start = 360, stop = 360},
            },
            stern = {
                {point = Vector( 1.601, 0,  0.776), start = 315, stop = 333},
                {point = Vector( 1.707, 0,  0.567), start = 333, stop = 350},
                {point = Vector( 1.740, 0,  0.380), start = 350, stop = 360},
                {point = Vector( 1.740, 0, -0.380), start = 0, stop = 10},
                {point = Vector( 1.707, 0, -0.567), start = 10, stop = 27},
                {point = Vector( 1.601, 0, -0.776), start = 27, stop = 45}
            },
            bow = {
                {point = Vector(-1.601, 0, -0.776), start = 135, stop = 153},
                {point = Vector(-1.707, 0, -0.567), start = 153, stop = 170},
                {point = Vector(-1.740, 0, -0.380), start = 170, stop = 180},
                {point = Vector(-1.740, 0,  0.380), start = 180, stop = 190},
                {point = Vector(-1.707, 0,  0.567), start = 190, stop = 207},
                {point = Vector(-1.601, 0,  0.776), start = 207, stop = 225}
            }
        }
    },
    large = {
        warpAttachment = Vector(0.43, 0, 1.275),
        toolAttachment = {
            fore = {pos = Vector(-2.82, 0 , 0), rot = 0},
            aft = {pos = Vector(2.82, 0, 0), rot = 180},
            port = {pos = Vector(0, 0, -1.53), rot = 270},
            starboard = {pos = Vector(0, 0, 1.53), rot = 90}
        },
        arcs = {
            aft_port = {
                {point = Vector( 2.500, 0,  0.000), start = 0, stop = 0},
                {point = Vector( 2.500, 0, -0.384), start = 0, stop = 10},
                {point = Vector( 2.425, 0, -0.812), start = 10, stop = 27},
                {point = Vector( 2.189, 0, -1.275), start = 27, stop = 90},
                {point = Vector( 0.000, 0, -1.275), start = 90, stop = 90}
            },
            fore_port = {
                {point = Vector( 0.000, 0, -1.275), start = 90, stop = 90},
                {point = Vector(-2.189, 0, -1.275), start = 90, stop = 153},
                {point = Vector(-2.425, 0, -0.812), start = 153, stop = 170},
                {point = Vector(-2.500, 0, -0.384), start = 170, stop = 180},
                {point = Vector(-2.500, 0, -0.000), start = 180, stop = 180},
            },
            fore_starboard = {
                {point = Vector(-2.500, 0,  0.000), start = 180, stop = 180},
                {point = Vector(-2.500, 0,  0.384), start = 180, stop = 190},
                {point = Vector(-2.425, 0,  0.812), start = 190, stop = 207},
                {point = Vector(-2.189, 0,  1.275), start = 207, stop = 270},
                {point = Vector( 0.000, 0,  1.275), start = 270, stop = 270}
            },
            aft_starboard = {
                {point = Vector( 0.000, 0,  1.275), start = 270, stop = 270},
                {point = Vector( 2.189, 0,  1.275), start = 270, stop = 333},
                {point = Vector( 2.425, 0,  0.812), start = 333, stop = 350},
                {point = Vector( 2.500, 0,  0.384), start = 350, stop = 360},
                {point = Vector( 2.500, 0,  0.000), start = 360, stop = 360},
            },
            stern = {
                {point = Vector( 2.296, 0,  1.066), start = 315, stop = 333},
                {point = Vector( 2.425, 0,  0.812), start = 333, stop = 350},
                {point = Vector( 2.500, 0,  0.384), start = 350, stop = 360},
                {point = Vector( 2.500, 0, -0.384), start = 0, stop = 10},
                {point = Vector( 2.425, 0, -0.812), start = 10, stop = 27},
                {point = Vector( 2.296, 0, -1.066), start = 27, stop = 45}
            },
            bow = {
                {point = Vector(-2.296, 0, -1.066), start = 135, stop = 153},
                {point = Vector(-2.425, 0, -0.812), start = 153, stop = 170},
                {point = Vector(-2.500, 0, -0.384), start = 170, stop = 180},
                {point = Vector(-2.500, 0,  0.384), start = 180, stop = 190},
                {point = Vector(-2.425, 0,  0.812), start = 190, stop = 207},
                {point = Vector(-2.296, 0,  1.066), start = 207, stop = 225}
            }
        }
    }
}

COMPOUND_ARCS = {
    all = {"aft_port", "fore_port", "fore_starboard", "aft_starboard"},
    fore = {"fore_port", "fore_starboard"},
    aft = {"aft_starboard", "aft_port"},
    starboard = {"fore_starboard", "aft_starboard"},
    port = {"aft_port", "fore_port"}
}

function onLoad(script_state)
    shipData = default
    local state = JSON.decode(script_state)
    if state and not ignore_save then
        saveData = state
        if saveData.detached then
            self.UI.setAttributes("saucerSeparation", {onClick = "reattach", text = "Reattach"})
            swapElements(shipData, shipData.alternate)
        end
        local xml = self.UI.getXmlTable()
        if saveData.UI_state and xml then
            for name, active in pairs(saveData.UI_state) do
                if xml[name] and xml[name].attributes then
                    xml[name].attributes.active = active
                end
            end
            if #xml > 0 then
                self.UI.setXmlTable(xml)
            end
        end
        local ship = getObjectFromGUID(saveData.shipGUID)
        if ship then
            setShipContextMenu()
        end
    end
end

function onSave()
    saveData.UI_state = {}
    for name, element in pairs(self.UI.getXmlTable()) do
        if element.tag == "Button" then
            saveData.UI_state[name] = element.attributes.active
        end
    end
    return JSON.encode(saveData)
end

function onDestroy()
    if saveData.dials then
        for _, dial in pairs(saveData.dials) do
            destroyObject(getObjectFromGUID(dial.GUID))
        end
    end
end

function setUp(player, value, id)

    activateButtons()

    -- Get the board's current position and rotation
    local pos = self.getPosition()
    local rot = self.getRotation()
    
    if shipData.dials then
        saveData.dials = saveData.dials or {}
        for name, dial in pairs(shipData.dials) do
            saveData.dials[name] = saveData.dials[name] or {}
            local dial_pos = Vector(DIAL_CONST[name].pos)
            if not saveData.dials[name].GUID then
                local parameters = {
                    data = generateDialData(name),
                    position = pos +  dial_pos:rotateOver("z", rot.z):rotateOver("x", rot.x):rotateOver("y", rot.y),
                    rotation = rot
                }
                local object = spawnObjectData(parameters)
                saveData.dials[name].GUID = object.getGUID()
                saveData.dials[name].value = 0
                object.interactable = false
                object.jointTo(self, {type = "Fixed"})
            end
        end
    end

    -- Ship
    if not saveData.shipGUID then
        local parameters = {
            data = generateShipModelData(shipData, Color.fromString(player.color):setAt("a", 0.33)),
            position = pos + Vector(5.5, 0, -5.5):rotateOver("y", rot.y),
            rotation = rot
        }
        local myShip = spawnObjectData(parameters)
        saveData.shipGUID = myShip.getGUID()
        setShipContextMenu()
    end
end

function generateDialData(dial_type)
    local scale = DIAL_CONST[dial_type].scale
    local result = {
        Name = "Custom_Token", Transform = {scaleX = scale, scaleY = 1, scaleZ = scale},
        CustomImage = {
            ImageURL = ASSET_ROOT .. "factions/" .. shipData.faction ..  "/ships/" .. shipData.type .. "/" .. dial_type .. "_dial.png",
            CustomToken = {Thickness = 0.1}
        }
    }
    return result
end

function generateShipModelData(ship_data, player_color, delta)
    local faction = ship_data.faction
    local folder = ship_data.folder
    local class = ship_data.type
    local size = ship_data.size
    local transform = ship_data.model_transform or {scaleX = 1}
    transform.scaleX = transform.scaleX or 1
    transform.scaleY = transform.scaleY or transform.scaleX
    transform.scaleZ = transform.scaleZ or transform.scaleX
    local color = type(player_color) == "string" and Color.fromString(player_color) or player_color
    local data = {
        Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1}, Tags = {"Ship"},
        ColorDiffuse = color,
        CustomMesh = {
            MeshURL = ASSET_ROOT .. "misc/bases/" .. size ..  "_base.obj",
            ColliderURL = ASSET_ROOT .. "misc/bases/" .. size ..  "_base.obj",
            Convex = false
        },
        ChildObjects = {
            {
                Name = "Custom_Model", Transform = transform,
                CustomMesh = {
                    MeshURL = ASSET_ROOT .. "factions/" .. faction .. "/" .. folder .. "/" .. class .. "/" .. class .. "_mesh.obj",
                    DiffuseURL = ASSET_ROOT .. "factions/" .. faction .. "/" .. folder .. "/" .. class .. "/" .. class .. "_skin.png",
                    ColliderURL = ASSET_ROOT .. "misc/no_collide.obj", MaterialIndex = 3
                }
            }
        }
    }
    if ship_data.model then
        mergeData(data, ship_data.model)
    end
    return data
end

function mergeData(data, delta)
    for key, value in pairs(delta) do
        if type(data[key]) == "table" then
            mergeData(data[key], value)
        else
            data[key] = value
        end
    end
end

function setShipContextMenu()
    local ship = getObjectFromGUID(saveData.shipGUID)
    ship.addContextMenuItem('Impulse', function() impulseMoveStart() end, false)
    ship.addContextMenuItem('Warp Speed', function() placeWarpTemplate() end, false)
end

function activateButtons()
    for _, button in pairs(self.UI.getXmlTable()) do
        self.UI.setAttribute(button.attributes.id, "active", button.attributes.active == "false" and "true" or "false")
    end
end

function constrainValue(value, min, max)
    value = value <= max and value or max
    value = value >= min and value or min
    return value
end

-- Dials

function rotateDial(name, difference)
    local dialData = shipData.dials[name]
    local dialValues = saveData.dials[name]
    local rot = self.getRotation()
    local dial = getObjectFromGUID(dialValues.GUID)
    local value = constrainValue(dialValues.value + difference, dialData.min, dialData.max)
    if value ~= dialValues.value then
        dialValues.value = value
        rot.y = rot.y + DIAL_CONST[name].rot * dialValues.value
        dial.jointTo()
        -- local result = calculateRotation(-dialData.rot * dialValues.value, self.getRotation())
        -- log(result)
        -- dial.setRotation(result)
        dial.setRotation(rot)
        dial.jointTo(self, {type = "Fixed"})
    end
end

function alertUp() rotateDial("alert", 1) end

function alertDown() rotateDial("alert", -1) end

function powerUp() rotateDial("power", -1) end

function powerDown() rotateDial("power", 1) end

function hullUp() rotateDial("hull", -1) end

function hullDown() rotateDial("hull", 1) end

function crewUp() rotateDial("crew", -1) end

function crewDown() rotateDial("crew", 1) end

function calculateRotation(alpha, rotation)
    local X, Y, Z = Vector(1, 0, 0), Vector(0, 1, 0), Vector(0, 0, 1)
    local result = Vector()
    X:rotateOver("y", alpha):rotateOver("z", rotation.z):rotateOver("x", rotation.x):rotateOver("y", rotation.y)
    Y:rotateOver("y", alpha):rotateOver("z", rotation.z):rotateOver("x", rotation.x):rotateOver("y", rotation.y)
    Z:rotateOver("y", alpha):rotateOver("z", rotation.z):rotateOver("x", rotation.x):rotateOver("y", rotation.y)
    result.x = math.deg(math.asin(Z.y))
    local cx = math.cos(math.rad(result.x))
    result.y = math.deg(math.atan2(-Z.x / cx, Z.z / cx))
    result.z = math.deg(math.atan2(X.y / cx, Y.y / cx))
    return result
end

function placeTracker(side)
    if tracker then
        tracker.destroy()
    end
    local myShip = getObjectFromGUID(saveData.shipGUID)
    local attachment = BASE_CONST[shipData.size].toolAttachment[side]
    oldPos = myShip.getPosition()
    oldRot = myShip.getRotation()
    tracker = spawnObjectData(TOOLS.tracker)
    tracker.setPosition(oldPos + (Vector(attachment.pos) + Vector(side == "aft" and -0.25 or 0.25, 0.05, 0)):rotateOver("y", oldRot.y))
    tracker.setRotation({0, oldRot.y + attachment.rot + 90, 0})
    tracker.createButton({function_owner = self, click_function = "cancelMove", label = "Cancel", position = {0, 0.2, 0}, rotation = {0, 180, 0}, width = 400, height = 180})
    tracker.lock()
end

function placeTrackerFore() placeTracker("fore") end
function placeTrackerAft() placeTracker("aft") end

function cancelMove()
    if template then
        template.destroy()
        template = nil
    end
    if ruler then
        ruler.destroy()
        ruler = nil
    end
    if rulerA then
        rulerA.destroy()
        rulerA = nil
        rulerB.destroy()
        rulerB = nil
    end
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.setPosition(oldPos)
    myShip.setRotation(oldRot)
    tracker.destroy()
    tracker = nil
end

-- Impulse

function impulseMoveStart()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.createButton({function_owner = self, click_function = "impulseMoveFront",label = "Fore", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    myShip.createButton({function_owner = self, click_function = "impulseMoveBack",label = "Aft", position = {-1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    myShip.createButton({function_owner = self, click_function = "impulseMoveLeft",label = "Port", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
    myShip.createButton({function_owner = self, click_function = "impulseMoveRight",label = "Starboard", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 550, height = 150})
end

function impulseMoveFront() placeToolToShipFront() end
function impulseMoveBack() placeToolToShipBack() end
function impulseMoveLeft() placeToolToShipLeft() end
function impulseMoveRight() placeToolToShipRight() end

-- Turning tool

function placeTurningTool(side, tracker)
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.clearButtons()
    myShip.lock()
    shipDirection = side
    if side == "aft" then
        placeTrackerFore()
    else
        placeTrackerAft()
    end
    local attachment = BASE_CONST[shipData.size].toolAttachment[side]
    local pos = myShip.getPosition()
    local rot = myShip.getRotation().y
    template = spawnObjectData(TOOLS.turning_tool)
    template.setPosition(pos + Vector(attachment.pos):rotateOver("y", rot))
    template.setRotation({0, rot + attachment.rot, 0})
    template.jointTo(myShip, {type = "Hinge", collision = false, break_force = 1000.0, axis = {0,1,0}, anchor = {0,0,0}})
end

function placeToolToShipFront()
    placeTurningTool("fore")
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Port", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Starboard", position= {0, .3, 0.5},rotation= {0, 90, 0},width= 550,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function placeToolToShipBack()
    placeTurningTool("aft")
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Starboard", position= {0, .3, -0.5},rotation= {0, 270, 0},width= 550,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Port", position= {0, .3, 0.3},rotation= {0, 270, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function placeToolToShipLeft()
    placeTurningTool("port")
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Reverse", position= {0, .3, -0.3},rotation= {0, 180, 0},width= 450,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Forward", position= {0, .3, 0.3},rotation= {0, 180, 0},width= 450,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function placeToolToShipRight()
    placeTurningTool("starboard")
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Forward", position= {0, .3, -0.3},rotation= {0, 0, 0},width= 450,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Reverse", position= {0, .3, 0.3},rotation= {0, 0, 0},width= 450,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

-- Step 2: Position the Ruler
function positionRuler(direction)
    local myShip = getObjectFromGUID(saveData.shipGUID)
    ruler = spawnObjectData(TOOLS.ruler_12in)
    local sign = direction == "right" and 1 or -1
    local pos = template.getPosition()
    local rot = template.getRotation()
    local offset = Vector(-1.3, 0, sign * 5.925 ):rotateOver("y", rot.y)
    rot.y = rot.y + sign * 90
    ruler.setPosition(pos + offset)
    ruler.setRotation(rot)
    ruler.lock()
    template.clearButtons()
	template.createButton({ click_function = "positionShip",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.jointTo()
    template.jointTo(myShip, {type = "Hinge", collision = false, break_force = 200.0, axis = {0,1,0}, anchor = {0,0,0}})
	print("Adjust template along the ruler before placing ship")
end

function positionRulerRight()
    positionRuler("right")
end

function positionRulerLeft()
    positionRuler("left")
end


-- Step 3: Position Ship to the Template and Remove Ruler
function positionShip()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    local spawnPos = template.getPosition()
    local spawnRot = template.getRotation()
    local attachment = BASE_CONST[shipData.size].toolAttachment[shipDirection]
    local leftVector = template.getTransformRight()
    spawnRot.y = spawnRot.y - attachment.rot
    spawnPos = spawnPos + (leftVector * Vector(attachment.pos):magnitude())
    myShip.setRotation(spawnRot)
    myShip.setPosition(spawnPos)

    -- Add context menu for the ruler
	template.clearButtons()
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    print("OPTIONAL: Adjust the Template Rotation, then place it again.")
	template.jointTo(myShip, {type = "Hinge", collision = false, axis = {0,1,0}, anchor = {0,0,0}})
	template.lock()
	myShip.setLock(false)
	ruler.destroy()
    ruler = nil
end

function clearTemplates()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.clearButtons()
    myShip.lock()
    template.destroy()
    template = nil
    if tracker then
        tracker.destroy()
        tracker = nil
    end
end

function clearWarp() 
    rulerA.destroy()
    rulerA = nil
    rulerB.destroy()
    rulerB = nil
    if tracker then
        tracker.destroy()
        tracker = nil
    end
end

function placeWarpTemplate()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.unlock()
    local pos = myShip.getPosition()
    local angle = myShip.getRotation().y
    local offset = Vector(BASE_CONST[shipData.size].warpAttachment):rotateOver("y", angle)
    local offsetA = offset + Vector(-6, 0.05, 0.3):rotateOver("y", angle)
    local offsetB = offset + Vector(-18, 0.05, 0.3):rotateOver("y", angle)
    rulerA = spawnObjectData(TOOLS.ruler_12in)
    rulerA.setPosition(pos + offsetA)
    rulerA.setRotation({0, angle , 0})
    -- Lock the ruler in place
    rulerA.lock()
	
    rulerB = spawnObjectData(TOOLS.ruler_12in)
    rulerB.setPosition(pos + offsetB)
    rulerB.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerB.lock()
    rulerA.createButton({ click_function = "clearWarp",function_owner = self,label= "Clear", position= {-8, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Clear Rulers",})
    placeTracker("aft")
end

function fireTorpedoFore() fireTorpedo("fore") end

function fireTorpedoAft() fireTorpedo("aft") end

function fireTorpedo(direction)
    placeTurningTool(direction)
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

-- Assumes all objects are scale = 1 and their dimensions returned by getBounds() are in inches.

function drawArc(system, jammed) -- system is "sensors", "comms", "weapons"
    local myShip = getObjectFromGUID(saveData.shipGUID)
    local stats = shipData[system]
    local clr = myShip.getColorTint()
    local geometry = BASE_CONST[shipData.size].arcs
    local lines = {}
    -- Axis overlay
    -- local lines = {
    --     {points = {{0,1,0}, {5,1,0}},color = {1,0,0}},
    --     {points = {{0,1,0}, {0,6,0}},color = {0,1,0}},
    --     {points = {{0,1,0}, {0,1,5}},color = {0,0,1}}
    -- } 
    for name, range in pairs(stats) do
        if name ~= "instruments" then
            local arcs
            -- Calculate range
            if jammed and system ~= "weapons" then
                range = 2
            elseif stats.instruments and stats.instruments[name] then
                range = range + shipData.instruments[saveData.dials.alert.value + 1]
            end
            if geometry[name] then
                arcs = {name}
            elseif COMPOUND_ARCS[name] then
                arcs = COMPOUND_ARCS[name]
            else
                log("Unable to find geometry for " .. name .. " arc")
            end
            if arcs then
                local points = {}
                local start = geometry[arcs[1]][1].point + Vector(0, 0.1, 0)
                local stop
                for _, arc in ipairs(arcs) do
                    sweepOverPoints(points, geometry[arc], range)
                    stop = geometry[arc][#geometry[arc]].point + Vector(0, 0.1, 0)
                end
                if name ~= "all" then
                    table.insert(points, 1, start)
                    table.insert(points, stop)
                end
                table.insert(lines, {points = points, color = clr, thickness = thickness})
            end
        end
    end
    myShip.setVectorLines(lines)
end

function sweepOverPoints(points, geometry, range)
    for _, vertex in ipairs(geometry) do
        for theta = vertex.start, vertex.stop do
            table.insert(points, vertex.point + Vector(range * math.cos(math.rad(theta)), 0.1, - range * math.sin(math.rad(theta))))
        end
    end
end

function drawBase()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    local geometry = BASE_CONST[shipData.size].arcs
    local lines = {}
    local points = {}
    local arcs = COMPOUND_ARCS["all"]
    for _, arc in ipairs(arcs) do
        sweepOverPoints(points, geometry[arc], 0)
    end
    table.insert(lines, {points = points, color = Color.Black, thickness = thickness})
    myShip.setVectorLines(lines)
end

function firePhaser()
    drawArc("weapons")
end

function scanCheck()
    drawArc("sensors")
end

function sensorsJammed()
    drawArc("sensors", true)
end

function hailCheck()
    drawArc("comms")
end

function commsJammed()
    drawArc("comms", true)
end

function clearArc(_rangeCir, _range)
    local myShip = getObjectFromGUID(saveData.shipGUID)
    myShip.setVectorLines({})
end

function launchFore() launch("fore") end
function launchAft() launch("aft") end
function launchPort() launch("port") end
function launchStarboard() launch("starboard") end

function launch(direction)
    placeTurningTool(direction)
    template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function launchAuxiliary(direction)
    local myShip = getObjectFromGUID(saveData.shipGUID)
    if direction == "fore" then
        myShip.createButton({function_owner = self, click_function = "launchFore",label = "Fore", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    elseif direction == "aft" then
        myShip.createButton({function_owner = self, click_function = "launchAft",label = "Aft", position = {-1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    else
        return
    end
    myShip.createButton({function_owner = self, click_function = "launchPort",label = "Port", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
    myShip.createButton({function_owner = self, click_function = "launchStarboard",label = "Starboard", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 550, height = 150})
end

function launchAuxFore() launchAuxiliary("fore") end
function launchAuxAft() launchAuxiliary("aft") end

function detach(player, value, id)
    if shipData.auxiliary and not saveData.detached then
        local rot = self.getRotation()
        local pos = self.getPosition()
        -- create cards
        shipData.auxiliary.ship_board.data.LuaScript = self.getLuaScript()
        local parameters = {
            data = shipData.alternate.ship_board.data,
            position = pos + Vector(-3.5, 0, -6):rotateOver("y", rot.y),
            rotation = rot
        }
        altCard = spawnObjectData(parameters)
        altCard.jointTo(self, {type = "Fixed"})
        altCard.interactable = false
        saveData.altGUID = altCard.getGUID()
        local path = ASSET_ROOT .. "factions/" .. shipData.faction .. "/" .. shipData.folder .. "/" .. shipData.type .. "/auxiliary.xml"
        local request = WebRequest.get(path)
        repeat until request.is_done
        if request.is_error or request.text == "404: Not Found" then
            log("Error downloading " .. ship.type .. ".xml")
            return
        else
            shipData.auxiliary.ship_board.data.XmlUI = request.text
        end
        parameters = {
            data = shipData.auxiliary.ship_board.data,
            position = pos + Vector(5.25, 0, -5.25):rotateOver("y", rot.y),
            rotation = rot
        }
        auxCard = spawnObjectData(parameters)
        saveData.auxGUID = auxCard.getGUID()
        launchAuxiliary(shipData.auxiliary.direction)
        -- swap ship models
        swapShip()
        -- check dial ranges
        for name, data in pairs(saveData.dials) do
            rotateDial(name, 0)
        end
        -- change detach button to reattach
        self.UI.setAttributes("saucerSeparation", {onClick = "reattach", text = "Reattach"})
    end
end

function reattach(player, value, id)
    if saveData.detached then
        swapShip()
        if saveData.altGUID then
            local altCard =  getObjectFromGUID(saveData.altGUID)
            if altCard then altCard.destroy() end
            saveData.altGUID = nil
        end
        if saveData.auxGUID then
            local auxCard = getObjectFromGUID(saveData.auxGUID)
            if auxCard then
                local auxData = auxCard.getTable("saveData")
                local auxShip = getObjectFromGUID(auxData.shipGUID)
                if auxShip then auxShip.destroy() end
                auxCard.destroy()
                saveData.auxGUID = nil
            end
        end
        rotateDial("crew", -2)
        -- change reattach button to detach
        self.UI.setAttributes("saucerSeparation", {onClick = "detach", text = "Detach"})
    end
end

function swapShip()
    local myShip = getObjectFromGUID(saveData.shipGUID)
    if default.alternate then
        local color = myShip.getColorTint()
        local pos = myShip.getPosition()
        local rot = myShip.getRotation()
        myShip.destroy()
        if saveData.detached then
            shipData = default
        else
            shipData = default.alternate
        end
        saveData.detached = not saveData.detached
        local parameters = {
            data = generateShipModelData(shipData, color, shipData.model),
            position = pos, rotation = rot
        }
        myShip = spawnObjectData(parameters)
        saveData.shipGUID = myShip.getGUID()
        setShipContextMenu()
    end
end

function swapElements(table1, table2)
    for key, value2 in pairs(table2) do
      local value1 = table1[key]
      if type(value1) == "table" and type(value2) == "table" then
        swapElements(value1, value2)
      else
        table1[key] = value2
        table2[key] = value1
      end
    end
end

function auxiliarySetup(player, value, id)
    if shipData.auxiliary then
         shipData = shipData.auxiliary
         shipData.xml = self.UI.getXml()
    end
    setUp(player, value, id)
end

function adjust_thickness(player, value, id)
    if value == "increase" then
        saveData.thickness = saveData.thickness + 0.01
    elseif value == "decrease" then
        saveData.thickness = saveData.thickness > 0.01 and saveData.thickness - 0.01 or 0.01
    end
    self.UI.setAttribute("thickness", "text", "Thickness: " .. saveData.thickness)
end

-- build 1.0.3.01