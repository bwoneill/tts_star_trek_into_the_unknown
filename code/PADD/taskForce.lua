xml_cache = {}

coreOfficers = {"command", "ops", "science", "spec1", "spec2"}
allOfficers = {"command", "ops", "science", "spec1", "spec2", "trans1", "trans2", "trans3", "trans4", "trans5", "trans6"}

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

SAVE_VERSION = "1.1"

-- Faction Selection

function taskForce(player, value, id)
    build = {equipment = {}}
    local index = 1
    for name, faction in pairs(ASSETS.factions) do
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

vLayoutFormat = [[<Panel class = "vertPanel" onClick = "%s">
    <Image class = "vertFront" image = "%s"/>
    <Image class = "vertBack" image = "%s"/>
</Panel>]]

function rebuildVertSelector(data)
    rebuildSelector(data, "vGridLayout", [[<GridLayout id = "vGridLayout" cellSize = "400 300" spacing = "10 10" colors = "Black">]], vLayoutFormat)
end

hLayoutFormat = [[<Panel class = "horPanel" onClick = "%s">
    <Image class = "horFront" image = "%s"/>
    <Image class = "horBack" image = "%s"/>
</Panel>]]

function rebuildHorSelector(data)
    rebuildSelector(data, "hGridLayout", [[<GridLayout id = "hGridLayout" cellSize = "800 300" spacing = "5 5" colors = "Black">]], hLayoutFormat)
end

function rebuildSelector(data, id, preamble, layout)
    local newXml = preamble
    for _, element in ipairs(data) do
        newXml = newXml .. string.format(layout, element.onClick, element.images[1], element.images[2])
    end
    if #data == 0 then
        newXml = newXml .. [[<Text>None</Text>]]
    end
    newXml = newXml .. "</GridLayout>"
    local xml = self.UI.getXml()
    local start, _ = string.find(xml, string.format([[<GridLayout id="%s"]], id))
    local _, stop = string.find(xml, "</GridLayout>", start)
    xml = string.sub(xml, 1, start -1) .. newXml .. string.sub(xml, stop + 1)
    self.UI.setXml(xml)
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
    -- Build list of available officers
    local filter = (id == "command" or id == "ops" or id == "science") and id or nil
    local data = {}
    for i, officer in ipairs(ASSETS.officers) do
        local available = officer.factions[build.faction] and (not filter or officer.roles[filter]) and not officer.line_officer
        if officer.unique and not (build[id] and officer.name == build[id].name) then
            for _, role in pairs(allOfficers) do
                available = available and not (build[role] and officer.name == build[role].name)
            end
        end
        if available then
            local images = Officer:new(officer):getImages()
            local element = {
                onClick = "offChoice(" .. id .. "=" .. i .. ")",
                images = Officer:new(officer):getImages()
            }
            table.insert(data, element)
        end
    end
    -- Rebuild XML
    rebuildVertSelector(data)
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(#data / 2) - 10})
    self.UI.show("vertCardSelector")
end

function offChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = ASSETS.officers[i]
    end
    self.UI.hide("vertCardSelector")
    showStaging()
end

-- Directive Selection

function selectDir(player, value, id)
    local directives = ASSETS.directives
    local data = {}
    for i, directive in ipairs(directives) do
        local available = directive.faction == build.faction and directive.type == id
        if available then
            local element = {
                onClick = "dirChoice(" .. id .. "=" .. i .. ")",
                images = Directive:new(directive):getImages()
            }
            table.insert(data, element)
        end
    end
    rebuildHorSelector(data)
    self.UI.setAttribute("directiveScrollPanel", "height", #data * 305 - 5)
    self.UI.show("horCardSelector")
end

function dirChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = ASSETS.directives[i]
    end
    self.UI.hide("horCardSelector")
    showStaging()
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
    for i, ship in pairs(ASSETS.ships) do
        local available = false
        for _, filter in pairs(filters) do
            available = available or (ship.role == filter and ship.faction == build.faction)
        end
        if available then
            count = count + 1
            local attributes = {
                onClick = "shipChoice(" .. id .. "=" .. i .. ")",
                image = Ship:new(ship):getImages()[2],
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
        build[index] = ASSETS.ships[i]
        build["title" .. index:match"%d+"] = nil
    end
    self.UI.hide("selectShip")
    fleetStaging()
end

-- Equipment Selection

function updateEquipment(player, value, id)
    local index = tonumber(string.gmatch(id, "%d+")())
    build.equipment[index].n = tonumber(value)
    fleetStaging()
end

function selectEquip(player, value, id)
    local index = tonumber(string.gmatch(id, "%d+")())
    local this = build.equipment[index]
    local data = {}
    for i, e in ipairs(ASSETS.equipment) do
        local available = not e.factions or e.factions[build.faction]
        if not (this and e.name == this.name) then
            for _, q in ipairs(build.equipment) do
                available = available and not (e.name == q.name)
            end
        end
        if available then
            local element = {
                onClick = "equipChoice(" .. index .. "=" .. i .. ")",
                images = Equipment:new(e):getImages()
            }
            table.insert(data, element)
        end
    end
    rebuildVertSelector(data)
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(#data / 2) - 10})
    self.UI.show("vertCardSelector")
end

function equipChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        local index = tonumber(id)
        build.equipment[index] = ASSETS.equipment[i]
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
    local data = {}
    if ship and ship.titles then
        for i, title in ipairs(ship.titles) do
            local available = true
            for j = 1, 3 do
                available = available and (j == index or build["title" .. j] ~= title)
            end
            if available then
                local element = {
                    onClick = "titleChoice(" .. index .. "=" .. i .. ")",
                    images = Ship:new(ship):getTitleImages(title.name)
                }
                table.insert(data, element)
            end
        end
    end
    rebuildVertSelector(data)
    self.UI.setAttributes("vCardScrollPanel", {height = 310 * math.ceil(count / 2) -10})
    self.UI.show("vertCardSelector")
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
    elseif id:sub(1, 1) == "s" then
        build["ship" .. index] = nil
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
            result = Officer:new(build[id]):getImages()[2]
        elseif isShip(id) then
            result = Ship:new(build[id]):getImages()[2]
        elseif isTitle(id) then
            local ship = "ship" .. id:match"%d+"
            result = Ship:new(build[ship]):getTitleImages(build[id].name)[2]
        elseif isDirective(id) then
            result = Directive:new(build[id]):getImages()[1]
        elseif isEquipment(id) then
            result = Equipment:new(build[id]):getImages()
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
        local images = Equipment:new(equip):getImages()
        self.UI.setAttributes("eq" .. i, {image = images.back or images[2], color = "White"})
        self.UI.setAttributes("ed" .. i, {value = build.equipment[i].n - 1, active = true})
        self.UI.setAttribute("ex" .. i, "active", true)
        self.UI.setAttribute("e" .. i, "active", true)
    end
    for i = 1, 3 do
        self.UI.setAttribute("tx" .. i, "active", build["title" .. i] and true or false)
        self.UI.setAttribute("sx" .. i, "active", build["ship" .. i] and true or false)
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
    local save_data = {version = SAVE_VERSION, faction = build.faction}
    -- Officers
    for _, role in pairs(allOfficers) do
        local officer = build[role]
        if officer and officer.name then
            save_data[role] = {name = officer.name, subtitle = officer.subtitle}
        end
    end
    -- Directives
    for _, type in pairs({"combat", "diplomacy", "exploration"}) do
        if build[type] then
            save_data[type] = build[type].name
        end
    end
    -- Ships
    for i = 1, 3 do
        local ship = "ship" .. i
        if build[ship] then
            save_data[ship] = build[ship].short
        end
        local title = "title" .. i
        if build[title] then
            save_data[title] = build[title].name
        end
    end
    -- Equipment
    if #build.equipment > 0 then
        save_data.equipment = {}
        local temp = {}
        for _, equip in ipairs(build.equipment) do
            table.insert({name = equip.name, n = equip.n})
        end
    end
    local data = {
        Name = "Custom_Token", LuaScriptState = JSON.encode(save_data), Nickname = "Isolinear Chip",
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
        local data = JSON.decode(save.script_state)
        if data.version ~= SAVE_VERSION then
            broadcastToColor("Save versions do not match, this may not work", player.color, Color.Red)
        end
        build.faction = data.faction
        
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
    for _, ship in pairs(ASSETS.ships) do
        if ship.type == type then
            return ship
        end
    end
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
    for _, directive in pairs(ASSETS.directives) do
        if directive.names[1] == name or directives.names[2] == name then
            return directive
        end
    end
end

function findEquipment(name)
    for _, equip in pairs(ASSETS.equipment) do
        if equip.name == name then
            return equip
        end
    end
end

function toArray(value)
    value = string.gsub(value, "[%[%]]", "")
    local result = {}
    for v in string.gmatch(value, "([^,]+)") do
        table.insert(result, v)
    end
    return result
end

function spawn(player, value, id)
    local pos = self.getPosition()
    local rot = self.getRotation()
    local cardPos = pos + Vector(10, 0, 0):rotateOver("y", rot.y)
    for _, type in pairs(dirTypes) do
        if build[type] then
            Directive:new(build[type]):spawnObject(pos + Vector(10, 0, 3.5):rotateOver("y", rot.y), Vector(0, rot.y + 180, 0))
        end
    end
    for _, role in pairs(coreOfficers) do
        if build[role] then
            Officer:new(build[role]):spawnObject(cardPos, Vector(0, rot.y + 180, 180))
        end
    end
    for i = 1, 2 do
        local transfer = build["option" .. i]
        local isSelected = build["select" .. i]
        if transfer and isSelected then
            Officer:new(transfer):spawnObject(cardPos, Vector(0, rot.y + 180, 180))
        end
    end
    for _, equip in pairs(build.equipment) do
        Equipment:new(equip):spawnObject(cardPos, Vector(0, rot.y + 180, 180))
    end
    for i = 1, 3 do
        local ship = build["ship" .. i]
        local title = build["title" .. i]
        if ship then
            GameType:new(ship):spawnObject(pos + Vector(15 * (i - 2), 0, 13):rotateOver("y", rot.y), Vector(0, rot.y + 180, 0), title)
        end
    end
end