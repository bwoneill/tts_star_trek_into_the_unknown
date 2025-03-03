--Federation Constellation Class

alert = 1
power = 1
health = 1
crew = 3
object = nil
shipData = Global.getTable("ASSETS").constellation
shipSize = shipData.size

function onLoad(script_state)
    local state = JSON.decode(script_state)
    if state then
        myShip = getObjectFromGUID(state.myShip_GUID)
        alert = state.alert_value
        alertWheel = getObjectFromGUID(state.alert_GUID)
        power = state.power_value
        powerWheel = getObjectFromGUID(state.power_GUID)
        crew = state.crew_value
        crewWheel = getObjectFromGUID(state.crew_GUID)
        health = state.health_value
        healthWheel = getObjectFromGUID(state.health_GUID)
    end
    local myscale = self.getScale()
    arc_scale = myscale.x --get x scale
    if myShip and alertWheel and crewWheel and healthWheel and powerWheel then
        setUp()
    end
end

function onSave()
    local state = {
        myShip_GUID = myShip and myShip.getGUID() or nil,
        alert_value = alert,
        alert_GUID = alertWheel and alertWheel.getGUID() or nil,
        power_value = power,
        power_GUID = powerWheel and powerWheel.getGUID() or nil,
        crew_value = crew,
        crew_GUID = crewWheel and crewWheel.getGUID() or nil,
        health_value = health,
        health_GUID = healthWheel and healthWheel.getGUID() or nil
    }
    return JSON.encode(state)
end

function setUp()

    self.UI.setAttribute("setUpBtn", "active", "false")
    
    self.UI.setAttribute("alertUpBtn", "active", "true")
    self.UI.setAttribute("alertDownBtn", "active", "true")
    self.UI.setAttribute("powerUpBtn", "active", "true")
    self.UI.setAttribute("powerDownBtn", "active", "true")
    self.UI.setAttribute("healthUpBtn", "active", "true")
    self.UI.setAttribute("healthDownBtn", "active", "true")
    self.UI.setAttribute("crewUpBtn", "active", "true")
    self.UI.setAttribute("crewDownBtn", "active", "true")
    self.UI.setAttribute("phaserBtn", "active", "true")
    self.UI.setAttribute("torpedoBtnF", "active", "true")
    self.UI.setAttribute("torpedoBtnA", "active", "true")
    self.UI.setAttribute("warpBtn", "active", "true")
    self.UI.setAttribute("moveBtnLeft", "active", "true")
    self.UI.setAttribute("moveBtnRight", "active", "true")
    self.UI.setAttribute("scanBtn", "active", "true")
    self.UI.setAttribute("commsBtn", "active", "true")
    self.UI.setAttribute("clear", "active", "true")
    self.UI.setAttribute("scanJammed", "active", "true")
    self.UI.setAttribute("commsJammed", "active", "true")

    -- Get the board's current position and rotation
    local pos = self.getPosition()
    local rot = self.getRotation()
    
    -- Alert Wheel
    if not alertWheel then
        alertWheel = Global.call("spawnAsset",shipData.alert_dial)
        alertWheel.setPosition(pos + Vector(-2.7, -0.1, 0.2):rotateOver("y", rot.y))
        alertWheel.setRotation(rot)
        alertWheel.interactable = false
    end
    alertWheel.jointTo(self, {type = "Fixed"})

    -- Power Wheel
    if not powerWheel then
        powerWheel = Global.call("spawnAsset",shipData.power_dial)
        powerWheel.setPosition(pos + Vector(0.6, -0.1, -2.9):rotateOver("y", rot.y))
        powerWheel.setRotation(rot)
        powerWheel.interactable = false
    end
    powerWheel.jointTo(self, {type = "Fixed"})

    -- Crew Wheel
    if not crewWheel then
        crewWheel = Global.call("spawnAsset",shipData.crew_dial)
        crewWheel.setPosition(pos + Vector(3.4, -0.1, 0.2):rotateOver("y", rot.y))
        crewWheel.setRotation(rot)
        crewWheel.interactable = false
    end
    crewWheel.jointTo(self, {type = "Fixed"})

    -- Health Wheel
    if not healthWheel then
        healthWheel = Global.call("spawnAsset", shipData.hull_dial)
        healthWheel.setPosition(pos + Vector(3.8, -0.1, -2.6):rotateOver("y", rot.y))
        healthWheel.setRotation(rot)
        healthWheel.interactable = false
    end
    healthWheel.jointTo(self, {type = "Fixed"})

    -- Ship
    if not myShip then
        myShip = Global.call("spawnModel", shipData)
        myShip.setPosition(pos + Vector(5, 0, -5):rotateOver("y", rot.y))
        myShip.setRotation(rot)
        myShip.setVar("myShipBase", "Small")
        myShip.addContextMenuItem('Impulse', function() impulseMoveStart() end, false)
        myShip.addContextMenuItem('Warp Speed', function() placeWarpTemplate() end, false)
	end
    baseSize = myShip.getBoundsNormalized().size
end

-- Dials

function rotateDial(dial, rot)
    local rotation = self.getRotation()
    rotation.y = rotation.y + rot
    dial.jointTo()
    dial.setRotation(rotation)
    dial.jointTo(self, {type = "Fixed"})
end

function alertUp()
	if alert <=5 then
        alert = alert + 1
        rotateDial(alertWheel, (1 - alert) * 40)
	end
end

function alertDown()
	if alert >=2 then
        alert = alert - 1
        rotateDial(alertWheel, (1 - alert) * 40)
	end
end

function powerUp()
	if power >=2  then
        power = power - 1
        rotateDial(powerWheel, (power - 1) * 40)
	end
end

function powerDown()
	if power <=7 then
        power = power + 1
        rotateDial(powerWheel, (power - 1) * 40)
	end
end

function hullUp()
	if health >=2  then
        health = health - 1 
        rotateDial(healthWheel, (health - 1) * 36)
	end
end

function hullDown()
	if health <=8 then
        health = health + 1
        rotateDial(healthWheel, (health -1) * 36)
	end
end

function crewUp()
	if crew >=2 then
        crew = crew - 1
        rotateDial(crewWheel, (crew - 3) * 40)
	end
end

function crewDown()
	if crew <=6 then
        crew = crew + 1
        rotateDial(crewWheel, (crew - 3) * 40)
	end
end

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
    local attachment = shipData.size.toolAttachment[side]
    local rel_pos = attachment.pos:copy()
    local pos = myShip.getPosition()
    local rot = myShip.getRotation().y
    rel_pos:rotateOver("y", rot)
    rot = rot + attachment.rot
    template = Global.call("spawnTurningTool")
    template.setPosition(pos + rel_pos)
    template.setRotation({0, rot, 0})
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
    template.jointTo(myShip, {type = "Hinge", collision = false, break_force = 100.0, axis = {0,1,0}, anchor = {0,0,0}})
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
    spawnPos = spawnPos + (leftVector * attachment.pos:magnitude())
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

function clearTemplatesA()
    template.destroy()
end

function clearWarp() 
    rulerA.destroy() 
    rulerB.destroy() 
end

function placeWarpTemplate()
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
	template.createButton({ click_function = "clearTemplatesA",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
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
    return m * min + origin
end

function drawArc(system, jammed) -- system is "sensors", "comms", "weapons"
    local arcs = shipData[system]
    local ARCS = Global.getVar("ARCS")
    local clr = myShip.getColorTint()
    local size = myShip.getBoundsNormalized().size
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
        local origin = shipData.size.arcOffsets[arc] or Vector(0, 0, 0)
        if ARCS[arc] then
            -- Calculate range
            if jammed and system ~= "weapons" then
                range = 2
            elseif arcs.instruments and arcs.instruments[arc] then
                range = range + shipData.instruments[alert]
            end
            -- Calculate vectors
            local start_angle = ARCS[arc][1]
            local end_angle = ARCS[arc][2]
            local points = {}
            local theta = start_angle
            local m = Vector(range, 0, 0)
            m:rotateOver("y", start_angle)
            local focal_point = calculateIntersect(size, m, origin)
            log(arc)
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