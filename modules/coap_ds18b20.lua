-- @module coap_ds18b20.lua
-- @author António, P. P. Almeida <appa@perusio.net>.
-- @date   Jul 7 2016
--
-- @brief Implements a simple CoAP service for reading the ds18b20.
--

--- Check if an NodeMCU SDK Lua module is available.
--
-- @param modname string module name
-- @param module table module
--
-- @return void or nil
--   If module isn's available return nil.
local function check_module(modname, module)
  if type(module) ~= 'romtable' then
    print(string.format('%s module is missing.', modname))
    return nil
  end
end

-- Check if the CoAP module is available.
check_module('CoAP', coap)
-- Check if the CJSON module is available.
check_module('CJSON', cjson)

-- Load the DS18B20 module.
local ds = require 'ds18b20'
-- Load the CoAP node module.
local coapn = require 'coap_node'
-- Load the configuration.
local config = require 'config'

-- Local definitions.
local cjson = cjson
local coap = coap
local format = string.format
local tmr = tmr
local setmetatable = setmetatable
local print = print

-- @table: the module table.
local M = {
  _VERSION = '0.2',
  _NAME = 'coap_ds18b20',
  _DESCRIPTION = 'Implements a simple CoAP server for DS18B20 sensor data',
  _CONTENT_TYPE = coap.JSON, -- default content type
  _DEBUG = false, -- no debugging by default
  _DS18B20_PIN = 5, -- GPIO pin for the DS18B20
  _COPYRIGHT = [[
                  Copyright 2016 (c) António P. P. Almeida <appa@perusio.net>,
                  relayr GmbH

                  Permission is hereby granted, free of charge, to any person
                  obtaining a copy of this software and associated documentation
                  files (the "Software"), to deal in the Software without
                  restriction, including without limitation the rights to use,
                  copy, modify, merge, publish, distribute, sublicense, and/or sell
                  copies of the Software, and to permit persons to whom the
                  Software is furnished to do so, subject to the following
                  conditions:

                  The above copyright notice and this permission notice shall be
                  included in all copies or substantial portions of the Software.
                  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                  OTHER DEALINGS IN THE SOFTWARE. ]],
}

-- Digital I/O pin to use for sending data from the DS18B20 sensor.
local ds18b20_pin = config.app.ds18b20_pin or M._DS18B20_PIN
-- Setup the sensor.
ds.setup(ds18b20_pin)

--- Wrapper for sending data from the DS18B20 sensor
--- to the relayr cloud.
--
-- @return tabĺe
--   The table with meaning and value.
local function ds18b20_data_source()
  -- Get the temperature in Celsius.
  return {
    meaning = 'temperature',
    value = ds.read()
  }
end

-- Instantiate a new CoAP server object.
local cs = coapn:new_server()
-- Get the variable and the 'pure' server instance.
local s = cs.s
-- Invoke the 'var' CoAP server method. Note that 't' *must* be a
-- global variable, otherwise the CoAP server doesn't work.
s:var('t', config.app.coap_content_type or M._CONTENT_TYPE)

--- Implements a simple CoAP service that sets the value of a
--- global variable in the 'var' method of the CoAP module.
--
-- @param callback function that sources the data to make available.
--
-- @return nothing
--   Side effects only.
local function simple_coap_service(callback)
  -- Set the value of the variable.
  t = cjson.encode(callback())
  -- Print debugging info.
  if M._DEBUG then
    print(format('data : %s', t))
  end
end

-- Return the module table.
return setmetatable(M,
                    {
                      __call = function(_, idx, period)
                        return
                          tmr.alarm(
                            idx, -- timer index (0 to 6)
                            period, -- reading updating period
                            tmr.ALARM_AUTO, -- run in a loop
                            function () -- callback that gets invoked
                              simple_coap_service(ds18b20_data_source)
                          end)
end })
