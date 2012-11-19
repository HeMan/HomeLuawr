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
require "pubsub"
require "common"

poll = { }

function addpoller ( fd, events, callback )
	return table.insert(poll, {fd=fd, events=events, callback=callback})
end  ----------  end of function addpoller  ----------

local modules = { "web", "rfxcom" }
--local modules = { "web" }

pubsub = Pubsub:new()

for _, v in ipairs(modules) do
  dofile(v..".lua")
end

pubsub:subscribe("TIME", function(data) if (data.sec==0) then print(os.date("%c",os.time(data))) end end)
repeat
  repeat
--    print("polling")
    stat, code = nixio.poll(poll, 1000)
    pubsub:publish("TIME", os.date("*t"))
  until stat and stat > 0
  
  for k, v in ipairs(poll) do
    if v.revents == v.events then
      v.callback(v.fd)
    end
  end
until false

