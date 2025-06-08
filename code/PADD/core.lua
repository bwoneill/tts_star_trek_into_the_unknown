ASSET_ROOT = Global.getVar("ASSET_ROOT")

refresh = 5
increments = 15

function onLoad()
    start()
    frame = 0
end

function onUpdate()
    if frame % refresh == 0 then
        local step = frame / refresh
        local n = step / increments
        local x = step % increments / increments
        local color
        if n < 1 then
            color = Color(1, x, 0)
        elseif n < 2 then
            color = Color(1 - x, 1, 0)
        elseif n < 3 then
            color = Color(0, 1, x)
        elseif n < 4 then
            color = Color(0, 1 - x, 1)
        elseif n < 5 then
            color = Color(x, 0, 1)
        elseif n < 6 then
            color = Color(1, 0, 1 - x)
        end
        self.UI.setAttribute("title", "color", "#" .. color:toHex())
    end
    frame = frame + 1
    if frame >= 6 * refresh * increments then
        frame = 0
    end
end

function start(player, value, id)
    for name, _  in pairs(apps) do
        self.UI.setAttribute(name, "active", false)
    end
    if apps[value] then
        apps[value]()
    end
end

function close(player, value, id)
    self.UI.setAttribute(value, "active", false)
end