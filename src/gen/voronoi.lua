local M = {}

local function rnd(a, b) return love.math.random(a, b) end
-- finds the nearest and second nearest seed
local function nearest_labels(w, h, sx, sy, n)
  local lab = {}
  for y = 1, h do
    local row = {}
    for x = 1, w do
      local best1, best2, i1 = math.huge, math.huge, 1
      for i = 1, n do
        local dx, dy = x - sx[i], y - sy[i]
        local d = dx*dx + dy*dy
        if d < best1 then best2 = best1; best1 = d; i1 = i
        elseif d < best2 then best2 = d end
      end
      row[x] = i1
    end
    lab[y] = row
  end
  return lab
end

local function lloyd(label, w, h, sx, sy, n)
  local accx, accy, cnt = {}, {}, {}
  for i = 1, n do accx[i]=0; accy[i]=0; cnt[i]=0 end
  for y = 1, h do
    local row = label[y]
    for x = 1, w do
      local id = row[x]
      accx[id] = accx[id] + x; accy[id] = accy[id] + y; cnt[id] = cnt[id] + 1
    end
  end
  for i = 1, n do
    if cnt[i] > 0 then
      sx[i] = math.floor(accx[i] / cnt[i] + 0.5)
      sy[i] = math.floor(accy[i] / cnt[i] + 0.5)
    end
  end
end

local function boundary_grid(label, w, h)
  local g = {}
  for y = 1, h do
    local row = {}
    for x = 1, w do row[x] = 0 end
    g[y] = row
  end
  local function diff(x, y, id)
    return x < 1 or x > w or y < 1 or y > h or label[y][x] ~= id
  end
  for y = 1, h do
    for x = 1, w do
      local id = label[y][x]
      if diff(x+1,y,id) or diff(x-1,y,id)
         or diff(x,y+1,id) or diff(x,y-1,id)
         or diff(x+1,y+1,id) or diff(x-1,y-1,id)
         or diff(x+1,y-1,id) or diff(x-1,y+1,id) then
        g[y][x] = 1
      end
    end
  end
  return g
end

-- thickening of walls (dilate) 1-2 passes
local function dilate(grid, w, h, passes)
  for _=1,(passes or 0) do
    local src = grid
    local dst = {}
    for y = 1, h do
      local row = {}
      for x = 1, w do
        local s = 0
        for oy=-1,1 do
          for ox=-1,1 do
            local yy, xx = y+oy, x+ox
            if yy>=1 and yy<=h and xx>=1 and xx<=w and src[yy][xx]==1 then s=1; break end
          end
          if s==1 then break end
        end
        row[x] = s
      end
      dst[y] = row
    end
    grid = dst
  end
  return grid
end

-- single "gates" between neighbors to ensure passability
local function carve_local_passages(label, w, h, sx, sy, n, hole_r, grid)
  local seen = {}
  local function mark_pair(a, b)
    if a == b then return end
    if a > b then a, b = b, a end
    seen[a .. ":" .. b] = true
  end
  for y = 1, h do
    for x = 1, w-1 do
      local a, b = label[y][x], label[y][x+1]
      if a ~= b then mark_pair(a, b) end
    end
  end
  for y = 1, h-1 do
    for x = 1, w do
      local a, b = label[y][x], label[y+1][x]
      if a ~= b then mark_pair(a, b) end
    end
  end

  local r = math.max(1, math.floor((hole_r or 3)/2))
  local r2 = r*r
  local function carve_disk(cx, cy)
    for yy = cy - r, cy + r do
      if yy >= 1 and yy <= h then
        for xx = cx - r, cx + r do
          if xx >= 1 and xx <= w then
            local dx, dy = xx - cx, yy - cy
            if dx*dx + dy*dy <= r2 then grid[yy][xx] = 0 end
          end
        end
      end
    end
  end

  for key in pairs(seen) do
    local i, j = key:match("(%d+):(%d+)")
    i, j = tonumber(i), tonumber(j)
    local mx = math.floor((sx[i] + sx[j]) * 0.5 + 0.5)
    local my = math.floor((sy[i] + sy[j]) * 0.5 + 0.5)
-- let's move it a little randomly so that not all the holes are on a straight line
    mx = math.max(2, math.min(w-1, mx + rnd(-1,1)))
    my = math.max(2, math.min(h-1, my + rnd(-1,1)))
    carve_disk(mx, my)
  end
end

function M.generate(opts)
  local w = assert(opts.width,  "width required")
  local h = assert(opts.height, "height required")
  local cells = w * h
  local seeds = opts.seeds or math.max(24, math.floor(cells * (opts.detail or 0.35)))
  local relax = opts.relax or 1
  local thicken = opts.thicken or 1   
  local hole = opts.passage_width or 3   

  -- seeds (SoA)
  local sx, sy = {}, {}
  for i = 1, seeds do sx[i] = rnd(2, w-1); sy[i] = rnd(2, h-1) end

  local label = nearest_labels(w, h, sx, sy, seeds)
  for _ = 1, relax do
    lloyd(label, w, h, sx, sy, seeds)
    label = nearest_labels(w, h, sx, sy, seeds)
  end

  local grid = boundary_grid(label, w, h)
  grid = dilate(grid, w, h, thicken)

  -- perimeter frame
  for x=1,w do grid[1][x]=1; grid[h][x]=1 end
  for y=1,h do grid[y][1]=1; grid[y][w]=1 end
  -- local "gates" between neighbors
  carve_local_passages(label, w, h, sx, sy, seeds, hole, grid)

  return { w = w, h = h, grid = grid }
end

return M
 

