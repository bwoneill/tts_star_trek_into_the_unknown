local ABoard = nil
local TheBoard = nil
local TheBoardGUID = nil
mapURL = {
	'https://i.imgur.com/8XFloOv.png',
 }
function onload ()

	self.createButton({
        label="Load This Map", click_function="click_LoadMap",function_owner=self, position={0,0.5,0},height=400, width=1200, font_size=150
    })

  self.createButton({
        label="Rotate Left", click_function="click_RotateLeft",function_owner=self, position={-4,0.5,0},height=400, width=1200, font_size=150
    })

	self.createButton({
        label="Rotate Right", click_function="click_RotateRight",function_owner=self, position={4,0.5,0},height=400, width=1200, font_size=150
    })

end
function click_LoadMap()
        local spos = self.getPosition()
        local nearest = nil
        local minDist = 2.89 -- 80mm
        for k,ship in pairs(getAllObjects()) do
            if ship.tag ~= 'Generic' then
                local pos = ship.getPosition()
                local dist = math.sqrt(math.pow((spos[1]-pos[1]),2) + math.pow((spos[3]-pos[3]),2))
                if dist < minDist then
                    nearest = ship
                    minDist = dist
                end
            end
        end
        if nearest ~= nil then
            TheBoard = nearest
			TheBoardGUID = TheBoard.getGUID()
        end
		TheBoard = getObjectFromGUID(TheBoardGUID)

		TheBoard = getObjectFromGUID(TheBoardGUID)

--	local myImage = self.getCustomObject()
--	myImage.diffuse =

	local selfParams = TheBoard.getCustomObject()
	selfParams.diffuse = mapURL[1]
	TheBoard.setCustomObject(selfParams)
	newSelf = TheBoard.reload()

end

function click_RotateLeft()

    local angle = newSelf.getRotation()

    newSelf.setRotation({angle.x, angle.y+90, angle.z})
end

function click_RotateRight()
    local angle = newSelf.getRotation()

    newSelf.setRotation({angle.x, angle.y-90, angle.z})
end