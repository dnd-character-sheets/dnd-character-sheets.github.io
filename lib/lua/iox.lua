local io = io

local assert, coroutine, error, ipairs, string, table
    = assert, coroutine, error, ipairs, string, table

local M, __doc, thismodule, _ENV = require 'module52'.new()

local doc = __doc

doc.contents = [[function(filename) returns string or nil, msg
Contents of the given file as a string, with f:read '*a'.
]]

doc.set_contents = [[function(filename, string) returns non-nil
Set the contents of the given file to the string.
(Asserts success of the write.)
]]

__doc.__order = { 'contents', 'set_contents', 'numbered_lines' }

function M.contents(filename)
  local f, msg = io.open(filename, 'r')
  if not f then return f, msg end
  local s, msg = f:read '*a'
  if not s then return s, string.format('%s: %s', filename, msg) end
  f:close()
  return s
end

function M.set_contents(filename, s)
  local f, msg = io.open(filename, 'w')
  if not f then return f, msg end
  local s = assert(f:write(s))
  f:close()
  return s or true
end

__doc.append = [[function(filename, string)
Append the given string to the given file, returning
the result of f:write or else true.
]]

function M.append(filename, s)
  local f, msg = io.open(filename, 'a+')
  if not f then return f, msg end
  local s = assert(f:write(s))
  f:close()
  return s or true
end

doc.line_list = [[function(filename) returns string list
List of lines in file, from io.lines(filename).
]]

function M.line_list(filename)
  local lines = { }
  for l in io.lines(filename) do
    table.insert(lines, l)
  end
  return lines
end


doc.arg_files = [[function(pathname list) returns iterator
Iterate over each file in the list, opened for reading,
or if the list is empty, standard input.
]]


function M.arg_files(arg)
  if #arg == 0 then
    local file = io.stdin
    return function()
             local answer = file
             file = nil
             return answer, nil
           end
  else
    return coroutine.wrap(function ()
                            for _, path in ipairs(arg) do
                              local f, msg = io.open(path)
                              if f then
                                coroutine.yield(f, path)
                                f:close()
                              else
                                error(path .. ': ' .. msg)
                              end
                            end
                          end)
  end
end

doc.numbered_lines = [[function(filename) returns iterator returns line, number]]
function M.numbered_lines(filename)
  local lines = io.lines(filename)
  local i = 0 -- number of lines read
  return function()
    local line = lines()
    if line then
      i = i + 1
      return line, i
    else
      return nil
    end
         end
end


local stream_meta = { }
local insert = table.insert
function stream_meta:write(...)
  for i = 1, select('#', ...) do
    insert(self, (select(i, ...)))
  end
end

function stream_meta:contents()
  return table.concat(self)
end

function M.outstream()
  return setmetatable({ }, { __index = stream_meta })
end

return thismodule()

