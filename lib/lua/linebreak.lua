-- updated for Lua 5.2

local function eprintf(...) return io.stderr:write(string.format(...)) end
require 'tabutil'

local io = io -- debug

local table, string, math
    = table, string, math

local assert, ipairs
    = assert, ipairs

local linebreak = { }

local __doc = { }

linebreak.__doc = __doc

local inf = 1/0
-- NOTE: real problem -- using inf is fine for typical paragraphs,
-- but it's making it nearly impossible to set narrow paragraphs
-- for dot.    If I *don't* use 'inf', however, then
-- breaking regular paragraphs goes quadtratic.

local linepenalty = 10

local function demerits(badness, penalty)
  penalty = penalty or 0
  if penalty < -10000 then
    return (linepenalty + badness)^2
  elseif penalty < 0 then
    return (linepenalty + badness)^2 - penalty^2
  elseif penalty < 10000 then
    return (linepenalty + badness)^2 + penalty^2
  else
    return inf -- (linepenalty + badness)^2 + 11000^2 -- inf does not work
  end
end
    
-- in the middle of a line, last word in a sentence is followed by an extra space
local function extend_midwords(midwords)
  for i = 1, #midwords-1 do
    local w, next = midwords[i], midwords[i+1]
    if w:find '[%.%?%!]"?$' and w:len() > 2 and next:find '^%u' then
      midwords[i] = w .. ' '
    end
  end
  return midwords
end

__doc.run = [[function(s, width, parms) returns string list
Where 's' is the input, 'width' is the number of columns,
and 'parms' can contain these fields:

  stretch    -- spaces to go under target
  shrink     -- spaces to go over target
  hangindent -- hanging indentation
  hangafter  -- line after which to indent
]]

function linebreak.run(s, width, parms)
  width = width or 78
  parms = parms or { }
  parms.stretch = parms.stretch or 5  -- spaces under
  parms.shrink  = parms.shrink or 2   -- spaces over
  parms.hangindent = parms.hangindent or 0
  parms.hangafter = parms.hangafter or math.huge
  local openpenalty = parms.openpenalty or 400

  local words = { }
  for w in s:gmatch '%S+' do table.insert(words, w) end
  local midwords    = extend_midwords(table.copy(words))
  local lastlengths = table.map(string.len, words) 
  local midlengths  = table.map(string.len, midwords) 

  local breaks = { } -- for each i: cost, lines before, prev to break after i
  breaks[0] = { demerits = 0, prev = nil, before = 0 }
  
  local ptab = { ['.'] = -400, [';'] = -200, [','] = -100, [')'] = -100 }
  ptab['?'] = ptab['.']
  ptab['!'] = ptab['.']

  local function penalty(i)
    local p = ptab[words[i]:sub(-1)] or 0
    if p == 0 and words[i+1] and words[i+1]:find '^%(' then
      p = openpenalty
    end
  end

  local function linebad(lo, hi, width) 
       -- break after word hi with word lo the last word on the previous line
    assert(hi > lo)
    local len = hi - lo - 1 -- number of spaces
    for i = lo + 1, hi do
      len = len + midlengths[i]
    end
    len = len + lastlengths[hi] - midlengths[hi]
    local badness
    local stretch = hi == #words and inf or parms.stretch
    if len <= width then
      badness = 100 * ((width - len)/stretch)^3
    elseif len > width + parms.shrink then
      badness = inf -- 10000 -- infinity does not work here for dot, but
                             -- anything less makes line-breaking quadratic
    else
      badness = 100 * ((len - width)/parms.shrink)^3
    end
    return badness
  end

--eprintf('Breaking %d words\n', #words)

  for hi = 1, #words do
    local mindem = inf
    local prev = 0
    local minbefore = 0
    for lo = hi-1, 0, -1 do
      local before = breaks[lo].before
      local w = parms.hangafter <= before and width - parms.hangindent or width
--io.stderr:write('Before = ', before, ' width = ', w, '\n')
      local badness = linebad(lo, hi, w)
      if #words[hi] > w then
        badness = math.min(badness, 100000)
      end
      if badness < inf then
        local dem = demerits(badness, penalty(hi)) + breaks[lo].demerits
        if dem < mindem then
          mindem = dem
          prev = lo
          minbefore = before
        end
      else
        break
      end
    end
    breaks[hi] = { demerits = mindem, prev = prev, before = minbefore + 1 }
    --eprintf('Break after %s (%d) preceded by %s (%d) with %g demerits\n',
    --        words[hi] or '???', hi, words[prev] or '<start>', prev,
    --        breaks[hi].demerits)
  end
  
  local lines = { }
  local last = #words
  
  while last > 0 do
    midwords[last], words[last] = words[last], midwords[last] -- temporary swap
    table.insert(lines, 1, table.concat(midwords, ' ', breaks[last].prev+1, last))
    midwords[last], words[last] = words[last], midwords[last] -- undo swap
    --eprintf('%d-%d: %s\n', breaks[last].prev or -1, last, lines[1])
    last = breaks[last].prev
  end
  if parms.hangindent > 0 then
    indent = string.rep(' ', parms.hangindent)
    for i = 1, #lines do
      if i > parms.hangafter then
        lines[i] = indent .. lines[i]
      end
    end
  end
--eprintf('RESULT %d lines\n', #lines)
  return lines
end


__doc.run_multi = [[function(s, width, params) returns string
Flows text with `run` using the paremters given on each 
paragraph within string s.  Paragraphs are separated by blank lines.
]]

function linebreak.run_multi(s, width, params)
  local opts = { hangafter = 0, hangindent = 2 }
  paragraphs = {}
  for _, paragraph in ipairs(s:split_fields '\n[ \t]*\n+') do
    local lines = linebreak.run(paragraph, width, params)
    table.insert(paragraphs, table.concat(lines, '\n'))
  end
  return table.concat(paragraphs, '\n\n')
end

linebreak.run_para = linebreak.run_multi -- legacy

return linebreak


