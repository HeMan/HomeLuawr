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

function Pubsub:new(o)
--  print("new")
  self.signals = { 'SENSOR', 'WEB', 'TIME', 'SIGNAL' }
  self.message = {}
  self.message[self.signals[1]] = {}
  self.message[self.signals[2]] = {}
  self.message[self.signals[3]] = {}

  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end  ----------  end of function Pubsub:new  ----------

function Pubsub:publish(signal, ...)
--  print("publish "..signal)
  for k, v in ipairs(self.message[signal]) do
--    print(signal, type(v))
    v(...)
  end
	return self
end  ----------  end of function Pubsub:publish  ----------

function Pubsub:subscribe (signal, event)
--  print("subscribe "..signal)
--  print(type(event))
  table.insert(self.message[signal], event)
	return true
end  ----------  end of function Pubsub:subscribe----------
