factions = Global.getTable("ASSETS").factions
equipment = Global.getTable("ASSETS").equipment

ASSET_ROOT = Global.getVar("ASSET_ROOT")

build = {}

coreOfficers = {"command", "ops", "science", "spec1", "spec2"}

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
    ship1 = "ui/PADD/capital.png",
    ship2 = "ui/PADD/non-capital.png",
    ship3 = "ui/PADD/non-capital.png",
    title1 = "",
    title2 = "",
    title3 = "",
    combat = "ui/PADD/combat.png",
    diplomacy = "ui/PADD/diplomacy.png",
    exploration = "ui/PADD/exploration.png",
    option1 = "ui/PADD/officer.png",
    option2 = "ui/PADD/officer.png"
}

panelIds = {"fPanel", "stagingPanel", "selectOfficer", "selectDirective", "selectShip", "fleetStaging", "selectEquip"}

-- Faction Selection

function start(player, value, id)
    hideAll()
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
    self.UI.show("fPanel")
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
    hideAll()
    local filter = (id == "command" or id == "ops" or id == "science") and id or nil
    local count = 0
    for i, officer in ipairs(factions[build.faction].officers) do
        local available = not filter or officer.roles[filter]
        available = available and not officer.line_officer
        if officer.unique and not (build[id] and officer.name == build[id].name) then
            for _, staff in pairs(build) do
                available = available and not (officer.name == staff.name)
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
            self.UI.setAttributes("o".. count, attributes)
            attributes.image = images.back
            self.UI.setAttributes("ob".. count, attributes)
            self.UI.show("off".. count)
        end
    end
    for i = count + 1, 20 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("o" .. i, attributes)
        self.UI.setAttributes("ob" .. i, attributes)
        self.UI.hide("off" .. i)
    end
    self.UI.setAttributes("officerScrollPanel", {height = 310 * math.ceil(count / 2) - 10})
    self.UI.show("selectOfficer")
end

function offChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = factions[build.faction].officers[i]
    end
    showStaging()
end

function getOfficerImage(officer)
    local path = string.gsub(officer.name .. (officer.subtitle and "_" .. officer.subtitle or ""), " ", "_")
    path = ASSET_ROOT .. "factions/" .. build.faction .. "/officers/" .. path
    local result = {front = path .. ".png", back = path .. "_back.png"}
    return result
end

-- Directive Selection

function selectDir(player, value, id)
    hideAll()
    local directives = factions[build.faction].directives[id]
    for i, dir in ipairs(directives) do
        local paths = getDirectiveImages(dir)
        local attributes = {
            onClick = "dirChoice(" .. id .. "=" .. i .. ")",
            image = paths.front, color = "White"
        }
        self.UI.setAttributes("d" .. i, attributes)
        attributes.image = paths.back
        self.UI.setAttributes("db" .. i, attributes)
        self.UI.setAttribute("dir" .. i, "active", true)
        -- self.UI.show("dir" .. i)
    end
    for i = #directives + 1, 5 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("d" .. i, attributes)
        self.UI.setAttributes("db" .. i, attributes)
        self.UI.setAttribute("dir" .. i, "active", false)
        -- self.UI.hide("dir" .. i)
    end
    self.UI.setAttribute("directiveScrollPanel", "height", #directives * 305 - 5)
    self.UI.show("selectDirective")
end

function dirChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = factions[build.faction].directives[id][i]
    end
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
    hideAll()
    updateImages()
    updateFlexPoints()
    local attributes = {text = string.format("%i/%i", fp, 50 - cp), color = fp <= (50 - cp) and "White" or "Red"}
    self.UI.setAttributes("fp", attributes)
    self.UI.show("fleetStaging")
end

-- Ship Selection

function selectShip(player, value, id)
    hideAll()
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
            self.UI.setAttribute("s" .. i, "active", true)
            -- self.UI.show("s" .. count)
        end
    end
    for i = count + 1, 5 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("s" .. i, attributes)
        self.UI.setAttribute("s" .. i, "active", false)
        -- self.UI.hide("s" .. i)
    end
    self.UI.setAttribute("shipScrollPanel", "height", 310 * math.ceil(count / 2) - 10)
    self.UI.show("selectShip")
end

function shipChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        build[id] = factions[build.faction].ships[i]
    end
    fleetStaging()
end

function getShipImage(ship)
    return ASSET_ROOT .. "factions/" .. ship.faction .. "/ships/" .. ship.type .. "/image.png"
end

-- Equipment Selection
-- 
-- -- -- does not work
-- 

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
    hideAll()
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
            self.UI.setAttributes("ef" .. count, attributes)
            attributes.image = images.back
            self.UI.setAttributes("eb" .. count, attributes)
            self.UI.setAttribute("ep" .. i, "active", true)
            -- self.UI.show("ep" .. i)
        end
    end
    for i = count + 1, 5 do
        local attributes = {image = "", color = "Black", onClick = ""}
        self.UI.setAttributes("ef" .. i, attributes)
        self.UI.setAttributes("eb" .. i, attributes)
        self.UI.setAttribute("ep" .. i, "active", false)
    end
    self.UI.setAttributes("equipScrollPanel", {height = 310 * math.ceil(count / 2) - 10})
    self.UI.show("selectEquip")
end

function equipChoice(player, value, id)
    local values = parseValues(value)
    for id, i in pairs(values) do
        local index = tonumber(id)
        build.equipment[index] = equipment[i]
        build.equipment[index].n = 1
    end
    fleetStaging()
end

function remove(player, value, id)
    local index = tonumber(string.gmatch(id, "%d+")())
    table.remove(build.equipment, index)
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
    local result = false
    for match in string.gmatch(id, "ship%d") do
        result = true
    end
    return result
end

function isDirective(id)
    local result = false
    for _, dir in pairs(dirTypes) do
        result = result or id == dir
    end
    return result
end

function isEquipment(id)
    local result = false
    for match in string.gmatch(id, "eq%d") do
        result = true
    end
    return result
end

function isTitle(id)
    return false
end

function hideAll()
    for _, id in pairs(panelIds) do
        self.UI.hide(id)
    end
end

function updateImages()
    hideAll()
    for type, path in pairs(defaultImages) do
        local image = getImage(type)
        self.UI.setAttribute(type, "image", image)
    end
    for i, equip in ipairs(build.equipment) do
        local images = getEquipmentImages(equip)
        self.UI.setAttributes("eq" .. i, {image = images.back, color = "White"})
        self.UI.setAttribute("e" .. i, "active", true)
    end
    self.UI.setAttributes("eq" .. #build.equipment + 1, {image = ASSET_ROOT .. "ui/PADD/equipment.png", color = "White"})
    self.UI.setAttribute("e" .. #build.equipment + 1, "active", true)
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