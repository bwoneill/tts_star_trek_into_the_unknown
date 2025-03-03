--Auxcraft Unit
myShip = nil
checkedArc = nil
function onLoad()

  local myscale = self.getScale()
  arc_scale = myscale.x --get x scale
  log (arc_scale)
end

local shipClass = getObjectFromGUID("ed8c10")

function setUp()
 
    self.UI.setAttribute("setUpBtn", "active", "false")

    self.UI.setAttribute("phaserBtn", "active", "true")
    self.UI.setAttribute("warpBtn", "active", "true")
    self.UI.setAttribute("impulsBtn", "active", "true")
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

    -- Ship
    local shipPos = calculateWorldPosition(-5, 5)
    myShip = getObjectFromGUID("ed8c10").clone()
    myShip.setPosition({shipPos.x, shipPos.y+.5, shipPos.z})
    myShip.setRotation(rot)
    myShip.setVar("myShipBase", "Small")
    myShip.addContextMenuItem('Impulse', function() impulseMoveStart() end, false)
    myShip.addContextMenuItem('Warp Speed', function() placeWarpTemplate() end, false)

end

--<><><><><>--

function impulseMoveStart()
myShip.createButton({function_owner = self, click_function = "impulseMoveFront",label = "Lateral", position = {1.5,.2,0}, rotation = {0, 90, 0}, width = 350, height = 150 })
myShip.createButton({function_owner = self, click_function = "impulseMoveLeft",label = "Left", position = {-0.1,.2,-1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
myShip.createButton({function_owner = self, click_function = "impulseMoveRight",label = "Right", position = {-0.1,.2,1.2}, rotation = {0, 90, 0}, width = 350, height = 150})
end

function impulseMoveLeft() myShip.clearButtons() placeTemplate("left") end

function impulseMoveRight() myShip.clearButtons() placeTemplate("right") end

function impulseMoveFront() myShip.clearButtons() placeTemplate("front") end

-- Assume myShip is already defined and points to the ship object
 templateGUID = "c52346" -- Replace with your template's GUID
 rulerGUID = "40c1ae" -- Use the known GUID of the ruler

-- Step 1: Place Template
function placeTemplate(direction)
	 myShip.Lock()
     template = getObjectFromGUID(templateGUID).clone()
     shipPosition = myShip.getPosition()
     shipRotation = myShip.getRotation()

    -- Set the offset distance
    local offset = 0.75

    -- Calculate the offset based on the direction
    local offsetX = 0
    local offsetZ = 0
    if direction == "left" then
        offsetX = math.cos(math.rad(shipRotation.y + 90)) * offset
        offsetZ = math.sin(math.rad(shipRotation.y - 90)) * offset
		template.setPosition({shipPosition.x + offsetX, shipPosition.y, shipPosition.z + offsetZ})
		template.setRotation({shipRotation.x,shipRotation.y-90,shipRotation.z})
		shipDirection = "left"
    elseif direction == "right" then
        offsetX = math.cos(math.rad(shipRotation.y - 90)) * offset
        offsetZ = math.sin(math.rad(shipRotation.y + 90)) * offset
		template.setPosition({shipPosition.x + offsetX, shipPosition.y, shipPosition.z + offsetZ})
		template.setRotation({shipRotation.x,shipRotation.y+90,shipRotation.z})
		shipDirection = "right"
	elseif direction == "front" then
        offsetX = math.sin(math.rad(shipRotation.y - 90)) * (offset +0.3)
        offsetZ = math.cos(math.rad(shipRotation.y - 90)) * (offset +0.3)
		template.setPosition({shipPosition.x + offsetX, shipPosition.y, shipPosition.z + offsetZ})
		template.setRotation({shipRotation.x,shipRotation.y+0,shipRotation.z})
		shipDirection = "front"
    end
	
    -- Add context menu for the ruler
    template.createButton({ click_function = "positionRulerLeft", function_owner = self, label= "Left", position= {0, .3, -0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	template.createButton({ click_function = "positionRulerRight", function_owner = self, label= "Right", position= {0, .3, 0.3},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	template.jointTo(myShip, {
    ["type"]        = "Hinge",
    ["collision"]   = false,
    ["axis"]        = {0,1,0},
    ["anchor"]      = {0,0,0}
})
end

function positionRulerLeft() rulerDirection = "left" positionRuler("left") end
function positionRulerRight() rulerDirection = "right" positionRuler("right") end

-- Step 2: Position the Ruler
function positionRuler(direction)
ruler = getObjectFromGUID(rulerGUID).clone()

     pos = template.getPosition()
     angle = template.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
     forwardOffset = -5.925
     sideOffset = 1.45

	if rulerDirection == "left" then
	 offsetX = math.sin(math.rad(angle)) * forwardOffset + math.sin(math.rad(angle - 90)) * sideOffset
     offsetZ = math.cos(math.rad(angle)) * forwardOffset + math.cos(math.rad(angle - 90)) * sideOffset
    -- Set the ruler's position and rotation
	
    ruler.setPosition({pos.x + offsetX, pos.y+.05, pos.z + offsetZ})
    ruler.setRotation({0, angle - 90, 0})
	elseif rulerDirection == "right" then
	 offsetX = math.sin(math.rad(angle)) * forwardOffset + math.sin(math.rad(angle + 90)) * sideOffset
     offsetZ = math.cos(math.rad(angle)) * forwardOffset + math.cos(math.rad(angle + 90)) * sideOffset
    -- Set the ruler's position and rotation
	
    ruler.setPosition({pos.x - offsetX, pos.y+.05, pos.z - offsetZ})
    ruler.setRotation({0, angle + 90, 0})
    end
    -- Lock the ruler in place
    ruler.lock()
    template.clearButtons()
	template.createButton({ click_function = "positionShip",function_owner = self,label= "Place", position= {.2, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Place Ruler aliened with template",})
	print("Adjust template along the ruler before placing ship")
	template.jointTo()
end

-- Step 3: Position Ship to the Template and Remove Ruler
function positionShip()

	 newPosition = template.getPosition()
     newRotation = template.getRotation()

    -- Set the offset distance
	local offset = 0.75


    -- Calculate the offset based on the direction
    local offsetX = 0
    local offsetZ = 0
    if shipDirection == "left" then
        offsetX = math.sin(math.rad(newRotation.y + 90)) * offset
        offsetZ = math.cos(math.rad(newRotation.y - 90)) * offset
		myShip.setPosition({newPosition.x + offsetX, newPosition.y, newPosition.z - offsetZ})
	    myShip.setRotation({newRotation.x,newRotation.y+90,newRotation.z})
    elseif shipDirection == "right" then
        offsetX = math.sin(math.rad(newRotation.y + 90)) * offset
        offsetZ = math.cos(math.rad(newRotation.y - 90)) * offset
		myShip.setPosition({newPosition.x + offsetX, newPosition.y, newPosition.z - offsetZ})
	    myShip.setRotation({newRotation.x,newRotation.y-90,newRotation.z})
	elseif shipDirection == "front" then
        offsetX = math.sin(math.rad(newRotation.y + 90)) * (offset +0.3)
        offsetZ = math.cos(math.rad(newRotation.y + 90)) * (offset +0.3)
		myShip.setPosition({newPosition.x + offsetX, newPosition.y, newPosition.z + offsetZ})
	    myShip.setRotation({newRotation.x,newRotation.y+0,newRotation.z})
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

function placeWarpTemplate()
	 rulerA = getObjectFromGUID(rulerGUID).clone()
	 rulerB = getObjectFromGUID(rulerGUID).clone()
     pos = myShip.getPosition()
     angle = myShip.getRotation().y

    -- Calculate forward and side offsets based on the template's rotation
     forwardOffsetA = -0.52
     sideOffsetA = 5.6
     forwardOffsetB = -0.52
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
	rulerB.setPosition({pos.x - offsetX, pos.y-1.05, pos.z - offsetZ})
    rulerB.setRotation({0, angle , 0})

    -- Lock the ruler in place
    rulerB.lock()
	rulerA.createButton({ click_function = "clearWarp",function_owner = self,label= "Clear", position= {-8, .2, 0},rotation= {0, 90, 0},width= 300,height= 200,font_size= 95,color= {1,1,1},font_color= {0,0,0}, tooltip= "Clear Rulers",})
	
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

beamArc = {    
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
function firePhaser()

    if arc_drawn then
        clearArc()
    else
        _rangeCir = 4
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



	
    if arc_drawn then
        clearArc()
    else
        _rangeCir = 4
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