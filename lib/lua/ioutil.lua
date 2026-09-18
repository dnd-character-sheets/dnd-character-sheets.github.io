-- legacy monkey-patched ioutil

local io = require 'io'
local iox = require 'iox'

for k, v in pairs(iox) do
  if not k:find '^__' then
    assert(io[k] == nil)
    io[k] = v
  end
end

return io

