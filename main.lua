Object = require 'lib/classic/classic'
require 'color'

function recursiveEnumerate(folder)
    local file_list = {}

    local function buildFileList(folder)
        local items = love.filesystem.getDirectoryItems(folder)

        for _, item in ipairs(items) do
            local file = folder .. '/' .. item
            local fileType = love.filesystem.getInfo(file).type

            if fileType == 'file' then
                table.insert(file_list, file)
            else
                buildFileList(file)
            end
        end
    end

    buildFileList(folder)
    return file_list
end

function requireAll(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require (file)
    end
end

function love.load()
    requireAll(recursiveEnumerate('obj'))
    fnt = love.graphics.newFont('res/fnt/Pixel Square 10.ttf')
    game = Minesweeper(14, 11, 18)
end

function love.mousepressed(x, y, button)
    -- Discard if it's another button
    if button ~= 1 then
        return
    end

    -- s: start and e: end of the grid boundary
    local sx, ex = game:getX(), game:getX() + game:getWidth()
    local sy, ey = game:getY(), game:getY() + game:getHeight()

    -- Primary button pressed (left mouse button)
    -- Check if the mouse cursor is inside the boundary or not
    if (x > sx and x < ex ) and (y > sy and y < ey) then
        local cellSize = game:getCellSize()

        -- Get grid position of mouse int the grid
        local gmx = math.floor(((x - sx) / cellSize ) + 1)
        local gmy = math.floor(((y - sy) / cellSize ) + 1)

        -- Get the position of the cell in the array
        local cell = game:getCell(gmx, gmy)
        -- Unfold cell
        if cell.folded then
            game:unfoldCells(gmx, gmy)
        end
    end
end

function love.keypressed(key, isrepeat)
    if key == 'r' then
        game = Minesweeper(14, 11, 18)
    end
end

function love.update(dt)
    -- Do nothing right now
end

function love.draw()
    love.graphics.setBackgroundColor(Color.RAYWHITE)
    -- love.graphics.setFont(fnt)
    game:draw()
end
