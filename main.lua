local CFG = require("config")
local W = require("src.ecs.world")

local SYS_build_map = require("src.systems.build_map")
local SYS_input = require("src.systems.input")
local SYS_move = require("src.systems.movement")
local SYS_enemy_ai = require("src.systems.enemy_ai")
local SYS_trap = require("src.systems.trap")
local SYS_collision = require("src.systems.collision")
local SYS_draw = require("src.systems.draw")

local state = "menu"  -- "menu" | "play" | "dead"
local player_id = nil

local function build_level_simple()
-- tile is smaller -> thinner than the wall and covers the whole map
  local thinTile = math.max(16, math.floor(CFG.level_tile / 2))

  -- generate walls via Voronoi
  local gen, tile = SYS_build_map.build_voronoi_level(W, {
    tile = thinTile,
    detail = 0.16,  -- walls density
    thicken = 0,
    relax = 1,
    passage_width = 3,
  })

  -- player and enemies
  player_id = W.spawn_player(CFG.width*0.20, CFG.height*0.20)
  W.spawn_enemy(CFG.width*0.75, CFG.height*0.25)
  W.spawn_enemy(CFG.width*0.75, CFG.height*0.75)

  -- random trap: choosing the correct center and radius
  local function cell_free(cx, cy)
    if cy<2 or cy>gen.h-1 or cx<2 or cx>gen.w-1 then return false end
    for oy=-1,1 do
      for ox=-1,1 do
        if gen.grid[cy+oy][cx+ox] == 1 then return false end
      end
    end
    return true
  end

  local function ring_fits(px, py, r_pix)
    local steps = 16
    for k=1,steps do
      local a = (k/steps) * 2*math.pi
      local x = px + r_pix * math.cos(a)
      local y = py + r_pix * math.sin(a)
      local cx = math.floor(x / tile) + 1
      local cy = math.floor(y / tile) + 1
      if cx < 1 or cx > gen.w or cy < 1 or cy > gen.h or gen.grid[cy][cx] == 1 then
        return false
      end
    end
    return true
  end

  local minR = math.floor(tile * 0.9)
  local maxR = math.floor(tile * 2.4)

  local px, py, rr
  for _=1,400 do
    local x = love.math.random(3, gen.w-2)
    local y = love.math.random(3, gen.h-2)
    if cell_free(x, y) then
      local px_try = (x - 0.5) * tile
      local py_try = (y - 0.5) * tile
      local r_try = love.math.random(minR, maxR)
      for r = r_try, minR, -math.floor(tile*0.2) do
        if ring_fits(px_try, py_try, r) then
          px, py, rr = px_try, py_try, r
          break
        end
      end
      if rr then break end
    end
  end

  if not rr then
    px, py = CFG.width*0.5, CFG.height*0.5
    rr = math.max(minR, math.min(maxR, math.floor(tile * 1.5)))
  end

  W.spawn_trap(px, py, rr, CFG.trap.radius, 2.2)
end

local function reset_game()
  package.loaded["src.ecs.components"] = nil
  package.loaded["src.ecs.view"] = nil
  package.loaded["src.ecs.world"] = nil
  package.loaded["src.systems.input"] = nil
  package.loaded["src.systems.movement"] = nil
  package.loaded["src.systems.enemy_ai"] = nil
  package.loaded["src.systems.trap"] = nil
  package.loaded["src.systems.collision"] = nil
  package.loaded["src.systems.draw"] = nil
  package.loaded["src.systems.build_map"] = nil
  collectgarbage()

  W = require("src.ecs.world")
  SYS_input = require("src.systems.input")
  SYS_move = require("src.systems.movement")
  SYS_enemy_ai = require("src.systems.enemy_ai")
  SYS_trap = require("src.systems.trap")
  SYS_collision = require("src.systems.collision")
  SYS_draw = require("src.systems.draw")
  SYS_build_map = require("src.systems.build_map")

  build_level_simple()
  state = "play"
end

function love.load()
  love.window.setTitle(CFG.window_title)
  love.window.setMode(CFG.width, CFG.height)
  state = "menu"
end

local function on_player_death() state = "dead" end

function love.update(dt)
  if state == "play" then
    SYS_input.update(dt, W, player_id)
    SYS_trap.update(dt, W)
    SYS_enemy_ai.update(dt, W, player_id)
    SYS_move.update(dt, W)
    SYS_collision.update(dt, W, player_id, on_player_death)
  end
end

function love.keypressed(key)
  if state == "menu" and (key == "return" or key == "space") then
    reset_game()
  elseif state == "dead" and (key == "return" or key == "space") then
    reset_game()
  elseif key == "escape" then
    love.event.quit()
  end
end

function love.draw()
  if state == "menu" then
    love.graphics.clear(CFG.bg)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Runaway Trap\n\nPress ENTER / SPACE to start",
      0, CFG.height*0.35, CFG.width, "center")
  elseif state == "play" then
    SYS_draw.draw(W)
  elseif state == "dead" then
    SYS_draw.draw(W)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("You were caught!\nPress ENTER / SPACE to retry",
      0, CFG.height*0.4, CFG.width, "center")
  end
end
