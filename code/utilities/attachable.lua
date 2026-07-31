-- data = {
--     station = "text",
--     requirements = {requirement = value},
--     xml = "text",
--     parent = object,
--     orders = {id = {call = "callableFunction", par = "parameters"}}
-- }

attaching = false

function onLoad(script_state)
    if not data then
        data = {}
    end
    if data.xml then
        self.UI.setXml()
    end
    if script_state and script_state.parent then
        data.parent = script_state.parent
    end
end

function onSave()
    return JSON.encode(data)
end

function onClick(player, value, id)
    order = data.orders[value]
    if order and data.parent then
        data.parent.call(order.call, order.par)
    end
end

function attach(player, value, id)
    attaching = player.color
    log("attach")
    log(player.color)
    -- display message
    broadcastToColor("Pick up a ship to attach", player.color)
end

function onObjectPickUp(player_color, object)
    log("onObjectPickUp")
    log(player_color)
    log(attaching)
    log(object)
    if player_color == attaching then
        data.parent = object.getGUID()
        attaching = false
        broadcastToColor("Equipment attached", player.color)
    end
end