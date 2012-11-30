--
--------------------------------------------------------------------------------
--         FILE:  callbacks.lua
--        USAGE:  ./callbacks.lua 
--  DESCRIPTION:  Library of callbacks
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Jimmy Hedman (), <jimmy.hedman@gmail.com>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-11-30 12:53:46 CET
--     REVISION:  ---
--------------------------------------------------------------------------------
--

function parsedata ( data  )
    for s,c in pairs(data) do
      if type(s) == "string" then
        print(s,c)
      end
    end
end  ----------  end of function parsedata  ----------

pubsub:subscribe("SENSOR", parsedata)

pubsub:subscribe("TIME", function(data) if (data.sec==0) then print(os.date("%c",os.time(data))) end end)

