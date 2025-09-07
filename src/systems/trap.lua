local C = require("src.ecs.components")
local M = {}
function M.update(dt, W)
  local V = W.traps
  for i = 1, V.size do
    local id = V.dense[i]
    local cx, cy = C.trap_cx[id], C.trap_cy[id]
    local rr = C.trap_rr[id]
    local ca, sa = C.trap_ca[id], C.trap_sa[id]
    local ang = C.trap_w[id] * dt
    local c, s = math.cos(ang), math.sin(ang)
    ca, sa = ca*c - sa*s, sa*c + ca*s
    C.trap_ca[id], C.trap_sa[id] = ca, sa
    C.pos_x[id] = cx + rr * ca
    C.pos_y[id] = cy + rr * sa
  end
end
return M
