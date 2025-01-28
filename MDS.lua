 
-- M.D.S. (Mega Draw System)

local Module = {}

Module.console = {
    logEntries = {},
    maxEntries = 20,
    defaultTextColor = {255, 255, 255, 255}
}

Module.draw = {}
Module.math = {}
Module.color = {}
Module.camera = {}
Module.ray = {}

Module.camera.position = {
    currentX = 0,
    currentY = 0,
    offsetX = 0,
    offsetY = 0,
    targetX = 0,
    targetY = 0,
    moveSpeed = 0.9
}

Module.camera.rotation = {
    currentAngle = 0,
    offsetAngle = 0,
    targetAngle = 0,
    rotationSpeed = 1
}

Module.camera.zoom = {
    currentZoom = love.graphics.getWidth(),
    targetZoom = love.graphics.getWidth(),
    offsetZoom = 0,
    zoomSpeed = 0.5
}

local BackgroundCache = {}

Module.file = {}

local isCameraAttached = false
local deltaTime = 1

-- Camera Functions

function Module.camera.setPosition(x, y)
    Module.camera.position.currentX = x
    Module.camera.position.currentY = y
    Module.camera.position.targetX = x
    Module.camera.position.targetY = y
end

function Module.camera.getPosition()
    return Module.camera.position.currentX, Module.camera.position.currentY
end

function Module.camera.getRotation()
    return Module.camera.rotation.currentAngle
end

function Module.camera.getZomm()
    return Module.camera.zoom.currentZoom
end

function Module.camera.setRotationSpeed(speed)
    speed = Module.clamp(speed, 0, 1)
    Module.camera.rotation.rotationSpeed = speed
end

function Module.camera.setZoomSpeed(speed)
    speed = Module.clamp(speed, 0, 1)
    Module.camera.zoom.zoomSpeed = rotationSpeed
end

function Module.camera.setMovimentSpeed(speed)
    speed = Module.clamp(speed, 0, 1)
    Module.camera.position.moveSpeed = speed
end

function Module.camera.smoothSetPosition(x, y)
    Module.camera.position.targetX = x
    Module.camera.position.targetY = y
end

function Module.camera.rotateBy(angle)
    Module.camera.rotation.targetAngle = Module.camera.rotation.targetAngle + angle
end

function Module.camera.setRotation(angle)
    Module.camera.rotation.targetAngle = angle
end

function Module.camera.zoomIn(amount)
    Module.camera.zoom.targetZoom = Module.camera.zoom.targetZoom - amount
end

function Module.camera.zoomOut(amount)
    Module.camera.zoom.targetZoom = Module.camera.zoom.targetZoom + amount
end

function Module.camera.setZoom(amount)
    Module.camera.zoom.targetZoom = amount
end

function Module.camera.update()
    local cam = Module.camera
    cam.position.currentX = Module.lerp(cam.position.currentX, cam.position.targetX, cam.position.moveSpeed) + cam.position.offsetX
    cam.position.currentY = Module.lerp(cam.position.currentY, cam.position.targetY, cam.position.moveSpeed) + cam.position.offsetY
    cam.zoom.currentZoom = Module.lerp(cam.zoom.currentZoom, cam.zoom.targetZoom, cam.zoom.zoomSpeed) + cam.zoom.offsetZoom
    cam.rotation.currentAngle = Module.lerp(cam.rotation.currentAngle, cam.rotation.targetAngle, cam.rotation.rotationSpeed) + cam.rotation.offsetAngle
end

function Module.camera.link()
    if not isCameraAttached then
        love.graphics.push()
        isCameraAttached = true
        local x = Module.camera.position.currentX
        local y = Module.camera.position.currentY
        local zoom = 1 / (Module.pixelToNormal(Module.camera.zoom.currentZoom, love.graphics.getWidth()) + 0.0001)
        local angle = math.rad(Module.camera.rotation.currentAngle)

        love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

        love.graphics.rotate(angle)
        love.graphics.scale(zoom)
        love.graphics.translate(-x, -y)
    end
end

function Module.camera.unlink()
    if isCameraAttached then
        love.graphics.pop()
        isCameraAttached = false
    end
end

-- Color Functions

function Module.color.set(color)
    if type(color) ~= "table" and type(color) ~= "nil" then
        error("expected a 'table' for the color value with RGBA but recived '" .. type(color) .. "'")
    end
    color = color or {255, 255, 255, 255}
    local r, g, b, a = Module.clamp(color[1], 0, 255), Module.clamp(color[2], 0, 255), Module.clamp(color[3], 0, 255), Module.clamp(color[4] or 255, 0, 255)
    love.graphics.setColor(r / 255, g / 255, b / 255, a / 255)
end

function Module.color.reset()
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw Functions

function Module.draw.BackgroundImage(img, sizeX, sizeY, rotation, color)
    local WIDTH, HEIGHT = love.graphics.getDimensions()
    local numX = WIDTH / sizeX + 2
    local numY = HEIGHT / sizeY + 2
    love.graphics.push()
    love.graphics.rotate(math.rad(rotation))
    for y = 0, numY + 2 do
        for x=0, numX + 2 do
            Module.draw.image((x * sizeX) - sizeX / 2,(y * sizeY) - sizeY / 2, sizeX, sizeY, img, nil, color)
        end
    end
    love.graphics.pop()
end

function Module.draw.rectangle(x, y, width, height, color, rotation, mode, borderRadius, options)
    mode = mode or "fill"
    rotation = rotation or 0
    borderRadius = borderRadius or 0
    options = options or {}
    local drawBorder = options.border or false
    local borderColor = options.borderColor or {0, 0, 0, 255}


    Module.color.set(color)
    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.rotate(math.rad(rotation))
    love.graphics.rectangle(mode, 0, 0, width, height, borderRadius)

    if drawBorder then
        Module.color.set(borderColor)
        love.graphics.rectangle("line", 0, 0, width, height, borderRadius)
    end

    love.graphics.pop()
end

function Module.draw.circle(x, y, radius, color, mode)
    mode = mode or "fill"
    Module.color.set(color)
    love.graphics.circle(mode, x - radius / 2, y - radius / 2, radius)
    Module.color.reset()
end

function Module.draw.line(x1, y1, x2, y2, color)
    Module.color.set(color)
    love.graphics.line(x1, y1, x2, y2)
end

function Module.draw.triangle(x, y, size, color, rotation, mode)
    mode = mode or "fill"
    rotation = rotation or 0
    Module.color.set(color)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(math.rad(rotation))
    
    local Hsize = size / 2
    local vertices = {
        0, -Hsize,        -- top point
        -Hsize, Hsize - 5, -- bottom left point
        Hsize, Hsize - 5   -- bottom right point
    }
    
    love.graphics.polygon(mode, vertices)
    love.graphics.pop()
end


function Module.draw.text(x, y, text, color, scale, rotation)
    rotation = math.rad(rotation or 0)
    Module.color.set(color)
    text = tostring(text)
    love.graphics.print(text, x, y, rotation, scale)
end

function Module.draw.loadImage(path)
    return love.graphics.newImage(path)
end

function Module.draw.image(x, y, sizeX, sizeY, image, rotation, color)
    rotation = rotation or 0
    Module.color.set(color)
    love.graphics.push()
    love.graphics.translate(x - sizeX / 2, y - sizeY / 2)
    
    local imageSizeX, imageSizeY = image:getWidth(), image:getHeight()

    love.graphics.scale(Module.pixelToNormal(sizeX, imageSizeX), Module.pixelToNormal(sizeY, imageSizeY))
    love.graphics.rotate(math.rad(rotation))
    love.graphics.draw(image, 0, 0)
    love.graphics.pop()
end

function Module.draw.polygon(x, y, vertices, color, angle, mode)
    mode = mode or 'line'
    color = color or {255, 255, 255, 255}
    color = Module.color.set(color)
    angle = angle or 0
    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.rotate(angle)
    love.graphics.polygon(mode, vertices)
    love.graphics.pop()
end


-- Math Functions

function Module.CheckItemInTable(tbl, item)
    for _, value in pairs(tbl) do
        if value == item then
            return true
        end
    end
    return false
end

function Module.setDeltaTime(dtValue)
    deltaTime = dtValue
end

function Module.clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function Module.round(value, decimals)
    decimals = decimals or 1
    local factor = 10 ^ decimals
    return math.floor(value * factor + 0.5) / factor
end

function Module.pixelToNormal(size, maxSize)
    return size / maxSize
end

function Module.linesIntersect(pos1, pos2, pos3, pos4)
    local x1, y1 = pos1[1], pos1[2]
    local x2, y2 = pos2[1], pos2[2]
    local x3, y3 = pos3[1], pos3[2]
    local x4, y4 = pos4[1], pos4[2]

    local function determinant(a, b, c, d)
        return a * d - b * c
    end

    local det = determinant(x2 - x1, x3 - x4, y2 - y1, y3 - y4)

    if det == 0 then
        return false
    end

    local t = determinant(x3 - x1, x3 - x4, y3 - y1, y3 - y4) / det
    local u = determinant(x2 - x1, x3 - x1, y2 - y1, y3 - y1) / det

    return t >= 0 and t <= 1 and u >= 0 and u <= 1
end

function Module.isPointInBox(px, py, x, y, width, height)
    return px > x and py > y and px < x + width and py < y + height
end

function Module.isCircleColliding(cx1, cy1, r1, cx2, cy2, r2)
    local dx, dy = cx1 - cx2, cy1 - cy2
    local distanceSquared = dx * dx + dy * dy
    local combinedRadius = r1 + r2
    return distanceSquared < combinedRadius * combinedRadius
end

function Module.isBoxColliding(box1, box2)
    local x1, y1, w1, h1 = unpack(box1)
    local x2, y2, w2, h2 = unpack(box2)
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

function Module.lerp(current, target, speed)
    return current + ((target - current) * speed)
end

function Module.updateLerp(values, dt)
    dt = dt or deltaTime
    for i, v in ipairs(values) do
        values[i] = {Module.lerp(v[1], v[2], v[3], dt), v[2], v[3]}
    end
    return values
end

function Module.ray.castRay(NowX, NowY, angle, Circles, Rectangles, Lines, StepSize, MaxSteps)
    Circles = Circles or {}
    Rectangles = Rectangles or {}
    Lines = Lines or {}

    local WIDTH, HEIGHT = love.graphics.getDimensions()

    function checkColison(posX,posY)
        local hit = false
        -- Circles
        for _, obj in ipairs(Circles) do
            local objX = obj.x + (obj.r / 2) + (WIDTH / 2)
            local objY = obj.y + (obj.r / 2) + (HEIGHT / 2)
            local objR = obj.r
            if ds.math.isCircleColliding(objX, objY, objR, posX, posY, 1) then
                return true
            end
        end

        -- Rectangles
        for _, obj in ipairs(Rectangles) do
            local objX = obj.x + (obj.sx / 2) + (WIDTH / 2)
            local objY = obj.y + (obj.sy / 2) + (HEIGHT / 2)
            local objWidth = obj.w
            local objHeight = obj.h
            
            if ds.math.isPointInBox(posX, posY, objX, objY, objWidth, objHeight) then return true end
        end

        -- Lines
        for _, obj in ipairs(Lines) do
            local pos1 = lines[1]
            local pos2 = lines[2]
            local pos3 = lines[3]
            local pos4 = lines[4]
            return ds.math.linesIntersect(pos1, pos2, pos3, pos4)
        end

        return false
    end

    MaxSteps = MaxSteps or 100
    StepSize = StepSize or 1
    
    local StartX, StartY = NowX, NowY

    local sx = math.cos(math.rad(angle))
    local sy = math.sin(math.rad(angle))

    local count = 0

    while not checkColison(NowX, NowY, 1) do
        NowX = NowX + (sx * StepSize)
        NowY = NowY + (sy * StepSize)
        if NowX > WIDTH or NowX < 0 or NowY > HEIGHT or NowY < 0 then
            break
        end
        count = count + 1
        if count > MaxSteps then
            break
        end
    end
    
    ds.draw.line(StartX, StartY, NowX, NowY, {0,0,255,255})
    ds.console.log(StartX .. "  " .. StartY .. "  " .. NowX .. "  " .. NowY)
    return StartX, StartY, NowX, NowY
end

function Module.math.Step(x)
    if x > 0 then
        return 1
    end
    return 0
end

-- Função Gaussiana: e^(-x^2)
function Module.math.Gaussian(x)
    return math.exp(-x * x)
end

-- Função Sigmoide: 1 / (1 + e^(-x))
function Module.math.Sigmoid(x)
    return 1 / (1 + math.exp(-x))
end

-- Função Hiperbólica Tangente: tanh(x) = (e^x - e^(-x)) / (e^x + e^(-x))
function Module.math.Hyperbolic(x)
    return (math.exp(x) - math.exp(-x)) / (math.exp(x) + math.exp(-x))
end

-- Console Functions

function Module.console.clear(maxEntries, showTime)
    maxEntries = maxEntries or 20
    showTime = showTime or false
    Module.console.maxEntries = maxEntries
    Module.console.showTime = showTime
    Module.console.logEntries = {}
end

function Module.console.setTextColor(color)
    Module.console.defaultTextColor = color
end

function Module.log(message, color)
    color = color or Module.console.defaultTextColor
    if #Module.console.logEntries > Module.console.maxEntries then
        table.remove(Module.console.logEntries, 1)
    end
    table.insert(Module.console.logEntries, {tostring(message), color})
end

function Module.console.render(x, y)
    y = y - 16
    local offset = 12 * (#Module.console.logEntries - 1)
    for i, entry in ipairs(Module.console.logEntries) do
        Module.draw.text(x, y - offset + (i - 1) * 12, entry[1], entry[2], 1)
    end
end

-- File functions & Debug/Test functions

function Module.file.read(filePath)
    local file = io.open(filePath, 'r')

    if not file then
        error("Erro ao abrir o arquivo para leitura: " .. filePath)
    end
    
    local fileContent = {}

    for line in file:lines() do
        table.insert(fileContent, line)
    end

    file:close()
    return fileContent
end

function Module.file.write(filePath, fileContent)
    local file = io.open(filePath, 'w')

    if not file then
        error("Erro ao abrir o arquivo para escrita: " .. filePath)
    end
    
    for _, line in ipairs(fileContent) do
        file:write(line .. '\n')
    end
    file:close()
end

return Module