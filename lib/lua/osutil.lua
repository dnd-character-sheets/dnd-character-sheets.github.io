-- legacy monkey-patched osutil

local os = require 'os'
local osx = require 'osx'

for k, v in pairs(osx) do
  if not k:find '^__' then
    assert(os[k] == nil or os[k] == v, k)
    os[k] = v
  end
end

return os
