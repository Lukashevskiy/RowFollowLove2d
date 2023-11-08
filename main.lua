require("vector")
require("vehicle")
require("path")

function path_gen(parts)
    paths = {}
    local x, y
    x = 0
    y = math.random(1, height - 1)
    for i = 1, parts-1 do
        local xs, ys
        xs = math.random(x + 1, width / 3 * i)
        ys = math.random(50, height/2)
        table.insert(paths, Path:create(Vector:create(x, y), Vector:create(xs, ys)))
        x = xs
        y = ys
    end
    local xs, ys
    xs = width
    ys = math.random(0, height)
    table.insert(paths, Path:create(Vector:create(x, y), Vector:create(xs, ys)))
    return paths
end

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    paths = path_gen(3)

    vehicle1 = Vehicle:create(30, 10)
    vehicle2 = Vehicle:create(20, 50)
    vehicle2.maxSpeed = 8
    vehicle2.maxForce = 2
    vehicle1.current_part = 1
    vehicle1.normal_pred_pos = getNormal(vehicle1.location + vehicle1:predict(), paths[vehicle1.current_part].start, paths[vehicle1.current_part].stop)
    vehicle2.current_part = 1
    vehicle2.normal_pred_pos = getNormal(vehicle2.location + vehicle2:predict(), paths[vehicle2.current_part].start, paths[vehicle2.current_part].stop)

end

function love.update(dt)
    
    for i = vehicle1.current_part, 3 do
        local pred = getNormal(vehicle1.location + vehicle1:predict(), paths[i].start, paths[i].stop)
        if vehicle1.location:distTo(vehicle1.normal_pred_pos) > vehicle1.location:distTo(pred) then
            vehicle1.normal_pred_pos = pred
            vehicle1.current_part = i
        end
        vehicle1.normal_pred_pos = getNormal(vehicle1.location + vehicle1:predict(), paths[vehicle1.current_part].start, paths[vehicle1.current_part].stop)
    end

    for i = vehicle2.current_part, 3 do
        local pred = getNormal(vehicle2.location + vehicle2:predict(), paths[i].start, paths[i].stop)
        if vehicle2.location:distTo(vehicle2.normal_pred_pos) > vehicle2.location:distTo(pred) then
            vehicle2.current_part = i
        end
        vehicle2.normal_pred_pos = getNormal(vehicle2.location + vehicle2:predict(), paths[vehicle2.current_part].start, paths[vehicle2.current_part].stop)
    end
    
    if love.keyboard.isDown('l') then
        paths = path_gen(3)
    end
    vehicle1:followPath(paths[vehicle1.current_part])
    vehicle1:update()
    vehicle1:borders()
    vehicle2:followPath(paths[vehicle2.current_part])
    vehicle2:update()
    vehicle2:borders()
end

function love.draw()
    for _, path in ipairs(paths) do
        path:draw()
    end
    local pp1 = vehicle1:predict() + vehicle1.location
    love.graphics.line(vehicle1.normal_pred_pos.x, vehicle1.normal_pred_pos.y, pp1.x, pp1.y)
    local pp2 = vehicle2:predict() + vehicle2.location
    love.graphics.line(vehicle2.normal_pred_pos.x, vehicle2.normal_pred_pos.y, pp2.x, pp2.y)
    vehicle1:draw()
    vehicle2:draw()
end
