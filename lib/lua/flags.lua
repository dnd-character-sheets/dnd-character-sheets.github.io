local flags = { }

local assert, ipairs, pairs, table, tonumber, string, setmetatable
    = assert, ipairs, pairs, table, tonumber, string, setmetatable

local unpack = table.unpack or unpack -- luacheck: ignore 143
local error, type, require, select, next
    = error, type, require, select, next

local math, os
    = math, os

local tablex = require 'tablex'
local stringx = require 'stringx'
require 'stringutil' -- add methods

local require = require

local stderr = io.stderr

-- protected arg
local base0 = arg and arg[0]:gsub('^.*/', '') or 'lua'

-- debugging --
local stringf = string.format
local function eprintf(...) return io.stderr:write(string.format(...)) end
local function errorf(...) return error(string.format(...)) end

local io = io



local __doc = { }
flags.__doc = __doc

__doc.__overview = [[
A parser understands *options* and *fields*:

  - An *option* is something that appears on the command line.

  - A *field* is something that is set in a data structure.

These often have the same names, but they need not.

Base methods 'bool', 'bool_or_no', 'string', and 'number' use the
field name as an option.  So do the file methods.

Method 'enum' does not use the field name as an option.

Methods may take 'fieldnames' as an argument.  This is a string
of a form like

  summary as s as summ

which gives the main field name (which is also an option) plus additional
aliases for that field (which are only options and do not appear in the field
table).

Moreover, when a field name is converted to an option, every underscore
becomes a dash.

Options containing only digits are parsed as strings *unless* the 'digits'
method is used, in which case they are parsed as numbers.

]]

__doc.__order = { 'parser', 'parse', 'help',
                  'string', 'number', 'digits',
                  'enum', 'bool', 'boolnot', 'bool_or_no',
                  'input_file', 'output_file',
                  'string_list', 'number_list', 'input_file_list', 'output_file_list',
                  'onerror', 'onerror_exit',
                  'minarg', 'maxarg',
}


local function fieldname(s)
  return s:gsub(' as .*', ''):gsub('%-', '_')
end

local function optnames(s)
  return s:gsub('%_', '-'):split_fields('%s+as%s+')
end

local digits_option_name = '<digits>'

--[[
Internal representation of parser

  _option   : { optname |--> function }
  _help     : { optname |--> string   }
  _help_arg : { optname |--> string option }  -- argument ID as shown in help
  _default  : { fieldname |--> value }
  _listfields : { fieldname |--> bool }  --- set of fields
  _mandated : { fieldname |--> bool } --- set of fields
  _onerror  : function (parser, string or bool, fields, args) -> value
  _aliases  : { optname |-> optname list } --
  _minarg   : number option      -- minimum permissible number of arguments
  _maxarg   : number option      -- maximum permissible number of arguments
  _usage_extra : string list     -- stuff to show after a usage message
  _usage_post : string list      -- stuff to show after options
  _lastoption : string option    -- name of last option set (used for help)
  _use_digits : bool             -- string of digits parses as number [default not]
]]

__doc.aliases = [[function(string) returns string list
Returns list of aliases for fields
]]

local methods = { }

function methods:setopts(options, f, arghelp)
  self._aliases[options[1]] = { select(2, unpack(options)) }
  self._lastoption = options[1]
  for _, option in ipairs(options) do
    if self._option[option] then
      error('Duplicate specification for option ' .. option)
    else
      self._option[option] = f
      self._help[option] = self._help[option] or false
      if arghelp then
        if self._help_arg[option] then
          error('Duplicate argument help for option ' .. option)
        else
          self._help_arg[option] = arghelp
        end
      end
    end
  end
  return self
end

function methods:setdefault(field, v)
  if v ~= nil then
    if self._default[field] ~= nil then
      error('Duplicate default specification for field ' .. field)
    else
      self._default[field] = v
    end
  end
  return self
end

__doc.help = [[method parser:help(fieldname, helptext) returns self
Associate help text with the given field.
]]

function methods:help(f, text)
  if text == nil then
    f, text = self._lastoption, f
  end
  assert(f and text, 'Help field for ' .. (f or 'nil') .. ' is missing fieldname or text')
  -- XXX need to track options of field
  for _, option in ipairs(optnames(f)) do
    if not self._help[option] then
      self._help[option] = text
    else
      errorf('Duplicate help text for option -%s', option)
    end
  end
  return self
end

__doc.mandated = [[method parser:mandated([fieldname], [boolean]) returns self
The given field is mandatory.  Or if boolean is false, not mandatory!
If fields omitted, use the last field defined.  If boolean is omitted,
use true.
]]

function methods:mandated(f, b)
  if b == nil and type(f) == 'boolean' then
    f, b = nil, f
  end
  if b == nil then b = true end
  self._mandated[assert(f or self._lastoption, 'nothing to mandate')] = b
  return self
end

__doc.bool_or_no = [[method parser:bool_or_no(fieldnames, [default]) returns self
Define setting option(s) as given by field name, and also
clearing options beginning with 'no'.
]]

function methods:bool_or_no(f, default)
  local field = fieldname(f)
  local options = optnames(f)
  local thisopt = options[1]
  self:setdefault(field, default or false)
  self:setopts(options, function(values, _, _) values[field] = true end)
  for i = 1, #options do options[i] = 'no' .. options[i] end
  self:setopts(options, function(values, _, _) values[field] = false end)
  self._lastoption = thisopt
  return self
end

__doc.bool = [[method parser:bool(fieldnames, [default]) returns self
Define setting option(s) as given by field name.
]]

function methods:bool(f, default)
  local field = fieldname(f)
  self:setdefault(field, default or false)
  self:setopts(optnames(f), function(values, _, _) values[field] = true end)
  return self
end

__doc.boolnot = [[method parser:boolnot(fieldnames, [default]) returns self
Define clearing option(s) as given by field name.
]]

function methods:boolnot(f, default)
  local field = fieldname(f)
  self:setopts(optnames(f), function(values, _, _) values[field] = false end)
  self:setdefault(field, default or false)
  return self
end

__doc.enum = [[method parser:enum(fieldname, option list, default) returns self
Add a field to the given parser whose value is one of the options
listed.  Each option sets the field to the name of that option.
An enum option may include aliases (as in the normal specification
for a field name). An enum field name may not include aliases.
]]

function methods:enum(f, options, default)
  local field = fieldname(f)
  local opts = optnames(f)
  if #opts ~= 1 then
    errorf([[Enumeration '%s' may not specify options]])
  else
    self:setdefault(field, default)
    for _, option in ipairs(options) do
      local optval = fieldname(option)
      self:setopts(optnames(option), function(values, _, _) values[field] = optval end)
    end
    self._lastoption = nil -- can't abbreviate help here
    return self
  end
end

local function with_arg(addvalue, arghelp, convert, errmsg)
  return function(self, f, default)
    local field = fieldname(f)
    self:setopts(optnames(f),
                 function(values, option, args)
                   if args[1] ~= nil then
                     local v, msg = convert(args[1])
                     if v then
                       table.remove(args, 1)
                       addvalue(values, field, v)
                     else
                       errorf(errmsg, option, msg)
                     end
                   else
                     errorf(errmsg, option, 'argument not provided')
                   end
                 end,
                 arghelp)
    self:setdefault(field, default)
    return self
  end
end
local function setfield(t, k, v) t[k] = v end
local function addfield(t, k, v) table.insert(t[k], v) end

local function dual_methods(name, arghelp, convert, errmsg, doctext)
  methods[name] = with_arg(setfield, arghelp, convert, errmsg)
  local listm   = with_arg(addfield, arghelp, convert, errmsg)
  methods[name .. "_list"] =
    function(self, f, ...)
      self._listfields[fieldname(f)] = true
      return listm(self, f, ...)
    end
  __doc[name] = __doc[name] or stringf([[method parser:%s(fieldnames, [default]) returns self
%s
]], name, doctext)
  __doc[name .. '_list'] = stringf([[method parser:%s_list(fieldnames, [defalut]) returns self
Field is a list of %s and the option adds to the list.]], name, name)
end

local function readable(path)
  local f, msg = io.open(path, 'r')
  if f then
    f:close()
    return true
  else
    return false, msg
  end
end


local function as_readable_file(path)
  if readable(path) then
    return path
  else
    errorf([['%s' is not a readable file]], path)
  end
end

__doc.digits = [[method parser:digits(fieldname, [default]) returns self
Define what field is set by an option matching Lua pattern %-%d+
]]

function methods:digits(f, default)
  local field = fieldname(f)
  self._use_digits = true
  self:setdefault(field, default or false)
  assert(#optnames(f) == 1, 'digits option cannot have alternate names')
  self:setopts({assert(digits_option_name)},
               function(fields, option, _) fields[field] = assert(tonumber(option)) end)
  return self
end




dual_methods('string', '<string>', function(s) return s end,
             'Option -%s expects a string argument',
             'Define an option that expects a string argument')
dual_methods('number', '<number>', tonumber, 'Option -%s expects a numeric argument',
             'Define an option that expects a numeric argument')

dual_methods('input_file', '<filename>', as_readable_file,
             'Option -%s expects the name of a readable file',
             'Define an option that expects as argument the name of a readable file')

dual_methods('output_file', '<filename>', function(s) return s end, -- as_nonfile,
             'Option -%s expects the name of a file to be written',
             'Define an option that expects as argument the name of a file to be written.')

__doc.onerror = [[
method parser:onerror([function]) returns parser
If a flag-parsing error occurs, the result is the result of calling
the given function with four arguments:
  - The current parser
  - A string or boolean giving the nature of the error
  - the current 'fields' table
  - the unconsumed 'args' table
The 'nature' of the error is 'true' if the option -? is passed,
and a string error message otherwise.

If no function is given, a function is installed that returns nil
followed by its arguments.   This function is suitable if the goal
is to handle parsing errors in the caller.
]]

function methods:onerror(f)
  assert(self._onerror)
  f = f or function(...) return nil, ... end
  assert(type(f) == 'function')
  self._onerror = f
  return self
end


__doc.onerror_exit = [=[
method parser:onerror_exit([[optsring,] argstring]) returns parser
Modifies the parser so that when an error occurs, the parser prints
an error message and a usage message and exits.  In the usage message,
the optional argstring describes the arguments; optstring describes
the options.  Defaults are respectively 'ARG' and 'OPT'.
]=]

function methods:onerror_exit(optstring, argstring)
  local function fail(parser, msg)
    if msg ~= true then
      stderr:write(base0, ': ', msg, '\n')
    end
    flags.usage(parser, optstring, argstring)
    os.exit(1)
  end
  return self:onerror(fail)
end

__doc.usage_opt_arg = [=[method parser:usage_opt_arg([[optsring,] argstring]) returns parser
Gives the default options and arg for usage message.
]=]

methods.usage_opt_arg = methods.onerror_exit



__doc.apply = [[
method parser:apply(field[, option], function) returns parser
When value for option is received, pass it through the
given function, which returns value or nil, error, and
put the value in the given field.  If omitted, option is assumed to equal field.
]]

function methods:apply(field, options, f)
  if f == nil then
    options, f = field, options
  end
  assert(type(f) == 'function', 'non-function passed to parser:apply(...)')
  for _, option in ipairs(optnames(options)) do
    local oldfun = self._option[option]
    if not oldfun then
      errorf('option %s has to be defined before an apply function can be added',
             option)
    else
      self._option[option] =
        function(values, ...)
          oldfun(values, ...)
          local v, msg = f(values[field])
          if v == nil then
            error(msg)
          else
            values[field] = v
          end
        end
    end
  end
  return self
end

__doc.onoption = [[
method parser:onoption(field, option, function) returns parser
When the given option is parsed, apply the given function
to its value.
]]

function methods:onoption(field, option, f)
  if f == nil then
    option, f = field, option
  end
  return self:apply(field, option, function(s) f(s); return s end)
end



__doc.maxarg = [[
method parser:maxarg(number) returns parser
Give the maximum permissible number of arguments after option parsing.
]]

__doc.minarg = [[
method parser:minarg(number) returns parser
Give the minimum permissible number of arguments after option parsing.
]]

__doc.numarg = [[
method parser:numarg(number) returns parser
Give the exact require number of arguments after option parsing.
]]

function methods:maxarg(n)
  assert(type(n) == 'number', 'argument to maxarg() must be a number')
  self._maxarg = n
  return self
end

function methods:minarg(n)
  assert(type(n) == 'number', 'argument to minarg() must be a number')
  self._minarg = n
  return self
end

function methods:numarg(n)
  assert(type(n) == 'number', 'argument to numarg() must be a number')
  self._maxarg = n
  self._minarg = n
  return self
end


__doc.wrap = [[
method parser:wrap(f) returns f(parser)
(Typically used to call methods conditionally.)
]]

function methods:wrap(f)
  return f(self)
end



__doc.parser = [[function () returns parser
Return a fresh, empty parser that can be modified by adding
fields/options and help text, then used to parse options.
By default, it exits on error.
]]

function flags.parser()
  local t =
    { _option = {}, _help = {}, _help_arg = {}, _default = {}, _listfields = {},
      _aliases = {}, _usage_extra = {}, _transformers = {}, _usage_post = {},
      _onerror = 'replace via a method call', _mandated = {},
    }
  return setmetatable(t, { __index = methods }):onerror_exit()
end


__doc.parse = [[method parser:parse(arg list) returns field table or (nil, error)
Parses the command line parameters and returns two tables:

  fields : fieldname |--> value
  error  : bool or string

Options and their arguments are removed from input argument list.

If the -? option is used, the 'error' result is `true`.
If an error occurs, the 'error' result contains a string message.
In either of these cases, the 'fields' result is nil.

Finally, an argument of '--' terminates option parsing.
]]
local helpopts = { ['-h'] = true, ['-help'] = true, ['--help'] = true }
function methods:is_help(option)
  return option == '-?' or self._option[option] == nil and helpopts[option]
end

function methods:parse(args)
  assert(args, [[flags module didn't get its args]])
  local fields = { __self = self }
  for k, v in pairs(self._default) do
    fields[k] = v
  end
  for k in pairs(self._listfields) do
    fields[k] = { }
  end

  while args[1] and args[1]:find '^%-' do
    if args[1] == '--' then
      table.remove(args, 1)
      break
    elseif self:is_help(args[1]) then
      return self:_onerror(true, fields, args)
    else
      local option = table.remove(args, 1):sub(2)
      local f = self._option[self._use_digits and option:find '^%d+$' and digits_option_name or option]
      if not f then
        return self:_onerror(stringf('Unknown option -%s', option), fields, args)
      else
--        local ok, msg = pcall (f, fields, option, args)
        local ok, msg = true, f(fields, option, args)
        if not ok then
          return self:_onerror(msg, fields, args)
        end
      end
    end
  end
  for f in pairs(self._mandated) do
    if fields[f] == nil then
      return self:_onerror(stringf('the -%s option must be given', f))
    end
  end

  if self._minarg or self._maxarg then
    if self._maxarg == 0 and #args > 0 then
      return self:_onerror(stringf('this script does not take any arguments; got %d',
                                   #args))
    elseif self._minarg == self._maxarg then
      if #args ~= self._minarg then
        return self:_onerror(stringf('Expected %d argument%s; got %d',
                                     self._minarg, self._minarg == 1 and '' or 's',
                                     #args))
      end
    elseif self._minarg and #args < self._minarg then
      return self:_onerror(stringf('Expected at least %d argument%s; got %d',
                                     self._minarg, self._minarg == 1 and '' or 's',
                                     #args))
    elseif self._maxarg and #args > self._maxarg then
      return self:_onerror(stringf('Expected at most %d argument%s; got %d',
                                     self._maxarg, self._maxarg == 1 and '' or 's',
                                     #args))
    end
  end

  return fields
end


__doc._test = [[function() -- run test cases]]

function flags._test()
  local p = flags.parser()
  p    :bool_or_no('dot')
       :help('dot', 'emit a dot file on standard output')
       :enum('dotratio', { 'fill', 'compress' }, 'compress')
       :help('dotratio', 'select ratio of dot output')
       :string('dotratio as ratio')
       :number('dotnodefontsize as nodefontsize', 9)
       :bool_or_no('template')
       :bool_or_no('keep_less_defined as lessdef', false)
       :bool_or_no('make_anon as anon')
       :help('anon', [[anonymize students' identities]])
       :bool_or_no('implications as imp')
       :enum('dotpaper', { 'landscape', 'portrait' }, false)
       :help('dotpaper', 'orient dot output')
       :enum('papersize', { 'usletter', 'a4' })
       :output_file('fault-list')
       :string('witness_file as witnesses as update-witnesses')
       :help('witness_file', 'file holding info about witnesses (to write or update)')
       :bool('use_witness as use-witnesses as uw')
       :help('use_witness', [[use the student's actual witness, not an 'explanation']])
       :bool_or_no('faults')
       :help('faults', 'emit a faults file')
       :input_file('utln_faults as utln as of-faults')
       :help('utln_faults', 'faults file to read to use when emitting utln')
       :bool('uniq_faults as uniq')
       :help('uniq_faults', '???')
       :bool('notsubmitted as nosubmit')
       :help('notsubmitted', 'become the set of IDs that did not submit a solution?')
       :string_list('showreps as rep') -- appends to list
       :help('showreps', 'show a representative of these tests')
       :bool('write_rep_outcomes as filter')
       :help('write_rep_outcomes', 'copy representative outcomes to stdout')
       :string('subset_matching as subset', false)
       :help('subset', 'pattern used to select outcomes')
       :number('txtest'):transform('txtest', 'txtest', function(n) return n + 1 end)
  local function test(s)
    local args = s:split_fields()
    return args, p:parse(args)
  end
  local _, f, _ = test '-txtest 99 -a4 -dot -anon -rep a -rep b -subset Welch -ratio 8,10 my-outcomes'
  assert(f.dot)
  assert(f.make_anon)
  assert(#f.showreps == 2)
  assert(f.txtest == 100)
  local a, f, _ = test '-noanon -filter -nodot my-outcomes'
  assert(f.dot == false and #f.showreps == 0 and #a == 1)
  flags.write_helps(io.stderr, p)
end

----------------------------------------------------------------


__doc.usage = [=[function(parser, [string, [string]]) prints to stderr
Prints a usage message that includes a one-line synopsis and
a list of options.  The synopsis always includes `arg[0]`, but
the rest of it is determined by the arguments passed in:

  - If two strings are passed, the first describes options and the
    second describes positional parameters.

  - If only one string is passed in, it describes positional parameters,
    and the default documentation of options is used.

  - If no strings are passed, the default descriptions of both options
    and positional parameters are used.

The defaults for options and for positional parameters are respectively
the strings 'OPT' and 'ARG'.
]=]

local function has_helps(parser)
  return next(parser._aliases)
end

local columns = tonumber(os.getenv 'COLUMNS') or 80

do
  local defaults = { OPT = '[options]', ARG = '...' }
  for _, field in ipairs { 'usage', 'onerror_exit' } do
    __doc[field] = __doc[field]:gsub('%U%U%U+', defaults)
  end

  function flags.usage(parser, options, args)
--    stderr:write('options == ', tostring(options), '; args == ', tostring(args), '\n')
    if options == nil then
      return flags.usage(parser, defaults.OPT, defaults.ARG)
    elseif args == nil then
      return flags.usage(parser, defaults.OPT, options)
    else
      eprintf('Usage: %s%s%s%s%s\n',
              base0,
              #options > 0 and ' ' or '', options,
              #args > 0 and ' ' or '', args)
      for _, u in ipairs(parser._usage_extra) do
        if u:find '\n' or #u < columns - 3 then
          eprintf('  %s\n', u)
        else
          eprintf('  I SHOULD RUN LINE BREAKING ON THIS:\n  %s\n', u)
        end
      end
      if has_helps(parser) then
        eprintf('Where the following options are defined:\n')
        flags.write_helps(stderr, '  ', parser)
      end
      if parser._usage_post[1] then
        eprintf '\n'
        for _, u in ipairs(parser._usage_post) do
          if u:find '\n' or #u < columns - 3 then
            eprintf('%s\n', u)
          else
            eprintf('I SHOULD RUN LINE BREAKING ON THIS:\n  %s\n', u)
          end
        end
      end
    end
  end
end

__doc.usage_extra = [[method parser:usage_extra(string) returns parser
Add the string to the parser's default usage message.
]]

function methods:usage_extra(s)
  assert(type(s) == 'string', 'usage_extra method expects string')
  for line in s:gmatch('[^\n]*') do
    table.insert(self._usage_extra, line)
  end
  return self
end

__doc.usage_post = [[method parser:usage_post(string) returns parser
Add the string to the parser's usage message to follow the options.
]]

function methods:usage_post(s)
  assert(type(s) == 'string', 'usage_post method expects string')
  require 'stringutil'
  if s:find '%S' and s:sub(-1, -1) ~= "\n" then
    s = s .. "\n"
  end
  for line in s:gmatch '([^\n]*)\n' do
    table.insert(self._usage_post, line)
  end
  return self
end


__doc.write_helps = [[function(file, [prefix], parser) writes to file
Write parser's options to file, each line preceded by prefix, if any.
]]

function flags.write_helps(file, pfx, parser)
  if parser == nil then
    pfx, parser = '', pfx
  end

  local helps = parser._help
  local arghelps = parser._help_arg
  local width = 0
  for flag in pairs(parser._aliases) do
    local w = #flag
    if arghelps[flag] then
      w = w + #arghelps[flag] + 1
    end
    width = math.max(width, w)
  end
  local fmt = stringf('-%%-%ds   ', width)
  local prefix = string.rep(' ', width+4)
  local hw = columns - 2 - #prefix - #pfx  -- width of a help line
  local linebreak = require 'linebreak'
  for _, flag in ipairs(tablex.sorted_keys(parser._aliases)) do
    local fstring = arghelps[flag] and stringf('%s %s', flag, arghelps[flag]) or flag
    local aliases = parser._aliases[flag]
    local also = ''
    if aliases[1] then
      local as =
        stringx.commafy(tablex.map(function(s) return '-' .. s end, aliases), 'or')
      also = stringf(' (also written %s)', as)
    end
    local helplines = linebreak.run((helps[flag] or '[undocumented]') .. also, hw)
    for i, line in ipairs(helplines) do
      file:write(pfx, i == 1 and stringf(fmt, fstring) or prefix, line, '\n')
    end
  end
end


return flags
