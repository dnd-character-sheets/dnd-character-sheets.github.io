local M = { }

local setmetatable, error, pairs, assert, require, type
    = setmetatable, error, pairs, assert, require, type

local __doc = { }
M.__doc = __doc

__doc.new = [[function([name]) returns module, doctable, function, environment
Returns a M, __doc, thismodule where

  M is a new, empty table suitable for making into a module 
  __doc is M.__doc
  thismodule is a function that, when called, checks the globals 
     table and then returns M.
  environment is an empty table that bleats if read from or written to

Usage:

  local M, __doc, thismodule, _ENV = require 'module52'.new()
  ...
  return thismodule()

If `name` is not nil, it must be a string that contains a dot.
We require the parent module, which must resolve to a table.
Then the new module `_M` gets inserted into the parent table at
the appropriate spot.

Special fields of `__doc` include `__overview`, `__order`, `__oneline`,
and `__methods`.
]]

local empty_globals = 
  setmetatable({}, {
      __newindex = function (_, n)
        error("attempt to write to undeclared variable "..n, 2)
      end,
      __index = function (_, n)
        error("attempt to read undeclared variable "..n, 2)
      end,
    })

function M.new(name)
  local newmodule = { }
  if name then
    newmodule._NAME = name
    local parent, member = assert(name:match '^(.+)%.([^%.]+)$')
    local pm = require(parent) -- might modify _G
    assert(type(pm) == 'table')
    pm[member] = newmodule
  end

  local globals = { }; for x in pairs(_G) do globals[x] = true end
  local function thismodule()
    for x in pairs(_G) do
      if not globals[x] then
        error('Accidentally defined global variable ' .. x)
      end
    end
    return newmodule
  end
  local __doc = { }
  newmodule.__doc = __doc


  return newmodule, __doc, thismodule, empty_globals
end

return M
