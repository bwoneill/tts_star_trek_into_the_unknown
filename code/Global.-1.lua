require("utilities/classes")
require("vscode/console")

--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    --[[ print('onLoad!') --]]
    local start = os.clock()
    local text = Global.call("getFile", "assets/assets.json")
    log(string.format("%0.2fs to download assets", os.clock() - start))
    start = os.clock()
    ASSETS = JSON.decode(string.gsub(text, "ROOT", ROOT))
    log(string.format("%0.2fs to parse assets", os.clock() - start))
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
    local mission = nil
    for _, m in pairs(ASSETS.missions[type]) do
        mission = mission or (m.name == object.getName() and m)
    end
    if mission and (type == "overture" or type == "situation") then
        local j = type == "situation" and 2 or 0
        if mission.features then
            for _, feature in pairs(mission.features) do
                feature = Feature:new(feature)
                for i = 1, feature.type == "anomalies" and 1 or feature.quantity do
                    feature:spawnObject(Vector(10.25 + 1.25 * i, 1, -19 - 1.25 * j))
                end
                j = j + 1
            end
        end
        if mission.objectives then
            for _, objective in pairs(mission.objectives) do
                feature = Objective:new(objective)
                for i = 1, feature.quantity do
                    feature:spawnObject(Vector(10.25 + 1.25 * i, 1, -19 - 1.25 * j))
                end
                j = j + 1
            end
        end
        if mission.ships then
            for _, data in pairs(mission.ships) do
                for name, n in pairs(data) do
                    ship = Ship:new(ASSETS.ships[name])
                    for i = 1, n do
                        ship:spawnObject(Vector(20 + 2 * i, 1, -15), Vector(0, 180, 0))
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

-- Constants: DO NOT MODIFY

zoneGUIDS = {overture = "737129", situation = "da2ad6", complication = "5860dd"}

complication_types = {"battle", "intrigue", "mystery", "politics", "study", "threat"}

ROOT = "https://raw.githubusercontent.com/bwoneill/tts_star_trek_into_the_unknown/v1.1.0/"
ASSET_ROOT =  ROOT .. "assets/"
CODE_ROOT = ROOT .. "code/"
FILE_CACHE = {}
LIBRARY = {}


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
                center = Vector(center)
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
    for _, o in pairs(ASSETS.officers) do
        table.insert(LIBRARY, GameType:new(o))
    end
    for _, o in pairs(ASSETS.ships) do
        table.insert(LIBRARY, GameType:new(o))
    end
    for _, o in pairs(ASSETS.equipment) do
        table.insert(LIBRARY, GameType:new(o))
    end
    for _, o in pairs(ASSETS.keywords) do
        table.insert(LIBRARY, GameType:new(o))
    end
    LIBRARY = table.sort(LIBRARY, function(a,b)
        return a:getName():lower() < b:getName():lower()
    end)
end