local anim = {}
anim.car = nil
anim.carSound = nil
anim.explosionSound = nil
anim.alpha = 0
anim.carX = -100
anim.carY = 400
anim.speed = 0
anim.state = "driving"
anim.result = ""
anim.time = 0
anim.explosionTime = 0
anim.explosionX = 0
anim.explosionY = 0
anim.soundVolume = 0.5
anim.fadeOutDuration = 1
anim.fadeOutTimer = 0

function anim.load()
    anim.car = love.graphics.newImage("assets/car.png")
    anim.carSound = love.audio.newSource("assets/car.mp3", "stream")
    anim.explosionSound = love.audio.newSource("assets/car_explosion.mp3", "static")
    anim.carSound:setLooping(false)
    anim.explosionSound:setLooping(false)
    anim.explosionSound:setVolume(0.3)
    
    anim.explosionShader = love.graphics.newShader[[
        extern float time;
        extern vec2 resolution;
        extern vec2 position;

        float rand(vec2 n) { 
            return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
        }

        float noise(vec2 p) {
            vec2 ip = floor(p);
            vec2 u = fract(p);
            u = u*u*(3.0-2.0*u);

            float res = mix(
                mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
                mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
            return res*res;
        }

        float fbm(vec2 x) {
            float v = 0.0;
            float a = 0.5;
            vec2 shift = vec2(100);
            mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
            for (int i = 0; i < 5; ++i) {
                v += a * noise(x);
                x = rot * x * 2.0 + shift;
                a *= 0.5;
            }
            return v;
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 uv = screen_coords.xy / resolution.xy;
            vec2 center = position / resolution.xy;
            vec2 delta = uv - center;
            float dist = length(delta);

            float angle = atan(delta.y, delta.x);
            float radius = 0.3 + 0.1 * fbm(vec2(angle * 5.0, time * 2.0));

            float fire = smoothstep(radius, radius * 0.5, dist);
            fire += fbm(delta * 10.0 + time * 3.0) * 0.5;
            fire = smoothstep(0.1, 1.0, fire);

            vec3 fireColor = mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 0.2, 0.0), fire);
            fireColor = mix(fireColor, vec3(0.1, 0.1, 0.1), smoothstep(0.5, 1.0, dist / radius));

            float smoke = fbm(delta * 4.0 - vec2(0, time));
            vec3 smokeColor = mix(vec3(0.3, 0.3, 0.3), vec3(0.7, 0.7, 0.7), smoke);

            vec3 finalColor = mix(fireColor, smokeColor, smoothstep(0.8, 1.5, dist / radius));
            float alpha = smoothstep(1.5, 0.5, dist / radius);

            return vec4(finalColor, alpha * color.a);
        }
    ]]
end

function anim.update(dt)
    anim.alpha = math.min(anim.alpha + dt, 1)
    anim.time = anim.time + dt
    
    if anim.state == "driving" then
        anim.carX = anim.carX + anim.speed * dt
        if anim.carX > 300 then
            anim.state = "jumping"
        end
    elseif anim.state == "jumping" then
        anim.carX = anim.carX + anim.speed * dt
        anim.carY = 400 - math.sin((anim.carX - 300) / 300 * math.pi) * 200
        
        if anim.carX > 600 then
            if anim.speed < 100 then
                anim.state = "falling"
            elseif anim.speed > 120 then
                anim.state = "overshooting"
            else
                anim.state = "success"
            end
        end
    elseif anim.state == "falling" then
        anim.carY = anim.carY + 500 * dt
        if anim.carY > 600 then
            anim.state = "exploded"
            anim.explosionTime = 0
            anim.explosionX = anim.carX
            anim.explosionY = 600
            anim.result = "FAILURE"
            anim.explosionSound:play()
        end
    elseif anim.state == "overshooting" then
        anim.carX = anim.carX + anim.speed * dt
        anim.carY = anim.carY + 200 * dt
        if anim.carX > 800 or anim.carY > 600 then
            anim.state = "exploded"
            anim.explosionTime = 0
            anim.explosionX = math.min(anim.carX, 800)
            anim.explosionY = math.min(anim.carY, 600)
            anim.result = "FAILURE"
            anim.explosionSound:play()
        end
    elseif anim.state == "success" then
        anim.carX = anim.carX + anim.speed * dt
        if anim.carX > 1000 then
            anim.result = "SUCCESS"
        end
    elseif anim.state == "exploded" then
        anim.explosionTime = anim.explosionTime + dt
    end

    -- Update sound
    if anim.state == "driving" or anim.state == "jumping" or anim.state == "success" then
        if not anim.carSound:isPlaying() then
            anim.carSound:play()
        end
        anim.fadeOutTimer = anim.fadeOutTimer + dt
        local volume = math.max(0, anim.soundVolume * (1 - anim.fadeOutTimer / anim.fadeOutDuration))
        anim.carSound:setVolume(volume)
        if volume == 0 then
            anim.carSound:stop()
        end
    end
end

function anim.draw()
    love.graphics.setColor(1, 1, 1, anim.alpha)
    
    -- Draw background
    love.graphics.setColor(0.5, 0.8, 1, anim.alpha)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Draw clouds
    love.graphics.setColor(1, 1, 1, anim.alpha * 0.8)
    for i = 1, 5 do
        love.graphics.circle("fill", (i * 200 + anim.time * 20) % 900 - 100, 100 + i * 30, 30)
        love.graphics.circle("fill", (i * 200 + anim.time * 20) % 900 - 70, 100 + i * 30, 20)
        love.graphics.circle("fill", (i * 200 + anim.time * 20) % 900 - 130, 100 + i * 30, 20)
    end
    
    -- Draw road
    love.graphics.setColor(0.3, 0.3, 0.3, anim.alpha)
    love.graphics.rectangle("fill", 0, 450, 400, 150)
    love.graphics.rectangle("fill", 700, 450, 100, 150)
    
    -- Draw pit
    love.graphics.setColor(0, 0, 0, anim.alpha)
    love.graphics.rectangle("fill", 400, 450, 300, 150)
    
    -- Draw ramps
    love.graphics.setColor(0.5, 0.5, 0.5, anim.alpha)
    love.graphics.polygon("fill", 300, 450, 500, 450, 400, 350)
    love.graphics.polygon("fill", 600, 450, 800, 450, 700, 350)
    
    -- Draw car (if not exploded)
    if anim.state ~= "exploded" then
        love.graphics.setColor(1, 1, 1, anim.alpha)
        love.graphics.draw(anim.car, anim.carX, anim.carY, 0, 0.2, 0.2, anim.car:getWidth()/2, anim.car:getHeight()/2)
    end
    
    -- Draw explosion if exploded
    if anim.state == "exploded" then
        love.graphics.setShader(anim.explosionShader)
        anim.explosionShader:send("time", anim.explosionTime)
        anim.explosionShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        anim.explosionShader:send("position", {anim.explosionX, anim.explosionY})
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end
    
    -- Draw result screen
    if anim.result ~= "" then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(48))
        love.graphics.printf(anim.result, 0, 250, 800, "center")
        
        if anim.result == "SUCCESS" then
            love.graphics.setColor(1, 1, 0, 1)
            for i = 1, 20 do
                local x = love.math.random(0, 800)
                local y = love.math.random(0, 600)
                love.graphics.circle("fill", x, y, 5)
            end
            love.graphics.setFont(love.graphics.newFont(24))
            love.graphics.printf("Congratulations! You made the perfect jump!", 0, 350, 800, "center")
        else
            love.graphics.setColor(1, 0, 0, 0.5)
            for i = 1, 10 do
                local x = love.math.random(0, 800)
                local y = love.math.random(0, 600)
                love.graphics.line(x, y, x + 20, y + 20)
                love.graphics.line(x, y + 20, x + 20, y)
            end
            love.graphics.setFont(love.graphics.newFont(24))
            love.graphics.printf("Oh no! Your car didn't make it.", 0, 350, 800, "center")
        end
    end
end

function anim.startAnimation(speed)
    anim.speed = speed
    anim.carX = -100
    anim.carY = 420
    anim.alpha = 0
    anim.state = "driving"
    anim.result = ""
    anim.time = 0
    anim.explosionTime = 0
    anim.explosionX = 0
    anim.explosionY = 0
    anim.soundVolume = 0.5
    anim.fadeOutTimer = 0
    anim.carSound:setVolume(anim.soundVolume)
    anim.carSound:play()
end

return anim