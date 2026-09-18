local string = require 'string'

local unpack = table.unpack or unpack -- luacheck: no global
local insert = table.insert

local math, table
    = math, table

local assert, setmetatable, type
    = assert, setmetatable, type


local M, __doc, thismodule, _ENV = require 'module52'.new()

__doc.split = [[iterator(string, pattern) yields string
Pieces of input as separated by pattern.
]]
function M:split(pat)
  pat = pat or '%s+'
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end

function M:find_any(pats, ...)
  local s = self
  local find = string.find
  local args = { ... }
  local function try(p) return find(s, p, unpack(args)) end
  local i = 1
  local function finish(n, ...)
    i = i + 1
    if n or not pats[i] then
      return n, ...
    else
      return finish(try(pats[i]))
    end
  end
  return finish(try(pats[i]))
end

function M:split_fields(pat)
  local fs = { }
  for f in self:split(pat) do insert(fs, f) end
  return fs
end

__doc.lines = [[iterator(string) yields string
All matches of (.-)\n.
]]

function M:lines()
  return self:gmatch('(.-)\n')
end

__doc.allmatches = [[function(string, pattern) returns string list
Returns a list of all matches of the given pattern.
Pattern defaults to '%S+'.
]]
function M:allmatches(pattern)
  local ms = { }
  for m in self:gmatch(pattern or '%S+') do insert(ms, m) end
  return ms
end

__doc.commafy = [[function(string list, [conjunction], [comma])
Return a string formatting a list of one or more items using
a serial comma and a conjunction.  The default conjunction is
'and', but 'or' is also useful.  (For two items, only the
conjunction is used.)

If passed nil or an empty list, returns an empty string.
]]

function M.commafy(t, andword, comma)
  if t == nil or #t == 0 then return '' end  -- ugly special case
  andword = andword or 'and'
  local comma_space = comma and comma .. ' ' or ', '
  local n = #t
  assert(n > 0, 'Empty list not handled correctly in stringx.commafy')
  if n == 1 then
    return t[1]
  elseif n == 2 then
    return table.concat { t[1], ' ', andword, ' ', t[2] }
  else
    local last = t[n]
    t[n] = andword .. ' ' .. t[n]
    local answer = table.concat(t, comma_space)
    t[n] = last
    return answer
  end
end

function M.center(s, len)
  if type(len) == 'string' then len = #len end
  local add = len - #s
  if add > 0 then
    local right = math.floor(add / 2)
    local left = add - right
    return table.concat { string.rep(' ', left), s, string.rep(' ', right) }
  else
    return s
  end
end

__doc.wrapf = [[function (string -> a) returns (string, ...) -> a
Wraps function so it takes the same arguments as string.format
]]

__doc.wrapf1 = [[function ((a, string) -> b) returns (a, string, ...) -> b
Wraps function so 2nd argument and beyond are like string.format
]]

__doc.wrapm = [[function (a, string) returns (...) -> b
string.wrapm(a, methodname)(...) = a:methodname(string.format(...))
]]

__doc.fwriter = [[function (a) returns (...) -> b
string.fwriter(a)(...) = a:write(string.format(...))
]]

function M.wrapf(f)
  return function(...) return f(string.format(...)) end
end

function M.wrapm(self, method)
  return function(...) return self[method](self, string.format(...)) end
end

function M.wrapf1(f)
  return function(x, ...) return f(x, string.format(...)) end
end

function M.fwriter(self)
  return function(...) return self:write(string.format(...)) end
end



__doc.center = [[function(string, width) returns string
Pads argument on the left and right with blanks to achieve desired width.
If 'width' is a string, pad to its size.
]]
function M.center(s, len)
  if type(len) == 'string' then len = #len end
  local add = len - #s
  if add > 0 then
    local right = math.floor(add / 2)
    local left = add - right
    return table.concat { string.rep(' ', left), s, string.rep(' ', right) }
  else
    return s
  end
end


__doc.byte_table = [[function(string) returns { code |--> bool}
Return table mapping every `string.byte` code in 'string' to true.
]]

function M.byte_table(s)
  local t = { }
  for i = 1, #s do
    t[string.byte(s, i)] = true
  end
  return t
end

__doc.random = [[function(minlen, maxlen) returns str
Generates a random string with length no shorter than minlen and
no longer than maxlen.

By default, minlen is 10 and maxlen is 30.

Only capital ASCII letters are used (i.e., A-Z).
]]
function M.random(minlen, maxlen)
  local minlen = minlen or 10
  local maxlen = maxlen or 30
  local len = math.random(minlen, maxlen)
  local let_start, let_end = string.byte('AZ', 1, 2)

  local letters = {}
  for _ = 1, len do
    insert(letters, string.char(math.random(let_start, let_end)))
  end
  return table.concat(letters)
end


__doc.trim = [[function([string]) returns string
Returns argument (default '') with leading and trailing space removed.
]]

function M.trim(s)
  if not s then
    return ''
  else
    return (s:gsub('^%s*(.-)%s*$', '%1'))
  end
end

__doc.rtrim = [[function([string]) returns string
Returns argument (default '') with trailing space removed.
]]

function M.rtrim(s)
  if not s then
    return ''
  else
    return (s:gsub('^(.-)%s*$', '%1'))
  end
end

__doc.distance = [[function(string, string, [limit]) returns number

Damerau–Levenshtein edit distance between two strings or tables.
Transposition, substitution, insertion, deletion.
Pass 'limit' to get better performance; returns math.min(limit, distance).

Cost is product of lengths.

Also works on tables.

http://en.wikipedia.org/w/index.php?title=Damerau%E2%80%93Levenshtein_distance&oldid=351641537
http://nayruden.com/?p=115
https://gist.github.com/Nayruden/427389
]]

function M.distance2d( s, t, lim )
    if lim and math.abs(#s - #t) >= lim then
      return lim
    else
      -- Convert string arguments to arrays of ints (ASCII values)
      if type(s) == "string" then
        s = { string.byte( s, 1, #s ) }
      end

      if type(t) == "string" then
        t = { string.byte( t, 1, #t ) }
      end

      local min = math.min -- Localize for performance

      local huge = math.huge
      local d = {} -- (#s+1) * (#t+1) is going to be the size of this array
        -- access to elements -1 has huge cost (bogus transposition
      for i = 0, #s do
        d[i] = { [-1] = huge, [0] = i } -- Initialize cost of deletion
      end
      d[-1] = setmetatable({}, { __index = function () return huge end })
      local d0 = d[0]
      for j = 0, #t do
        d0[j] = j -- Initialize cost of insertion
      end

      for i = 1, #s do
        local best = huge -- best cost for this i, any j
        local d_i, d_prev_i, d_i_2 = d[i], d[i-1], d[i-2]
        for j = 1, #t do
          local cost = s[i] ~= t[j] and 1 or 0 -- substitution or transposition
          local trans_cost = s[i] == t[j - 1] and s[i - 1] == t[j] and cost or huge

          local mincost = min(d_prev_i[j]     + 1,   -- Deletion
                              d_i     [j - 1] + 1,   -- Insertion
                              d_prev_i[j - 1] + cost, -- Subsn
                              d_i_2   [j - 2] + trans_cost
                             )
          d_i[j] = mincost
          best = min(best, mincost)
        end
        if lim and best >= lim then
          return lim
        end
      end
      return d[#s][#t]
    end
end



function M.distance( s, t, lim )
    if lim and math.abs(#s - #t) >= lim then
      return lim
    else
      -- Convert string arguments to arrays of ints (ASCII values)
      if type(s) == "string" then
        s = { string.byte( s, 1, #s ) }
      end

      if type(t) == "string" then
        t = { string.byte( t, 1, #t ) }
      end

      local min = math.min -- Localize for performance
      local num_columns = #t + 1 -- We use this a lot

      local d = {} -- (#s+1) * (#t+1) is going to be the size of this array

      -- This is technically a 2D array, but we're treating it as
      -- 1D. Remember that 2D access in the form my_2d_array[ i, j ] can
      -- be converted to my_1d_array[ i * num_columns + j ], where
      -- num_columns is the number of columns you had in the 2D array
      -- assuming row-major order and that row and column indices start
      -- at 0 (we're starting at 0).

      for i = 0, #s do
        d[i * num_columns] = i -- Initialize cost of deletion
      end
      for j = 0, #t do
        d[j] = j -- Initialize cost of insertion
      end
      local huge = math.huge
      local function idx(t, k)
        t[k] = huge
        return huge
      end
      setmetatable(d, { __index = idx })

      for i = 1, #s do
        local i_pos = i * num_columns
        local best = huge -- best cost for this i, any j
        for j = 1, #t do
          local add_cost = s[i] ~= t[j] and 1 or 0
          local trans_cost = s[i] == t[j - 1] and s[i - 1] == t[j] and add_cost or huge

          local mincost = min(d[i_pos - num_columns + j] + 1,   -- Deletion
                              d[i_pos + j - 1] + 1,             -- Insertion
                              d[i_pos - num_columns + j - 1] + add_cost, -- Subsn
                              d[i_pos - num_columns - num_columns + j - 2] + trans_cost
                             )
          d[i_pos + j] = mincost
          best = min(best, mincost)
        end
        if lim and best >= lim then
          return lim
        end
      end
      return d[#d]
    end
end


__doc.square_quote = [=[function(string [,newline]) returns string
Using Lua's [[...]] quoting mechanism, return a quoted
version of the argument.  If newline is not nil, always
open with a newline.
]=]



function M.square_quote(s, newline)
  local nl = '' -- possible opening
  if newline or s:find '^\n' then
    nl = '\n'
  end
  if s:find '%]%]' then
    local eqmax = 0
    for eq in s:gmatch '%=+' do
      eqmax = math.max(eqmax, #eq)
    end
    local delim = string.rep('=', #eqmax+1)
    return table.concat { '[', delim, '[', nl, s, ']', delim, ']' }
  else
    return table.concat { '[[', nl, s, ']]' }
  end
end


function M.to_bits(s)
  local function as_bits(s)
    local n = string.byte(s)
    local bits = { }
    local hi = 128
    while hi >= 1 do
      if n >= hi then
        insert(bits, '1')
        n = n - hi
      else
        insert(bits, '0')
      end
      hi = hi / 2
    end
    return table.concat(bits)
  end
  return (s:gsub('.', as_bits))
end


function M.explode(s)
  local t = { }
  for i = 1, #s do
    t[i] = s:sub(i, i)
  end
  return t
end

--string.implode = table.concat

function M.longest_matching_prefix(s, pat)
  for i = 1, #pat do
    local ok, found = s:find(pat:sub(1, -i))
    if ok and found then
      return pat:sub(1, -i)
    end
  end
  return ''
end

__doc.is_proper_prefix = [[function(needle, haystack) returns bool
Is the needle a proper prefix of the haystack?
]]

function M.is_proper_prefix(needle, haystack)
  return #haystack > #needle and haystack:find(needle, 1, true) == 1
end

__doc.file_line_table = [[function(string) returns string list
Returns a list of what file:lines would return if the string
were the contents of a file.
]]

function M.file_line_table(s)
  local lines = { }
  for line in s:gmatch('(.-)\n') do
    insert(lines, line)
  end
  if #s > 0 and s:sub(-1) ~= '\n' then
    insert(lines, s:match '[^\n]*$')
  end
  return lines
end

do
  local function lines_are(s, expected)
    local lines = M.file_line_table(s)
    assert(#lines == #expected)
    for i = 1, #expected do
      assert(lines[i] == expected[i])
    end
  end
  lines_are('', {})
  lines_are('a', {'a'})
  lines_are('a\n', {'a'})
  lines_are('a\nb', {'a', 'b'})
  lines_are('a\n\n', {'a', ''})
end

return thismodule()
