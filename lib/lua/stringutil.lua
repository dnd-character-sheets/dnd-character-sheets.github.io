-- legacy monkey-patched stringutil

local string = require 'string'
local stringx = require 'stringx'

for k, v in pairs(stringx) do
  if not k:find '^__' then
    assert(string[k] == nil)
    string[k] = v
  end
end

return string
