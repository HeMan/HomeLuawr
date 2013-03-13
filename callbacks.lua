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

function tempwrite ( data )
  if data.id == 40192 then
    local fil = io.open("/www/rfxcom/ut.html","w")
    fil:write(data.temp)
    fil:close()
  end
	return true
end  ----------  end of function tempwrite  ----------

function temprrd ( data )
  if data.id == 40192 then
    io.popen("/usb/usr/bin/rrdupdate /usb/proj/data/temperature.rrd N:"..data.temp)
  end
	return true
end  ----------  end of function temprrd  ----------


function tempcosm ( data )
  if data.id == 40192 then
    io.popen("curl --silent --request PUT --data-binary '{ \"version\":\"1.0.0\", \"datastreams\":[{\"id\":\"Utetemp\", \"current_value\":\""..data.temp.."\"}]}' --header \"X-ApiKey: 9422WoQJ_ntMtDznZ0aVyi-KA0mSAKxOZlV6QUxIUHYyUT0g\" -o /dev/null http://api.cosm.com/v2/feeds/91433")
  end
	return true
end  ----------  end of function tempcosm  ----------

function tempsense ( data )
  if data.id == 40192 then
    io.popen("curl --silent --request POST -H \"sense_key: 2oGGutVpxpSQMEEl-jILOg\" -H \"Content-Type: application/json\" --data-binary '{\"feed_id\": 22946, \"value\": \""..data.temp.."\"}' http://api.sen.se/events/")
  end
	return true
end  ----------  end of function tempsense  ----------
pubsub:subscribe("SENSOR", parsedata)
pubsub:subscribe("SENSOR", tempwrite)
pubsub:subscribe("SENSOR", temprrd)
pubsub:subscribe("SENSOR", tempcosm)
pubsub:subscribe("SENSOR", tempsense)

pubsub:subscribe("TIME", function(data) if (data.sec==0) then print(os.date("%c",os.time(data))) end end)

