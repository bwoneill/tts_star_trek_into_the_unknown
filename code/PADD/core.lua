ASSET_ROOT = Global.getVar("ASSET_ROOT")

function onLoad()
    start()
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