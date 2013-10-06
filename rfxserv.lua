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

local nixio = require "nixio"
local mqtt = require "mqtt_library"

local parse = require "rfxcom.parse"
local encode = require "rfxcom.encode"
require "rfxcom.common"

function mqcallback(topic, payload)
    print("mqtt callback " .. topic .. ": " .. payload)
end

local function flush (ttyn)
  while not ttyn:read(0) do
    ttyn:read(1)
  end
  return 0
end  ----------  end of function flush  ----------


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
      if (realdata.id) then
        for s,c in pairs(realdata) do
          if (type(s) == "string") and not (s == "id") then
              mqtt_client:publish("home/sensors/"..realdata.id.."/"..s,c)
          end -- if (type)
        end -- for s,c
      else -- if (realdata.id)
        for k,v in pairs(realdata) do
          if not (type(k) == "number") then print(k, v) end
        end -- for k,v
      end -- if(realdata.id)
    end -- if (realdata)
  end -- if (len)
end  ----------  end of function rfxcallback  ----------

local function flush (ttyn)
  while not ttyn:read(0) do
    ttyn:read(1)
  end
  return 0
end  ----------  end of function flush  ----------

mqtt_client = mqtt.client.create("localhost","1883", mqcallback)
mqtt_client:connect("rfxserv")

mqtt_client:subscribe({"home/#"})

tty = assert(nixio.open("/dev/ttyUSB0","r+"))

local poll = { { fd=tty, events=nixio.poll_flags("in") } }

print("reseting")
-- reset the rfxcom
encode.Protocol:reset()
nixio.nanosleep(1,500000000)

-- flush inputs
flush(tty)

-- get info on status
encode.Protocol:get_status()

-- enable all senders
encode.Protocol:enable_some(msg3.Viking, 0, msg5.OregonScientific + msg5.AC + msg5.ARC )

--addpoller(tty, nixio.poll_flags("in"), rfxcallback)

repeat
  repeat
    stat, code = nixio.poll(poll, 1000)
    mqtt_client:handler()
  until stat and stat > 0
  rfxcallback(tty)
until false
