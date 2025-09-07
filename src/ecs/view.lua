local view = {}

function view.new()
return { dense = {}, sparse = {}, size = 0 }
end

function view.add(V, id)
if V.sparse[id] then return end
local i = V.size + 1
V.size = i
V.dense[i] = id
V.sparse[id] = i
end


function view.has(V, id)
return V.sparse[id] ~= nil
end

function view.del(V, id)
local i = V.sparse[id]
if not i then return end
local last = V.dense[V.size]
V.dense[i] = last
V.sparse[last] = i
V.dense[V.size] = nil
V.sparse[id] = nil
V.size = V.size - 1
end

return view