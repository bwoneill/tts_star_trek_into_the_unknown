colors = {
    A = "#ce6737",
    B = "#ce6737",
    C = "#3b3690",
    D = "#3b3690",
    E = "#d83e83",
    F = "#d83e83",
    G = "#8db9c7",
    H = "#8db9c7",
    ["1\""] = "#ce6737",
    ["2\""] = "#ce6737",
    ["3\""] = "#ce6737",
    ["4\""] = "#8db9c7",
    ["5\""] = "#8db9c7",
    ["6\""] = "#8db9c7"
}

textColor = {
    C = "#ffffff",
    D = "#ffffff"
}

values = {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4,
    F = 5,
    G = 6,
    H = 7,
    ["1\""] = 0,
    ["2\""] = 1,
    ["3\""] = 2,
    ["4\""] = 3,
    ["5\""] = 4,
    ["6\""] = 5
}

description = {
    A = "in the [ce6737]orange[ffffff]orange quadrent",
    B = "in the [ce6737]orange[ffffff] quadrent",
    C = "in the [3b3690]dark blue[ffffff] quadrent",
    D = "in the [3b3690]dark blue[ffffff] quadrent",
    E = "in the [d83e83]magenta[ffffff] quadrent",
    F = "in the [d83e83]magenta[ffffff] quadrent",
    G = "in the [8db9c7]light blue[ffffff] quadrent",
    H = "in the [8db9c7]light blue[ffffff] quadrent",
    ["1\""] = "within [ce6737]orange[ffffff] range (1-3\")",
    ["2\""] = "within [ce6737]orange[ffffff] range (1-3\")",
    ["3\""] = "within [ce6737]orange[ffffff] range (1-3\")",
    ["4\""] = "within [8db9c7]light blue[ffffff] range (4-6\")",
    ["5\""] = "within [8db9c7]light blue[ffffff] range (4-6\")",
    ["6\""] = "within [8db9c7]light blue[ffffff] range (4-6\")",
}

rotation = {
    A = 210, B = 240, C = 300, D = 330, E = 30, F = 60, G = 120, H = 150
}

reset_ui = false

function setData(new_data)
    data = new_data or {
        pos = "A",
        dis = "1\"",
        ship_type = "Unknown ship",
        owner = "Black"
    }
end

function onLoad(script_state)
    data = {
        pos = "A",
        dis = "1\"",
        ship_type = "Unknown ship",
        owner = "Black"
    }
    local state = JSON.decode(script_state)
    if state then
        data = state
        if state.xml and not reset_ui then
            self.UI.setXmlTable(state.xml)
            self.UI.setAttribute("posDrp", "value", values[data.pos])
            self.UI.setAttribute("disDrp", "value", values[data.dis])
        end
    end
    self.UI.setAttribute("foreground", "visibility", data.owner)
end

function onSave()
    data.xml = self.UI.getXmlTable()
    return JSON.encode(data)
end

function onDestroy()
    local parent = getObjectFromGUID(data.parent)
    parent.call("clearCloak")
end

function valueChanged(player, value, id)
    local ui_type = id:sub(-3)
    local tlm_type = id:sub(0, 3)
    if ui_type == "Drp" then
        data[tlm_type] = value
        self.UI.setAttribute(id, "color", colors[value])
        self.UI.setAttribute(id, "textColor", textColor[value] or "#000000")
        self.UI.setAttribute(id, "itemTextColor", "#000000")
        self.UI.setAttribute(id, "arrowColor", textColor[value] or "#000000")
    elseif ui_type == "Rev" then
        self.UI.setAttribute(tlm_type .. "Tlm", "color", value == "True" and colors[data[tlm_type]] or "#000000")
        if value == "True" then
            print(data.ship_type .. "(" .. data.parent .. ") detected " .. description[data[tlm_type]] .. " of the wake tracker")
        end
    end
end

function cloak(player, value, id)
    self.UI.setAttribute("posDrp", "interactable", "false")
    self.UI.setAttribute("disDrp", "interactable", "false")
    self.UI.setAttribute("cloak", "interactable", "false")
    print(data.ship_type .. "(" .. data.parent .. ") cloaked (position locked-in)")
    local parent = getObjectFromGUID(data.parent)
    parent.call("completeCloak")
end

function close(player, value, id)
    self.UI.setAttribute("stealth", "active", "false")
    self.UI.setAttribute("show", "active", "true")
end

function show(player, value, id)
    self.UI.setAttribute("stealth", "active", "true")
    self.UI.setAttribute("show", "active", "false")
end

function decloak(player, value, id)
    self.UI.setAttribute("foreground", "visibility", "")
    print(data.ship_type .. "(" .. data.parent .. ") decloaking in direction " .. data.pos .. " at " .. data.dis     .. " of the wake tracker")
    local parent = getObjectFromGUID(data.parent)
    decloaking = true
    placeRuler(player, data.dis, data.pos)
end

function cancelDecloak(player, value, id)
    clearRuler()
end

function finishDecloak(player, value, id)
    clearRuler()
    local parent = getObjectFromGUID(data.parent)
    parent.call("decloak")
end

function clearRuler(player, value, id)
    if ruler then
        ruler.destroy()
        ruler = nil
        ruler_pos = nil
    end
end

function placeRuler(player, value, id)
    ruler_pos = id
    local pos = self.getPosition()
    local rot = self.getRotation()
    local offset = Vector(0, 0.2, 6.4):rotateOver("y", rot.y + rotation[id])
    local ruler_data = Global.getTable("ASSETS").tools.ruler_12in
    ruler = spawnObjectData(ruler_data)
    ruler.lock()
    ruler.setPosition(pos + offset)
    ruler.setRotation(rot + Vector(0, rotation[id] + 90, 0))
    for i = 1, 6 do
        if string.sub(value, -1) ~= "\"" or value == i .. "\"" then
            ruler.createButton({function_owner = self, click_function = "placeShipDis" .. i, label = i .. "\"", rotation = {0, 90, 0},
                                position = {(i - 6) / ruler_data.data.Transform.scaleX, 0.07, 0}, width = 150, height = 125})
        end
    end
    ruler.createButton({function_owner = self, click_function = "clearRuler", label = "Cancel", rotation = {0, 90, 0}, width = 400,
                        position = {-5.9 / ruler_data.data.Transform.scaleX, 0.07, 0}})
end

function placeShipDis1() placeShip(1) end
function placeShipDis2() placeShip(2) end
function placeShipDis3() placeShip(3) end
function placeShipDis4() placeShip(4) end
function placeShipDis5() placeShip(5) end
function placeShipDis6() placeShip(6) end

function placeShip(dis)
    local ruler_data = Global.getTable("ASSETS").tools.ruler_12in
    local parent = getObjectFromGUID(data.parent)
    local myShip = getObjectFromGUID(parent.getTable("saveData").shipGUID)
    myShip.setRotation(self.getRotation())
    local offset = parent.call("getCloakOffset", ruler_pos)
    local delta = Vector(0, 0, dis + offset + 0.4):rotateOver("y", self.getRotation().y + rotation[ruler_pos])
    myShip.setPosition(self.getPosition() + delta)
    local buttons = ruler.getButtons()
    for i = #buttons, 1, -1 do
        if buttons[i].label == "Decloak" then
            ruler.removeButton(buttons[i].index)
        end
    end
    if decloaking then
        ruler.createButton({function_owner = self, click_function = "finishDecloak", label = "Decloak", rotation = {0, 90, 0}, width = 450,
                            position = {(dis - 6) / ruler_data.data.Transform.scaleX, 0.07, 0.75}})
    end
end

-- build v1.1.0.9