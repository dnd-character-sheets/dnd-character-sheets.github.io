-- migrated to Lua 5.1 only (15 Feb 2013)

-- migrated to Lua 5.1/5.3 (10 Mar 2016)

local stringf = string.format
local strfind = string.find
local insert = table.insert
local concat = table.concat
local stdout = io.stdout
local stderr = io.stderr
local floor = math.floor
local remove = table.remove
local sort = table.sort

local type, tostring, ipairs, pairs, select, pcall, next
    = type, tostring, ipairs, pairs, select, pcall, next

local inspect = { }

local __doc = { }
inspect.__doc = __doc
__doc.__overview = [[
Functions for printing Lua values with debugging information.
]]

__doc.__order = { 'image', 'show' }

__doc.image = [[function(value) returns string
Returns a string representation of the given value, suitable
for debugging.  Digs arbitrarily deep into tables and should
cope correctly with cycles and sharing.  The result is *not*
machine-readable.
]]

__doc.show = [[function(value, ...) prints
Write the 'image' of each value to io.stderr, separated by newlines.
There is *no* newline terminator.
]]

local function safe_tostring(v)
  local ok, s = pcall(tostring, v)
  if ok then
    return s
  else
    return 'tostring() failed: ' .. s
  end
end


function inspect.image(x, inspected, indent)
  inspected = inspected or { }
  indent = indent or ''
  local image = inspect.image
  local pfx
  if type(x) == 'string' then return stringf("%q", x)
  elseif type(x) == 'number' then
     if x == floor(x) then return stringf("%.0f", x)
     else                       return stringf("%f", x)
     end
  elseif type(x) == 'function' or type(x) == "cfunction" then
       return tostring(x)
  elseif type(x) == 'table' then
        if inspected[x] then
          return 'inspected ' .. safe_tostring(x)
        else
          inspected[x] = true
          local listform = { } -- map integer keys shown
          local parts = { }
          local function add(...)
            for i = 1, select('#', ...) do
              insert(parts, (select(i, ...)))
            end
          end
          add(safe_tostring(x), ' {')
          pfx = " "
          if x[1] then
            for i, v in ipairs(x) do
              listform[i] = true
              add(pfx, image(v, inspected))
              pfx = ", "
            end
          end
          pfx = pfx == ' ' and '\n  ' .. indent or ',\n  ' .. indent
          local newindent = indent .. '  '
          for k, v in pairs(x) do
            if not listform[k] then
              add(pfx)
              if type(k) == "string" and strfind(k, "^[%a_][%w_]*$") then
                add(k)
              else
                add("[", image(k, inspected, newindent), "]")
              end
              add(' = ', image(v, inspected, newindent))
              pfx = ",\n  " .. indent
            end
          end
          if pfx:find '^,' then
            add('\n', indent, '}')
          else
            add('}')
          end
          return concat(parts)
        end
  elseif x == nil then return 'nil'
  else return safe_tostring(x)
  end
end
function inspect.show(...)
  for i = 1, select('#', ...) do
    if i>1 then stderr:write '\n' end
    stderr:write(inspect.image((select(i, ...))))
  end
end

__doc.friendly = [[function(v) returns string
Return a string describing v, suitable for use in error messages.
]]

local key_cap = 4





local function plural(count, what, plural)
  if count == 1 then
    return stringf('one %s', what)
  elseif count == 0 then
    return stringf('no %s', plural or what .. 's')
  else
    return stringf('%d %s', count, plural or what .. 's')
  end
end

local function friendly_table(t)
  if next(t) == nil then
    return 'an empty table'
  elseif t[1] then
    return 'a list of ' .. plural(#t, 'value')
  else
    local string_keys, number_keys, other = { }, 0, 0
    for k in pairs(t) do
      if type(k) == 'string' then
        insert(string_keys, k)
      elseif type(k) == 'number' then
        number_keys = number_keys + 1
      else
        other = other + 1
      end
    end
    table.sort(string_keys)
    if #string_keys == 0 then
      if other > 0 then
        if number_keys > 0 then
          return stringf('a sparse array with %s', plural(other, 'other inscrutable key'))
        else
          return stringf('a table with %s', plural(other, 'inscrutable key'))
        end
      else
        assert(number_keys > 0)
        return stringf('a sparse array with %s', plural(number_keys, 'entry', 'entries'))
      end
    else
      local nstrings = #string_keys
      assert(nstrings > 0)

      sort(string_keys)
      while #string_keys > key_cap do -- strip extras
        remove(string_keys)
      end

      for i, s in ipairs(string_keys) do -- quote as needed
        if #s == 0 or s:find '[^%w_]' then
          string_keys[i] = stringf('%q', s)
        end
      end

      local what = number_keys > 0
               and stringf('a sparse array with %s and also', plural(number_keys, 'entry', 'entries'))
                or 'a table'

      local with
      if nstrings <= #string_keys then
        if #string_keys == 1 then
          with = stringf('with key %s', string_keys[1])
        elseif #string_keys == 2 then
          with = stringf('with keys %s and %s', string_keys[1], string_keys[2])
        else
          string_keys[#string_keys] = 'and ' .. string_keys[#string_keys]
          with = stringf('with keys %s', concat(string_keys, ', '))
        end
      else
        with = stringf('with keys %s, %s%s',
                       concat(string_keys, ', '),
                       other == 0 and 'and ' or '',
                       plural(nstrings - #string_keys, 'other string key'))
      end

      if other > 0 then
        with = stringf('%s, plus %s', with, plural(other, 'other inscrutable key'))
      end
      return stringf('%s %s', what, with)
    end
  end
end

local function const(s) return function(_) return s end end

local friendly = {
  ['nil'] = const 'the value `nil`',
  number  = function(n) return stringf('the number %s', tostring(n)) end,
  string  = function(s)
              if #s < 20 then
                return stringf('the string %q', s)
              else
                return stringf('a string of %s, beginning %q...', plural(#s, 'byte'), s:sub(1, 17))
              end
            end,
  boolean = function(b) return stringf('the Boolean value `%s`', b and 'true' or 'false') end,
  table   = friendly_table,
  ['function'] = const 'a function',
  thread  = const 'a Lua thread',
  userdata = const 'userdata',
}

function inspect.friendly(v)
  return assert(friendly[type(v)])(v)
end

-- One table for each control-flow path through `inspect.friendly` when it is
-- given a table; that is, each branch of `friendly_table` above.  The comment
-- on each entry names the branch it exercises.
inspect.test_tables = {
  { },                              -- next(t) == nil: an empty table
  { 'x' },                          -- t[1]: a list, plural(#t) == 1: 'a list of one value'
  { 'x', 'y', 'z' },                -- t[1]: a list, plural(#t) > 1: 'a list of N values'

  -- no string keys (#string_keys == 0):
  { [3] = 'x' },                    -- other == 0, number_keys == 1: 'a sparse array with one entry'
  { [3] = 'x', [4] = 'y' },         -- other == 0, number_keys > 1: 'a sparse array with N entries'
  { [true] = 'x' },                 -- other == 1, number_keys == 0: 'a table with one inscrutable key'
  { [true] = 'x', [false] = 'y' },  -- other > 1, number_keys == 0: 'a table with N inscrutable keys'
  { [2] = 'x', [true] = 'y' },      -- other == 1, number_keys > 0: 'sparse array with one other inscrutable key'

  -- string keys present, count fits under key_cap (nstrings <= #string_keys):
  { a = 1 },                                 -- #string_keys == 1: 'with key a'
  { a = 1, b = 2 },                          -- #string_keys == 2: 'with keys a and b'
  { a = 1, b = 2, c = 3 },                   -- #string_keys >= 3: 'with keys a, b, and c'
  { a = 1, b = 2, c = 3, d = 4 },            -- #string_keys == key_cap (the <= boundary)
  { a = 1, b = 2, [3] = 'x' },               -- 'a sparse array', number_keys == 1
  { a = 1, b = 2, [3] = 'x', [4] = 'y' },    -- 'a sparse array', number_keys > 1: 'N entries and also'
  { a = 1, b = 2, [true] = 'x' },            -- other > 0: appends inscrutable keys
  { a = 1, b = 2, [3] = 'x', [true] = 'y' }, -- sparse array + inscrutable keys

  -- more string keys than key_cap (nstrings > #string_keys):
  { a = 1, b = 2, c = 3, d = 4, e = 5 },                           -- other == 0, one extra: 'and one other string key'
  { a = 1, b = 2, c = 3, d = 4, e = 5, f = 6 },                    -- other == 0, many extra: 'and N other string keys'
  { a = 1, b = 2, c = 3, d = 4, e = 5, [99] = 'x' },               -- sparse array, other == 0
  { a = 1, b = 2, c = 3, d = 4, e = 5, [true] = 'x' },             -- other > 0: '' prefix + inscrutable keys
  { a = 1, b = 2, c = 3, d = 4, e = 5, [99] = 'x', [true] = 'y' }, -- sparse array + inscrutable keys

  -- the key-quoting loop:
  { ['a b'] = 1 },                  -- key contains a non-word character (s:find '[^%w_]')
  { [''] = 1 },                     -- key is the empty string (#s == 0)
}


function inspect.show_test_tables(img)
  for i, t in ipairs(inspect.test_tables) do
    stdout:write(stringf('%2d: %s%s\n', i, inspect.friendly(t), img and ', which is ' .. inspect.image(t) or ''))
  end
end

return inspect
