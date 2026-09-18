local assert, ipairs, require, string, table, tostring
    = assert, ipairs, require, string, table, tostring

local _VERSION = _VERSION

local os = require 'os'
local io = require 'io'
local ok, posix = pcall(require, 'courseware-posix')
if not ok then
  if _VERSION == 'Lua 5.1' then
    posix = assert(require 'posix')
  else
    ok, posix = pcall(require, 'posix')
    if not ok then
      posix = nil
    end
  end
end

assert(io.popen)

local M, __doc, thismodule, _ENV = require 'module52'.new()

local function cook_output(s)
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

M.__doc = M.__doc or { }
local __doc = M.__doc

__doc.pipethrough = [[function(string, command) returns string
Result of piping the given string through the given command.
]]

function M.pipethrough(s, cmd)
  local tmpfile = M.capture 'mktemp -t osutil.luaXXXXXX'
  require 'ioutil'
  io.set_contents(tmpfile, s)
  local xcmd = string.format('%s < %s', cmd, M.quote(tmpfile))
  local f = assert(io.popen(xcmd, 'r'))
  local result = assert(f:read '*a')
  f:close()
  os.remove(tmpfile)
  return result
end

__doc.capture = [[function(command : string, [raw : flag]) returns string
Runs command through `io.popen` and returns what is
captured on standard output.  Output is "cooked" as
by an unquoted shell command, unless `raw` flag is set,
in which case it is passed through untouched.
]]

function M.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return raw and s or cook_output(s)
end

function M.capture2(cmd, raw)
  local tmpfile = M.capture 'mktemp -t osutil.luaXXXXXX'
  local cmd = string.format('(%s) 2> %s', cmd, M.quote(tmpfile))
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  local f = assert(io.open(tmpfile))
  local s2 = assert(f:read('*a'))
  f:close()
  os.remove(tmpfile)
  if raw then
    return s, s2
  else
    return cook_output(s), cook_output(s2)
  end
end

if _VERSION:find '^Lua 5%.[23]$' then
  M.exec52 = os.execute
elseif _VERSION == 'Lua 5.1' then
  function M.exec52(...)
    local rc = os.execute(...)
    return rc == 0 or nil, 'exit', rc
  end
end



function M.runf(...) return os.execute(string.format(...)) end

function M.runf52(...) return M.exec52(string.format(...)) end

function M.oexists(file)
  local f, msg = io.open(file, 'r')
  if f then
    f:close()
    return true
  else
    return false, msg
  end
end

M.readable = M.oexists

__doc.exists = [[function(pathname) return true or false, msg
Says whether we can run `posix.stat` on the given file.
]]

function M.exists(file)
  local t, msg = posix.stat(file)
  if t then
    return true
  else
    return false, msg
  end
end

function M.size(file)
  local t, msg = posix.stat(file)
  if t then
    return assert(t.size)
  else
    return nil, msg
  end
end

local access_ok -- can use posix.access as proxy for opening a file
if posix then
  local p = posix.getpid()
  access_ok = p.uid == p.euid
end

__doc.writeable = [[function(pathname) returns true or false, msg]]

if access_ok then
  __doc.readable = [[function(pathname) returns true or false, msg]]
  function M.readable(file)
    local n, msg = posix.access(file, 'r')
    if n == 0 then
      return true
    else
      return false, msg
    end
  end

  function M.writeable(file)
    local n, msg = posix.access(file, 'w')
    if n == 0 then
      return true
    else
      return false, msg
    end
  end
else
  function M.writeable(_)
    assert(false, 'tested writeability while running setuid()')
  end
end

function M.bg(cmd)
  local pid = assert(posix.fork())
  if pid == 0 then
    os.exit(os.execute(cmd))
    assert(false, 'finished executing in forked process')
  else
    return pid
  end
end

local quote_me = '[^%w%+%-%=%@%_%/%.%:]' -- easier to complement what doesn't need quotes
local strfind = string.find

__doc.quote = [[function(string) returns string
Returns string with whatever markup is needed to quote it
to the POSIX shell.
]]

function M.quote(s)
  if strfind(s, quote_me) or s == '' then
    return "'" .. string.gsub(s, "'", [['"'"']]) .. "'"
  else
    return s
  end
end

assert(M.quote [[three]] == [[three]])
assert(M.quote [[three"]] == [['three"']])
assert(M.quote [[your mama]] == [['your mama']])
assert(M.quote [[$i]] == [['$i']])

local quote = M.quote

function M.execv(t)
  local u = { }
  for i, v in ipairs(t) do
    u[i] = quote(v)
  end
  return os.execute(table.concat(u, ' '))
end


function M.basename(s, ext)
  s = s:gsub([=[.*[\/]]=], '')
  if ext then
    s = s:gsub(ext:gsub('%W', '%%%1'), '')
  end
  return s
end

function M.varsub(s, t)
  local function sub(v)
    local function try(pat)
      local k = v:match(pat)
      if k and t[k] then
        return v:gsub(pat, tostring(t[k]))
      end
    end
    return try '^{(.-)}' or try '^(%a[%w_]*)' or try '^.'
  end
  return (s:gsub('$([^%$]+)', sub))
end

-- string.varsub = string.varsub or M.varsub

if true then
  local t = { hello = 'howdy', world = 'Earth', ['*'] = 'one two three' }
  assert(M.varsub("$hello world", t) == "howdy world")
  assert(M.varsub("$hello, world", t) == "howdy, world")
  assert(M.varsub("${hello}world", t) == "howdyworld")
  assert(M.varsub("${hello}$world", t) == "howdyEarth", 'brackets')
  assert(M.varsub("args are $*", t) == "args are one two three", 'star')
end

return thismodule()

