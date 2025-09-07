local C = {
pos_x = {}, pos_y = {},
vel_x = {}, vel_y = {},

radius = {},

col_r = {}, col_g = {}, col_b = {}, col_a = {},

tag_player = {},
tag_enemy = {},
tag_trap = {},
tag_wall = {},

alive = {},

-- walls (AABB in the form of the upper-left corner and dimensions)
wall_x = {}, wall_y = {}, wall_w = {}, wall_h = {},

-- trap (rotating point around the center):
trap_cx = {}, trap_cy = {}, -- center
trap_rr = {}, -- radius of the circle of motion
trap_ca = {}, trap_sa = {}, -- cos(angle), sin(angle) 
trap_w = {}, -- angular velocity 
}

return C