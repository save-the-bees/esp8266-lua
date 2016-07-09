# Lua code for the ESP8266 running as a CoAP node (client+server)

## Introduction

This is the Lua code to run the ESP8266 as a CoAP node, i.e., as both
a client and a server.

## Implementation notes

We have lofty goals regarding the Lua implementation. Some of the
ideas are described
[here](https://github.com/save-the-bees/plans/blob/master/esp8266_sensor_nodes.md).

The current code is just a placeholder for that. It runs a very basic
CoAP server that provides temperature sensing data from a
[DS18B20](https://www.maximintegrated.com/en/products/analog/sensors-and-sensor-interface/DS18B20.html). 

Check the
[instructions](https://github.com/relayr/ESP8266_Lua/blob/master/README.md#building-sensor-nodes-using-coap)
on how to get started.

## TODO

The real implementation along the lines of the above mentioned plans.

## License

 Copyright (C) 2016 relayr GmbH, António P. P. Almeida <appa@perusio.net> 

 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation 
 the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the 
 Software is furnished to do so, subject to the following conditions: 

 The above copyright notice and this permission notice shall be included in 
 all copies or substantial portions of the Software. 

 Except as contained in this notice, the name(s) of the above copyright 
 holders shall not be used in advertising or otherwise to promote the sale, 
 use or other dealings in this Software without prior written authorization. 

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL 
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 DEALINGS IN THE SOFTWARE.
