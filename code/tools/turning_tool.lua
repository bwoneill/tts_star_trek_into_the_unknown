function onDrop()
    local rulers = getObjectsWithTag("Ruler")
    local closest = nil
    local dist = 12
    local pos = self.getPosition()
    for _, ruler in pairs(rulers) do
        local d = (pos - ruler.getPosition()):magnitude()
        if d < dist then
            d = dist
            closest = ruler
        end
    end
    if closest then
        local rot = closest.getRotation().y
        local d = (pos - closest.getPosition()):rotateOver("y", -rot)
        if d.z > 0 then
            d.z = 1.3
            self.setRotation(Vector(0, rot - 90, 0))
        else
            d.z = -1.3
            self.setRotation(Vector(0, rot + 90, 0))
        end
        d:rotateOver("y", rot)
        self.setPosition(d + closest.getPosition())
    end
end