-- legacy monkey-patched tableutil

local table = require 'table'
local tablex = require 'tablex'

for k, v in pairs(tablex) do
  if not k:find '^__' then
    assert(table[k] == nil)
    table[k] = v
  end
end

return table
