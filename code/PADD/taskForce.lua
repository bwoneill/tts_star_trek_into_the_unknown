CODE_ROOT = Global.getVar("CODE_ROOT")

factions = Global.getTable("ASSETS").factions
equipment = Global.getTable("ASSETS").equipment
xml_cache = {}

coreOfficers = {"command", "ops", "science", "spec1", "spec2"}
allOfficers = {"command", "ops", "science", "spec1", "spec2", "trans1", "trans2", "trans3", "trans4", "trans5", "trans6"}

dirTypes = {"combat", "diplomacy", "exploration"}

dirTypes = {"combat", "diplomacy", "exploration"}

defaultImages = {
    command = "ui/PADD/command.png",
    ops = "ui/PADD/ops.png",
    science = "ui/PADD/science.png",
    spec1 = "ui/PADD/officer.png",
    spec2 = "ui/PADD/officer.png",
    trans1 = "ui/PADD/officer.png",
    trans2 = "ui/PADD/officer.png",
    trans3 = "ui/PADD/officer.png",
    trans4 = "ui/PADD/officer.png",
    trans5 = "ui/PADD/officer.png",
    trans6 = "ui/PADD/officer.png",
    combat = "ui/PADD/combat.png",
    diplomacy = "ui/PADD/diplomacy.png",
    exploration = "ui/PADD/exploration.png",
    option1 = "ui/PADD/officer.png",
    option2 = "ui/PADD/officer.png",
    ship1 = "ui/PADD/capital.png",
    ship2 = "ui/PADD/non-capital.png",
    ship3 = "ui/PADD/non-capital.png",
    title1 = "ui/PADD/title.png",
    title2 = "ui/PADD/title.png",
    title3 = "ui/PADD/title.png"
}

panelIds = {"fPanel", "stagingPanel", "vertCardSelector", "horCardSelector", "selectShip", "fleetStaging"}

SAVE_VERSION = "1.0"
function downloadScript()
    SHIP_BOARD_SCRIPT = Global.call("getFile", CODE_ROOT .. "ships/ship.lua")
end

-- Faction Selection

function taskForce(player, value, id)
    if not SHIP_BOARD_SCRIPT then
        downloadScript()
    end
    build = {equipment = {}}
    local index = 1
    for name, faction in pairs(factions) do
        if faction.playable then
            local path = ASSET_ROOT .. "factions/" .. name .. "/logo.png"
            self.UI.setAttributes(string.format("fLogo%i", index), {
                image = path,
                onClick = "selectFaction(" .. name .. ")",
                tooltip = faction.displayName
            })
            self.UI.setAttributes(string.format("faction%i", index),{
                active = true,
                tooltip = faction.displayName
            })
            index = index + 1
        end
    end
    self.UI.show("taskForce")
end

function selectFaction(player, value, id)
    build.faction = value
    showStaging()
end

-- Staging

function showStaging()
    updateImages()
    cp = 0
    for _, role in pairs(coreOfficers) do
        if build[role] then
            cp = cp + build[role].cp
        end
    end
    self.UI.setAttributes("cp",{text = string.format("%i/50", cp), color = cp <= 50 and "White" or "Red"})
    self.UI.show("stagingPanel")
end

-- Officer Selection

function selectOff(player, value, id)
    local filter = (id == "command" or id == "ops" or id == "science") and id or nil
    local count = 0
    for i, officer in ipairs(factions[build.faction].officers) do
        local available = not filter or officer.roles[filter]
        available = available and not officer.line_officer
        if officer.unique and not (build[id] and officer.name == build[id].name) then
            for _, role in pairs(allOfficers) do
                available = available and not (build[role] and officer.name == build[role].name)
            end
        end
        if available then
            count = count + 1
            local images = getOfficerImage(officer)
            local attributes = {
                onClick = "offChoice(" .. id .. "=" .. i .. ")",
                image = images.front,
                color = "White"
            }
            self.UI.setAttributes("vf".. count, attributes)
            attributes.image = images.back
            self.UI.setAttributes("vb".. count, attributes)
            self.UI.setAttribute("vc" .. count, "active", true)
        end
    end
    for i = count + 1, 20 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("vf" .. i, attributes)
        self.UI.setAttributes("vb" .. i, attributes)
        self.UI.setAttribute("vc" .. i, "active", false)
    end
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(count / 2) - 10})
    self.UI.show("vertCardSelector")
end

function offChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = factions[build.faction].officers[i]
    end
    self.UI.hide("vertCardSelector")
    showStaging()
end

function getOfficerImage(officer)
    local path = string.gsub(officer.name .. (officer.subtitle and "_" .. officer.subtitle or ""), " ", "_")
    path = path:gsub("[^%w%d%s_]", "")
    path = ASSET_ROOT .. "factions/" .. build.faction .. "/officers/" .. path
    local result = {front = path .. ".png", back = path .. "_back.png"}
    return result
end

-- Directive Selection

function selectDir(player, value, id)
    local directives = factions[build.faction].directives[id]
    for i, dir in ipairs(directives) do
        local paths = getDirectiveImages(dir)
        local attributes = {
            onClick = "dirChoice(" .. id .. "=" .. i .. ")",
            image = paths.front, color = "White"
        }
        self.UI.setAttributes("hf" .. i, attributes)
        attributes.image = paths.back
        self.UI.setAttributes("hb" .. i, attributes)
        self.UI.setAttribute("hc" .. i, "active", true)
    end
    for i = #directives + 1, 5 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("hf" .. i, attributes)
        self.UI.setAttributes("hb" .. i, attributes)
        self.UI.setAttribute("hc" .. i, "active", false)
    end
    self.UI.setAttribute("directiveScrollPanel", "height", #directives * 305 - 5)
    self.UI.show("horCardSelector")
end

function dirChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = factions[build.faction].directives[id][i]
    end
    self.UI.hide("horCardSelector")
    showStaging()
end

function getDirectiveImages(directive)
    local paths = {}
    for _, key in pairs({"front", "back"}) do
        paths[key] = ASSET_ROOT .. "factions/" .. build.faction .. "/directives/" .. string.gsub(directive[key], " ", "_") .. ".png"
    end
    return paths
end

-- Fleet Staging

function fleetStaging(player, value, id)
    updateImages()
    updateFlexPoints()
    local attributes = {text = string.format("%i/%i", fp, 50 - cp), color = fp <= (50 - cp) and "White" or "Red"}
    self.UI.setAttributes("fp", attributes)
    self.UI.setAttribute("fleetPanel", "height", 1005 + 300 * math.ceil((#build.equipment + 1) / 5))
    self.UI.show("fleetStaging")
end

-- Ship Selection

function selectShip(player, value, id)
    local count = 0
    local filters = id == "ship1" and {"capital"} or {"scout", "specialist", "support"}
    for i, ship in pairs(factions[build.faction].ships) do
        local available = false
        for _, filter in pairs(filters) do
            available = available or ship.role == filter
        end
        if available then
            count = count + 1
            local attributes = {
                onClick = "shipChoice(" .. id .. "=" .. i .. ")",
                image = getShipImage(ship),
                color = "White"
            }
            self.UI.setAttributes("s" .. count, attributes)
            self.UI.setAttribute("s" .. count, "active", true)
        end
    end
    for i = count + 1, 5 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("s" .. i, attributes)
        self.UI.setAttribute("s" .. i, "active", false)
    end
    self.UI.setAttribute("shipScrollPanel", "height", 310 * math.ceil(count / 2) - 10)
    self.UI.show("selectShip")
end

function shipChoice(player, value, id)
    local values = parseValues(value)
    for index, i in pairs(values) do
        build[index] = factions[build.faction].ships[i]
        build["title" .. index:match"%d+"] = nil
    end
    self.UI.hide("selectShip")
    fleetStaging()
end

function getShipImage(ship)
    return ASSET_ROOT .. "factions/" .. ship.faction .. "/ships/" .. ship.type .. "/image.png"
end

-- Equipment Selection

function updateEquipment(player, value, id)
    local index = tonumber(string.gmatch(id, "%d+")())
    build.equipment[index].n = tonumber(value)
    fleetStaging()
end

function getEquipmentImages(equip)
    local path = ASSET_ROOT .. "equipment/" .. string.gsub(equip.name, " ", "_")
    local result = {front = path .. ".png", back = path .. "_back.png"}
    return result
end

function selectEquip(player, value, id)
    local index = tonumber(string.gmatch(id, "%d+")())
    local this = build.equipment[index]
    local count = 0
    for i, e in ipairs(equipment) do
        local available = not e.factions or e.factions[build.faction]
        if not (this and e.name == this.name) then
            for _, q in ipairs(build.equipment) do
                available = available and not (e.name == q.name)
            end
        end
        if available then
            count = count + 1
            local images = getEquipmentImages(e)
            local attributes = {
                onClick = "equipChoice(" .. index .. "=" .. i .. ")",
                image = images.front,
                color = "White"
            }
            self.UI.setAttributes("vf" .. count, attributes)
            attributes.image = images.back
            self.UI.setAttributes("vb" .. count, attributes)
            self.UI.setAttribute("vc" .. count, "active", true)
        end
    end
    for i = count + 1, 20 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("vf" .. i, attributes)
        self.UI.setAttributes("vb" .. i, attributes)
        self.UI.setAttribute("vc" .. i, "active", false)
    end
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(count / 2) - 10})
    self.UI.show("vertCardSelector")
end

function equipChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        local index = tonumber(id)
        build.equipment[index] = equipment[i]
        build.equipment[index].n = 1
    end
    self.UI.hide("vertCardSelector")
    fleetStaging()
end

-- Title Selection

function selectTitle(player, value, id)
    local index = tonumber(id:match"%d+")
    local ship = build["ship" .. index]
    local count = 0
    if ship and ship.titles then
        for i, name in ipairs(ship.titles) do
            count = count + 1
            local images = getTitleImages(ship, name)
            local attributes = {
                onClick = "titleChoice(" .. index .. "=" .. i .. ")",
                image = images.front,
                color = "White"
            }
            self.UI.setAttributes("vf" .. count, attributes)
            attributes.image = images.back
            self.UI.setAttributes("vb" .. count, attributes)
            self.UI.setAttribute("vc" .. count, "active", true)
        end
    end
    for i = count + 1, 20 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("vf" .. i, attributes)
        self.UI.setAttributes("vb" .. i, attributes)
        self.UI.setAttribute("vc" .. i, "active", false)
    end
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(count / 2) -10})
    self.UI.show("vertCardSelector")
end

function getTitleImages(ship, title)
    local name = string.gsub(title.name, " ", "_"):lower()
    local path = ASSET_ROOT .. "factions/" .. build.faction .. "/ships/" .. ship.type .. "/title_" .. name
    return {front = path .. "_front.png", back = path .. "_back.png"}
end

function titleChoice(player, value, id)
    local values = parseValues(value)
    for index, i in pairs(values) do
        build["title" .. index] = build["ship" .. index].titles[i]
    end
    self.UI.hide("vertCardSelector")
    fleetStaging()
end

function remove(player, value, id)
    local index = tonumber(id:match"%d+")
    if id:sub(1, 1) == "e" then
        table.remove(build.equipment, index)
    elseif id:sub(1, 1) == "t" then
        build["title" .. index] = nil
    end
    fleetStaging()
end

-- Utility funcitons

function parseValues(values)
    local result = {}
    for line in string.gmatch(values, "%S+") do
        local temp = {}
        for x in string.gmatch(line, "([^=]+)") do
            temp[#temp + 1] = x
        end
        result[temp[1]] = tonumber(temp[2]) or temp[2]
    end
    return result
end

function getImage(id)
    local result = ""
    if build[id] then
        if isOfficer(id) then
            result = getOfficerImage(build[id]).back
        elseif isShip(id) then
            result = getShipImage(build[id])
        elseif isTitle(id) then
            local ship = "ship" .. id:match"%d+"
            result = getTitleImages(build[ship], build[id]).back
        elseif isDirective(id) then
            result = getDirectiveImages(build[id]).front
        elseif isEquipment(id) then
            result = getEquipmentImage(build[id])
        end
    else
        result = ASSET_ROOT .. defaultImages[id]
    end
    return result
end

function isOfficer(id)
    local result = false
    for _, role in pairs(coreOfficers) do
        result = result or id == role
    end
    for i = 1, 6 do
        result = result or id == "trans" .. i
    end
    for i = 1, 2 do
        result = result or id == "option" .. i
    end
    return result
end

function isShip(id)
    return id:match"ship%d"
end

function isDirective(id)
    local result = false
    for _, dir in pairs(dirTypes) do
        result = result or id == dir
    end
    return result
end

function isEquipment(id)
    return id:match"ed%d"
end

function isTitle(id)
    return id:match"title%d"
end

function hideAll()
    for _, id in pairs(panelIds) do
        self.UI.hide(id)
    end
end

function updateImages()
    for type, path in pairs(defaultImages) do
        local image = getImage(type)
        self.UI.setAttribute(type, "image", image)
    end
    for i, equip in ipairs(build.equipment) do
        local images = getEquipmentImages(equip)
        self.UI.setAttributes("eq" .. i, {image = images.back, color = "White"})
        self.UI.setAttributes("ed" .. i, {value = build.equipment[i].n - 1, active = true})
        self.UI.setAttribute("ex" .. i, "active", true)
        self.UI.setAttribute("e" .. i, "active", true)
    end
    for i = 1, 3 do
        self.UI.setAttribute("tx" .. i, "active", build["title" .. i] and true or false)
    end
    local index = #build.equipment + 1
    self.UI.setAttributes("eq" .. index, {image = ASSET_ROOT .. "ui/PADD/equipment.png", color = "White"})
    self.UI.setAttribute("ed" .. index, "active", false)
    self.UI.setAttribute("ex" .. index, "active", false)
    self.UI.setAttribute("e" .. index, "active", true)
    for i = #build.equipment + 2, 5 do
        self.UI.setAttribute("e" .. i, "active", false)
    end
end

function updateFlexPoints()
    fp = 0
    for i = 1, 3 do
        local ship = build["ship" .. i]
        if ship and ship.fp then
            fp = fp + ship.fp
        end
        local title = build["title" .. i]
        if title and title.fp then
            fp = fp + title.fp
        end
    end
    for i = 1, 2 do
        local transfer = build["option" .. i]
        local isSelected = build["select" .. i]
        if transfer and isSelected == "True" then
            fp = fp + transfer.fp
        end
    end
    for _, equip in pairs(build.equipment) do
        fp = fp + equip.n * equip.fp
    end
end

function logTransfer(player, value, id)
    build[id] = value
    fleetStaging()
end

function reroll(player, value, id)
    options = {math.random(6), math.random(5)}
    if options[2] >= options[1] then
        options[2] = options[2] + 1
    end
    build.option1 = build["trans" .. options[1]]
    build.option2 = build["trans" .. options[2]]
    fleetStaging()
end

function export(player, value, id)
    local save_data = "version: " .. SAVE_VERSION .. "\nfaction: " .. build.faction
    -- Officers
    for _, role in pairs(allOfficers) do
        local officer = build[role]
        if officer and officer.name then
            save_data = save_data .. "\n" .. role .. ": " .. officer.name
            if officer.subtitle then
                save_data = save_data .. " [" .. officer.subtitle .. "]"
            end
        end
    end
    -- Directives
    for _, type in pairs({"combat", "diplomacy", "exploration"}) do
        if build[type] then
            save_data = save_data .. "\n" .. type .. ": " .. build[type].front
        end
    end
    -- Ships
    for i = 1, 3 do
        local ship = "ship" .. i
        if build[ship] then
            save_data = save_data .. "\n" .. ship .. ": " .. build[ship].type
        end
        local title = "title" .. i
        if build[title] then
            save_data = save_data .. "\n" .. title .. ": " .. build[title].name
        end
    end
    -- Equipment
    if #build.equipment > 0 then
        save_data = save_data .. "\nequipment: ["
        local temp = {}
        for i, equip in ipairs(build.equipment) do
            temp[i] = equip.name .. " = " .. equip.n
        end
        save_data = save_data .. table.concat(temp, ",") .. "]"
    end
    local data = {
        Name = "Custom_Token", LuaScriptState = save_data, Nickname = "Isolinear Chip",
        Transform = {scaleX = 1, scaleY = 1, scaleZ = 1}, Tags = {"Save"},
        CustomImage = {
            ImageURL = ASSET_ROOT .. "factions/" .. build.faction .. "/save_token.png",
            CustomToken = {Thickness = 0.1, MergeDistancePixels = 1}
        }
    }
    local rot = self.getRotation().y
    spawnObjectData({
        data = data,
        position = self.getPosition() + Vector(-8.75, 0, 2):rotateOver("y", rot),
        rotation = Vector(0, rot + 180, 0)
    })
end

function import(player, value, id)
    local chips = getObjectsWithTag("Save")
    local distance = 1000
    local save = nil
    local pos = self.getPosition()
    for _, c in pairs(chips) do
        local d = (pos - c.getPosition()):magnitude()
        if d < distance then
            save = c
            distance = d
        end
    end
    if distance < 12 then
        local lines = readLines(save.script_state)
        local data = {}
        for i, line in ipairs(lines) do
            local k, v = split(line, ":")
            data[k] = v
        end
        if data.version == SAVE_VERSION then
            build.version = data.version
            build.faction = data.faction
            for _, role in pairs(allOfficers) do
                if data[role] then
                    build[role] = findOfficer(build.faction, data[role])
                end
            end
            for _, type in pairs(dirTypes) do
                if data[type] then
                    build[type] = findDirective(build.faction, type, data[type])
                end
            end
            for i = 1, 3 do
                local ship = "ship" .. i
                if data[ship] then
                    build[ship] = findShip(build.faction, data[ship])
                    local title = "title" .. i
                    if data[title] then
                        build[title] = findTitle(build[ship], data[title]) 
                    end
                end
            end
            if data.equipment then
                local temp = toArray(data.equipment)
                for i, equip in ipairs(temp) do
                    local name, n = split(equip, "=")
                    build.equipment[i] = findEquipment(name)
                    build.equipment[i].n = tonumber(n)
                end
            end
            showStaging()
        else
            broadcastToColor("Unsupported save version", player.color, Color.Red)
        end
    else
        broadcastToColor("No isolinear chips in range", player.color, Color.Red)
    end
end

function trim(s)
    if s then
        return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
    else
        return nil
    end
end

function readLines(s)
    local result = {}
    for m in string.gmatch(s, "([^\n]+)") do
        table.insert(result, m)
    end
    return result
end

function split(s, d)
    local temp = {}
    for m in string.gmatch(s, "([^" .. d .. "]+)") do
        table.insert(temp, trim(m))
    end
    return temp[1], temp[2]
end

function toNameSubtitle(s)
    local name = trim(s:match'([^%[]+)')
    local subtitle = trim(s:match'%[(.+)%]')
    return name, subtitle
end

function findOfficer(faction, value)
    local name, subtitle = toNameSubtitle(value)
    local result = nil
    for _, officer in pairs(factions[faction].officers) do
        if officer.name == name and officer.subtitle == subtitle then
            result = officer
        end
    end
    return result
end

function findShip(faction, type)
    local result = nil
    for _, ship in pairs(factions[faction].ships) do
        if ship.type == type then
            result = ship
        end
    end
    return result
end

function findTitle(ship, name)
    local result = nil
    for _, title in pairs(ship.titles) do
        if title.name == name then
            result = title
        end
    end
    return result
end

function findDirective(faction, type, name)
    local result = nil
    for _, dir in pairs(factions[faction].directives[type]) do
        if dir.front == name then
            result = dir
        end
    end
    return result
end

function findEquipment(name)
    local result = nil
    for _, equip in pairs(equipment) do
        if equip.name == name then
            result = equip
        end
    end
    return result
end

function toArray(value)
    value = string.gsub(value, "[%[%]]", "")
    local result = {}
    for v in string.gmatch(value, "([^,]+)") do
        table.insert(result, v)
    end
    return result
end

function spawnCard(args)
    local delta = args.offset or Vector(10, 0, 0)
    local scale = args.scale or Vector(1, 1, 1)
    local rot = self.getRotation().y
    local position = self.getPosition() + delta:rotateOver("y", rot)
    local card = spawnObject({type = "CardCustom", position = position,
        rotation = Vector(0, rot + 180, args.faceUp and 0 or 180), scale = scale})
    card.setCustomObject({face = args.images.front, back = args.images.back, sound = false})
    return card
end

function spawnShipBoard(ship, n)
    local path = ASSET_ROOT .. "factions/" .. ship.faction .. "/" .. ship.folder .. "/" .. ship.type .. "/"
    local ship_xml = Global.call("getFile", path .. ship.type .. ".xml")
    local script = "default = Global.getTable(\"ASSETS\").factions." .. ship.faction .. "." .. ship.folder .."." .. ship.type .. "\n" .. SHIP_BOARD_SCRIPT
    local rot = self.getRotation().y
    local pos = self.getPosition() + Vector(15 * (n - 2), 0, 13):rotateOver("y", rot)
    local result = {position = pos, rotation = Vector(0, rot + 180, 0)}
    result.data = {
        Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1}, Nickname = ship.name,
        CustomMesh = {
            MeshURL = ASSET_ROOT .. "misc/ship_board.obj",
            DiffuseURL = path .. "ship_board.png",
            MaterialIndex = 3, Convex = false
        },
        LuaScript = script, XmlUI = ship_xml
    }
    local back = path .. "crit_back.png"
    for i = 1, ship.crit_deck_size do
        local images = {front = path .. "crit_" .. i .. ".png", back = back}
        spawnCard({images = images, offset = Vector(15 * (n - 2) + 6.25, 0, 7)})
    end
    spawnObjectData(result)
end

function spawnAuxiliary(aux)
end

function getTeamImages(faction, team)
    local path = ASSET_ROOT .. "factions/" .. faction .. "/teams/team_"
    return {front = path .. team.front .. ".png", back = path .. team.back .. ".png"}
end

function spawn(player, value, id)
    for _, type in pairs(dirTypes) do
        if build[type] then
            spawnCard({images = getDirectiveImages(build[type]), offset = Vector(10, 0, 3.5), faceUp = true})
            if build[type].teams then
                for _, team in pairs(build[type].teams) do
                    spawnCard({images = getTeamImages(build.faction, team), offset = Vector(14, 0, 3.25),
                        scale = Vector(1.33, 1, 1.33), faceUp = true})
                end
            end
        end
    end
    local line_officer = nil
    for _, officer in ipairs(factions[build.faction].officers) do
        if officer.line_officer then
            line_officer = officer
        end
    end
    for _, role in pairs(coreOfficers) do
        if build[role] then
            spawnCard({images = getOfficerImage(build[role])})
        end
    end
    for i = 1, 2 do
        local transfer = build["option" .. i]
        local isSelected = build["select" .. i]
        if transfer and isSelected then
            spawnCard({images = getOfficerImage(transfer)})
        end
    end
    for _, equip in pairs(build.equipment) do
        spawnCard({images = getEquipmentImages(equip)})
    end
    for i = 1, 3 do
        local ship = build["ship" .. i]
        local title = build["title" .. i]
        if ship then
            if ship.folder == "ships" then
                spawnCard({images = getOfficerImage(line_officer), offset = Vector(15 * (i - 2) + 3, 0, 7)})
                if title then
                    spawnCard({images = getTitleImages(ship, title), offset = Vector(15 * (i - 2) + 6.25, 0, 15)})
                end
                spawnShipBoard(ship, i)
            elseif ship.folder == "auxiliary" then
                spawnAuxiliary(ship)
            end
        end
    end
end