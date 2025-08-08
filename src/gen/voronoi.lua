local VoronoiGen = {}

local function rnd(a,b) return love.math.random(a,b) end

local function dist2(ax,ay,bx,by)
  local dx, dy = ax-bx, ay-by
  return dx*dx + dy*dy
end

local function spawnSeeds(w,h,n)
  local seeds = {}
  for i=1,n do
    seeds[i] = { x = rnd(2, w-1), y = rnd(2, h-1), id = i }
  end
  return seeds
end

local function labelByNearestSeed(w,h,seeds)
  local label = {}
  for y=1,h do
    label[y] = {}
    for x=1,w do
      local bestId, bestD2 = -1, math.huge
      for i,s in ipairs(seeds) do
        local d2 = dist2(x,y,s.x,s.y)
        if d2 < bestD2 then bestD2 = d2; bestId = i end
      end
      label[y][x] = bestId
    end
  end
  return label
end

local function lloyd(label,w,h,seeds)
  local acc, cnt = {}, {}
  for i=1,#seeds do acc[i]={x=0,y=0}; cnt[i]=0 end
  for y=1,h do
    for x=1,w do
      local id = label[y][x]
      acc[id].x = acc[id].x + x
      acc[id].y = acc[id].y + y
      cnt[id] = cnt[id] + 1
    end
  end
  for i,s in ipairs(seeds) do
    if cnt[i] > 0 then
      s.x = math.floor(acc[i].x / cnt[i] + 0.5)
      s.y = math.floor(acc[i].y / cnt[i] + 0.5)
    end
  end
end

local function buildTiles(label,w,h)
  local tiles = {}
  for y=1,h do
    tiles[y] = {}
    for x=1,w do
      tiles[y][x] = { wall=false }
    end
  end
  local function diff(x,y,id)
    if x<1 or x> w or y<1 or y>h then return false end
    return label[y][x] ~= id
  end
  for y=1,h do
    for x=1,w do
      local id = label[y][x]
      if diff(x+1,y,id) or diff(x-1,y,id) or diff(x,y+1,id) or diff(x,y-1,id) then
        tiles[y][x].wall = true
      end
    end
  end
  return tiles
end

local function collectNeighborPairs(label, w, h)
  local pairsSet = {}
  local function add(a,b)
    if a == b then return end
    local i, j = math.min(a,b), math.max(a,b)
    local key = i .. "_" .. j
    if not pairsSet[key] then pairsSet[key] = { i=i, j=j } end
  end

  for y=1,h do
    for x=1,w-1 do
      local a, b = label[y][x], label[y][x+1]
      if a ~= b then add(a,b) end
    end
  end

  for y=1,h-1 do
    for x=1,w do
      local a, b = label[y][x], label[y+1][x]
      if a ~= b then add(a,b) end
    end
  end
  local list = {}
  for _,v in pairs(pairsSet) do list[#list+1] = v end
  return list
end

local function bresenham(x0, y0, x1, y1, fn)
  local dx = math.abs(x1 - x0)
  local sx = (x0 < x1) and 1 or -1
  local dy = -math.abs(y1 - y0)
  local sy = (y0 < y1) and 1 or -1
  local err = dx + dy
  while true do
    if fn(x0, y0) == false then break end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end

local function carveDisk(tiles, w, h, cx, cy, r)
  local r2 = r * r
  for yy = cy - r, cy + r do
    if yy >= 1 and yy <= h then
      for xx = cx - r, cx + r do
        if xx >= 1 and xx <= w then
          local dx, dy = xx - cx, yy - cy
          if dx*dx + dy*dy <= r2 then
            tiles[yy][xx].wall = false
          end
        end
      end
    end
  end
end

local function carvePassages(label, seeds, tiles, w, h, passage_width)
  local neighborPairs = collectNeighborPairs(label, w, h)
  local radius = math.max(1, math.floor((passage_width or 3) / 2))
  for _, p in ipairs(neighborPairs) do
    local a, b = seeds[p.i], seeds[p.j]
    if a and b then
      bresenham(a.x, a.y, b.x, b.y, function(x, y)
        carveDisk(tiles, w, h, x, y, radius)
        return true
      end)
    end
  end
end

function VoronoiGen.generate(opts)
  local w = assert(opts.width,  "width required")
  local h = assert(opts.height, "height required")
  local n = opts.seeds or 24
  local relax = opts.relax or 0
  local passage_width = opts.passage_width or 4 -- ширина прохода в тайлах (!)

  local seeds = spawnSeeds(w,h,n)
  local label = labelByNearestSeed(w,h,seeds)
  for _=1,relax do
    lloyd(label,w,h,seeds)
    label = labelByNearestSeed(w,h,seeds)
  end

  local tiles = buildTiles(label,w,h)

  carvePassages(label, seeds, tiles, w, h, passage_width)

  return { w=w, h=h, seeds=seeds, label=label, tiles=tiles }
end

return VoronoiGen
