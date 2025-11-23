Ship = {}

function Ship:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Ship:getImagePaths()
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/" .. self.folder .. "/" .. self.type .. "/"
    return {path .. "ship_board.png", path .. "image.png"}
end

function Ship:spawnObject(pos, rot)
    pos = pos or Vector(0,0,0)
    rot = rot or Vector(0,0,0)
    local path = ASSET_ROOT .. "factions/" .. self.faction .. "/" .. self.folder .. "/" .. self.type .. "/"
    local ship_xml = Global.call("getFile", path .. self.type .. ".xml")
    local script = "default = Global.getTable(\"ASSETS\").factions." .. self.faction .. "." .. self.folder .."." .. self.type .. "\n"
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
    local back = path .. "crit_back.png"
    for i = 1, self.crit_deck_size do
        local front = path .. "crit_" .. i .. ".png"
        local offset = Vector(-6.25, 0, 6):rotateOver("y", rot.y)
        local card = spawnObject({type = "CardCustom", position = pos + offset, rotation = Vector(0, rot.y, 180)})
        card.setCustomObject({face = front, back = back, sound = false})
    end
    return spawnObjectData(result)
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

Card = {}

function Card:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Card:spawnObject(pos, rot)
    local card = spawnObject({type = "CardCustom", position = pos, rotation = rot})
    local images = self:getImagePaths()
    card.setCustomObject({face = images[1], back = images[2]})
    return card
end

Officer = Card:new()

function Officer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Officer:getImagePaths()
    local path = ASSET_ROOT .. "/officers/" .. string.gsub(self.name .. (self.subtitle and "_" .. self.subtitle or ""), " ", "_")
    local result = {path .. ".png", path .. "_back.png"}
    return result
end

Equipment = Card:new()

function Equipment:getImagePaths()
    local path = ASSET_ROOT .. "/equipment/" .. string.gsub(self.name, " ", "_")
    local result = {path .. ".png", path .. "_back.png"}
    return result
end

otype = {ship = Ship, auxiliary = Auxiliary, officer = Officer, equipment = Equipment}