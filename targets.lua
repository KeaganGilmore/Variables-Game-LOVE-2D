local Targets = {}

function Targets:new()
    local targets = {
        list = {},
        spawnTimer = 0,
        spawnInterval = 1,
        shapes = {'rectangle', 'circle', 'triangle'},
        colors = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,0}, {1,0,1}, {0,1,1}}
    }
    setmetatable(targets, self)
    self.__index = self
    return targets
end

function Targets:update(dt)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self:spawn()
        self.spawnTimer = 0
    end
    
    for i, target in ipairs(self.list) do
        target.y = target.y + 100 * dt
        if target.y > love.graphics.getHeight() then
            table.remove(self.list, i)
        end
    end
end

function Targets:draw()
    for _, target in ipairs(self.list) do
        love.graphics.setColor(target.color)
        if target.shape == 'rectangle' then
            love.graphics.rectangle('fill', target.x, target.y, target.width, target.height)
        elseif target.shape == 'circle' then
            love.graphics.circle('fill', target.x + target.width/2, target.y + target.width/2, target.width/2)
        elseif target.shape == 'triangle' then
            love.graphics.polygon('fill', 
                target.x + target.width/2, target.y,
                target.x, target.y + target.height,
                target.x + target.width, target.y + target.height)
        end
    end
end

function Targets:spawn()
    local target = {
        shape = self.shapes[love.math.random(#self.shapes)],
        color = self.colors[love.math.random(#self.colors)],
        x = love.math.random(0, love.graphics.getWidth() - 30),
        y = -30,
        width = 30,
        height = 30
    }
    table.insert(self.list, target)
end

return Targets