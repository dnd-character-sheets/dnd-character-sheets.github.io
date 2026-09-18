local setmetatable, getmetatable, table, type, math, select, assert
    = setmetatable, getmetatable, table, type, math, select, assert

local coroutine, error, io, ipairs, next, pairs, require, string
    = coroutine, error, io, ipairs, next, pairs, require, string

local unpack = table.unpack or unpack -- multiversion

local tostring
    = tostring

local stringf = string.format

local M, __doc, thismodule, _ENV = require 'module52'.new()

function M.average(xs)
  local sum = 0
  for _, x in ipairs(xs) do
    sum = sum + x
  end
  return sum / #xs
end

function M.of_generator(f, ...)
  local l = { }
  for x in f(...) do table.insert(l, x) end
  return l
end

__doc.take = [[function(t, [n]) returns t
Keeps the first n elements from t.  Default n == 1.
]]

function M.take(t, n)
  n = n or 1
  for i = 1, #t - n do -- luacheck: no unused
    table.remove(t)
  end
  return t
end

__doc.shift = [[function(t, [n]) returns t
Removes the first n elements from t.  Default n == 1.
]]

function M.shift(t, n)
  n = n or 1
  for i = 1, n do  -- luacheck: no unused
    table.remove(t, 1)
  end
  return t
end

function M.reverse(xs)
  local u = { }
  for _, x in ipairs(xs) do
    table.insert(u, 1, x)
  end
  return u
end

__doc.random = [[function(value list, [number]) return value
Return random element from list
]]

function M.random(l, n)
  n = n or #l
  assert(n > 0, 'random element from empty list')
  return l[math.random(n)]
end

__doc.sorted_keys = [[function(table, [lt]) returns list
Returns list of all keys in argument, sorted by function lt,
or if lt is missing the default <.
]]

function M.sorted_keys(t, lt)
  local u = { }
  for k in pairs(t) do table.insert(u, k) end
  table.sort(u, lt)
  return u
end

__doc.randomize = [[function(xs, [random]) returns ys
Result ys is a fresh list containing elements of xs in random order.
]]
function M.randomize(l, random)
  random = random or math.random
  local u = { }
  local n = #l
  for i = 1, n do
    u[i] = l[i]
  end
  for i = 1, n do
    local j = random(n)
    u[i], u[j] = u[j], u[i]
  end
  return u
end

__doc.key = [[function(v) returns function (table) returns value
Return the function that looks up by the given key.
]]

function M.key(v)
  return function(t) return t[v] end
end

__doc.filter = [[function(f: function, xs : value list) returns value list
Returns the list of values v in xs satisfying f(v).
]]

function M.filter(f, l)
  local u = { }
  if type(f) == 'table' then
    for _, v in ipairs(l) do
      if f[v] then
        table.insert(u, v)
      end
    end
  else
    for _, v in ipairs(l) do
      if f(v) then
        table.insert(u, v)
      end
    end
  end
  return u
end

function M.filternot(f, l)
  local u = { }
  if type(f) == 'table' then
    for _, v in ipairs(l) do
      if not f[v] then
        table.insert(u, v)
      end
    end
  else
    for _, v in ipairs(l) do
      if not f(v) then
        table.insert(u, v)
      end
    end
  end
  return u
end

function M.filtersplit(f, l)
  local good, bad = { }, { }
  if type(f) == 'table' then
    for _, v in ipairs(l) do
      table.insert(f[v] and good or bad, v)
    end
  else
    for _, v in ipairs(l) do
      table.insert(f(v) and good or bad, v)
    end
  end
  return good, bad
end



__doc.get_key = [=[function(x)(t) returns t[x]]=]

function M.get_key(x)
  return function(t) return t[x] end
end

__doc.map = [[function(f, t, ...) returns list of values
Returns a map that is like `t` except each key `k`
is mapped to `f(v, k, ...)` where `v == t[k]`.

If `f` is a table it does table lookup instead of function application.
]]

function M.map(f, l, ...)
  local u = { }
  if type(f) == 'table' then
    for k, v in pairs(l) do
      u[k] = f[v]
    end
  else
    for k, v in pairs(l) do
      u[k] = f(v, k, ...)
    end
  end
  return u
end

function M.mapi(f, l, ...)
  local u = { }
  if type(f) == 'table' then
    for k, v in ipairs(l) do
      u[k] = f[v]
    end
  else
    for k, v in ipairs(l) do
      u[k] = f(v, k, ...)
    end
  end
  return u
end



function M.app(f, l, ...)
  for k, v in pairs(l) do
    f(v, k, ...)
  end
end

__doc.map_no_key = [[function(f, t : table, ...) returns table
Returns a table u in which u[k] = f(t[k], ...) for every k in t.
]]

function M.map_no_key(f, l, ...)
  local u = { }
  for k, v in pairs(l) do
    u[k] = f(v, ...)
  end
  return u
end

function M.setmap(f, t)
  local u = { }
  for k, v in pairs(t) do
    u[assert(f(k))] = v
  end
  return u
end

__doc.argmin = [[function(f, t) returns k, v, f(v, k)
Return key, value, and result where f(v, k) is minimized.
]]

function M.argmin(f, l)
  local bestarg, bestk, bestres = nil, nil, math.huge
  for k, v in pairs(l) do
    local x = f(v, k)
    if x < bestres then
      bestarg, bestk, bestres = k, v, x
    end
  end
  return bestarg, bestk, bestres
end

__doc.indexmin = [[function(f, xs) returns int
Return the index i into nonempty xs that minimizes f(xs[i]).
If xs is empty, returns nil.
]]

function M.indexmin(f, xs)
  local besti, bestres = nil, math.huge
  for i, x in ipairs(xs) do
    local y = f(x)
    if y < bestres then
      besti, bestres = i, y
    end
  end
  return besti, bestres
end

local function pack(...) return { ... } end

function M.fold(f, t, ...)
  local z = pack(...)
  for k, v in pairs(t) do
    z = pack(f(k, v, unpack(z)))
  end
  return unpack(z)
end

__doc.forall = [[function(f or t, xs) returns boolean
True iff every element v enumerated by ipairs(xs) satisfies
function f(v) or table t[v].
]]

function M.forall(f, l)
  if type(f) == 'function' then
    for _, v in ipairs(l) do
      if not f(v) then
        return false
      end
    end
  else
    for _, v in ipairs(l) do
      if not f[v] then
        return false
      end
    end
  end
  return true
end

__doc.exists = [[function(fun or table, list) returns bool
Return ∃ x ∈ list : fun(x) or table[x].
]]

__doc.existsp = [[function(fun, table) returns boolish
Return ∃ k, v ∈ table : fun(v, k).
]]

function M.exists(f, l)
  if type(f) == 'function' then
    for _, v in ipairs(l) do
      if f(v) then
        return true
      end
    end
  else
    for _, v in ipairs(l) do
      if f[v] then
        return true
      end
    end
  end
  return false
end
M.any = M.exists
M.anyp = M.existsp
__doc.any = __doc.exists
__doc.anyp = __doc.existsp


function M.existsp(f, t)
  for k, v in pairs(t) do
    if f(v, k) then
      return true
    end
  end
  return false
end

function M.forallp(f, l)
  if type(f) == 'function' then
    for k, v in pairs(l) do
      if not f(v, k) then
        return false
      end
    end
  else
    for _, v in pairs(l) do
      if not f[v] then
        return false
      end
    end
  end
  return true
end




__doc.find = [[function(p, l) returns v, i in list s.t. p(v) or nil
Returns the first v, i pair in list l such that p(v) and l[i] == v.
]]

function M.find(f, l)
  for i, v in ipairs(l) do
    if f(v) then
      return v, i
    end
  end
  return nil
end

__doc.index_of = [[function(l, v) returns i s.t. l[i] == v or nil
Returns the first i in list l where l[i] == v.
]]

function M.index_of(l, v)
  for i = 1, #l do
    if l[i] == v then return i end
  end
  return nil
end

__doc.invert = [[function(table) returns table
return table with keys and values swapped.
If multiple argument keys map to the same value,
which one wins is arbitrary.
]]

function M.invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end

__doc.set = [[function(value list) returns table
Returns a table in which every value in the argument list
is mapped to `true`.  No metatable!  Consider instead `set.of_list`.
]]

function M.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

__doc.subset = [[function(t1, t2) returns bool
return true if and only if every key in `t1` is also in `t2`.
]]

function M.subset(l, r) -- every key in l is in r
  for k in pairs(l) do if r[k] == nil then return false end end
  return true
end

__doc.setminus = [[function(t1, t2) returns bool
Returns a shallow copy of table t1 with every key in t2 removed.
]]

function M.setminus(l, r)
  local u = M.copy(l)
  for k in pairs(r) do u[k] = nil end
  return u
end

function M.numpairs(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

__doc.union = [[function(table, ...) returns table
Returns a table in which every key bound in any argument
is bound to `true`.
]]

function M.union(...)
  local u = { }
  for _, t in ipairs { ... } do
    for k in pairs(t) do
      u[k] = true
    end
  end
  return u
end

__doc.seteq = [[function(table, ...) returns bool
Takes two or more table arguments and returns true if and only if
all are "set equal" to the first, according to table.subset.
]]

function M.seteq(...)
  local n = select('#', ...)
  assert(n > 0)
  local s1 = select(1, ...)
  if type(s1) ~= 'table' then
    local i = require 'inspect'
    io.stderr:write('set s1 is a ', type(s1), ': ', i.image(s1), '\n')
  end
  assert(type(s1) == 'table')
  for i = 2, n do
    local s2 = select(i, ...)
    assert(type(s2) == 'table')
    if not (table.subset(s1, s2) and table.subset(s2, s1)) then
      return false
    end
  end
  return true
end

__doc.elements = [[function(table) returns value list
Return list of all the keys in the argument table, in arbitrary order.
]]

function M.elements(t) --- list of set
  local u = { }
  for v in pairs(t) do table.insert(u, v) end
  return u
end

__doc.values = [[function(table) returns value list
Returns the values of a table (from `pairs`) in a list.
]]

function M.values(t) --- values in table as list
  local u = { }
  for _, v in pairs(t) do table.insert(u, v) end
  return u
end

__doc.copy = [[function(table) returns table
Return a shallow copy of the argument. Result has same metatable
as the argument.
]]

function M.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

__doc.deep_copy = [[function(table) returns table
Returns its argument, unless argument is a table,
in which case it returns a fresh table in which
every key is mapped to a deep copy of the corresponding
value.  Metatables are also copied.

(Only values are copied deeply, not keys.)
]]

function M.deep_copy(t)
  if type(t) == 'table' then
    return setmetatable(table.map(table.deep_copy, t), getmetatable(t))
  else
    return t
  end
end

function M.default_to(default)
  return setmetatable({ }, { __index = function() return default end })
end

do
  local default_meta = { __index = function(t) return t['*'] or t.default end }
  function M.defaulting(t, defaultkey)
    t = t or { }
    defaultkey = defaultkey or '*'
    local om = getmetatable(t)
    if om then
      assert(om.__index == nil, "Defaulting table already has __index method")
      local m = { }
      for k, v in pairs(om) do m[k] = v end
      m.__index = function(t) return t[defaultkey] or t.default end
      setmetatable(t, m)
    elseif defaultkey == '*' then
      setmetatable(t, default_meta)
    else
      setmetatable(t, { __index = function(t) return t[defaultkey] or t.default end })
    end
    return t
  end
end

do
  local meta = { __index = function(t, k) local u = {} t[k] = u return u end }
  __doc.of_tables = [[function([table]) returns table
Returns table in which a reference to any unbound key
materializes as a fresh, empty table.
]]
  function M.of_tables(t)
    t = t or { }
    local om = getmetatable(t)
    if om then
      assert(om.__index == nil, "Defaulting table already has __index method")
      local m = { }
      for k, v in pairs(om) do m[k] = v end
      m.__index = meta.__index
      setmetatable(t, m)
    else
      setmetatable(t, meta)
    end
    return t
  end
end

do
  local meta = { }
  meta.__index = function(t, k) local u = setmetatable({}, meta) t[k] = u return u end
  __doc.of_deep_tables = [[function([table]) returns table
Returns table in which a reference to any unbound key
materializes as a fresh, empty table.
]]
  function M.of_deep_tables(t)
    t = t or { }
    local om = getmetatable(t)
    if om then
      assert(om.__index == nil, "Defaulting table already has __index method")
      local m = { }
      for k, v in pairs(om) do m[k] = v end
      m.__index = meta.__index
      setmetatable(t, m)
    else
      setmetatable(t, meta)
    end
    return t
  end
end

do
  local function newset()
    local set = require 'set'
    return set.of_list {}
  end
  local meta = { __index = function(t, k) local u = newset(); t[k] = u return u end }
  __doc.of_sets = [[function([table]) returns table
Returns table in which a reference to any unbound key
materializes as a new set.
]]
  function M.of_sets(t)
    t = t or { }
    local om = getmetatable(t)
    if om then
      assert(om.__index == nil, "Defaulting table already has __index method")
      local m = { }
      for k, v in pairs(om) do m[k] = v end
      m.__index = meta.__index
      setmetatable(t, m)
    else
      setmetatable(t, meta)
    end
    return t
  end
end

do
  local meta = { __index = function(t, k) t[k] = 0 return 0 end }
  __doc.of_zeroes = [[function([table]) returns table
Returns table in which a reference to any unbound key materializes as 0.
Argument defaults to a fresh, empty table.
]]
  function M.of_zeroes(t)
    t = t or { }
    local om = getmetatable(t)
    if om then
      assert(om.__index == nil, "Defaulting table already has __index method")
      local m = { }
      for k, v in pairs(om) do m[k] = v end
      m.__index = meta.__index
      setmetatable(t, m)
    else
      setmetatable(t, meta)
    end
    return t
  end
end

-------------
--- for lexicographic sorting

local function listlt(l1, l2, lt)
  for i = 1, #l1 do
    local v1, v2 = l1[i], l2[i]
    if lt(v1, v2) then return true
    elseif lt(v2, v1) then return false
    end
  end
  return false
end

function M.lt(l1, l2, lt) -- must be same length
  if lt then return listlt(l1, l2, lt) end
  for i = 1, #l1 do
    local v1, v2 = l1[i], l2[i]
    if v1 ~= v2 then
      if type(v1) == 'boolean' then
        return not v1 and v2
      elseif type(v1) == 'nil' then
        return true
      elseif type(v2) == 'nil' then
        return false
      else
        return v1 < v2
      end
    end
  end
  return false
end

function M.gt(l1, l2, lt) return M.lt(l2, l1, lt) end

__doc.lt_field = [[function(key, [lt]) returns function(t1, t2) returns bool
Compare two tables on the given field.
]]

function M.lt_field(key, lt)
  if lt then
    return function(t1, t2) return lt(t1[key], t2[key]) end
  else
    return function(t1, t2) return t1[key] < t2[key] end
  end
end

__doc.cat = [[function(value list, ...) returns value list
Use with `unpack` to flatten a list of lists.
]]

function M.cat(...)
  local t = { }
  for i = 1, select('#', ...) do
    local u = select(i, ...)
    for _, v in ipairs(u) do table.insert(t, v) end
  end
  return t
end

__doc.append = [[function(t, ...) returns t
Append every value in the list ... to the list t, returning t.
]]
function M.append(t, ...)
  for i = 1, select('#', ...) do
    table.insert(t, (select(i, ...)))
  end
  return t
end

__doc.deep_insert = [[function(t, k1, k2, ..., kn, v)
Assign t[k1][k2][k3]...[kn] = v, creating tables as needed.
]]

function M.deep_insert(t, k, v, ...)
  if select('#', ...) == 0 then
    t[k] = v
  else
    t[k] = t[k] or { }
    return M.deep_insert(t[k], v, ...)
  end
end

__doc.deep_lookup = [[function(t, k1, k2, ..., kn)
Return t[k1][k2][k3]...[kn], returning nil if any part is missing.
]]

function M.deep_lookup(t, k, ...)
  if t == nil then
    error('Attempted to index nil value with key ' .. tostring(k))
  else
    local v = t[k]
    if select('#', ...) == 0 then
      return v
    else
      t = v
      if t ~= nil then
        return M.deep_lookup(t, ...)
      else
        return nil
      end
    end
  end
end


__doc.flip_keys = [[function(t) returns u
where forall k1, k2 in keys(t) : u[k2][k1] = t[k1][k2]
]]

function M.flip_keys(t)
  local u = { }
  for k1, t in pairs(t) do
    for k2, v in pairs(t) do
      local uk = u[k2] or { }
      u[k2] = uk
      assert(uk[k1] == nil)
      uk[k1] = v
    end
  end
  return u
end

__doc.total_group_by = [[function(a -> a -> Bool, 'a list) returns 'a list list
Like group_by, but satisfies the following property:

    Forall (x, y) in xs, p(x, y) iff x is in the same sub-list as y

i.e., elements from different bins never satisfy p.
]]
function M.total_group_by(p, xs)
  if #xs == 0 then
    return {}
  end

  xs = M.copy(xs)
  local sublists = {}
  while xs[1] do
    local tmp = {xs[1]}
    local new_xs = {}
    for i = 2, #xs do
      if p(xs[1], xs[i]) then
        table.insert(tmp, xs[i])
      else
        table.insert(new_xs, xs[i])
      end
    end
    xs = new_xs
    table.insert(sublists, tmp)
  end
  return sublists
end

__doc.group_by = [[function(a -> a -> Bool, 'a list) returns 'a list list
Algebraic law:

    xs = concat (group_by p xs)
]]
function M.group_by(p, xs)
  if #xs == 0 then
    return {}
  end

  local sublists = {}
  local tmp = {}
  for i, x in ipairs(xs) do
    if i == 1 or p(xs[i-1], x) then
      table.insert(tmp, x)
    else -- not p(xs[i-1], x)
      table.insert(sublists, tmp)
      tmp = {}
      table.insert(tmp, x)
    end
  end
  table.insert(sublists, tmp)
  return sublists
end

__doc.break_before = [==[function(p, 'a list) returns 'a list, 'a list list
Returns prefix, partition, where partition is a list of nonempty
sublists with a break before each element satisfying p.
The prefix of elements not satisfying p may be empty; no other
sublist is empty.

See http://stackoverflow.com/questions/5438558/ and the Haskell list-grouping
package.
]==]


function M.break_before(p, xs)
  xs = M.copy(xs)
  local prefix, sublists = { }, { }
  local i = 1
  while xs[1] and not p(xs[1], i) do
    table.insert(prefix, table.remove(xs, 1))
    i = i + 1
  end
  while xs[1] do
    assert(p(xs[1], i))
    local ys = { table.remove(xs, 1) }
    i = i + 1
    while xs[1] and not p(xs[1], i) do
      table.insert(ys, table.remove(xs, 1))
      i = i + 1
    end
    table.insert(sublists, ys)
  end

if false then
  -- luacheck: ignore 511
  local function eprintf(...) io.stderr:write(string.format(...)) end
  eprintf '\n\n\n===================================\n'
  eprintf('%s\n', table.concat(prefix, '\n'))
  for _, ls in ipairs(sublists) do
    eprintf('--------------------\n%s\n', table.concat(ls, '\n'))
  end
  eprintf '===================================\n'
end


  return prefix, sublists
end


__doc.sum = [[function(number list) returns number]]

function M.sum(xs)
  local total = 0
  for _, x in ipairs(xs) do
    total = total + x
  end
  return total
end

__doc.sumall = [[function(table) returns number
Sums *all* values in table (which must all be numbers).
]]

function M.sumall(t)
  local total = 0
  for _, x in pairs(t) do
    total = total + x
  end
  return total
end


__doc.pairsN = [[iterator(n, table) returns k1, k2, ..., k{n-1}, v
Iterates over nested pairs of nested tables.
Obeys "pairsN(2, t) == pairs", and pairsN(n, t)
returns n results per iteration.
]]

function M.pairsN(n, t)
  assert(n >= 2)
  assert(type(t) == 'table')
  local yield = coroutine.yield
  if n == 2 then
    return coroutine.wrap(function ()
                            for k, v in pairs(t) do
                              yield(k, v)
                            end
                          end)
  else
    return coroutine.wrap(function ()
                            for k, v in pairs(t) do
                              local function extend(iterator)
                                local function finish(...)
                                  if ... ~= nil then
                                    yield(k, ...)
                                    return finish(iterator())
                                  end
                                end
                                return finish(iterator())
                              end
                              extend(table.pairsN(n-1, v))
                            end
                          end)
  end
end

__doc.sortpairs = [[iterator(table, [function]) returns k, v
like 'pairs', but returns keys in sort order
]]

function M.sortpairs(t)
  local keys = M.sorted_keys(t)
  local yield = coroutine.yield
  return coroutine.wrap(function()
                          for _, k in ipairs(keys) do
                            yield(k, t[k])
                          end
                        end)
end

__doc.over = [[function(t1, t2, ...) returns t
Return an empty table with a metatable whose __index
method searches each argument table in turn.
]]

local function over(...)
  if select('#', ...) == 0 then
    return { }
  else
    local first = select(1, ...)
    local rest = over(select(2, ...))
    local function get(_, key)
      local v = first[key]
      if v == nil then
        return rest[key]
      else
        return v
      end
    end
    return setmetatable({ }, { __index = get })
  end
end

M.over = over

__doc.tconcat = [[function(t1, ...) returns t
Return concatenation of all list arguments, as in Haskell concat.
]]

function M.tconcat(...)
  local t = { }
  for i = 1, select('#', ...) do
    local u = select(i, ...)
    for _, v in ipairs(u) do
      table.insert(t, v)
    end
  end
  return t
end

M.cat = M.tconcat

__doc.combine = [[function(table, ...) returns table
Combines the keys from multiple tables in a  left-biased merge.
]]

function M.combine(...)
  local u = {}
  for _,t in ipairs{...} do
    for k,v in pairs(t) do
      if u[k] == nil then
        u[k] = v
      end
    end
  end
  return u
end

__doc.overlay = [[function(t1, t2) returns table
Return an empty table t such that t[k] returns t1[k] when
that is not nil and t2[k] otherwise.  No values are copied.
]]

function M.overlay(t1, t2)
  return setmetatable({}, {
      __index = function(_, k)
        local v = t1[k]
        if v ~= nil then return v end
        return t2[k]
      end
  })
end

__doc.of_iterator = [[function(iterator) returns list
Return a list of all the elements produced by an iterator.
]]

function M.of_iterator(iter)
  local t = { }
  for v in iter do table.insert(t, v) end
  return t
end

__doc.list_of = [[function(element or list) returns list
If argument is not a list, return a new list with the argument.
]]

function M.list_of(e_or_l)
  return type(e_or_l) == 'table'
     and #e_or_l == M.numpairs(e_or_l)
     and e_or_l or {e_or_l}
end

__doc.inserted = [[function(table, [pos,] value) returns self
Behaves like table.insert, except it returns its first argument.
]]

function M.inserted(t, ...)
  table.insert(t, ...)
  return t
end

__doc.sorted = [[function(table, ...) returns self
Behaves like table.sort, except it returns its first argument.
]]

function M.sorted(t, ...)
  table.sort(t, ...)
  return t
end

__doc.iota = [[function(n, [f]) returns list
Returns list { f(1), ..., f(n) }, where f defaults
to the identity function.  The name is from APL.
]]

function M.iota(n, f)
  local t = { }
  if f then
    for i = 1, n do table.insert(t, f(i)) end
  else
    for i = 1, n do table.insert(t, i) end
  end
  return t
end

__doc.inc = [[function(t, k1, ..., kn)
Increment the number stored in n t[k1][k2]...[kn]
]]

local function inc(t, ...)
  local k = ...
  if select('#', ...) == 1 then
    t[k] = (t[k] or 0) + 1
  else
    t[k] = t[k] or { }
    inc(t[k], select(2, ...))
  end
end
M.inc = inc


__doc.eq = [[function(t1, t2) returns bool
Do a deep check for isomorphic tables.
]]

function M.eq(t1, t2)
  if t1 == t2 then
    return true
  elseif type(t1) ~= 'table' or type(t2) ~= 'table' then
    return false
  else
    for k, v in pairs(t1) do
      if not M.eq(v, t2[k]) then
        return false
      end
    end
    for k in pairs(t2) do
      if t1[k] == nil then
        return false
      end
    end
    return true
  end
end


__doc.only_key = [[function (table) returns value option
If the given table has exactly one key, return that key,
otherwise return nothing.
]]

function M.only_key(t)
  local o = next(t)
  if o ~= nil then
    local no = next(t, o)
    if no == nil then
      return o
    end
  end
end

__doc.writevalues = [[function(file, table)
To the given file, write the contents of the table
as lines of the form x.y.z : type
]]

function M.writevaluetypes(fd, t, pfx)
  pfx = pfx or ''
  for k, v in pairs(t) do
    if type(v) ~= 'table' then
      fd:write(stringf('%s%s : %s\n', pfx, tostring(k), type(v)))
    else
      M.writevaluetypes(fd, v, pfx .. tostring(k) .. '.')
    end
  end
end


__doc.writevalues = [[function(file, table, [limit])
To the given file, write the contents of the table as lines of
the form x.y.z : value, where `value` at most `limit` characters
]]

local function limited(n, s)
  local fmt = '%s'
  if type(s) == 'string' then
    fmt = '%q'
    if #s + 2 > n then
      s = s:sub(1, n-5) .. '...'
    end
  else
    s = tostring(s)
    if #s > n then
      s = s:sub(1,n-3) .. '...'
    end
  end
  return stringf(fmt, s)
end

function M.writevalues(fd, t, limit, pfx)
  limit = limit or math.huge
  pfx = pfx or ''
  for k, v in pairs(t) do
    if type(v) ~= 'table' then
      fd:write(stringf('%s%s : %s\n', pfx, tostring(k), limited(limit, v)))
    else
      M.writevalues(fd, v, limit, pfx .. tostring(k) .. '.')
    end
  end
end




return thismodule()

