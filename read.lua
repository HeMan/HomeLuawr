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

function turnonoff (onoff, id)
  local sendcode = ""
  if (type(id) == "table") then
    if (id.type == LIGHTNING1) then
      sendcode = encode.encode[id.type](id.subtype,id.housecode,id.unitcode,onoff)
    elseif (id.type == LIGHTNING2) then
      sendcode = encode.encode[id.type](id.subtype,id.id,id.unitcode,onoff,0)
    end
    return tty:write(sendcode)
  end
end  ----------  end of function turnonoff  ----------

function sandbox ( untrusted_code )
  local env = { display=print, on=function(id) turnonoff(1, id) end,
              off = function(id) turnonoff(0, id) end }
  if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
  local untrusted_function, message = loadstring(untrusted_code)
  if not untrusted_function then return nil, message end
  setfenv(untrusted_function, env)
  return pcall(untrusted_function)
end  ----------  end of function sandbox  ----------

tty = assert(nixio.open(arg[1],"r+"))

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

nixio.fs.mkfifo("/tmp/myfifo","700")

fifo = assert(io.open("/tmp/myfifo","r+"))

local poll = {
  { fd=tty, events=nixio.poll_flags("in") },
	{ fd=fifo, events=nixio.poll_flags("in") },
}

repeat
  repeat
--    print("polling")
    stat, code = nixio.poll(poll, 10000)
  until stat and stat > 0

	if (poll[1].revents==poll[1].events) then
    len = string.byte(tty:read(1))
    if (len < 4) then
      flush(tty)
    else
      print("read len "..len)
      local data = ''
      while (string.len(data) < len) do
        data = data..tty:read(len - string.len(data))
      end
      realdata=parse.parse(data)
      if realdata then
        for s,c in pairs(realdata) do
          print(s,c)
        end
      else
        print("Unimplemented 0x"..string.format("%x",string.byte(data:sub(1,1))))
      end
    end
	end

	if (poll[2].revents==poll[2].events) then
		command=fifo:read("*line")
		print(command)
		print(sandbox(command))
	end
until false
