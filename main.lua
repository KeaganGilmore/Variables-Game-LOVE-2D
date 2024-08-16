local Player = require('player')
local Targets = require('targets')
local Particles = require('particles')
local Rules = require('rules')
local Button = require('button')
local anim = require('carAnimation')

-- Declare variables
local player, targets, particles, rules, font, titleFont, score, animateButton, gameState
local introShader, backgroundShader

function love.load()
    love.window.setMode(800, 600, {resizable = false, vsync = true})
    font = love.graphics.newFont(18)
    titleFont = love.graphics.newFont(32)

    -- Initialize game components
    player = Player:new()
    targets = Targets:new()
    particles = Particles:new()
    rules = Rules:new()
    score = 0

    -- Initialize the animation
    anim.load()

    -- Create the button instance
    animateButton = Button:new(650, 550, 120, 40, "Animate")

    -- Set initial game state
    gameState = "intro"

    -- Load shaders
    introShader = love.graphics.newShader("shaders/intro.glsl")
    introShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})

    backgroundShader = love.graphics.newShader("shaders/background.glsl")
    backgroundShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function love.update(dt)
    if gameState == "playing" then
        -- Update game components
        player:update(dt)
        targets:update(dt)
        particles:update(dt)
        animateButton:update(dt)

        -- Check for collisions
        for i, target in ipairs(targets.list) do
            if player:checkCollision(target) then
                local targetScore = rules:calculateScore(target)
                score = score + targetScore
                particles:spawn(target.x, target.y)
                table.remove(targets.list, i)
            end
        end

        backgroundShader:send("time", love.timer.getTime())
    elseif gameState == "animating" then
        anim.update(dt)
        if anim.result ~= "" then
            gameState = "result"
        end
    elseif gameState == "intro" then
        introShader:send("time", love.timer.getTime())
    end
end

function love.draw()
    if gameState == "intro" then
        love.graphics.setShader(introShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
        drawIntro()
    else
        love.graphics.setShader(backgroundShader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()

        love.graphics.setFont(font)

        if gameState == "playing" then
            -- Draw game components
            targets:draw()
            player:draw()
            particles:draw()
            animateButton:draw()
        elseif gameState == "animating" then
            anim.draw()
        end

        if gameState == "result" then
            anim.draw() -- Ensure the animation result is displayed
            love.graphics.printf("Animation complete. Score: " .. score, 0, 500, 800, "center")
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score: " .. score, 10, 10)

        rules:drawIndex()
    end
end

function drawIntro()
    -- Draw intro screen with bold text
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Mission: Crossing Chaos", 0, 100, 800, "center")
    
    love.graphics.setFont(font)
    love.graphics.printf(
        "Welcome, Agent.\n\n" ..
        "Your mission is to ensure the safe passage of the vehicles across the chaotic intersection.\n" ..
        "To succeed, you must adjust the score by maneuvering through targets to reach a score between 100 and 120.\n\n" ..
        "Once you're ready, click the 'Animate' button to test the crossing.\n" ..
        "Good luck!\n\n" ..
        "Press Enter to begin your mission.",
        0, 200, 800, "center"
    )
end

function love.keypressed(key)
    if gameState == "intro" and key == "return" then
        gameState = "playing"
    elseif gameState == "playing" then
        if key == 'escape' then
            love.event.quit()
        elseif key == 'space' then
            player:shoot()
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == "playing" then -- If left mouse button is clicked
        if animateButton:isMouseOver(x, y) then
            gameState = "animating" -- Change game state to animating when button is clicked
            anim.startAnimation(score) -- Start the animation with the current score
        end
    end
end
