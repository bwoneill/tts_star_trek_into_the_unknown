-- data = {
--     station = "text",
--     requirements = {requirement = value},
--     xml = "text",
--     orders = {id = {call = "callableFunction", par = "parameters"}}
-- }

attaching = false
parent = nil

function onLoad(script_state)
    if not data then
        data = {}
    end
    if data.xml then
        self.UI.setXml()
    end
    if script_state and script_state.parentGUID then
        data.parentGUID = script_state.parentGUID
        parent = getObjectFromGUID(data.parentGUID)
    end
end

function onSave()
    return JSON.encode(data)
end

function onClick(player, value, id)
    if not parent then
        broadcastToColor("Not attached to a ship, press the Attach button", player.color)
    else
        order = data.orders[value]
        if order then
            if order.par == "player" then
                parent.call(order.call, player)
            else
                parent.call(order.call, order.par)
            end
        end
    end
end

function attach(player, value, id)
    attaching = player.color
    broadcastToColor("Pick up a ship board to attach", player.color)
end

function onObjectPickUp(player_color, object)
    if player_color == attaching then
        if object.hasTag("Ship") then
            data.parentGUID = object.getGUID()
            parent = getObjectFromGUID(data.parentGUID)
            attaching = false
            broadcastToColor("Card attached", player_color)
        else
            broadcastToColor("Must select a ship board", player_color)
        end
    end
end