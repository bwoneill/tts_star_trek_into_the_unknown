function library()
    self.UI.setAttribute("library", "active", true)
    librarySearch()
end

libraryImages = {"cardFront","cardBack", "shipBoard", "shipImage", "auxFront", "auxBack", "libraryText"}
typeImages = {officer = {"cardFront", "cardBack"}, equipment = {"cardFront", "cardBack"},
              ship = {"shipBoard", "shipImage"}, auxiliary = {"auxFront", "auxBack"}}

function librarySearch(player, value, id)
    searchResults = searchAssets(value)
    local newXml = [[<GridLayout id="searchResults" cellSize="400 50" color="Black">"]]
    for i, value in pairs(searchResults) do
        newXml = newXml .. [[<Text id = "sr]] .. i ..  [[" fontSize="28" alignment = "MiddleLeft" onClick = "displayResult">]]
                        .. GameType:new(value):getName() .. "</Text>"
    end
    if #searchResults < 1 then
        newXml = newXml .. [[<Text fontSize = "28" alignment = "LowerLeft">None</Text>]]
    end
    newXml = newXml .. "</GridLayout>"
    local xml = self.UI.getXml()
    local start, _ = string.find(xml, [[<GridLayout id="searchResults"]])
    local _, stop = string.find(xml, "</GridLayout>", start)
    xml = string.sub(xml, 1, start -1) .. newXml .. string.sub(xml, stop + 1)
    self.UI.setXml(xml)
    self.UI.setAttribute("searchField", "text", value)
    self.UI.setAttribute("searchScrollPanel", "height", math.max(50 * #searchResults, 700))
end

function searchAssets(text)
    text = cleanSearchText(text)
    if not LIBRARY then
        LIBRARY = Global.getTable("LIBRARY")
    end
    local results = {}
    for _, value in pairs(LIBRARY) do
        local target = ""
        if gtype[value.gtype] then
            local obj = GameType:new(value)
            target = cleanSearchText(obj:toString())
        else
            target = value.name .. " " .. value.text
        end
        if wordMatch(target, text) then
            table.insert(results, value)
        end
    end
    return results
end

function displayResult(player, value, id)
    local index = tonumber(string.match(id, "%d+"))
    for i = 1, #searchResults do
        self.UI.setAttribute("sr" .. i, "color", index == i and "Blue" or "White")
    end
    selected = searchResults[index]
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