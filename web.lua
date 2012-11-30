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

--local os = require "os"

function webcallback ( fd )
  command=fd:read("*line")
  first, _ = command:find(" ")
  subsystem = command:sub(1, first-1)
  sendcommand = command:sub(first+1, -1)
  pubsub:publish("SIGNAL", {subsystem=subsystem, command=sendcommand})
end  ----------  end of function webcallback  ----------

nixio.fs.mkfifo("/tmp/myfifo","700")

fifo = assert(io.open("/tmp/myfifo","r+"))

addpoller(fifo, nixio.poll_flags("in"), webcallback)
