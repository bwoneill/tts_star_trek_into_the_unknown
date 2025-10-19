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

selected = {pos = "A", dis = "1\""}

reset = true

ship_type = "Unknown ship"

function onLoad(script_state)
    if not reset then
        local state = JSON.decode(script_state)
        if state then
            selected = state.selected
            self.UI.setXmlTable(state.xml)
            local xml = self.UI.getXmlTable()
            if state.UI_state and xml then
                for name, active in pairs(saveData.UI_state) do
                    if xml[name] and xml[name].attributes then
                        xml[name].attributes.active = active
                    end
                end
                if #xml > 0 then
                    self.UI.setXmlTable(xml)
                end
            end
            self.UI.setAttribute("posDrp", "value", values[selected.pos])
            self.UI.setAttribute("disDrp", "value", values[selected.dis])
        end
    end
end

function onSave()
    local state = {}
    state.selected = selected
    state.owner = owner
    state.xml = self.UI.getXmlTable()
    return JSON.encode(state)
end

function valueChanged(player, value, id)
    local ui_type = id:sub(-3)
    local tlm_type = id:sub(0, 3)
    if ui_type == "Drp" then
        selected[tlm_type] = value
        self.UI.setAttribute(id, "color", colors[value])
        self.UI.setAttribute(id, "textColor", textColor[value] or "#000000")
        self.UI.setAttribute(id, "itemTextColor", "#000000")
        self.UI.setAttribute(id, "arrowColor", textColor[value] or "#000000")
    elseif ui_type == "Rev" then
        self.UI.setAttribute(tlm_type .. "Tlm", "color", value == "True" and colors[selected[tlm_type]] or "#000000")
        if value == "True" then
            print(ship_type .. " detected " .. description[selected[tlm_type]] .. " of the wake tracker")
        end
    end
end

function cloak(player, value, id)
    self.UI.setAttribute("posDrp", "interactable", "false")
    self.UI.setAttribute("disDrp", "interactable", "false")
    self.UI.setAttribute("cloak", "interactable", "false")
    print(ship_type .. " cloaked (position locked-in)")
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
    print(ship_type .. " decloaking in direction " .. selected.pos .. " at " .. selected.dis     .. " of the wake tracker")
end