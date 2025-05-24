mapURLs = {
    "grid_empty.png", "A_Touch_of_Pink.png", "Aqua_Marine.png", "Horsehead.png",
    "Last_Star_Tonight.png", "Lower_Decks.png", "Mr_Blue_Sky.png",
    "Mystic_Mountain.png", "Nexus_ribbon.png", "Space_Clouds.jpg",
    "Space_Frost.jpg", "Starry_Knight.png", "Sword_of_Orion.png"
}

function maps()
    for i, url in ipairs(mapURLs) do
        local attributes = {
            image = ASSET_ROOT .. "maps/" .. url,
            onClick = "loadMap(" .. i .. ")"
        }
        self.UI.setAttributes("map" .. i, attributes)
    end
    self.UI.setAttribute("mapsPanel", "height", 360 * math.ceil(#mapURLs / 3))
    self.UI.setAttribute("maps", "active", true)
end

function rotateLeft()
    local board = locateBoard()
    local angle = board.getRotation()
    board.setRotation({angle.x, angle.y+90, angle.z})
end

function rotateRight()
    local board = locateBoard()
    local angle = board.getRotation()
    board.setRotation({angle.x, angle.y-90, angle.z})
end

function locateBoard()
    local boards = getObjectsWithTag("Board")
    if #boards < 1 then
        log("Unable to find board")
    elseif #boards > 1 then
        log("Too many boards")
    else
        return boards[1]
    end
end

function loadMap(player, value, id)
    local i = tonumber(value)
    if i > 0 and i <= #mapURLs then
        local board = locateBoard()
        if board then
            local param = board.getCustomObject()
            param.image = ASSET_ROOT .. "maps/" .. mapURLs[i]
            board.setCustomObject(param)
            board.reload()
        end
    end
end

function closeMaps(player, value, id)
    self.UI.setAttribute("maps", "active", false)
end