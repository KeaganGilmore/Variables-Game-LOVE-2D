-- particles.lua
local Particles = {}

function Particles:new()
    local particles = {
        systems = {}
    }
    setmetatable(particles, self)
    self.__index = self
    return particles
end

function Particles:update(dt)
    for i, system in ipairs(self.systems) do
        system:update(dt)
        if system:getCount() == 0 then
            table.remove(self.systems, i)
        end
    end
end

function Particles:draw()
    for _, system in ipairs(self.systems) do
        love.graphics.draw(system)
    end
end

function Particles:spawn(x, y)
    local system = love.graphics.newParticleSystem(love.graphics.newCanvas(1, 1), 100)
    system:setPosition(x, y)
    system:setParticleLifetime(0.5, 1)
    system:setEmissionRate(100)
    system:setSizeVariation(1)
    system:setLinearAcceleration(-100, -100, 100, 100)
    system:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    system:emit(100)
    table.insert(self.systems, system)
end

return Particles

