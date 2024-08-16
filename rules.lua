local Rules = {}

function Rules:new()
    local rules = {
        shapes = {},
        colors = {},
        operations = {
            function(x) return x + 5 end,
            function(x) return x * 2 end,
            function(x) return x^2 end,
            function(x) return math.max(10, x) end,
            function(x) return x + math.floor(x/2) end,
            function(x) return x - 5 end,  -- Decreasing function
            function(x) return math.floor(x / 2) end,  -- Decreasing function
            function(x) return x / 3 end,  -- Decreasing function
            function(x) return math.min(x, 10) end,  -- Decreasing function
            function(x) return x - math.floor(x / 4) end  -- Decreasing function
        }
    }
    setmetatable(rules, self)
    self.__index = self
    
    rules:generateRules()
    
    return rules
end

function Rules:generateRules()
    local shapeTypes = {'rectangle', 'circle', 'triangle'}
    local colorNames = {'Red', 'Green', 'Blue', 'Yellow', 'Magenta', 'Cyan'}
    
    for _, shape in ipairs(shapeTypes) do
        self.shapes[shape] = love.math.random(1, 10)
    end
    
    for _, color in ipairs(colorNames) do
        self.colors[color] = self.operations[love.math.random(#self.operations)]
    end
end

function Rules:calculateScore(target)
    local baseScore = self.shapes[target.shape]
    local colorName = self:getColorName(target.color)
    return self.colors[colorName](baseScore)
end

function Rules:getColorName(color)
    if color[1] == 1 and color[2] == 0 and color[3] == 0 then return 'Red'
    elseif color[1] == 0 and color[2] == 1 and color[3] == 0 then return 'Green'
    elseif color[1] == 0 and color[2] == 0 and color[3] == 1 then return 'Blue'
    elseif color[1] == 1 and color[2] == 1 and color[3] == 0 then return 'Yellow'
    elseif color[1] == 1 and color[2] == 0 and color[3] == 1 then return 'Magenta'
    elseif color[1] == 0 and color[2] == 1 and color[3] == 1 then return 'Cyan'
    end
end

function Rules:drawIndex()
    local y = 50
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Rules:", 10, y)
    y = y + 30
    
    for shape, value in pairs(self.shapes) do
        love.graphics.print(shape .. " = " .. value, 10, y)
        y = y + 20
    end
    
    y = y + 20
    for color, func in pairs(self.colors) do
        local funcStr = self:getFunctionString(func)
        love.graphics.print(color .. ": " .. funcStr, 10, y)
        y = y + 20
    end
end

function Rules:getFunctionString(func)
    for i, operation in ipairs(self.operations) do
        if func == operation then
            if i == 1 then return "f(x) = x + 5"
            elseif i == 2 then return "f(x) = x * 2"
            elseif i == 3 then return "f(x) = x^2"
            elseif i == 4 then return "f(x) = max(10, x)"
            elseif i == 5 then return "f(x) = x + floor(x/2)"
            elseif i == 6 then return "f(x) = x - 5"
            elseif i == 7 then return "f(x) = floor(x / 2)"
            elseif i == 8 then return "f(x) = x / 3"
            elseif i == 9 then return "f(x) = min(x, 10)"
            elseif i == 10 then return "f(x) = x - floor(x / 4)"
            end
        end
    end
end

return Rules
