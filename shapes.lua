local Shapes = {}

function Shapes:new()
    local shapes = {
        list = {},
        spawnTimer = 0,
        spawnInterval = 2
    }
    setmetatable(shapes, self)
    self.__index = self
    return shapes
end

function Shapes:update(dt)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self:spawn()
        self.spawnTimer = 0
    end
    
    for i, shape in ipairs(self.list) do
        shape.y = shape.y + 100 * dt
        if shape.y > love.graphics.getHeight() then
            table.remove(self.list, i)
        end
    end
end

function Shapes:draw()
    for _, shape in ipairs(self.list) do
        love.graphics.setColor(shape.color)
        if shape.type == 'circle' then
            love.graphics.circle('fill', shape.x, shape.y, shape.radius)
        elseif shape.type == 'rectangle' then
            love.graphics.rectangle('fill', shape.x - shape.width/2, shape.y - shape.height/2, shape.width, shape.height)
        elseif shape.type == 'triangle' then
            love.graphics.polygon('fill', 
                shape.x, shape.y - shape.height/2,
                shape.x - shape.width/2, shape.y + shape.height/2,
                shape.x + shape.width/2, shape.y + shape.height/2)
        end
    end
end

function Shapes:spawn()
    local shapeTypes = {'circle', 'rectangle', 'triangle'}
    local colors = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,0}, {1,0,1}, {0,1,1}}
    
    local shapeType = shapeTypes[love.math.random(#shapeTypes)]
    local size = love.math.random(30, 50)
    
    local shape = {
        type = shapeType,
        color = colors[love.math.random(#colors)],
        x = love.math.random(50, love.graphics.getWidth() - 50),
        y = -50,
    }
    
    if shapeType == 'circle' then
        shape.radius = size / 2
    else
        shape.width = size
        shape.height = size
    end
    
    table.insert(self.list, shape)
end

return Shapes