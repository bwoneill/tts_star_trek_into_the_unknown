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

reset_ui = true

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

function setData(new_data)
    for key, value in pairs(new_data) do
        data[key] = value
    end
    self.UI.setAttribute("foreground", "visibility", data.owner)
end

function onSave()
    data.xml = self.UI.getXmlTable()
    return JSON.encode(data)
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
            print(data.ship_type .. "(" .. data.shipGUID .. ") detected " .. description[data[tlm_type]] .. " of the wake tracker")
        end
    end
end

function cloak(player, value, id)
    self.UI.setAttribute("posDrp", "interactable", "false")
    self.UI.setAttribute("disDrp", "interactable", "false")
    self.UI.setAttribute("cloak", "interactable", "false")
    print(data.ship_type .. "(" .. data.shipGUID .. ") cloaked (position locked-in)")
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
    print(data.ship_type .. "(" .. data.shipGUID .. ") decloaking in direction " .. data.pos .. " at " .. data.dis     .. " of the wake tracker")
end