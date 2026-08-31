function library()
    self.UI.setAttribute("library", "active", true)
    librarySearch()
end

function initLibrary()
    if not LIBRARY then
        LIBRARY = Global.getTable("LIBRARY")
    end
    local newXml = [[<GridLayout id="searchResults" cellSize="400 50" color="Black">]]
    newXml = newXml .. [[<Text id = "sr0" fontSize = "28" alignment = "LowerLeft">None</Text>]]
    for i, value in pairs(LIBRARY) do
        newXml = newXml .. [[<Text id = "sr]] .. i ..  [[" fontSize="28" alignment = "MiddleLeft" onClick = "displayResult" horizontalOverflow = "Overflow">]]
                        .. GameType:new(value):getName() .. "</Text>"
    end
    newXml = newXml .. "</GridLayout>"
    local xml = self.UI.getXml()
    local start, _ = string.find(xml, [[<GridLayout id="searchResults"]])
    local _, stop = string.find(xml, "</GridLayout>", start)
    xml = string.sub(xml, 1, start -1) .. newXml .. string.sub(xml, stop + 1)
    self.UI.setXml(xml)
end

libraryImages = {"cardFront","cardBack", "shipBoard", "shipImage", "auxFront", "auxBack", "libraryText"}
typeImages = {officer = {"cardFront", "cardBack"}, equipment = {"cardFront", "cardBack"},
              ship = {"shipBoard", "shipImage"}, auxiliary = {"auxFront", "auxBack"},
              overture = {"auxFront", "auxBack"}, situation = {"auxFront", "auxBack"}, complication = {"auxFront", "auxBack"},
              directive = {"auxFront", "auxBack"}, title = {"cardFront", "cardBack"}}

function librarySearch(player, text, id)
    text = cleanSearchText(text)
    if not LIBRARY then
        LIBRARY = Global.getTable("LIBRARY")
    end
    local count = 0
    for i, value in pairs(LIBRARY) do
        local target = ""
        if gtype[value.gtype] then
            local obj = GameType:new(value)
            target = cleanSearchText(obj:toString())
        else
            log(value)
            target = value.name .. " " .. value.text
        end
        local match = wordMatch(target, text)
        self.UI.setAttribute("sr" .. i, "active", match and true or false)
        count = count + (match and 1 or 0)
    end
    self.UI.setAttribute("sr0", "active", count == 0)
    self.UI.setAttribute("searchScrollPanel", "height", math.max(50 * count, 700))
    return results
end

function displayResult(player, value, id)
    local index = tonumber(string.match(id, "%d+"))
    for i = 1, #LIBRARY do
        self.UI.setAttribute("sr" .. i, "color", index == i and "Blue" or "White")
    end
    selected = LIBRARY[index]
    for _, element in ipairs(libraryImages) do
        self.UI.setAttribute(element, "active", false)
    end
    if gtype[selected.gtype] then
        selected = GameType:new(selected)
        if selected.gtype == "keyword" then
            self.UI.setAttributes("libraryText", {text = selected.name .. "\n" .. selected.text, active = true})
        else
            local images = selected:getImages()
            if typeImages[selected.gtype] then
                for i, x in ipairs(typeImages[selected.gtype]) do
                    local attributes = {image = images[i], active = true}
                    self.UI.setAttributes(x, {image = images[i], active = true})
                end
            end
        end
        self.UI.setAttribute("librarySpawn", "interactable", selected.spawnable or false)
    end

end

function librarySpawn(player, value, id)
    if selected then
        local obj = GameType:new(selected)
        local pos = self.getPosition()
        local rot = self.getRotation()
        rot.y = rot.y + 180
        if selected.gtype == "ship" then
            pos = pos + Vector(16, 0, -3.25):rotateOver("y", rot.y)
        elseif selected.gtype == "auxiliary" then
            pos = pos + Vector(17.75, 0, 3):rotateOver("y", rot.y)
        else
            pos = pos + Vector(13, 0, 2.75):rotateOver("y", rot.y)
        end
        obj:spawnObject(pos, rot)
    end
end

function cleanSearchText(text)
    text = text or ""
    text = string.lower(text)
    text = string.gsub(text, "[-_]", " ")
    text = string.gsub(text, "[^%w%d%s]", "")
    return text
end

function wordMatch(target, words)
    local match = true
    for w in words:gmatch("%S+") do
        match = match and target:match(w)
    end
    return match
end

apps.library = {start = library, init = initLibrary}