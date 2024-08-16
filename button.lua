-- button.lua
local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, label)
    local btn = setmetatable({}, Button)
    btn.x = x
    btn.y = y
    btn.width = width
    btn.height = height
    btn.label = label
    btn.hovered = false
    return btn
end

function Button:isMouseOver(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

function Button:draw()
    if self.hovered then
        love.graphics.setColor(0.8, 0.8, 0.2)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    love.graphics.printf(self.label, self.x, self.y + self.height / 4, self.width, "center")
    love.graphics.setColor(1, 1, 1)
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = self:isMouseOver(mx, my)
end

function Button:mousepressed(mx, my, button, score)
    if button == 1 and self:isMouseOver(mx, my) then
        anim.startAnimation(score) -- Call the animation with the current score
    end
end

return Button
