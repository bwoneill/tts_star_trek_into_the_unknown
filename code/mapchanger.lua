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
    local board = locateBoard()
    if board then
        local param = board.getCustomObject()
        param.image = mapURL
        board.setCustomObject(param)
        board.reload()
    end
end

function click_RotateLeft()
    local board = locateBoard()
    local angle = board.getRotation()
    board.setRotation({angle.x, angle.y+90, angle.z})
end

function click_RotateRight()
    local board = locateBoard()
    local angle = board.getRotation()
    board.setRotation({angle.x, angle.y-90, angle.z})
end

function locateBoard()
    local boards = getObjectsWithTag("Board")
    if #boards < 1 then
        log("Unable to find board")
    elseif #boards > 1 then
        log("Too many boards")
    else
        return boards[1]
    end
end