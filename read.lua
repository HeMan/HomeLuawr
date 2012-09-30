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

tty = assert(nixio.open(arg[1],"r+"))

print("reseting")
tty:write(encode.reset())
nixio.nanosleep(0,500000000)

while not tty:read(0) do
	tty:read(1)
end

tty:write(encode.get_status())

tty:write(encode.enable_all())
tty:write(encode.enable_undecoded())

local ttypoll = {
	{ fd=tty, events=nixio.poll_flags("in") }
}

repeat
	repeat
		print("polling")
		local stat, code = nixio.poll(ttypoll, 10000)
	until stat and stat > 0

	len = tty:read(1)
	print("read len "..string.byte(len))
	data = tty:read(string.byte(len))

	realdata=parse.parse(data)
	if realdata then
		for s,c in pairs(realdata) do
			print(s,c)
		end
	else
		print("Unimplemented 0x"..string.format("%x",string.byte(data:sub(1,1))))
	end
until false
