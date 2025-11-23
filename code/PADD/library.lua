function library()
    self.UI.setAttribute("library", "active", true)
    librarySearch()
end

function librarySearch(player, value, id)
    results = searchAssets(value)
    local newXml = "<GridLayout id=\"searchResults\" cellSize=\"400 50\" color=\"Black\">"
    for i, value in pairs(results) do
        newXml = newXml .. "<Text id = \"sr" .. i ..  "\" fontSize=\"28\" alignment = \"LowerLeft\" onClick = \"displayResult\">"
                        .. value.name .. (value.subtitle and ", " .. value.subtitle or "") .. "</Text>"
    end
    if #results < 1 then
        newXml = newXml .. "<Text fontSize = \"28\" alignment = \"LowerLeft\">None</Text>"
    end
    newXml = newXml .. "</GridLayout>"
    local xml = self.UI.getXml()
    local start, _ = string.find(xml, [[<GridLayout id="searchResults"]])
    local _, stop = string.find(xml, "</GridLayout>", start)
    xml = string.sub(xml, 1, start -1) .. newXml .. string.sub(xml, stop + 1)
    self.UI.setXml(xml)
    self.UI.setAttribute("searchField", "text", value)
    self.UI.setAttribute("searchScrollPanel", "height", math.max(50 * #results, 700))
end

function searchAssets(text)
    text = text or ""
    if not LIBRARY then
        LIBRARY = Global.getTable("LIBRARY")
    end
    local results = {}
    for _, value in pairs(LIBRARY) do
        local fullName = value.name .. (value.subtitle and ", " .. value.subtitle or "")
        if string.match(fullName, text) then
            table.insert(results, value)
        end
    end
    return results
end

function displayResult(player, value, id)
    local index = tonumber(string.match(id, "%d+"))
    for i = 1, #results do
        self.UI.setAttribute("sr" .. i, "color", index == i and "Blue" or "White")
    end
    local selected = results[index]
    local obj = otype[selected.otype]:new(selected)
    obj:spawnObject()
end