ROOT = Global.getVar("ROOT")

ASSET_ROOT = Global.getVar("ASSET_ROOT")

apps = {}

function onLoad()
    ASSETS = Global.getTable("ASSETS")
    LIBRARY = Global.getTable("LIBRARY")
    for name, app in pairs(apps) do
        if app and app.init then
            app.init()
        end
    end
    start()
end

function start(player, value, id)
    for name, _  in pairs(apps) do
        self.UI.setAttribute(name, "active", false)
    end
    if apps[value] and apps[value].start then
        apps[value].start()
    end
end

function close(player, value, id)
    self.UI.setAttribute(value, "active", false)
end