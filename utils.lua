local imageCache = {}

local function imageFromCache(path)
    if imageCache[path] == nil then
        imageCache[path] = love.graphics.newImage(path)
    end
    return imageCache[path]
end

local audioCache = {}

local function audioFromCache(path)
    if audioCache[path] == nil then
        audioCache[path] = love.audio.newSource('assets/music/' .. path, 'static')
    end
    return audioCache[path]:clone()
end

local function gradientMesh(dir, ...)
    local isHorizontal = true
    if dir == 'vertical' then
        isHorizontal = false
    elseif dir ~= 'horizontal' then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    local colorLen = select('#', ...)
    if colorLen < 2 then
        error('color list is less than two', 2)
    end

    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4]}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4]}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4]}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4]}
        end
    end

    return love.graphics.newMesh(meshData, 'strip', 'static')
end

local function deepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, deepCopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[deepCopy(orig_key, copies)] = deepCopy(orig_value, copies)
            end
        end
    else
        copy = orig
    end
    return copy
end

local function removeByKey(array, key)
    array[key] = nil
end

local function triangleArea(a, b, c)
    return math.abs(a[1]*(b[2] - c[2]) + b[1]*(c[2] - a[2]) + c[1]*(a[2] - b[2]))/2
end

local function rectArea(a, b, c, d)
    return math.abs(a[1]*b[2] - b[1]*a[2] + b[1]*c[2] - c[1]*b[2] + c[1]*d[2] - d[1]*c[2] + d[1]*a[2] - a[1]*d[2])/2
end

local function pointInRect(a, b, c, d, m)
    local amb = triangleArea(a, m, b)
    local bmc = triangleArea(b, m, c)
    local cmd = triangleArea(c, m, d)
    local dma = triangleArea(d, m, a)
    local abcd = rectArea(a, b, c, d)
    return math.abs(amb + bmc + cmd + dma - abcd) <= 1e-6
end

local function clamp(x, a, b)
    if x < a then
        return a
    elseif x > b then
        return b
    else
        return x
    end
end

local function tableSize(t)
    local s = 0
    for _ in pairs(t) do s = s + 1 end
    return s
end

local function fileExists(name)
    return love.filesystem.getInfo(name, 'file') ~= nil
end

return {
    imageFromCache = imageFromCache,
    audioFromCache = audioFromCache,
    gradientMesh = gradientMesh,
    deepCopy = deepCopy,
    removeByKey = removeByKey,
    pointInRect = pointInRect,
    clamp = clamp,
    tableSize = tableSize,
    fileExists = fileExists
}
