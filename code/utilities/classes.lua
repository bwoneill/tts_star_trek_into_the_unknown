gtype = {}

GameType = {}

function GameType:new(o)
    o = o or {}
    local t = (o.gtype and gtype[o.gtype]) or self
    setmetatable(o, t)
    t.__index = t
    return o
end

function GameType:getName()
    return self.name
end

Ship = GameType:new{gtype = "ship", spawnable = true}

function Ship:getImagePaths()
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/ships/" .. self.type .. "/"
    return {path .. "ship_board.png", path .. "image.png"}
end

function Ship:getTitleImages(name)
    local result
    for i, v in ipairs(self.titles) do
        if v.name == name then
            name = name:gsub(" ", "_"):lower()
            local path = ASSET_ROOT .. "factions/" .. self.faction .. "/ships/" .. self.type .. "/title_" .. name
            result = {path .. "_front.png", path .. "_back.png"}
        end
    end
    return result
end

function Ship:toString()
    local result = "ship"
    for k, v in pairs(self) do
        result = result .. (type(v) == "string" and k~= "gtype" and " " .. v or "")
    end
    return result
end

function Ship:spawnObject(pos, rot, title)
    pos = pos or Vector(0,0,0)
    rot = rot or Vector(0,0,0)
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/ships/" .. self.type .. "/"
    local ship_xml = Global.call("getFile", path .. self.type .. ".xml")
    local script = "default = Global.getTable(\"ASSETS\").factions." .. self.faction .. ".ships." .. self.type .. "\n"
    script = script .. Global.call("getFile", CODE_ROOT .. "/ships/ship.lua")
    local result = {
        data = {
            Name = "Custom_Model", Transform = {scaleX = 1, scaleY = 1, scaleZ = 1}, Nickname = self.name,
            CustomMesh = {
                MeshURL = ASSET_ROOT .. "misc/ship_board.obj",
                DiffuseURL = path .. "ship_board.png",
                MaterialIndex = 3, Convex = false
            },
            LuaScript = script, XmlUI = ship_xml
        },
        position = pos,
        rotation = rot
    }
    -- Spawn damage deck
    local back = path .. "crit_back.png"
    for i = 1, self.crit_deck_size do
        local front = path .. "crit_" .. i .. ".png"
        local offset = Vector(-6.25, 0, 6):rotateOver("y", rot.y)
        local card = spawnObject({type = "CardCustom", position = pos + offset, rotation = Vector(0, rot.y, 180)})
        card.setCustomObject({face = front, back = back, sound = false})
    end
    -- Spawn line officer
    local officers = Global.getTable("ASSETS").factions[self.faction].officers
    for i, officer in ipairs(officers) do
        if officer.line_officer then
            local offset = Vector(-3, 0, 6):rotateOver("y", rot.y)
            Officer:new(officer):spawnObject(pos + offset, Vector(0, rot.y, 180))
        end
    end
    -- Spawn title
    if title and title.name then
        local offset = Vector(-6.25, 0, -2):rotateOver("y", rot.y)
        Card:new({images = self:getTitleImages(title.name)}):spawnObject(pos + offset, Vector(0, rot.y, 180))
    end
    return spawnObjectData(result)
end

function Ship:getTitles()
end

Auxiliary = Ship:new()

function Auxiliary:getImagePaths()
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/" .. self.folder .. "/" .. self.type .. "/"
    return {path .. self.type .. "_front.png", path .. self.type .. "_back.png"}
end

function Auxiliary:spawnObject(pos, rot)
    pos = pos or Vector(0,0,0)
    rot = rot or Vector(0,0,0)
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/" .. self.folder .. "/" .. self.type .. "/"
    local ship_xml = Global.call("getFile", path .. self.type .. ".xml")
    local script = "default = Global.getTable(\"ASSETS\").factions." .. self.faction .. "." .. self.folder .."." .. self.type .. "\n"
    script = script .. Global.call("getFile", CODE_ROOT .. "/ships/ship.lua")
    local card = spawnObject({type = "CardCustom", position = pos, rotation = rot, scale = {1.47, 1, 1.47}})
    local images = self:getImagePaths()
    card.setCustomObject({face = images[1], back = images[2], sound = false})
    card.setLuaScript(script)
    card.setName(self.name)
    card.UI.setXml(ship_xml)
    return card
end

Card = GameType:new{spawnable = true}

function Card:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Card:getImagePaths()
    return self.images
end

function Card:spawnObject(pos, rot)
    local card = spawnObject({type = "CardCustom", position = pos, rotation = rot})
    local images = self:getImagePaths()
    card.setCustomObject({face = images[1], back = images[2]})
    return card
end

function Card:toString()
    local result = ""
    for k, v in pairs(self) do
        result = result .. (type(v) == "string" and " " .. v or "")
    end
    return result
end

Officer = Card:new{gtype = "officer"}

function Officer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Officer:getImagePaths()
    local fullName = string.gsub(self.name .. (self.subtitle and "_" .. self.subtitle or ""), "%s", "_")
    local path = ASSET_ROOT .. "officers/" .. fullName:gsub("[^%w%d%s-_]", ""):gsub("%s", "_")
    local result = {path .. ".png", path .. "_back.png"}
    return result
end

function Officer:toString()
    local result = "officer"
    for k, v in pairs(self) do
        if k == "factions" or k == "sway" or k == "roles" then
            result = result .. (k == "sway" and " sway" or "")
            for i, j in pairs(v) do
                result = result .. " " .. i
            end
        elseif k == "unique" then
            result = result .. (v and " unique" or "")
        elseif k == "line_officer" then
            result = result .. (v and " line officer" or "")
        elseif type(v) == "string" and k ~= "gtype" then
            result = result .. " " .. v
        end
    end
    return result
end

function Officer:getName()
    return self.name .. (self.subtitle and ", " .. self.subtitle or "")
end

Equipment = Card:new{gtype = "equipment"}

function Equipment:getImagePaths()
    local path = ASSET_ROOT .. "/equipment/" .. string.gsub(self.name, " ", "_")
    local result = {path .. ".png", path .. "_back.png"}
    return result
end

function Equipment:toString()
    local result = "equipment "
    for k, v in pairs(self) do
        result = result .. (type(v) == "string" and " " .. v or "")
    end
    if self.factions then
        for k, v in pairs(self.factions) do
            result = result .. (v and k or "")
        end 
    end
    return result
end

Directive = Card:new{gtype = "directive"}

function Directive:spawnObject(pos, rot)
end

Keyword = GameType:new{gtype = "keyword"}

function Keyword:toString()
    local result = "keyword " .. self.name .. " " .. self.text
    return result
end

gtype = {ship = Ship, auxiliary = Auxiliary, officer = Officer, equipment = Equipment, keyword = Keyword}