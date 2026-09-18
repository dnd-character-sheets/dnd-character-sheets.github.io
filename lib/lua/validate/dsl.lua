------------------ classic print functions ---------------------
local stringf = string.format
local function eprintf(...) return io.stderr:write(stringf(...)) end
local function dief(...) eprintf(...); os.exit(1) end
local function errorf(...) return error(stringf(...)) end
----------------------------------------------------------------


local getmetatable, ipairs, math, next
    = getmetatable, ipairs, math, next
local pairs, setmetatable, table
    = pairs, setmetatable, table
local tonumber, tostring, type
    = tonumber, tostring, type
local assert, error, io, os, require
    = assert, error, io, os, require

local inspect = require 'inspect'

local M, __doc, thismodule, _ENV = require 'module52'.new()

local function sq(s) -- string quote
  if type(s) ~= 'table' then
    return stringf('%q', s)
  else
    local quoted = { }
    for k, v in pairs(s) do
      quoted[k] = sq(v)
    end
    return quoted
  end
end



local nothing = { }



local function non_nil_or(v, u)
  if v ~= nil then
    return v
  else
    return u
  end
end


local function plural(count, what, theplural)
  if count == 1 then
    return what
  else
    return theplural or what .. 's'
  end
end


local function a(s)
  if s:find '^[aeiouAEIOU]' then
    return 'an ' .. s
  else
    return 'a ' .. s
  end
end

local function wrap(p) -- on failure, produces the offending field (XXX name)
  return function(v)
    if p(v) then return true else return false, v end
  end
end


local function tcopy(t)
  local u = { }
  for k, v in pairs(t) do
    u[k] = v
  end
  return setmetatable(u, getmetatable(t))
end

local function update(t, k, v)
  local u = tcopy(t)
  u[k] = v
  return u
end

local function any(p, list) -- existential quantifier
  local ok, msg
  for _, v in ipairs(list) do
    ok, msg = p(v)
    if ok then
      return ok
    end
  end
  return false, msg
end

-- predicate `can_be(tau1, tau2, ...)(v)` knows about type conversions

local can_be_tab = {
  string = wrap(function(v)
             return type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean'
             end),
  number = wrap(function(v) return tonumber(v) end),
  boolean = wrap(function(v) return type(v) == 'boolean' or tostring(v):find '^[01]$' end),
}
setmetatable(can_be_tab, { __index = function(_, t)
                                       return wrap(function(v) return type(v) == t end)
                           end})

local function can_be(...)
  local types = { ... }
  return function(v) return any(function(t) return can_be_tab[t](v) end, types) end
end

local function commafy(t, andword, comma)
  if t == nil or #t == 0 then return '' end  -- ugly special case
  andword = andword or 'and'
  local comma_space = comma and comma .. ' ' or ', '
  local n = #t
  assert(n > 0, 'Empty list not handled correctly in string.commafy')
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

local empty = wrap(function(v)
  return v == nil
      or type(v) == 'table' and next(v) == nil
      or type(v) == 'string' and not v:find '%S'
      or false
end)



__doc.__overview = [=[

Valid inputs are specified by a little language that can be used to
check the structure and types of Lua objects that come from YAML.
A "validator" is like a type but with a little extra action, including
hooks for external validation and naming.

  Validator v ::= s⟦tring⟧                -- can be interpreted as text
               |  b⟦ool⟦ean⟧⟧             --  true, false, 0, or 1
               |  n⟦number⟧ ⟦[⟦N⟧..⟦M⟧]⟧   -- a number with optional range constraints
               |  empty                   -- empty string, table, YAML null
               |  null                    -- YAML null
               |  any                     -- any value
               |  l⟦ist⟧(v)               -- list of values of type v
               |  {⦃key,⦄}                -- a table with the given keys
               |  v|v                     -- a choice between two validators
               |  (v)                     -- bracketing
               |  name@v                  -- names the type
               |  fname$v                 -- additional, external validation with function fname

  key         ::= ⦃?|%|^⦄name⟦:v⟧   -- type defaults to text

Operators @ and $ associate to the right and bind tighter than |.

]=]

-- a context is a table with fields

-- { longstring: string           --- narrative
-- , topkey : string option    --- top-level key if any
-- , topindex: int          --- top-level list index, if any
-- , key : string option    --- most recent key
-- }

local context = { }

M.context = context


do
  local methods = { }
  local meta = { __index = methods }

  function meta.__tostring(c)
    return c:short()
  end


  function methods:short()
    local function topelement()
      if self.topindex then
        return stringf('element %d of %s', self.topindex, self.topkey)
      else
        return self.topkey
      end
    end

    if not self.topkey then
      return self:long()
    elseif self.topkey == self.key then
      return topelement()
    else
      return stringf('field %q of %s', self.key, topelement())
    end
  end

  function methods:long()
    return self.longstring
  end

  function context.is(v)
    return getmetatable(v) == meta
  end

  function context.new(v)
    if type(v) == 'string' then
      return setmetatable({ longstring = v }, meta)
    else
      return setmetatable(v, meta)
    end
  end

  function context.extend(c, x)
    -- x has table longstring, key, topkey, topindex
    if type(x) == 'string' then
      return update(c, 'longstring', x)
    elseif type(x) == 'number' then
      if c.topindex == nil then
        return update(c, 'topindex', x) + stringf('element %d of %s', x, c:long())
      else
        return c
      end
    else
      local d = { longstring = x.longstring
                      or x.index and stringf('element %d of %s', x.index, c:long())
                      or x.key   and stringf('field %q of %s', x.key, c:long())
                      or c:long(),
                  topkey   = c.topkey or x.key,
                  topindex = c.topindex or x.index,
                  key = x.key or c.key,
      }
      return setmetatable(d, meta)
    end
  end

  meta.__add = context.extend
end

do
  local function tokenize(s)
    assert(type(s) == 'string', 'tried to parse a non-string')
    local tokens = { }
    local init = s:find '%S'
    while init do
      local first, last, found  -- luacheck: no unused
      for _, pat in ipairs { '^(%.%.)', '^([^%w%d])', '^(%d+)', '(%a[%w%-_]*)' } do
        first, last, found = s:find(pat, init)
        if found then
          table.insert(tokens, found)
          break
        end
      end
      if found then
        init = s:find('%S', last + 1)
      else
        dief('Unrecognized character at position %d in string %q', init, s)
      end
    end
    return tokens
  end

  function M.parse(semantics, s)

    local tokens = tokenize(s)
    local tindex = 1

    local maybe, maybe_find, eat, backup, eos -- basic token functions

    local lastmaybe

    function eos()
      return not tokens[tindex]
    end

    function maybe(token, ...)
      lastmaybe = nil
      if token ~= nil then
        if tokens[tindex] == token then
          tindex = tindex + 1
          lastmaybe = token
          return lastmaybe
        else
          return maybe(...)
        end
      else
        return nil
      end
    end

    function maybe_find(pat)
      lastmaybe = nil
      if tokens[tindex]:find(pat) then
        lastmaybe = tokens[tindex]
        tindex = tindex + 1
        return lastmaybe
      else
        return nil
      end
    end

    function backup()
      assert(tindex > 1)
      tindex = tindex - 1
    end

    local function expected(parsing, wanted)
      local tcontext = { }
      for j = math.max(1, tindex-5), math.min(#tokens, tindex+5) do
        if j == tindex then
          table.insert(tcontext, "·")
        end
        table.insert(tcontext, tokens[j])
      end
      errorf('Error parsing %s; expected %s, got %s at token %d ⟨%s⟩', parsing:long(), wanted,
             tokens[tindex] ~= nil and inspect.image(tokens[tindex]) or "end of stream", tindex,
             table.concat(tcontext, ' '))
    end

    function eat(context, token)
      if maybe(token) == nil then
        expected(context, token)
      end
    end

    local alts, alt, range, keys, key -- parsers

    alts = function()
      local alts = { alt() }
      while maybe '|' do
        table.insert(alts, alt())
      end
      return #alts > 1 and semantics:alts(alts) or alts[1]
    end

    local key_prefix_meaning = {
      ['?'] = 'optional',
      ['^'] = 'insensitive',
      ['%'] = 'fontable',
    }

    key = function()
      if maybe '*' then
        local validator = maybe ':' and alts() or nil
        return semantics:any_key(validator)
      else
        local props = { }
        while maybe ('?', '^', '%') do
          props[key_prefix_meaning[lastmaybe]] = true
        end
        local nameparts = { }
        while maybe_find '%w' or maybe '&' do
          table.insert(nameparts, lastmaybe)
        end
        if #nameparts == 0 then
          expected(context.new 'parsing table key', 'name')
        end
        local validator = maybe ':' and alts() or nil
        return semantics:key(table.concat(nameparts, ' '), props, validator)
      end
    end

    keys = function()
      local keys = { key() }
      while maybe ',' do
        if maybe '}' then
          backup()
        else
          table.insert(keys, key())
        end
      end
      eat('table keys', '}')
      return semantics:table(keys)
    end

    alt = function()
      if eos() then
        errorf('Ran out of tokens parsing validator: %s', inspect.image(tokens))
      elseif maybe 'any' then
        return semantics:any()
      elseif maybe 'null' then
        return semantics:null()
      elseif maybe('s', 'string') then
        return semantics:string()
      elseif maybe('b', 'bool', 'boolean') then
        return semantics:boolean()
      elseif maybe 'empty' then
        return semantics:empty()
      elseif maybe('n', 'number') then
        return semantics:number(range())
      elseif maybe('l', 'list') then
        if maybe '{' then
          return semantics:list(keys())
        else
          eat ('list type', '(')
          local v = alts()
          eat ('eend of list type', ')')
          return semantics:list(v)
        end
      elseif maybe '{' then
        return keys()
      elseif maybe '(' then
        local v = alts()
        eat('parenthesized validator', ')')
        return v
      elseif maybe_find '%w' then -- good name
        local name = lastmaybe
        if maybe '@' then
          return semantics:named(name, alt())
        elseif maybe '$' then
          return semantics:validate(name, alt())
        else
          errorf('Unrecognized validation type %q', name)
        end
      else
        errorf('Validation parser found unknown token %q at position %d in %s',
             tokens[tindex], tindex, inspect.image(tokens))
      end
    end

    range = function()
      if maybe '[' then
        local lo = tonumber(maybe_find '^%d+$')
        eat('numeric range', '..')
        local hi = tonumber(maybe_find '^%d+$')
        eat('numeric range', ']')
        return { lo = lo, hi = hi }
      end
    end

    return alts()

  end
end




---------- validation infrastructure (syntax-directed validators) ------------

function M.semantics(verrorf, options)
  assert(type(verrorf) == 'function')

  options = options or nothing

  local function with_verrorf(new, f, ...)
    local old = verrorf
    assert(type(new) == 'function')
    verrorf = new
    local function finish(...)
      verrorf = old
      return ...
    end
    return finish(f(...))
  end

  local function without_verrorf(f, ...)
    return with_verrorf(function () end, f, ...)
  end

  local isnull = options.isnull or function() return false end

  local vfactory = { } -- methods
  local validators, vnames = { }, { } -- these hold the escape hatches
  local friendly = options.friendly or require 'inspect'.friendly


  local ctx = context

  -- Semantic objects are built as follows:
  --
  -- key       : { name : string, validator = v, ... property fields ... }
  -- validator : object with methods and fields
  --    self:validate(context, value) optionally returns normalized value
  --    self:mine(value) returns bool
  --    self:maybe_mine(value) returns bool  -- optional
  --    self.what : string
  --
  -- postcondition:
  --    if v:validator(context, value) returns nil then value is valid
  --    if v:validator(context, value) returns non-nil then it returns a valid valuea

  local function out_of_range(n, rg)
    if rg then
      return rg.lo and n < rg.lo or rg.hi and n > rg.hi
    end
  end

  local function choose_a_number(rg)
    if rg.lo and rg.hi then
      return math.floor((rg.lo + rg.hi) / 2)
    elseif rg.lo then
      return rg.lo
    elseif rg.hi then
      return rg.hi
    else
      return 99
    end
  end

  local function missing(context, wanted, found, replacement)
    assert(type(context) == 'table')
    verrorf(context, 'I was looking for %s, but I found %s.  I substituted %s',
            wanted, friendly(found), friendly(replacement))
  end

  function vfactory:number(rg)
    local range_string = ''
    if rg then
      if rg.lo and rg.hi then
        range_string = stringf(' in the range %d..%d', rg.lo, rg.hi)
      elseif rg.lo then
        range_string = stringf(' at least %d', rg.lo)
      elseif rg.hi then
        range_string = stringf(' at most %d', rg.hi)
      end
    end

    local what = stringf('a number%s', range_string)

    return {
      validate = function(_, context, v)
        if not tonumber(v) or out_of_range(tonumber(v), rg) then
          local substitute = rg and choose_a_number(rg) or 11
          missing(context, what, v, substitute)
          return substitute
        else
          return tonumber(v)
        end
      end,
      mine = function(_, v) return can_be 'number'(v) end,
      what = what,
    }
  end

  local text = {
    validate = function(_, context, v)
      if not can_be 'string' (v) then
        missing(context, 'text', v, tostring(v))
      end
      return tostring(v)
    end,
    mine = function(_, v) return can_be 'string'(v) end,
    what = 'text',
  }

  local function fontkeyname(key)
    assert(key.fontable)
    return stringf('%s FONT', key.name)
  end

  function vfactory:key(name, props, v)
    local key = { name = name, validator = v }
    for k, v in pairs(props) do key[k] = v end
    if props.insensitive then
      assert(name == name:lower(), 'case-insensitive key is not all lowercase')
    end
    return key
  end

  function vfactory:any_key(v)  -- XXX unused validator
    return { any = true, name = '*', validator = v } -- gross hack, but it should work
  end

  function vfactory:table(keys)
    local required, optional, other = { }, { }, false
    local seen = { }
    for _, key in ipairs(keys) do
      if key.name then
        if seen[key.name] then
          errorf('Duplicate keys %q in validation spec', key.name)
        else
          seen[key.name] = true
        end
      end
      if key.fontable then
        table.insert(optional, fontkeyname(key))
      end
      if key.any then
        other = key.validator or true
      elseif key.optional then
        table.insert(optional, key.name)
      else
        table.insert(required, key.name)
      end
    end

    local also
    local wanted =
      #required > 0 and stringf('a table with %s %s', plural(#required, 'key'), commafy(sq(required)))
                     or 'a table without any required keys'
    if #optional > 0 then
      also = stringf('%s %s', plural(#optional, 'key'), commafy(sq(optional)))
    end
    if other and not also then
      if #required > 0 then
        wanted = stringf('%s, and possibly other keys', wanted)
      else
        wanted = stringf('%s but allowing any key you wish to include', wanted)
      end
    elseif other and also then
      if #required > 0 then
        wanted = stringf('%s, plus optionally %s, and possibly other keys', wanted, also)
      else
        wanted = stringf('a table with optional %s, plus any other key you wish to include', also)
      end
    elseif also then
      local conjunction = #required > 0 and 'and also' or 'but'
      wanted = stringf('%s %s optionally %s', wanted, conjunction, also)
    end

    local acceptable, insensitive
    if not other then
      acceptable, insensitive = { }, { }
      for _, k in ipairs(keys) do
        acceptable[k.name] = true
        if k.fontable then
          acceptable[fontkeyname(k)] = true
        end
        if k.insensitive then
          insensitive[k.name] = true
        end
      end
    end

    local function has_key(v, required_only)
      return any(function(key)
                   if not key.insensitive then
                     return v[key.name] ~= nil and not (key.optional and required_only)
                   else
                     local low = key.name:lower()
                     for h in pairs(v) do
                       if type(h) == 'string' and h:lower() == low then
                         return true
                       end
                     end
                   end
                 end,
                 keys)
    end

    local function validate_font(context, s)
      if type(s) ~= 'string' or not s:find [[^\]] then
        verrorf(context, 'expected a LaTeX font command but did not find one in %q', s)
      end
    end

    local maybe_my_key = #required > 0 and has_key or other and next or function() end

    return {
      what = wanted,
      mine = function(_, v) return type(v) == 'table' and has_key(v, true) end,
      maybe_mine = function(_, v) return type(v) == 'table' and maybe_my_key(v) end,
      validate = function(_, context, v)
        if type(v) ~= 'table' then
          missing(context, wanted, v, nothing)
          return { } -- will not have the required keys, but is better than just v
        else
          local validated = { }
          local myname = v.name or v.NAME
          assert(ctx.is(context))
          local mycontext =
               myname and type(myname) == 'string' and
                      context + stringf('%q, which is %s', myname, context:long())
               or context
          assert(ctx.is(mycontext))
          local omitted = { }
          for _, key in ipairs(keys) do
            if key.fontable and v[fontkeyname(key)] then
              validate_font(mycontext + { key = fontkeyname(key) }, v[fontkeyname(key)])
              validated[fontkeyname(key)] = true
            end
            local validator = key.validator or text
            if key.any then
              -- validator  is run below
            elseif v[key.name] == nil and not key.optional then
              table.insert(omitted, sq(key.name))
              v[key.name] =
                without_verrorf(function() validator:validate(mycontext+{key=key.name}, nil) end)
            elseif v[key.name] ~= nil then
              assert(ctx.is(mycontext))
              local u = validator:validate(mycontext + { key = key.name }, v[key.name])
              validated[key.name] = true
              if u ~= nil then
                v[key.name] = u
              end
            end
          end
          if #omitted > 0 then
            verrorf(mycontext, 'required %s %s %s missing', plural(#omitted, 'key'),
                    commafy(omitted), #omitted == 1 and 'is' or 'are')
          end

          local sanitized = tcopy(v)
          if type(other) ~= 'boolean' then
            -- other is permitted
            for k, field in pairs(v) do
              if type(k) ~= 'string' then
                verrorf(mycontext, 'table has a non-string key %s', friendly(k))
                sanitized[k] = nil
              elseif not validated[k] and not validated[k:lower()] then
                sanitized[k] =
                  non_nil_or(other:validate(mycontext + { key = k }, field), sanitized[k])
              end
            end
            return sanitized
          elseif not other then
            local unexpected = { }
            for k in pairs(v) do
              if not (acceptable[k] or type(k) == 'string' and insensitive[k:lower()]) then
                table.insert(unexpected, type(k) == 'string' and sq(k) or tostring(k))
                sanitized[k] = nil
              end
            end
            if #unexpected > 0 then
              verrorf(mycontext, 'found and removed unexpected %s %s',
                      plural(#unexpected, 'key'), commafy(unexpected))
            end
            return sanitized
          end
        end
      end,
    }
  end

  function vfactory:string()
    return text
  end

  function vfactory:boolean()
    return {
      what = 'a Boolean',
      mine = function(_, v) return can_be 'boolean' (v) end,
      validate = function(_, context, v)
        if not can_be 'boolean' (v) then
          missing(context, 'a Boolean', v, false)
        end
      end,
    }
  end

  function vfactory:empty()
    return {
      what = 'something empty',
      mine = function(_, v) return empty(v) or isnull(v) end,
      validate = function(self, context, v)
        if not self:mine(v) then
          missing(context, 'something empty', v, '')
          return ''
        end
      end,
    }
  end

  function vfactory:list(element)
    return {
      what = stringf('a list of (%s)', element.what),
      mine = function(_, v) return type(v) == 'table' and (v[1] ~= nil or next(v) == nil) end,
      validate = function(self, context, v)
        if not self:mine(v) then
          missing(context, 'a list', v, nothing)
          return { }
        else
          for i, e in ipairs(v) do
            v[i] = non_nil_or(element:validate(context + { index = i }, e), e)
          end
        end
      end,
    }
  end

  function vfactory:named(name, validator)
    name = vnames[name] or name
    return {
      mine = function(_, v) return validator:mine(v) end,
      what = #validator.what > 30 and a(name) or stringf('%s, which is %s', name, validator.what),
      validate = function(_, context, v)
        if #context:long() > 30 then
          context = context + name
        else
          context = context + stringf('%s, which is %s', a(name), context:long())
        end
        return validator:validate(context, v)
      end,
    }
  end

  function vfactory:any()
    return { mine = function() return true end,
             what = 'anything',
             validate = function() end,
    }
  end

  function vfactory:null()
    return
      { mine = function(_, v) return isnull(v) end,
        what = 'YAML null',
        validate = function(_, context, v)
          if not isnull(v) then
            verrorf(context, 'expected YAML null but found %s', friendly(v))
          end
        end,
      }
  end

  function vfactory:alts(alts)
    local whatnames = { }
    for _, alt in ipairs(alts) do
      table.insert(whatnames, alt.what)
    end
    whatnames = commafy(whatnames, 'or')

    return { mine = function(_, v) return any(function(alt) return alt:mine(v) end, alts) end,
             what = whatnames,
             validate = function(_, context, v)
               assert(#alts > 1)
               for _, alt in ipairs(alts) do
                 if alt:mine(v) then
                   return alt:validate(context, v)
                 end
               end
               for _, alt in ipairs(alts) do
                 if alt.maybe_mine and alt:maybe_mine(v) then
                   return alt:validate(context, v)
                 end
               end
               local substitute =
                 without_verrorf(function() return alts[1]:validate(context, v) end)
               -- or maybe just the first? XXX
               local any = #alts == 2 and 'either' or 'any'
               verrorf(context, "expected %s, but I didn't find %s of those things.  " ..
                       "I found %s and substituted %s.",
                       whatnames, any, friendly(v), friendly(substitute))
               return substitute
             end,
    }
  end

  function vfactory:validate(f, validator)
    return {
      mine = function(_, v) return validator:mine(v) end,
      what = stringf('%s validated by function %s', validator.what, f),
      validate = function(_, context, v)
        local bad = false
        local outer_verrorf = verrorf  -- whatever's actually in effect right now
        local function setbad(...)
          bad = true
          return outer_verrorf(...)  -- forward instead of discarding (was silently dropped)
        end
        local function go() return validator:validate(context, v) end
        local u = non_nil_or(with_verrorf(setbad, go), v)
        if bad then
          return u
        else
          local vf = assert(validators[f], 'No validation function named ' .. f)
          return non_nil_or(vf(context, u), u)
        end
      end,
    }
  end

  return setmetatable({ validators = validators, names = vnames }, {__index = vfactory})


end

function M.validate(context, validation, semantics, sheet)
  return non_nil_or(M.parse(semantics, validation):validate(context, sheet), sheet)
end


return thismodule()
