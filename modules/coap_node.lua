-- @module coap_node.lua
-- @author António, P. P. Almeida <appa@perusio.net>.
-- @date   Jun 23 2016
--
-- @brief Implements a sensor node using CoAP. Both a server and a client.
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

-- Local definitions.
local coap = coap
local find = string.find
local format = string.format
local upper = string.upper
local lower = string.lower
local print = print
local setmetatable = setmetatable
local type = type

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
  _SECURE_PORT = 5684, -- CoAP + DTLS (coaps) default port number
  _REQ_TYPE = coap.CON, -- by default use a confirmable request
  _METHOD = 'GET', -- default METHOD
  _SECURE = false, -- default is normal CoAP (coap scheme in URLs)
  _ADDRESS = '127.0.0.1', -- localhost as the default address
  _CONTENT_TYPE = coap.JSON, -- default Content Type for server
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

local mt = { __index = M }

-- Allowed CoAP methods.
local allowed_methods ={
  client = '/GET/POST/PUT/DELETE/', -- for client
  server = '/GET/POST/', -- for server
}

--- Checks the request type. Only CONfirmable or NON-confirmable
--  requests are allowed.
--
-- @param req_type number request type: CONfirmable or NON-confirmable.
-- @return boolean
--   true if request is CONfirmable or NON-confirmable.
--   false otherwise.
local function check_request_type(req_type)
  -- Currently only CONfirmable and NONconfirmable messages are
  -- supported.
  return coap.CON == req_type or coap.NON == req_type
end

--- Checks the CoAP method for the client
--
-- @param method string CoAP method name.
-- @param allowed string allowed methods as a string.
--
-- @return boolean
--   true if method is allowed, false if not.
local function check_method(method, allowed)
  return find(format('/%s/', upper(method)), allowed) ~= nil
end

--- Builds a CoAP URL.
--
-- @param address string IPv4 address or a domain name.
-- @param port number port for the server to be queried.
-- @param is_secure boolean true if scheme is coaps (CoAP + DTLS).
-- @return string
--   The URL.
local function get_url(address, port, uri, is_secure)
  return format('%s://%s:%s%s',
                is_secure and 'coaps' or 'coap',
                address, port, uri)
end

--- Checks if the address given is admissible. Either an
--  IPv4 or a domain name.
--
-- @param address string IPv4 address or domain name.
-- @return string or false
--    string if address is valid. false if not.
local function check_address(address)
  -- Is either an IPv4 IP address or a domain address.
  return
    find(address, '%d+%.%d+%.%d+%.%d+') ~= nil
    or
    find(address, '[%a%.%-_]') ~= nil
    and address
end

--- Instantiates a CoAP client.
--
-- @param self table client object.
-- @param params table client parameters.
--
-- @return table
--   The CoAP client object.
function M.new_client(self, params)
  -- The client settings.
  local client = {
    -- Check the request type.
    req_type = M._REQ_TYPE,
    -- Check the port number.
    port = M._PORT,
    -- Check the address.
    address = M._ADDRESS,
    -- No coaps by default.
    is_secure = M._SECURE,
  }
  -- Loop over all parameters.
  if params and type(params) == 'table' then
    for key, value in pairs(params) do
      if params[key] ~= nil then
        client[key] = params[key]
      end
    end
  end
  -- Instantiate the client.
  client.c = coap.Client()
  return setmetatable(client, mt)
end

--- Makes a CoAP request to a given URI.
--
-- @param self table client object.
-- @param uri string URI to request.
-- @param method string CoAP method.
-- @param payload string The payload in serialized form (POST + PUT).
--
-- @return string
--   Response (serialized).
function M.request(self, uri, method, payload)
  -- Check the method.
  local client_method = method
    and check_method(method, allowed_methods.client)
    or M._METHOD

  -- Perform the request.
  return self.c[lower(client_method)](self.c,
                                      self.req_type,
                                      get_url(self.address,
                                              self.port,
                                              uri,
                                              self.is_secure),
                                      payload)
end

--- Instantiates a CoAP server.
--
-- @param self table server object.
-- @param port number port number.
-- @param is_secure boolean true if the scheme is coaps.
-- @return table
--   The server object.
function M.new_server(self, port, is_secure)

  local server = {
    -- Check the port number.
    p = port and type(port) == 'number' or (is_secure and M._SECURE_PORT or M._PORT),
  }
  -- Instantiate the server.
  server.s = coap.Server()
  server.s:listen(server.p)
  return setmetatable(server, mt)
end

-- Return the module table.
return M
