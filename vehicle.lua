Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:create(x, y)
    local vehicle = {}
    setmetatable(vehicle, Vehicle)
    vehicle.acceleration = Vector:create(0, 0)
    vehicle.velocity = Vector:create(0, 0)
    vehicle.location = Vector:create(x, y)
    vehicle.r = 5
    vehicle.vertices = {0, - vehicle.r * 2, -vehicle.r, vehicle.r * 2, vehicle.r, 2 * vehicle.r}
    vehicle.maxSpeed = 4
    vehicle.maxForce = 0.1
    vehicle.wtheta = 0
    vehicle.current_part = 0
    vehicle.normal_pred_pos = 0
    return vehicle
end

function Vehicle:update()
    self.velocity:add(self.acceleration)
    self.velocity:limit(self.maxSpeed)
    self.location:add(self.velocity)
    self.acceleration:mul(0)
end

function Vehicle:applyForce(force)
    self.acceleration:add(force)
end

-- function Vehicle:borders(path)
--     if self.location.x > path.stop.x + self.r then
--         self.location.x = path.start.x - self.r
--         self.location.y = path.start.y + (self.location.y - path.stop.y)
--     end
-- end

function Vehicle:borders()
    if self.location.x < -self.r then
        self.location.x = width + self.r - 10
        self.location.y = math.random(10, width);

        self.current_part = 1
    end
    if self.location.y < -self.r then
        self.location.y = height + self.r - 10
        self.current_part = 1
    end
    if self.location.x > width + self.r then
        self.location.x = -self.r + 10
        self.location.y = math.random(10, width);
        self.current_part = 1
    end
    if self.location.y > height + self.r then
        self.location.y = -self.r 
        self.current_part = 1
    end
end

function Vehicle:seek(target)
    local desired = target - self.location
    local mag = desired:mag()
    desired:norm()
    if mag < 100 then
        local m = math.map(mag, 0, 100, 0, self.maxSpeed)
        desired:mul(m)
    else
        desired:mul(self.maxSpeed)
    end
    local steer = desired - self.velocity
    steer:limit(self.maxForce)
    self:applyForce(steer)
end

function getNormal(p, a, b)
    local ap = p - a
    local ab = b - a
    ab:norm()
    ab:mul(ap:dot(ab))
    local point = a + ab
    return point
end

function Vehicle:predict()
    local predict = self.velocity:copy()
    predict:norm()
    predict:mul(50)
    return predict 
end

function Vehicle:followPath(path)
    -- local predict = self:predict()
    local pos = self:predict() + self.location
    local a = path.start
    local b = path.stop
    local normal = getNormal(pos, a, b)
    local dir = b - a
    dir:norm()
    dir:mul(10)
    local target = normal + dir
    local distance = pos:distTo(dir)
    if distance > path.d then
        self:seek(target)
    end
end

function Vehicle:draw()
    local theta = self.velocity:heading() + math.pi / 2
    love.graphics.push()
    love.graphics.translate(self.location.x, self.location.y)
    love.graphics.line(0, 0, self:predict().x, self:predict().y)
    love.graphics.rotate(theta)
    love.graphics.polygon("fill", self.vertices)
    -- local p = self.location + Vector:create(100, 100)
    love.graphics.pop()
end
