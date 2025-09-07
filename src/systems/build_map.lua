local CFG = require("config")
local VOR = require("src.gen.voronoi")

local M = {}

-- return gen (grid, w, h)
function M.build_voronoi_level(W, opts)
  local tile = (opts and opts.tile) or CFG.level_tile
  local gw = math.floor(CFG.width  / tile)
  local gh = math.floor(CFG.height / tile)

  local gen = VOR.generate{
    width = gw, height = gh,
    detail = (opts and opts.detail) or 0.35,  
    relax  = (opts and opts.relax)  or 1,
    thicken = (opts and opts.thicken) or 1, 
    passage_width = (opts and opts.passage_width) or 3,
  }

  W.spawn_walls_from_grid(gen.grid, tile)
  return gen, tile
end

return M
