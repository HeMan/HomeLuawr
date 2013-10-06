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

local MQTT_SERVER = "localhost"
local MQTT_PORT = 1883

local mqtt = require "mqtt_library"
local nixio = require "nixio"
local rrd = require "rrd"

function outsidetemp(topic, payload)
    print("outsidetemp " .. topic .. ": " .. payload)
    -- data for the web
    local fil = io.open("/proj/data/ut.html","w")
    fil:write(payload)
    fil:close()
    -- rrd graph
    rrd.update("/proj/data/temperature.rrd", "N:"..payload)
    -- post data to cosm
    io.popen("curl --silent --request PUT --data-binary '{ \"version\":\"1.0.0\", \"datastreams\":[{\"id\":\"Utetemp\", \"current_value\":\""..payload.."\"}]}' --header \"X-ApiKey: 9422WoQJ_ntMtDznZ0aVyi-KA0mSAKxOZlV6QUxIUHYyUT0g\" -o /dev/null http://api.cosm.com/v2/feeds/91433")
    -- post data to sen.se
    io.popen("curl --silent --request POST -H \"sense_key: 2oGGutVpxpSQMEEl-jILOg\" -H \"Content-Type: application/json\" --data-binary '{\"feed_id\": 22946, \"value\": \""..payload.."\"}' http://api.sen.se/events/")
end 

local listners = {
    ['outsidetemp'] = {{"home/sensors/33280/temp"}, outsidetemp},
    ['any'] = {{"home/#"}, function(topic, payload) print("any "..topic..": "..payload) end, server="localhost", port="1883",}
}

for k,v in pairs(listners) do
    v.MQTT = mqtt.client.create(v.server or MQTT_SERVER, v.port or MQTT_PORT, v[2])
    v.MQTT:connect(k)
    v.MQTT:subscribe(v[1])
end

while true do
    for k,v in pairs(listners) do 
        v.MQTT:handler()
    end
    nixio.nanosleep(0,500000000)
end
