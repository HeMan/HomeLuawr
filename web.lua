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
  print(command)
  local env = { 
                on  = function(id) pubsub:publish("SIGNAL",{ "on", id}) end,
                off = function(id) pubsub:publish("SIGNAL",{ "off", id}) end,
              }
  if command:byte(1) == 27 then return nil, "binary bytecode prohibited" end
  local untrusted_function, message = loadstring(command)
  if not untrusted_function then return nil, message end
  setfenv(untrusted_function, env)
  return pcall(untrusted_function)
end  ----------  end of function webcallback  ----------

nixio.fs.mkfifo("/tmp/myfifo","700")

fifo = assert(io.open("/tmp/myfifo","r+"))

addpoller(fifo, nixio.poll_flags("in"), webcallback)

--pubsub:subscribe("WEB", )

