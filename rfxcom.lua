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

nixio.nanosleep(5,0)
print("reseting")
-- reset the rfxcom
tty:write(encode.reset())
nixio.nanosleep(0,500000000)

-- flush inputs
flush(tty)

-- get info on status
tty:write(encode.get_status())

-- enable all senders
tty:write(encode.enable_all())
tty:write(encode.enable_undecoded())

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
    pubsub:publish("SENSOR", data)
  end  ----------  end of function rfxcallback  ----------
end

table.insert(poll, { fd=tty, events=nixio.poll_flags("in"), callback=rfxcallback })

function parsedata ( data  )
    realdata=parse.parse(data)
    if realdata then
      for s,c in pairs(realdata) do
        print(s,c)
      end
    else
      print("Unimplemented 0x"..string.format("%x",string.byte(data:sub(1,1))))
    end
end  ----------  end of function parsedata  ----------

pubsub:subscribe("SENSOR", parsedata)

