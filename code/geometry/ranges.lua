proj_geometry = {
    {start = 0, stop = 30, focal_point = Vector(0.43, 0, 0)},
    {start = 30, stop = 90, focal_point = Vector(0.43, 0, 0):rotateOver("y",60)},
    {start = 90, stop = 150, focal_point = Vector(0.43, 0, 0):rotateOver("y",120)},
    {start = 150, stop = 210, focal_point = Vector(0.43, 0, 0):rotateOver("y",180)},
    {start = 210, stop = 270, focal_point = Vector(0.43, 0, 0):rotateOver("y",240)},
    {start = 270, stop = 330, focal_point = Vector(0.43, 0, 0):rotateOver("y",300)},
    {start = 330, stop = 360, focal_point = Vector(0.43, 0, 0)}
}

feat_geometry = {
    {start = 0, stop = 360, focal_point = Vector(), radius = 0.625}
}

function toggleRanges(player, value, id)
    if active then
        self.setVectorLines({})
        active = false
    else
        local lines = {}
        local points = {}
        local scale = self.getScale().x
        local scales = {}
        for pair in value:gmatch("[^;]+") do
            local color, range = pair:match("%s*([%S]+)%s*=%s*([%S]+)")
            scales[color] = range / scale
            points[color] = {}
        end
        for _, g in ipairs(geometry) do
            local v = Vector(1, 0.05, 0):rotateOver("y", g.start)
            local focal_point = g.focal_point and g.focal_point:copy():scale(1 / scale) or Vector(0, 0, 0)
            local radius = g.radius and g.radius / scale or 0
            for theta = g.start, g.stop do
                for color, s in pairs(scales) do
                    table.insert(points[color], v:copy():scale(Vector(s + radius, 1, s + radius)) + focal_point)
                end
                v:rotateOver("y", 1)
            end
        end
        for color, p in pairs(points) do
            table.insert(lines, {points = p, color = color, thickness = 0.05})
        end
        self.setVectorLines(lines)
        active = true
    end
end