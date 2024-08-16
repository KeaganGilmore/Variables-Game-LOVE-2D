local Player = {}

function Player:new()
    local player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - 50,
        width = 40,
        height = 60,
        speed = 300,
        bullets = {}
    }
    setmetatable(player, self)
    self.__index = self
    return player
end

function Player:update(dt)
    if love.keyboard.isDown('a') and self.x > 0 then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown('d') and self.x < love.graphics.getWidth() - self.width then
        self.x = self.x + self.speed * dt
    end
    
    for i, bullet in ipairs(self.bullets) do
        bullet.y = bullet.y - 500 * dt
        if bullet.y < 0 then
            table.remove(self.bullets, i)
        end
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(self.bullets) do
        love.graphics.circle('fill', bullet.x, bullet.y, 5)
    end
end

function Player:shoot()
    table.insert(self.bullets, {x = self.x + self.width / 2, y = self.y})
end

function Player:checkCollision(target)
    for i, bullet in ipairs(self.bullets) do
        if bullet.x > target.x and bullet.x < target.x + target.width and
           bullet.y > target.y and bullet.y < target.y + target.height then
            table.remove(self.bullets, i)
            return true
        end
    end
    return false
end

return Player