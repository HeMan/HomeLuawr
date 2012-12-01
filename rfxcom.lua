--
--------------------------------------------------------------------------------
--         FILE:  read.lua
--        USAGE:  ./read.lua 
--  DESCRIPTION:  Read data from rfxcom
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:   (), <>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-05-22 21:58:56 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

local parse = require "parse"
local encode = require "encode"
local nixio = require "nixio"
local os = require "os"
require "common"

local function flush (ttyn)
  while not ttyn:read(0) do
    ttyn:read(1)
  end
  return 0
end  ----------  end of function flush  ----------

tty = assert(nixio.open("/dev/ttyUSB0","r+"))

--nixio.nanosleep(5,0)
print("reseting")
-- reset the rfxcom
encode.Protocol:reset()
nixio.nanosleep(1,500000000)

-- flush inputs
flush(tty)

-- get info on status
encode.Protocol:get_status()

-- enable all senders
encode.Protocol:enable_all()

function rfxcallback ( fd )
  len = string.byte(fd:read(1))
  if (len < 4) then
    flush(fd)
  else
    print("read len "..len)
    local data = ''
    while (string.len(data) < len) do
      data = data..fd:read(len - string.len(data))
    end
    realdata = parse.parse(data)
    if realdata then
      pubsub:publish("SENSOR", realdata)
    end
  end  ----------  end of function rfxcallback  ----------
end

addpoller(tty, nixio.poll_flags("in"), rfxcallback)

function command ( signal )
  if type(signal)=="table" then
    if signal.subsystem=="rfxcom" then
      local env = encode
      env.tty = tty
      env.print = print
      if signal.command:byte(1) == 27 then return nil, "binary bytecode prohibited" end
      local untrusted_function, message = loadstring(signal.command)
      if not untrusted_function then return nil, message end
      setfenv(untrusted_function, env)
      print( pcall(untrusted_function))
    end
  end
end  ----------  end of function command  ----------

pubsub:subscribe("SIGNAL", command)

