-- @module coap_node.lua
-- @author António, P. P. Almeida <appa@perusio.net>.
-- @date   Jun 23 2016
--
-- @brief Implements a sensor node using CoAP. Both a server and a client.
--

local function check_module(modname, module)
  if type(module) ~= 'romtable' then
    print(string.format('%s module is missing.', modname))
    return nil
  end
end

-- Check if the CoAP module is available.
check_module('CoAP', coap)
-- Check CJSON module is available.
check_module('CJSON', cjson)

-- Local definitions.
local coap = coap
local cjson = cjson
local find = string.find
local format = string.format
local upper = string.upper
local print = print
local setmetatable = setmetable

-- Avoid polluting the global environment.
-- If we are in Lua 5.1 this function exists.
if _G.setfenv then
  setfenv(1, {})
else -- Lua 5.2.
  _ENV = nil
end

-- @table: the module table.
local M  = {
  _VERSION = '0.1',
  _NAME = 'coap_node',
  _DESCRIPTION = 'An implementation of a CoAP sensor node',
  _DEBUG = false, -- no debugging by default
  _PORT = 5683, -- CoAP default port
  _REQ_TYPE = coap.CON, -- by default use a confirmable request
  _METHOD = 'GET', -- default METHOD
  _SECURE = false -- default is normal CoAP (coap scheme in URLs)
  _CONTENT_TYPE = coap.JSON -- default Content Type for server
  _COPYRIGHT = [[
                  Copyright (c) António P. P. Almeida <appa@perusio.net>,
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

local mt = { __index = M }


-- Allowed CoAP methods.
local allowed_methods = '/GET/POST/PUT/DELETE/'

local function check_request_type(req_type)
  -- Currently only CONfirmable and NONconfirmable messages are
  -- supported.
  return coap.CON == req_type or coap.NON == req_type
end

local function check_method(method)
  return find(allowed_methods, format('/%s/', upper(method))) ~= nil
end

local function get_url(address, port, is_secure)
  return format('%s://%s:%s', is_secure and 'coaps' or 'coap', address, port)
end


local function check_address(address)
  -- Is either an IPv4 IP address or a domain address.
  return find('%d+.%d+.%d+.%d+', address) ~= nil or find('[%a.-_]', address) ~= nil
end


function M.req(self, address, port, req_type, is_secure, payload)

  -- Set the client settings.
  local client = {
    -- Check the request type.
    req_t = req_type and check_request_type(req_type) or M._CONN,
    -- Check the port number.
    p = port and type(port) == 'number' or M._PORT,
    -- Check the address.
    addr = address and check_address(address),
  }

  -- Instantiate the client.
  client.cc = coap.Client()
  return setmetatable(client, mt)

end
