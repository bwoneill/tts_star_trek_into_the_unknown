--Federation Galaxy Class

shipData = Global.getTable("ASSETS").galaxy

function onLoad(script_state)
    -- local load_state = JSON.decode(script_state)
    if load_tate then
        shipData = load_state
    else
        shipData = Global.getTable("ASSETS").galaxy
    end
end

function onSave()
    return JSON.encode(shipData)
end

function setUp()
    
    for _, button in pairs(self.UI.getXmlTable()) do
        self.UI.setAttribute(button.attributes.id, "active", button.attributes.active == "false" and "true" or "false")
    end

    -- Get the board's current position and rotation
    local pos = self.getPosition()
    local rot = self.getRotation()
    
    for name, dial in pairs(shipData.dials) do
        if not dial.GUID then
            local object = Global.call("spawnAsset", dial)
            dial.GUID = object.getGUID()
            dial.value = 0
            object.setPosition(pos +  Vector(dial.pos):rotateOver("y", rot.y))
            object.setRotation(rot)
            object.interactable = false
            object.jointTo(self, {type = "Fixed"})
        end
    end

    -- Ship
    if not myShip then
        myShip = Global.call("spawnModel", shipData)
        myShip.setPosition(pos + Vector(5, 0, -5):rotateOver("y", rot.y))
        myShip.setRotation(rot)
        myShip.setVar("myShipBase", "Small")
        myShip.addContextMenuItem('Impulse', function() impulseMoveStart() end, false)
        myShip.addContextMenuItem('Warp Speed', function() placeWarpTemplate() end, false)
        shipData.shipGUID = myShip.getGUID()
	end
end

function constrainValue(value, min, max)
    value = value <= max and value or max
    value = value >= min and value or min
    return value
end

-- Dials

function rotateDial(dialData, difference)
    local rot = self.getRotation()
    local dial = getObjectFromGUID(dialData.GUID)
    local value = constrainValue(dialData.value + difference, dialData.min, dialData.max)
    if value ~= dialData.value then
        dialData.value = value
        rot.y = rot.y + dialData.rot * dialData.value
        dial.jointTo()
        dial.setRotation(rot)
        dial.jointTo(self, {type = "Fixed"})
    end
end

function alertUp() rotateDial(shipData.dials["alert"], 1) end

function alertDown() rotateDial(shipData.dials["alert"], -1) end

function powerUp() rotateDial(shipData.dials["power"], -1) end

function powerDown() rotateDial(shipData.dials["power"], 1) end

function hullUp() rotateDial(shipData.dials["hull"], -1) end

function hullDown() rotateDial(shipData.dials["hull"], 1) end

function crewUp() rotateDial(shipData.dials["crew"], -1) end

function crewDown() rotateDial(shipData.dials["crew"], 1) end

-- Impulse

function impulseMoveStart()
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

function placeTurningTool(side)
    myShip.clearButtons()
    myShip.lock()
    shipDirection = side
    log(side)
    local attachment = shipData.size.toolAttachment[side]
    local pos = myShip.getPosition()
    local rot = myShip.getRotation().y
    template = Global.call("spawnTurningTool")
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
    ruler = Global.call("spawnRuler")
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
    local spawnPos = template.getPosition()
    local spawnRot = template.getRotation()
    local attachment = shipData.size.toolAttachment[shipDirection]
    local leftVector = template.getTransformRight()
    spawnRot.y = spawnRot.y - attachment.rot
    spawnPos = spawnPos + (leftVector * Vector(attachment.pos):magnitude())
    myShip.setRotation(spawnRot)
    myShip.setPosition(spawnPos)

    -- Add context menu for the ruler
	template.clearButtons()
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    print("OPTIONAL: Adjust the Template Rotatation, then place it again.")
	template.jointTo(myShip, {type = "Hinge", collision = false, axis = {0,1,0}, anchor = {0,0,0}})
	template.lock()
	myShip.setLock(false)
	ruler.destroy()
end

function clearTemplates()
    myShip.clearButtons()
    myShip.lock()
    template.destroy()
end

function clearWarp() 
    rulerA.destroy() 
    rulerB.destroy() 
end

function placeWarpTemplate()
    myShip.unlock()
    local pos = myShip.getPosition()
    local angle = myShip.getRotation().y
    local offset = shipData.size.warpAttachment:copy():rotateOver("y", angle)
    local offsetA = offset + Vector(-6, 0.05, 0.3):rotateOver("y", angle)
    local offsetB = offset + Vector(-18, 0.05, 0.3):rotateOver("y", angle)
	
    rulerA = Global.call("spawnRuler")
    rulerA.setPosition(pos + offsetA)
    rulerA.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerA.lock()
	
    rulerB = Global.call("spawnRuler")
    rulerB.setPosition(pos + offsetB)
    rulerB.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerB.lock()
	rulerA.createButton({ click_function = "clearWarp",function_owner = self,label= "Clear", position= {-8, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Clear Rulers",})
end

function fireTorpedoFore() fireTorpedo("fore") end

function fireTorpedoAft() fireTorpedo("aft") end

function fireTorpedo(direction)
    placeTurningTool(direction)
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

-- Single Primary Arc Drawing Code (Solid Outer Arc Only, 6" from the object's front edge)
-- Assumes all objects are scale = 1 and their dimensions returned by getBounds() are in inches.

function calculateIntersect(size, m, origin)
    local distances = {
        size.x/m.x/2 - origin.x,
        -size.x/m.x/2 - origin.x,
        size.z/m.z/2 - origin.z,
        -size.z/m.z/2 - origin.z
    }
    local min = 10000
    for i, d in ipairs(distances) do
        if d > 0 and d < min then
            min = d
        end
    end
    local value = m * min + origin
    value.x = constrainValue(value.x, -size.x/2, size.x/2)
    value.z = constrainValue(value.z, -size.z/2, size.z/2)
    return value
end

function drawArc(system, jammed) -- system is "sensors", "comms", "weapons"
    local arcs = shipData[system]
    local ARCS = Global.getVar("ARCS")
    local clr = myShip.getColorTint()
    local size = shipData.size.bounds
    local lines = {}
    --[[ Axis overlay
        local v = Vector(1,1,0)
        v:rotateOver("y", 45)
        local lines = {
            {points = {{0,1,0}, {5,1,0}},color = {1,0,0}},
            {points = {{0,1,0}, {0,6,0}},color = {0,1,0}},
            {points = {{0,1,0}, {0,1,5}},color = {0,0,1}}
        } 
        --]]
    for arc, range in pairs(arcs) do
        local origin = Vector(shipData.size.arcOffsets[arc]) or Vector(0, 0, 0)
        origin.y = origin.y + shipData.size.arcHeight
        if ARCS[arc] then
            -- Calculate range
            if jammed and system ~= "weapons" then
                range = 2
            elseif arcs.instruments and arcs.instruments[arc] then
                range = range + shipData.instruments[shipData.dials.alert.value + 1]
            end
            -- Calculate vectors
            local start_angle = ARCS[arc][1]
            local end_angle = ARCS[arc][2]
            local points = {}
            local theta = start_angle
            local m = Vector(range, 0, 0)
            m:rotateOver("y", start_angle)
            local focal_point = calculateIntersect(size, m, origin)
            if arc ~= "all" then
                table.insert(points, focal_point:copy())
            end
            while theta < 360 and theta < end_angle do
                table.insert(points, focal_point + m)
                if theta == -90 or theta == 270 then
                    focal_point.x = size.x/2
                elseif theta == 0 then
                    focal_point.z = -size.z/2
                elseif theta == 90 then
                    focal_point.x = -size.x/2
                elseif theta == 180 then
                    focal_point.z = size.z/2
                end
                if theta % 90 == 0 then
                    table.insert(points, focal_point + m)
                end
                theta = theta + 1
                m:rotateOver("y", 1)
            end
            table.insert(points, focal_point + m)
            focal_point = calculateIntersect(size, m, origin)
            table.insert(points, focal_point + m)
            if arc ~= "all" then
                table.insert(points, focal_point:copy())
            end
            table.insert(lines, {points = points, color = clr, thickness = 0.01})
        end
        -- do something
    end
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
    myShip.setVectorLines({})
end

-- Saucer separtaion code

state = 0
myShipBackup = nil
mySaucer = nil
function detachSaucer()
    if state == 0 then
        pos = myShip.getPosition()
        rot = myShip.getRotation()
        shipHull = getObjectFromGUID("b5188f").clone()
        myShipBackup = myShip.getGUID()
        myShip.setPosition({-32.24, -0.02, 105.33})
        shipHull.setPosition(pos)
        shipHull.setRotation(rot)
        myShip = shipHull
        state = 1
        myShip.lock()
        myShip.createButton({function_owner = self, click_function = "launchFront",label = "Front", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
        myShip.createButton({function_owner = self, click_function = "launchLeft",label = "Left", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
        myShip.createButton({function_owner = self, click_function = "launchRight",label = "Right", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
        mySaucer = getObjectFromGUID("75ad43").clone()
        mySaucer.setPosition(pos)
        mySaucer.setRotation(rot)
        pos2 = self.getPosition()
        hullCard = getObjectFromGUID("5137f3").clone()
        hullCard.setPosition({pos2.x+1,pos2.y+.5,pos2.z})
        saucerCard = getObjectFromGUID("0077fb").clone()
        saucerCard.setPosition({pos2.x-1,pos2.y+.5,pos2.z})
        saucerCard.createButton({function_owner = self, click_function = "fireSaucerPhaser",label = "Fire", position = {1,.2,.5}, rotation = {0, 0, 0}, width = 200, height = 100})
        saucerCard.createButton({function_owner = self, click_function = "scanSaucer",label = "Scan", position = {1,.2,0}, rotation = {0, 0, 0}, width = 200, height = 100})
        saucerCard.createButton({function_owner = self, click_function = "hailSaucer",label = "Hail", position = {1,.2,-.5}, rotation = {0, 0, 0}, width = 200, height = 100})
        saucerCard.createButton({function_owner = self, click_function = "impulseMoveSaucer",label = "Move", position = {1,.2,-1}, rotation = {0, 0, 0}, width = 200, height = 100})
        saucerCard.createButton({function_owner = self, click_function = "placeWarpTemplateSaucer",label = "Warp", position = {1,.2,-1.5}, rotation = {0, 0, 0}, width = 200, height = 100})
        
        hullCard.createButton({function_owner = self, click_function = "firePhaser",label = "Fire", position = {1,.2,.5}, rotation = {0, 0, 0}, width = 200, height = 100})
        hullCard.createButton({function_owner = self, click_function = "scanHull",label = "Scan", position = {1,.2,0}, rotation = {0, 0, 0}, width = 200, height = 100})
        hullCard.createButton({function_owner = self, click_function = "hailHull",label = "Hail", position = {1,.2,-.5}, rotation = {0, 0, 0}, width = 200, height = 100})
        hullCard.createButton({function_owner = self, click_function = "impulseMoveStart",label = "Move", position = {1,.2,-1}, rotation = {0, 0, 0}, width = 200, height = 100})
        hullCard.createButton({function_owner = self, click_function = "placeWarpTemplate",label = "Warp", position = {1,.2,-1.5}, rotation = {0, 0, 0}, width = 200, height = 100})

	elseif state == 1 then
        myShipBase = getObjectFromGUID(myShipBackup)
        pos = myShip.getPosition()
        myShipBase.setPosition(pos)
        myShipBase.setRotation(rot)
        shipHull = myShip
        myShip = myShipBase
        state = 0
        shipHull.destroy()
        mySaucer.destroy()
        hullCard.destroy()
        saucerCard.destroy()
	end
end

function launchLeft() myShip.clearButtons() placeToolToShipLeft() template.clearButtons()
    template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function launchRight() myShip.clearButtons() placeToolToShipRight() template.clearButtons()
    template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function launchFront() myShip.clearButtons() placeToolToShipFront() template.clearButtons()
    template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
end

function impulseMoveSaucer()
    mySaucer.createButton({function_owner = self, click_function = "impulseSaucerFront",label = "Lateral", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    mySaucer.createButton({function_owner = self, click_function = "impulseSaucerBack",label = "Reverse", position = {-1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
    mySaucer.createButton({function_owner = self, click_function = "impulseSaucerLeft",label = "Left", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
    mySaucer.createButton({function_owner = self, click_function = "impulseSaucerRight",label = "Right", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
end
function impulseSaucerFront() mySaucer.clearButtons() placeToolToShipFrontSaucer() end
function impulseSaucerBack() mySaucer.clearButtons() placeToolToShipBackSaucer() end
function impulseSaucerLeft() mySaucer.clearButtons() placeToolToShipLeftSaucer() end
function impulseSaucerRight() mySaucer.clearButtons() placeToolToShipRightSaucer() end

function placeToolToShipFrontSaucer()
    shipDirection = "Front"
    mySaucer.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = mySaucer.getTransformRight()
    local distance   = -saucerSize.length
    local spawnPos   = mySaucer.getPosition() + (leftVector * distance)
    local spawnRot   = mySaucer.getRotation()

    template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+0, spawnRot.z})
    })

    template.jointTo(mySaucer, {
        ["type"]        = "Hinge",
        ["collision"]   = false,
        ["break_force"]  = 300.0,
        ["axis"]        = {0,1,0},
        ["anchor"]      = {0,0,0}
    })
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end


function placeToolToShipBackSaucer()
shipDirection = "Back"
    mySaucer.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = mySaucer.getTransformRight()
    local distance   = saucerSize.length
    local spawnPos   = mySaucer.getPosition() + (leftVector * distance)
    local spawnRot   = mySaucer.getRotation()

    template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+180, spawnRot.z})
    })

    template.jointTo(mySaucer, {
        ["type"]        = "Hinge",
        ["collision"]   = false,
        ["break_force"]  = 300.0,
        ["axis"]        = {0,1,0},
        ["anchor"]      = {0,0,0}
    })
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end

function placeToolToShipLeftSaucer()
    shipDirection = "Left"
    mySaucer.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = mySaucer.getTransformForward()
    local distance   = -saucerSize.width
    local spawnPos   = mySaucer.getPosition() + (leftVector * distance)
    local spawnRot   = mySaucer.getRotation()

    template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y-90, spawnRot.z})
    })

    template.jointTo(mySaucer, {
        ["type"]        = "Hinge",
        ["collision"]   = false,
        ["break_force"]  = 300.0,
        ["axis"]        = {0,1,0},
        ["anchor"]      = {0,0,0}
    })
    template.createButton({ click_function = "positionRulerLeftSaucer", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    template.createButton({ click_function = "positionRulerRightSaucer", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end

function placeToolToShipRightSaucer()
shipDirection = "Right"
    mySaucer.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = mySaucer.getTransformForward()
    local distance   = saucerSize.width
    local spawnPos   = mySaucer.getPosition() + (leftVector * distance)
    local spawnRot   = mySaucer.getRotation()

    template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+90, spawnRot.z})
    })

    template.jointTo(mySaucer, {
        ["type"]        = "Hinge",
        ["collision"]   = false,
        ["break_force"]  = 300.0,
        ["axis"]        = {0,1,0},
        ["anchor"]      = {0,0,0}
    })
    	template.createButton({ click_function = "positionRulerLeftSaucer", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    	template.createButton({ click_function = "positionRulerRightSaucer", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end



-- Step 2: Position the Ruler
function positionRulerRightSaucer()
ruler = getObjectFromGUID("40c1ae").clone()

    pos = template.getPosition()
    angle = template.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
    forwardOffset = -5.925
    sideOffset = 1.4

	offsetX = math.sin(math.rad(angle)) * forwardOffset + math.sin(math.rad(angle + 90)) * sideOffset
    offsetZ = math.cos(math.rad(angle)) * forwardOffset + math.cos(math.rad(angle + 90)) * sideOffset
    -- Set the ruler's position and rotation
	
    ruler.setPosition({pos.x - offsetX, pos.y+.1, pos.z - offsetZ})
    ruler.setRotation({0, angle + 90, 0})

    -- Lock the ruler in place
    ruler.lock()
    template.clearButtons()
	template.createButton({ click_function = "positionShipSaucer",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	print("Adjust template along the ruler before placing ship")
    --template.reload()
end

function positionRulerLeftSaucer()
    ruler = getObjectFromGUID("40c1ae").clone()

    pos = template.getPosition()
    angle = template.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
    forwardOffset = -5.925
    sideOffset = 1.45

	offsetX = math.sin(math.rad(angle)) * forwardOffset + math.sin(math.rad(angle - 90)) * sideOffset
    offsetZ = math.cos(math.rad(angle)) * forwardOffset + math.cos(math.rad(angle - 90)) * sideOffset
    -- Set the ruler's position and rotation
	
    ruler.setPosition({pos.x + offsetX, pos.y+.1, pos.z + offsetZ})
    ruler.setRotation({0, angle - 90, 0})

    -- Lock the ruler in place
    ruler.lock()
    template.clearButtons()
	template.createButton({ click_function = "positionShipSaucer",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	print("Adjust template along the ruler before placing ship")
    --template.reload()
end


-- Step 3: Position Ship to the Template and Remove Ruler
function positionShipSaucer()


    if shipDirection == "Left" then

        local leftVector = template.getTransformRight()
        local distance   = shipSize.width
        local spawnPos   = template.getPosition() + (leftVector * distance)
        local spawnRot   = template.getRotation()

        mySaucer.setPosition(spawnPos)
        mySaucer.setRotation({spawnRot.x, spawnRot.y+90, spawnRot.z})
    elseif shipDirection == "Right" then  

        local leftVector = template.getTransformRight()
        local distance   = shipSize.width
        local spawnPos   = template.getPosition() + (leftVector * distance)
        local spawnRot   = template.getRotation()

        mySaucer.setPosition(spawnPos)
        mySaucer.setRotation({spawnRot.x, spawnRot.y-90, spawnRot.z})
    elseif shipDirection == "Front" then  

        local leftVector = template.getTransformRight()
        local distance   = shipSize.length
        local spawnPos   = template.getPosition() + (leftVector * distance)
        local spawnRot   = template.getRotation()

        mySaucer.setPosition(spawnPos)
        mySaucer.setRotation({spawnRot.x, spawnRot.y-0, spawnRot.z}) 
    elseif shipDirection == "Back" then  

        local leftVector = template.getTransformRight()
        local distance   = shipSize.length
        local spawnPos   = template.getPosition() + (leftVector * distance)
        local spawnRot   = template.getRotation()

        mySaucer.setPosition(spawnPos)
        mySaucer.setRotation({spawnRot.x, spawnRot.y-180, spawnRot.z})
    end


    -- Add context menu for the ruler
	template.clearButtons()
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    print("OPTIONAL: Adjust the Template Rotatation, then place it again.")
	template.jointTo(mySaucer, {
        ["type"]        = "Hinge",
        ["collision"]   = false,
        ["axis"]        = {0,1,0},
        ["anchor"]      = {0,0,0}
    })
	template.lock()
	mySaucer.setLock(false)
	ruler.destroy()

end

function placeWarpTemplateSaucer()
	rulerA = getObjectFromGUID(rulerGUID).clone()
	rulerB = getObjectFromGUID(rulerGUID).clone()
    pos = mySaucer.getPosition()
    angle = mySaucer.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
    forwardOffsetA = -1.71
    sideOffsetA = 5.6
    forwardOffsetB = -1.71
    sideOffsetB = 11.5
	offsetX = math.sin(math.rad(angle)) * forwardOffsetA + math.sin(math.rad(angle + 90)) * sideOffsetA
    offsetZ = math.cos(math.rad(angle)) * forwardOffsetA + math.cos(math.rad(angle + 90)) * sideOffsetA
    -- Set the ruler's position and rotation
	
    rulerA.setPosition({pos.x - offsetX, pos.y+.05, pos.z - offsetZ})
    rulerA.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerA.lock()
	
	offsetX = math.sin(math.rad(angle)) * forwardOffsetB + math.sin(math.rad(angle + 90)) * sideOffsetB
    offsetZ = math.cos(math.rad(angle)) * forwardOffsetB + math.cos(math.rad(angle + 90)) * sideOffsetB
	rulerB.setPosition({pos.x - offsetX, pos.y+.05, pos.z - offsetZ})
    rulerB.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerB.lock()
	rulerA.createButton({ click_function = "clearWarp",function_owner = self,label= "Clear", position= {-8, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Clear Rulers",})
	
end

function fireSaucerPhaser()

    if arc_drawn then
        clearArcSaucer()
    else
        _rangeCir = 6
		_range = 0
		_range = _range + _rangeCir
        arc_def = scanArc
        arc_defB = scanArcFront

        bounds = mySaucer.getBounds()
        front_edge_distance = bounds.size.z / 2
        
        local desired_arc_distance_cir = front_edge_distance + _rangeCir - 0.4
        local desired_arc_distance_front = front_edge_distance + _range - 0.4

        local all_lines = {}

        -- Draw arcs from arc_def
        for i, single_arc_def in ipairs(arc_def) do
            single_arc_def.range = {desired_arc_distance_cir, desired_arc_distance_cir}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Draw arcs from arc_defB
        for i, single_arc_def in ipairs(arc_defB) do
            single_arc_def.range = {desired_arc_distance_front, desired_arc_distance_front}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Now set them all at once
        mySaucer.setVectorLines(all_lines)
        arc_drawn = true
    end
end

function scanSaucer()

    if arc_drawn then
        clearArcSaucer()
    else
        _rangeCir = 4
		_range = 2
		_range = _range + _rangeCir
        arc_def = scanArc
        arc_defB = scanArcFront

        bounds = mySaucer.getBounds()
        front_edge_distance = bounds.size.z / 2
        
        local desired_arc_distance_cir = front_edge_distance + _rangeCir - 0.4
        local desired_arc_distance_front = front_edge_distance + _range - 0.4

        local all_lines = {}

        -- Draw arcs from arc_def
        for i, single_arc_def in ipairs(arc_def) do
            single_arc_def.range = {desired_arc_distance_cir, desired_arc_distance_cir}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Draw arcs from arc_defB
        for i, single_arc_def in ipairs(arc_defB) do
            single_arc_def.range = {desired_arc_distance_front, desired_arc_distance_front}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Now set them all at once
        mySaucer.setVectorLines(all_lines)
        arc_drawn = true
    end
end

function hailSaucer()

    if arc_drawn then
        clearArcSaucer()
    else
        _rangeCir = 6
		_range = 2
		_range = _range + _rangeCir
        arc_def = scanArc
        arc_defB = scanArcFront

        bounds = mySaucer.getBounds()
        front_edge_distance = bounds.size.z / 2
        
        local desired_arc_distance_cir = front_edge_distance + _rangeCir - 0.4
        local desired_arc_distance_front = front_edge_distance + _range - 0.4

        local all_lines = {}

        -- Draw arcs from arc_def
        for i, single_arc_def in ipairs(arc_def) do
            single_arc_def.range = {desired_arc_distance_cir, desired_arc_distance_cir}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Draw arcs from arc_defB
        for i, single_arc_def in ipairs(arc_defB) do
            single_arc_def.range = {desired_arc_distance_front, desired_arc_distance_front}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Now set them all at once
        mySaucer.setVectorLines(all_lines)
        arc_drawn = true
    end
end

function scanHull()
	callTag = "Alert"
	locate()
	
	if object.getStateId() == 1 or object.getStateId() == 2 then _range = 3 end
	if object.getStateId() == 3 or object.getStateId() == 4 then _range = 2 end
	if object.getStateId() == 5 or object.getStateId() == 6 then _range = 1 end
	if object.getStateId() == 7 then _range = 0 end
	
    if arc_drawn then
        clearArc()
    else
        _rangeCir = 2
		_range = _range + _rangeCir +2
        arc_def = scanArc
        arc_defB = scanArcFront

        bounds = myShip.getBounds()
        front_edge_distance = bounds.size.z / 2
        
        local desired_arc_distance_cir = front_edge_distance + _rangeCir - 0.4
        local desired_arc_distance_front = front_edge_distance + _range - 0.4

        local all_lines = {}

        -- Draw arcs from arc_def
        for i, single_arc_def in ipairs(arc_def) do
            single_arc_def.range = {desired_arc_distance_cir, desired_arc_distance_cir}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Draw arcs from arc_defB
        for i, single_arc_def in ipairs(arc_defB) do
            single_arc_def.range = {desired_arc_distance_front, desired_arc_distance_front}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Now set them all at once
        myShip.setVectorLines(all_lines)
        arc_drawn = true
    end
end

function hailHull()
	callTag = "Alert"
	locate()
	
	if object.getStateId() == 1 or object.getStateId() == 2 then _range = 3 end
	if object.getStateId() == 3 or object.getStateId() == 4 then _range = 2 end
	if object.getStateId() == 5 or object.getStateId() == 6 then _range = 1 end
	if object.getStateId() == 7 then _range = 0 end
	
    if arc_drawn then
        clearArc()
    else
        _rangeCir = 2
		_range = _range + _rangeCir +2
        arc_def = scanArc
        arc_defB = scanArcFront

        bounds = myShip.getBounds()
        front_edge_distance = bounds.size.z / 2
        
        local desired_arc_distance_cir = front_edge_distance + _rangeCir - 0.4
        local desired_arc_distance_front = front_edge_distance + _range - 0.4

        local all_lines = {}

        -- Draw arcs from arc_def
        for i, single_arc_def in ipairs(arc_def) do
            single_arc_def.range = {desired_arc_distance_cir, desired_arc_distance_cir}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Draw arcs from arc_defB
        for i, single_arc_def in ipairs(arc_defB) do
            single_arc_def.range = {desired_arc_distance_front, desired_arc_distance_front}
            local outer_points = computeArcPoints(single_arc_def)
            table.insert(all_lines, {
                points = outer_points,
                color = single_arc_def.clr1,
                thickness = single_arc_def.thic
            })
        end

        -- Now set them all at once
        myShip.setVectorLines(all_lines)
        arc_drawn = true
    end
end

function clearArcSaucer(_rangeCir, _range)
    mySaucer.setVectorLines({})
    arc_drawn = false
end