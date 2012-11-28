--
--------------------------------------------------------------------------------
--         FILE:  pubsub.lua
--        USAGE:  ./pubsub.lua 
--  DESCRIPTION:  Pubsub engine
--      OPTIONS:  ---
-- REQUIREMENTS:  ---
--         BUGS:  ---
--        NOTES:  ---
--       AUTHOR:  Jimmy Hedman (), <jimmy.hedman@gmail.com>
--      COMPANY:  
--      VERSION:  1.0
--      CREATED:  2012-10-21 08:48:49 CEST
--     REVISION:  ---
--------------------------------------------------------------------------------
--

Pubsub = {}

--- @class Pubsub
-- A simple pubsub engine
-- It uses four types of signals (SENSOR, WEB, TIME and SIGNAL)
-- SENSOR is for sensor data like thermometers
-- WEB is signal from web cgi socket
-- TIME is for all types of time messages like day/night or daytime clock
-- SIGNAL is the opposit of SENSOR, information to send out

function Pubsub:new(o)
  self.signals = { 'SENSOR', 'WEB', 'TIME', 'SIGNAL' }
  self.message = {}
  for k,v in ipairs(self.signals) do
    self.message[v] = {}
  end

  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end  ----------  end of function Pubsub:new  ----------

function Pubsub:publish(signal, ...)
  for k, v in ipairs(self.message[signal]) do
    v(...)
  end
	return self
end  ----------  end of function Pubsub:publish  ----------

function Pubsub:subscribe (signal, event)
  table.insert(self.message[signal], event)
	return true
end  ----------  end of function Pubsub:subscribe----------
