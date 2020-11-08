Minesweeper = Object:extend()

function Minesweeper:new(rows, cols, mines)
    -- Geometry
    self.rows, self.cols = rows, cols
    self.cellsize        = 32
    self.width           = self.cols * self.cellsize
    self.height          = self.rows * self.cellsize
    self.x               = love.graphics.getWidth()/2 - self.width/2
    self.y               = love.graphics.getHeight()/2 - self.height/2

    -- Properties
    self.mines = mines
    self.array = {}

    -- Generate
    self:emptyGrid()
    self:populateMines(0.55)
    self:populateHints()
    self:populateHints()
end

function Minesweeper:getX()
    return self.x
end

function Minesweeper:getY()
    return self.y
end

function Minesweeper:getPosition()
    return self:getX(), self:getY()
end

function Minesweeper:getRows()
    return self.rows
end

function Minesweeper:getCols()
    return self.cols
end

function Minesweeper:getWidth()
    return self.width
end

function Minesweeper:getHeight()
    return self.height
end

function Minesweeper:getDimensions()
    return self:getWidth(), self:getHeight()
end

function Minesweeper:getCellSize()
    return self.cellsize
end

function Minesweeper:emptyGrid()
    local length = self.rows * self.cols

    for i = 1, length do
        self.array[i]        = {}
        self.array[i].mine   = false
        self.array[i].folded = true
        self.array[i].hints  = 0
    end
end

function Minesweeper:getCell(x, y)
    if x < 1 or y < 1 then
        return nil, 0
    end

    if x > self.cols or y > self.rows then
        return nil, 0
    end

    local pos = x + (y - 1) * self.cols
    return self.array[pos], pos
end

function Minesweeper:populateMines(chances)
    local count = self.mines

    while count > 0 do
        local cx = love.math.random(self.cols)
        local cy = love.math.random(self.rows)
        local rand_chance = love.math.random()

        if rand_chance > chances then
            local cell, pos = self:getCell(cx, cy)

            if not cell.mine then
                self.array[pos].mine = true
                count = count - 1
            end
        end
    end
end

function Minesweeper:getMineCount(x, y)
    local count = 0

    for ly = -1, 1 do
        for lx = -1, 1 do
            -- nx, ny: neighbour x and y
            local nx, ny = x + lx, y + ly
            local cell = self:getCell(nx, ny)

            if not (nx == x and ny == y) then
                if cell ~= nil and cell.mine then
                    count = count + 1
                end
            end
        end
    end

    return count
end

function Minesweeper:populateHints()
    for ly = 1, self.rows do
        for lx = 1, self.cols do
            local cell, pos = self:getCell(lx, ly)

            if not cell.mine then
                self.array[pos].hints = self:getMineCount(lx, ly)
            end
        end
    end
end

function Minesweeper:unfold(pos)
    self.array[pos].folded = false
end

function Minesweeper:unfoldCells(x, y)
    local cell, pos = self:getCell(x, y)
    if cell == nil then
        return
    end

    if cell.folded then
        self:unfold(pos)
        if cell.hints > 0 or cell.mine then
            return
        else
            -- Unfold neighbours
            for ly = -1, 1 do
                for lx = -1, 1 do
                    local nx, ny = x + lx, y + ly

                    -- Skip the current cell position
                    if nx ~= x or ny ~= y then
                        self:unfoldCells(nx, ny)
                    end
                end
            end
        end
    end
end

function Minesweeper:update(dt)
end

function Minesweeper:draw(dt)
    love.graphics.setColor(Color.LIGHTGRAY)
    -- love.graphics.setColor(Color.DARKGREEN)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    for ly = 1, self.rows do
        for lx = 1, self.cols do
            local cell, pos = self:getCell(lx, ly)

            local px = self.x + ((lx - 1) * self.cellsize)
            local py = self.y + ((ly - 1) * self.cellsize)
            local tx = px + self.cellsize/2 - 5
            local ty = py + self.cellsize/2 - 5

            love.graphics.setColor(Color.BLACK)
            love.graphics.rectangle("line", px, py, self.cellsize, self.cellsize)

            if cell.folded then
                love.graphics.setColor(Color.WHITE)
                -- love.graphics.setColor(Color.LIME)
                love.graphics.rectangle("fill", px, py, self.cellsize - 4, self.cellsize - 4)
            else
                if cell.mine then
                    -- love.graphics.setColor(Color.RED)
                    love.graphics.setColor(Color.BLACK)
                    love.graphics.print('x', tx, ty)
                else
                    -- love.graphics.setColor(Color.BLUE)
                    love.graphics.setColor(Color.BLACK)
                    love.graphics.print(cell.hints == 0 and "" or cell.hints, tx, ty)
                end
            end
        end
    end
end
