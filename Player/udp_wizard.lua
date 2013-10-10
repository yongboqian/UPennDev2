--SJ: listen from udp message
--with format "ArmFsm", 'init'
--And send it to arm_ch ipc channel
-----------------------------

dofile'include.lua'
local mp   = require'msgpack'
local util = require'util'
local vector = require'vector'
local simple_ipc = require'simple_ipc'

-- TODO: Use the Config file for the ports
local udp = require'udp'
local rpc_zmq = simple_ipc.new_replier(Config.net.reliable_rpc,'*')
local rpc_udp = udp.new_receiver( Config.net.unreliable_rpc )

-- TODO: Require all necessary modules
require'vcm'
require'jcm'
require'mcm'
require'hcm'

-- Require all necessary fsm channels
local fsm_channels = {}

--[[
for _,sm in ipairs(Config.fsm.enabled) do
  fsm_channels[sm] = simple_ipc.new_publisher(sm,true)
end
--]]

--Now we are using arm_ch, body_ch, etc.
local listing = unix.readdir(HOME..'/Player')
-- Add all FSM directories that are in Player
local fsm_ch_vars = {}
for _,sm in ipairs(listing) do
  local found = sm:find'FSM'
  if found then
    -- make GameFSM to game_ch
    local name = sm:sub(1,found-1):lower()..'_ch'
    table.insert(fsm_ch_vars,name)
    -- Put into the global space
    fsm_channels[name] = simple_ipc.new_publisher(sm,true)
--    print("channel found:",name)    
  end
end

--NOTE: Can do memory AND fsm event.  In that order
local function process_rpc(rpc)
  -- for debugging
  util.ptable(rpc) 

  local status, reply
  -- Shared memory modification
  local shm = rpc.shm
  if shm then
    local mem = _G[shm]
    if type(mem)~='table' then return'Invalid memory' end
    if rpc.val then
      -- Set memory
      local method = string.format('set_%s_%s',rpc.segment,rpc.key)
      local func = mem[method]
      -- Use a protected call
      status, reply = pcall(func,rpc.val)
    elseif rpc.delta then
      -- Increment/Decrement memory
      local method = string.format('_%s_%s',rpc.segment,rpc.key)
      local func = mem['get'..method]
      status, cur = pcall(func)
      func = mem['set'..method]
      local up = vector.new(cur)+vector.new(rpc.delta)
      status, reply = pcall(func,up)
    else
      -- Get memory
      local method = string.format('get_%s_%s',rpc.segment,rpc.key)
      local func = mem[method]
      -- Use a protected call
      status, reply = pcall(func)
    end
  end -- if shm

  -- State machine events
  local fsm = rpc.fsm
   if fsm then print("HERE",fsm) end
  if fsm and type(rpc.evt)=='string' then
    --Matlab msg is "ArmFSM" format
    --should change it to arm_ch

    --local ch = fsm_channels[fsm]
    local fsm_ch_name = fsm
    local found = fsm_ch_name:find'FSM'
    if found then
      -- make GameFSM to game_ch
      fsm_ch_name = fsm_ch_name:sub(1,found-1):lower()..'_ch'
    end
    local ch = fsm_channels[fsm_ch_name]
    --
    if ch then
      if rpc.special then
        ch:send{rpc.evt,rpc.special}
      else
        ch:send(rpc.evt)
      end
    end
    --
  end

  return reply
end

local function process_zmq()
  local request, has_more
  repeat
    request, has_more = rpc_zmq:receive()
    local rpc         = mp.unpack(request)
    local reply       = process_rpc(rpc)
    -- NOTE: The zmq channel is REP/REQ
    -- Reply with the result of the request
    local ret         = rpc_zmq:send( mp.pack(reply) )
  until not has_more
end

local function process_udp()
  while rpc_udp:size()>0 do
    local request = rpc_udp:receive()
    local rpc = mp.unpack(request)
    local reply = process_rpc(rpc)
    --print('Reply',reply)
  end
end

rpc_zmq.callback = process_zmq
local rpc_udp_poll = {}
rpc_udp_poll.socket_handle = rpc_udp:descriptor()
rpc_udp_poll.callback = process_udp
local wait_channels = {rpc_zmq,rpc_udp_poll}
local channel_poll = simple_ipc.wait_on_channels( wait_channels );
channel_poll:start()