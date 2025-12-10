require("utilities/classes")

--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
    ASSETS = JSON.decode(string.gsub(Global.call("getFile", "assets/assets.json"), "ROOT", ROOT))
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
        local request = WebRequest.get(ROOT .. path)
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
    for i, o in ipairs(ASSETS.officers) do
        o.gtype = "equipment"
        table.insert(LIBRARY, GameType:new(o))
    end
    for i, o in ipairs(ASSETS.ships) do
        o.gtype = "equipment"
        table.insert(LIBRARY, GameType:new(o))
    end
    for i, o in ipairs(ASSETS.equipment) do
        o.gtype = "equipment"
        table.insert(LIBRARY, GameType:new(o))
    end
    for i, o in ipairs(ASSETS.keywords) do
        o.gtype = "keyword"
        table.insert(LIBRARY, GameType:new(o))
    end
    LIBRARY = table.sort(LIBRARY, function(a,b)
        return a:getName():lower() < b:getName():lower()
    end)
end