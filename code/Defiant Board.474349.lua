--Federation Defiant Class
shipSize = Global.getTable("shipSize").small

templateGUID = "c52346" -- Replace with your template's GUID
rulerGUID = "40c1ae" -- Use the known GUID of the ruler
 
function onLoad()

  local myscale = self.getScale()
  arc_scale = myscale.x --get x scale
  log (arc_scale)
end

local shipClass = getObjectFromGUID("ff2cf4")
local alertToken = getObjectFromGUID("773f3a")
local powerToken = getObjectFromGUID("f5bb7f")
local healthToken = getObjectFromGUID("b21c74")
local crewToken = getObjectFromGUID("a00a3b")

function setUp()
    local shipBag = getObjectFromGUID("539a50").clone()
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
    self.UI.setAttribute("cannonBtn", "active", "true")
    self.UI.setAttribute("torpedoBtnF", "active", "true")
    self.UI.setAttribute("torpedoBtnA", "active", "true")
    self.UI.setAttribute("warpBtn", "active", "true")
    self.UI.setAttribute("impulseMove", "active", "true")
    self.UI.setAttribute("scanBtn", "active", "true")
    self.UI.setAttribute("commsBtn", "active", "true")

    -- Get the board's current position and rotation
    local pos = self.getPosition()
    local rot = self.getRotation()

    -- Function to calculate world position from local coordinates
    local function calculateWorldPosition(localX, localZ)
        local angle = math.rad(rot.y)
        local worldX = pos.x + localX * math.cos(angle) - localZ * math.sin(angle)
        local worldZ = pos.z + localX * math.sin(angle) + localZ * math.cos(angle)
        return {x = worldX, y = pos.y - .1, z = worldZ} -- Adjust Y position
    end

    -- Alert Wheel
    local alertPos = calculateWorldPosition(3, -0.2)
    local alertWheel = shipBag.takeObject({ guid = alertToken })
    alertWheel.setPosition({alertPos.x, alertPos.y, alertPos.z})
    alertWheel.setRotation(rot)
    alertWheel.jointTo(self, {["type"] = "Fixed"})

    -- Power Wheel
    local powerPos = calculateWorldPosition(-0.6, 3.6)
    local powerWheel = shipBag.takeObject({ guid = powerToken })
    powerWheel.setPosition({powerPos.x, powerPos.y, powerPos.z})
    powerWheel.setRotation(rot)
    powerWheel.jointTo(self, {["type"] = "Fixed"})

    -- Crew Wheel
    local crewPos = calculateWorldPosition(-4.5, -0.2)
    local crewWheel = shipBag.takeObject({ guid = crewToken })
    crewWheel.setPosition({crewPos.x, crewPos.y, crewPos.z})
    crewWheel.setRotation(rot)
    crewWheel.jointTo(self, {["type"] = "Fixed"})

    -- Health Wheel
    local healthPos = calculateWorldPosition(-4.6, 2.6)
    local healthWheel = shipBag.takeObject({ guid = healthToken })
    healthWheel.setPosition({healthPos.x, healthPos.y, healthPos.z})
    healthWheel.setRotation(rot)
    healthWheel.jointTo(self, {["type"] = "Fixed"})

    -- Ship
    local shipPos = calculateWorldPosition(-5, 5)
    myShip = shipBag.takeObject({ guid = shipClass })
    myShip.setPosition({shipPos.x, shipPos.y, shipPos.z})
    myShip.setRotation(rot)
    myShip.setVar("myShipBase", "Small")
    myShip.addContextMenuItem('Move Left', function() placeTemplate("left") end, false)
    myShip.addContextMenuItem('Move Right', function() placeTemplate("right") end, false)
    myShip.addContextMenuItem('Warp Speed', function() placeWarpTemplate() end, false)
	
	shipBag.destroy()
end


--<><>--<><>--

function impulseMoveStart()
myShip.createButton({function_owner = self, click_function = "impulseMoveFront",label = "Lateral", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
myShip.createButton({function_owner = self, click_function = "impulseMoveBack",label = "Reverse", position = {-1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
myShip.createButton({function_owner = self, click_function = "impulseMoveLeft",label = "Left", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
myShip.createButton({function_owner = self, click_function = "impulseMoveRight",label = "Right", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
end

function impulseMoveFront() myShip.clearButtons() placeToolToShipFront() end
function impulseMoveBack() myShip.clearButtons() placeToolToShipBack() end
function impulseMoveLeft() myShip.clearButtons() placeToolToShipLeft() end
function impulseMoveRight() myShip.clearButtons() placeToolToShipRight() end

function placeToolToShipFront()
shipDirection = "Front"
    myShip.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = myShip.getTransformRight()
    local distance   = -shipSize.length
    local spawnPos   = myShip.getPosition() + (leftVector * distance)
    local spawnRot   = myShip.getRotation()

    	template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+0, spawnRot.z})
    })

    	template.jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["break_force"]  = 300.0,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
    	template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    	template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end


function placeToolToShipBack()
shipDirection = "Back"
    myShip.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = myShip.getTransformRight()
    local distance   = shipSize.length
    local spawnPos   = myShip.getPosition() + (leftVector * distance)
    local spawnRot   = myShip.getRotation()

    	template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+180, spawnRot.z})
    })

    	template.jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["break_force"]  = 300.0,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
    	template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    	template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end

function placeToolToShipLeft()
shipDirection = "Left"
    myShip.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = myShip.getTransformForward()
    local distance   = -shipSize.width
    local spawnPos   = myShip.getPosition() + (leftVector * distance)
    local spawnRot   = myShip.getRotation()

    	template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y-90, spawnRot.z})
    })

    	template.jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["break_force"]  = 300.0,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
    	template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    	template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end

function placeToolToShipRight()
shipDirection = "Right"
    myShip.setLock(true)
    local tool = getObjectFromGUID("c52346")

    -- Negative transformRight() = left direction
    local leftVector = myShip.getTransformForward()
    local distance   = shipSize.width
    local spawnPos   = myShip.getPosition() + (leftVector * distance)
    local spawnRot   = myShip.getRotation()

    	template = tool.clone({
        position = ({spawnPos.x, spawnPos.y+.05, spawnPos.z}),
        rotation = ({spawnRot.x, spawnRot.y+90, spawnRot.z})
    })

    	template.	jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["break_force"]  = 300.0,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
    	template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
    	template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})

end



-- Step 2: Position the Ruler
function positionRulerRight()
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
	template.createButton({ click_function = "positionShip",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	print("Adjust template along the ruler before placing ship")
--template.reload()
end

function positionRulerLeft()
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
	template.createButton({ click_function = "positionShip",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	print("Adjust template along the ruler before placing ship")
--template.reload()
end


-- Step 3: Position Ship to the Template and Remove Ruler
function positionShip()


    if shipDirection == "Left" then


    local leftVector = template.getTransformRight()
    local distance   = 1.0
    local spawnPos   = template.getPosition() + (leftVector * distance)
    local spawnRot   = template.getRotation()

    myShip.setPosition(spawnPos)
    myShip.setRotation({spawnRot.x, spawnRot.y+90, spawnRot.z})
    elseif shipDirection == "Right" then  

    local leftVector = template.getTransformRight()
    local distance   = 1.0
    local spawnPos   = template.getPosition() + (leftVector * distance)
    local spawnRot   = template.getRotation()

    myShip.setPosition(spawnPos)
    myShip.setRotation({spawnRot.x, spawnRot.y-90, spawnRot.z})
    elseif shipDirection == "Front" then  

    local leftVector = template.getTransformRight()
    local distance   = 1.5
    local spawnPos   = template.getPosition() + (leftVector * distance)
    local spawnRot   = template.getRotation()

    myShip.setPosition(spawnPos)
    myShip.setRotation({spawnRot.x, spawnRot.y-0, spawnRot.z}) 
    elseif shipDirection == "Back" then  

    local leftVector = template.getTransformRight()
    local distance   = 1.5
    local spawnPos   = template.getPosition() + (leftVector * distance)
    local spawnRot   = template.getRotation()

    myShip.setPosition(spawnPos)
    myShip.setRotation({spawnRot.x, spawnRot.y-180, spawnRot.z})
    end


    -- Add context menu for the ruler
	template.clearButtons()
	template.createButton({ click_function = "clearTemplates",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
		print("OPTIONAL: Adjust the Template Rotatation, then place it again.")
	template.jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
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

--<><>--<><>--

local alert = 1
local power = 1
local health = 1
local crew = 3
local object = nil

function alertUp()
	if alert <=4 then
    alert = alert + 1
	callTag = "Alert"
	locate()
	object.setState(alert)
	end
end

function alertDown()
	if alert >=2 then
    alert = alert - 1
	callTag = "Alert"
	locate()
	object.setState(alert)
	end
end

function powerUp()
	if power >=2  then
    power = power - 1
	callTag = "Power"
	locate()
	object.setState(power)
	end
end

function powerDown()
	if power <=6 then
    power = power + 1
	callTag = "Power"
	locate()
	object.setState(power)
	end
end

function hullUp()
	if health >=2  then
    health = health - 1
	callTag = "Health"
	locate()
	object.setState(health)
	end
end

function hullDown()
	if health <=7 then
    health = health + 1
	callTag = "Health"
	locate()
	object.setState(health)
	end
end

function crewUp()
	if crew <=5 then
    crew = crew + 1
	callTag = "Crew"
	locate()
	object.setState(crew)
	end
end

function crewDown()
	if crew >=2 then
    crew = crew - 1
	callTag = "Crew"
	locate()
	object.setState(crew)
	end
end




--<><><><><>--


-- Function to calculate the Euclidean distance between two positions
function calculateDistance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end
	
function locate()
    local allObjects = getAllObjects()  
    local minDistance = math.huge  

    for _, obj in ipairs(allObjects) do
        if obj.hasTag(callTag) then
            local pos1 = obj.getPosition()
            local pos2 = self.getPosition()
            local distance = calculateDistance(pos1, pos2)

            if distance < minDistance then
                minDistance = distance
                object = obj
            end
        end
    end
end

function placeWarpTemplate()
	 rulerA = getObjectFromGUID(rulerGUID).clone()
	 rulerB = getObjectFromGUID(rulerGUID).clone()
     pos = myShip.getPosition()
     angle = myShip.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
     forwardOffsetA = -1
     sideOffsetA = 5.6
     forwardOffsetB = -1
     sideOffsetB = 17.5
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

function fireTorpedoFore() fireTorpedo("fore") end

function fireTorpedoAft() fireTorpedo("aft") end

function fireTorpedo(direction)
	 myShip.Lock()
     template = getObjectFromGUID(templateGUID).clone()
     shipPosition = myShip.getPosition()
     shipRotation = myShip.getRotation()

     local offset = 1.3

    -- Calculate the offset based on the direction
    local offsetX = 0
    local offsetZ = 0
	if direction == "fore" then
        offsetX = math.cos(math.rad(shipRotation.y + 180)) * offset
        offsetZ = math.sin(math.rad(shipRotation.y - 180)) * offset
		template.setPosition({shipPosition.x + offsetX, shipPosition.y, shipPosition.z - offsetZ})
		template.setRotation({shipRotation.x,shipRotation.y+0,shipRotation.z})
    elseif direction == "aft" then
	    offsetX = math.cos(math.rad(shipRotation.y + 180)) * offset * -1
        offsetZ = math.sin(math.rad(shipRotation.y - 180)) * offset * -1
		template.setPosition({shipPosition.x + offsetX, shipPosition.y, shipPosition.z - offsetZ})
		template.setRotation({shipRotation.x,shipRotation.y+180,shipRotation.z})
	end
	template.createButton({ click_function = "clearTemplatesA",function_owner = self,label= "Clear", position= {.8, .2, 0},rotation= {0, 180, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	
	template.jointTo(myShip, {
		["type"]        = "Hinge",
		["collision"]   = false,
		["axis"]        = {0,1,0},
		["anchor"]      = {0,0,0}
	})
end

-- Single Primary Arc Drawing Code (Solid Outer Arc Only, 6" from the object's front edge)
-- Assumes all objects are scale = 1 and their dimensions returned by getBounds() are in inches.

arc_drawn = false

function locate()
    local allObjects = getAllObjects()  
    local minDistance = math.huge  

    for _, obj in ipairs(allObjects) do
        if obj.hasTag(callTag) then
            local pos1 = obj.getPosition()
            local pos2 = self.getPosition()
            local distance = calculateDistance(pos1, pos2)

            if distance < minDistance then
                minDistance = distance
                object = obj
            end
        end
    end
end

cannonArc = {    
	{
        origin = {-0.5, 0.1, 0},
        arc    = {180, 270},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {-0.5, 0.1, 0},
        arc    = {270, 360},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    }
}

phaserArc = {    
	{
        origin = {0.5, 0.1, 0},
        arc    = {90, 180},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {-0.5, 0.1, 0},
        arc    = {180, 270},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {-0.5, 0.1, 0},
        arc    = {270, 360},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {0.5, 0.1, 0},
        arc    = {0, 90},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    }
}
scanArcFront ={ 
	{
        origin = {-0.5, 0.1, 0},
        arc = {225,315},
        range  = {1, 1},
        clr1   = {1, 0, 0},
        thic   = 0.05
    }
}
scanArc = {    
	{
        origin = {0.5, 0.1, 0},
        arc    = {90, 180},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {-0.5, 0.1, 0},
        arc    = {180, 270},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {-0.5, 0.1, 0},
        arc    = {270, 360},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    },{
        origin = {0.5, 0.1, 0},
        arc    = {0, 90},
        range  = {0, 0},
        clr1   = {1, 0, 0},
        thic   = 0.05
    }
}
function fireCannon()

    if arc_drawn then
        clearArc()
    else
        _rangeCir = 4
		_range = 0
		_range = _range + _rangeCir
        arc_def = cannonArc
        arc_defB = cannonArc

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

function firePhaser()

    if arc_drawn then
        clearArc()
    else
        _rangeCir = 6
		_range = 0
		_range = _range + _rangeCir
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

function scanCheck()
	callTag = "Alert"
	locate()
	
	if object.getStateId() == 1 or object.getStateId() == 2 then _range = 6 end
	if object.getStateId() == 3 or object.getStateId() == 4 then _range = 5 end
	if object.getStateId() == 5 or object.getStateId() == 6 then _range = 4 end
	
    if arc_drawn then
        clearArc()
    else
        _rangeCir = 2
		_range = _range + _rangeCir
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


function clearArc(_rangeCir, _range)
    myShip.setVectorLines({})
    arc_drawn = false
end

function computeArcPoints(def)
     origin    = Vector(def.origin[1], def.origin[2], def.origin[3])
     arc_start = def.arc[1]
     arc_end   = def.arc[2]
     max_range = def.range[2]

     fwd_long = vector(0,0,max_range)

     adjusted_end = arc_end
    if adjusted_end < arc_start then
        adjusted_end = adjusted_end + 360
    elseif adjusted_end == arc_start then
        adjusted_end = adjusted_end + 360
    end

     total_deg = adjusted_end - arc_start
     increment = 1
     segments = math.floor(total_deg / increment)
    if segments < 1 then segments = 1 end
    increment = total_deg / segments

    fwd_long:rotateOver('y', arc_start)

     outer_points = {}

     start_point = origin + fwd_long
    start_point.y = origin.y
    table.insert(outer_points, start_point)

    for i = 1, segments do
        fwd_long:rotateOver('y', increment)
         outer_pt = origin + fwd_long
        outer_pt.y = origin.y
        table.insert(outer_points, outer_pt)
    end

    return outer_points
end