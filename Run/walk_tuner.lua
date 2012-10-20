dofile('include.lua')

----------------------------------------------------------------------
-- Walk Tuner
----------------------------------------------------------------------

require('unix')
require('util')
require('Body')
require('walk')
require('getch')
require('curses')
require('Config')
require('Motion')
require('Locomotion')

local walk_config_file = arg[1]
  or '../Config/Motion/Config_'..Config.platform.name..'_Walk.lua'

local parameter_keys = {}
local parameter_increments = {}
for k,v in pairs(walk.parameters) do
  parameter_keys[#parameter_keys + 1] = k
  parameter_increments[#parameter_increments + 1] =
    Config.walk.increments[k] or 0.001
end

local TIMEOUT = 1
local NCOLS = 1
local NROWS = #parameter_keys
local ROW_WIDTH = 1
local COL_WIDTH = 14
local COL_OFFSET = 30
local ROW_OFFSET = 4
local COL_PARAM = 1
local ROW_CMD = NROWS + 2

local row = 1
local col = 1

-- Commands
----------------------------------------------------------------------

function cmd_set_value(arg)
  local varg = parse_double_arguments(arg)
  if varg[1] then
    set_value(varg[1], row, col)
  end
  draw_screen()
end

function cmd_increment_value(scale)
  val = get_value(row, col)
  if val then
    val = val + scale*get_increment(row, col)  
    set_value(val, row, col)
  end
  draw_col(COL_PARAM)
end

function cmd_start_walking()
  walk:set_velocity(0, 0, 0)
  walk:start()
  draw_command_row('Walk Mode: press <space> to stop...')
end

function cmd_stop_walking()
  walk:set_velocity(0, 0, 0)
  walk:stop()
  draw_command_row('                                      ')
end

function cmd_set_velocity(vx, vy, va)
  walk:set_velocity(vx, vy, va)
  draw_stats()
end

function cmd_increment_velocity(dvx, dvy, dva)
  walk:set_velocity(unpack(walk:get_velocity() + vector.new{dvx, dvy, dva}))
  draw_stats()
end

function cmd_save(arg)
  local varg = parse_string_arguments(arg)
  walk_config_file = varg[1] or walk_config_file
  local f = assert(io.open(walk_config_file,'w+'))
  f:write('module(..., package.seeall)\n\n')
  f:write('-- this config file was automatically ')
  f:write('generated by the walk_tuner utility\n\n')
  f:write(Config.platform.walk..' = {}\n\n')
  f:write(Config.platform.walk..'.parameters = {\n')
  for i = 1,#parameter_keys do
    f:write(string.format('  %s = %f,\n', parameter_keys[i],
      walk.parameters[parameter_keys[i]]))
  end
  f:write('}\n\n')
  f:write(Config.platform.walk..'.increments = {\n')
  for i = 1,#parameter_keys do
    f:write(string.format('  %s = %f,\n', parameter_keys[i],
      parameter_increments[i]))
  end
  f:write('}\n\n')
  f:close()
end

function cmd_quit()
  exit()
  os.exit()
end

function cmd_help()
  curses.timeout(-1)
  curses.clear()
  curses.move(0, 0)
  curses.printw('------------------------------------------------ Navigation\n')
  curses.printw('save                  write current parameter to file\n')
  curses.printw('q                     quit\n')
  curses.printw('h                     help\n')
  curses.printw('------------------------------------------------ Editing\n')
  curses.printw('set [value]           set value under cursor\n')
  curses.printw('------------------------------------------------ Walking\n')
  curses.printw('space                 start/stop walking\n')
  curses.printw('i                     forward\n')
  curses.printw(',                     back\n')
  curses.printw('j                     turn left\n')
  curses.printw('l                     turn right\n')
  curses.printw('h                     side left\n')
  curses.printw(';                     side right\n')
  curses.printw('k                     zero velocity\n')
  curses.printw('press any key to continue...')
  curses.getch()
  curses.clear()
  draw_screen()
  curses.timeout(TIMEOUT)
end

local commands = {
  ['save'] = cmd_save,
  ['h'] = cmd_help,
  ['help'] = cmd_help,
  ['q'] = cmd_quit,
  ['quit'] = cmd_quit,
  ['exit'] = cmd_quit,
  ['set'] = cmd_set_value,
}

-- Access
---------------------------------------------------------------------

function get_value(r, c)
  if (c == COL_PARAM) then
    return walk.parameters[parameter_keys[r]]
  end
end

function set_value(val, r, c)
  if (c == COL_PARAM) then
    walk.parameters[parameter_keys[r]] = val
  end
end

function get_increment(r, c)
  return parameter_increments[r]
end

-- Display
----------------------------------------------------------------------

function draw_command_row(str)
  local cursory = get_cursor(ROW_CMD, 0)
  curses.move(cursory, 0)
  curses.printw(':%80s', ' ')
  curses.move(cursory, 2)
  curses.printw(str)
  curses.refresh()
end

function draw_col(c)
  for r = 1,NROWS do
    curses.move(get_cursor(r, c))
    val = get_value(r, c)
    if val then
      curses.printw('[%10.4f]', val)
    else
      curses.printw('[----------]')
    end
  end
  curses.move(get_cursor(row, col))
  curses.refresh()
end

function draw_stats()
  local x, y = get_cursor(NROWS, COL_PARAM + 1)
  curses.move(x, y)
  curses.printw('velocity :%7.4f %7.4f %7.4f', unpack(walk:get_velocity()))
  curses.move(get_cursor(row, col))
  curses.refresh()
end

function draw_screen()
  curses.clear()
  curses.move(0, 0)
  curses.printw('                                Walk Tuner\n')
  curses.printw('///////////////////////////////////////')
  curses.printw('//////////////////////////////////////\n')
  curses.printw('%-28s %12s \n', 'parameter', 'value')
  curses.printw('---------------------------------------')
  curses.printw('--------------------------------------\n')
  for i = 1,NROWS do
    curses.printw('%2d', i)
    curses.printw(' %25s\n', parameter_keys[i])
  end
  for c = 1,NCOLS do
    draw_col(c)
  end
  draw_stats()
  curses.refresh()
  curses.move(get_cursor(row, col))
end

-- Parsing
-----------------------------------------------------------------

function parse_int_arguments(arg)
  local varg = {}
  for int in arg:gmatch('[ ,](%-?%d+)') do
    varg[#varg + 1] = tonumber(int)
  end
  return varg
end

function parse_double_arguments(arg)
  local varg = {}
  for double in arg:gmatch('[ ,](%-?%d*%.?%d+e?-?%d*)') do
    varg[#varg + 1] = tonumber(double)
  end
  return varg
end

function parse_string_arguments(arg)
  local varg = {}
  for token in arg:gmatch('[ ,](%a[%a_%d]*)') do
    varg[#varg + 1] = token 
  end
  return varg
end

function read_command(key)
  -- clear prompt
  draw_command_row('')
  -- get command string
  curses.echo()
  curses.timeout(-1)
  local str = curses.getstr()
  curses.timeout(TIMEOUT)
  curses.noecho()
  -- call command
  local cmd, arg = str:match('^([%a_]+)(.*)$')
  if commands[cmd] then
    commands[cmd](arg)
  elseif cmd then
    draw_command_row('Invalid command')
  end
  -- restore cursor 
  curses.move(get_cursor(row, col))
end

-- Navigation
----------------------------------------------------------------------

function get_cursor(r, c)
  local y = ROW_OFFSET + (r-1)*ROW_WIDTH
  local x = COL_OFFSET + (c-1)*COL_WIDTH
  return y, x 
end

function cursor_right()
  col = math.min(col + 1, COL_PARAM)
  curses.move(get_cursor(row, col))
end

function cursor_left()
  col = math.max(col - 1, COL_PARAM)
  curses.move(get_cursor(row, col))
end

function cursor_up()
  row = math.max(row - 1, 1)
  curses.move(get_cursor(row, col))
end

function cursor_down()
  row = math.min(row + 1, NROWS)
  curses.move(get_cursor(row, col))
end

-- Main
------------------------------------------------------------------

function entry()
  -- setup curses environment
  curses.initscr()
  curses.cbreak()
  curses.noecho()
  curses.keypad(1)
  curses.timeout(TIMEOUT)
  draw_screen()
  -- initialize shared memory
  unix.usleep(5e5)
  draw_screen()
  -- initialize motion engine
  Body.entry()
  Motion.add_fsm(Locomotion)
  Locomotion:add_event('walk')
end

function update()
  -- handle keystrokes
  local key = curses.getch()
  if key == string.byte('-') then
    cmd_increment_value(-0.1)
  elseif key == string.byte('=') then
    cmd_increment_value(0.1)
  elseif key == string.byte('_') then
    cmd_increment_value(-0.5)
  elseif key == string.byte('+') then
    cmd_increment_value(0.5)
  elseif key == string.byte('[') then
    cmd_increment_value(-1)
  elseif key == string.byte(']') then
    cmd_increment_value(1)
  elseif key == string.byte('{') then
    cmd_increment_value(-10)
  elseif key == string.byte('}') then
    cmd_increment_value(10)
  elseif key == curses.KEY_UP then
    cursor_up()
  elseif key == curses.KEY_DOWN then
    cursor_down()
  elseif key == curses.KEY_LEFT then
    cursor_left()
  elseif key == curses.KEY_RIGHT then
    cursor_right()
  elseif key == string.byte(' ') then
    if walk:is_active() then
      cmd_stop_walking()
    else
      cmd_start_walking()
    end
  elseif key and not walk:is_active() then
    curses.ungetch(key)
    read_command()
  elseif key == string.byte('k') then
    cmd_set_velocity(0, 0, 0)
  elseif key == string.byte('i') then
    cmd_increment_velocity(0.005, 0, 0)
  elseif key == string.byte(',') then
    cmd_increment_velocity(-0.005, 0, 0)
  elseif key == string.byte('j') then
    cmd_increment_velocity(0, 0, 0.005)
  elseif key == string.byte('l') then
    cmd_increment_velocity(0, 0, -0.005)
  elseif key == string.byte('h') then
    cmd_increment_velocity(0, 0.005, 0)
  elseif key == string.byte(';') then
    cmd_increment_velocity(0, -0.005, 0)
  end
  Body.update()
  Motion.update()
end

function exit()
  curses.endwin()
  Motion.exit()
  Body.exit()
end

local count = 0

entry()
while true do
  update()
  count = count + 1
  if (count % 5 == 0) then
    draw_stats()
  end
end
exit()
