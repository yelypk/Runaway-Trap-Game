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

function VoronoiGen.generate(opts)
  local w = assert(opts.width,  "width required")
  local h = assert(opts.height, "height required")
  local n = opts.seeds or 24
  local relax = opts.relax or 0

  local seeds = spawnSeeds(w,h,n)
  local label = labelByNearestSeed(w,h,seeds)
  for _=1,relax do
    lloyd(label,w,h,seeds)
    label = labelByNearestSeed(w,h,seeds)
  end
  
  local tiles = buildTiles(label,w,h)

  return { w=w, h=h, seeds=seeds, label=label, tiles=tiles }
end

return VoronoiGen
