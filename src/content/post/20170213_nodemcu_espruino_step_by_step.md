+++
date        = "2017-02-29T14:47:30Z"
title       = "Espruino on NodeMCU (step-by-step guide)"
tags        = ['iot', 'javascript', 'espruino', 'nodemcu']
topics      = ['IoT']
description = "How to flash NodeMCU with Espruino firmware and basic examples on how to use it."
slug        = "espruino-nodemcu-step-by-step"
author      = "Bladedu"
+++
[SparkFabrik]: http://www.sparkfabrik.com/  "SparkFabrik"

## Introduction
This step-by-step guide is going to help you setting up and use [Espruino](https://www.espruino.com/ "A firmware JavaScript Interpreter for Microcontrollers that runs on a variety of different chipsets") on NodeMCU device.
[NodeMCU](http://www.nodemcu.com/index_en.html) is:
> An open-source firmware and development kit that helps you to prototype your IOT product within a few Lua script lines.

We chosen the NodeMCU because it uses the ESP8266 chip which is one of the most cheap wifi module.

We will first list all tools required to complete this tutorial, then we will flash the NodeMCU with the Espruino firmware (1v91) and at the end we will see how to connect to the wifi and push temp and humidity values over internet
using [dweet.io](https://dweet.io/, "Ridiculously simple messaging (and alerts) for the Internet of Things.")

## Buy all the things!
Everything for this tutorial has been bought on Amazon (fast shipment reason :) )
If you're not in a hurry, you could have a look on Aliexpress.

[NodeMCU](https://www.amazon.it/gp/product/B01GCK3J40/ref=oh_aui_detailpage_o01_s00?ie=UTF8&psc=1)
[DHT11 sensor](https://www.amazon.it/gp/product/B0154JQRPI/ref=oh_aui_detailpage_o01_s00?ie=UTF8&psc=1)

## Prepare the ground
First of all we have to prepare everything that is needed to perform the installation and usage of the espruino.
We would need a tool to copy the firmware into the device, we would need the firmware itself and a IDE that would facilitate us writing and uploading custom code.

#### Utility
The [esptool.py](https://github.com/themadinventor/esptool) is needed to flash the firmware into the device. Just follow the instruction on the github page.

Given that python is already installed on your system, just type
```
pip install esptool
```
Once installed, the executable is available on path (linux)```/usr/local/bin/esptool.py```


For the Board described in this tutorial, CP2102 USB to UART driver is required. This driver is already part of the Linux core and maintained since version 3.x.
The driver for Mac OSX is available [here](https://www.silabs.com/Support%20Documents/Software/Mac_OSX_VCP_Driver.zip).


#### Firmware
Espruino firmware for ESP8266 can either be built from source-code that can be found on [github](https://github.com/tve/Espruino) 
or simply install an already compiled one.
Updates on this firmware are tracked in a forum thread http://forum.espruino.com/conversations/279176/

For those not interested in discussions, just [download the latest firmware version](https://www.espruino.com/Download)
Make sure to use the firmware compatible with ESP8266.

### Flash the espruino firmware
To set NodeMCU to flash mode, keep pressed the "Flash" button while plugging in the device into the USB.

Before we actually upload the new firmware, we have to make sure everything is clean. For that, we first erase the flash on the device by executing: 
```
esptool.py --port /dev/ttyUSB0 erase_flash
```

After that we can upload the Espruino firmware with the following command:
```
esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 32m 0x0000 "boot_v1.6.bin" 0x1000 espruino_esp8266_user1.bin 0x3FC000 esp_init_data_default.bin 0x37E000 blank.bin
```
Note that this command is explained within the README_flash.txt file contained into the downloaded firmware.
The command above might be different according to the ESP board you're using. In my case I'm using an ```esp-12``` board, so I can use up to 4MB of space.
For more info about flash and phisical addresses, please refer to https://www.espruino.com/EspruinoESP8266

Please note that bauds sets are different from those listed on the device.
You should find the same instruction in a README file within the downloaded firmware.

### Espruino IDE
[Espruino Web-IDE plugin for Chrome](https://chrome.google.com/webstore/detail/espruino-web-ide/bleoifhkdalbjfbobjackfdifdneehpo?hl=en) is the easiest tool to use to upload custom code into the NodeMCU.
Once installed, go to settings > communications and update Baud rate to 115200.

Now if you click on the connect button, you should be able to get access to the device.


### Connect to wifi
To gain access to internet from your device, you should first setup the code for the connectivity. An example is the following code:
```javascript
var wifi = require("Wifi");
wifi.connect("<YOUR-SSID-HERE>", {password:"<YOUR-PASSWORD-HERE>"}, function(err){
 console.log("connected? err=", err, "info=", wifi.getIP());
});
wifi.stopAP();
```

You could, optionally, setup a hostname ```wifi.setHostname("Sparkfabrik-espruino");``` to identify your device on your router.
Paste the code into the espruino IDE and click (while connected to nodeMCU) on "Send to Espruino".
Once the wifi works as expected, add ```wifi.save()``` to store the connection logic into the device. This operation will persist during device reset.

Final code would be this:

```javascript
var wifi = require("Wifi");
wifi.setHostname("Sparkfabrik-espruino");
wifi.connect("<YOUR-SSID-HERE>", {password:"<YOUR-PASSWORD-HERE>"}, function(err){
 console.log("connected? err=", err, "info=", wifi.getIP());
});
wifi.stopAP();
wifi.save()
```

Once stored, you can wipe it out of the IDE and start building some useful code.

### Examples
#### Temp and RH data over internet
NodeMCU GPIO label don't match the actual GPIO pin. With Espruino, there is a NodeMCU class that allows an easy mapping between Espruino and NodeMCU pins.
Please refer to the [espruino reference](http://www.espruino.com/Reference#NodeMCU) for it.

![NodeMCU DHT11 connection](/posts/espruino-dht11-min.jpg)

On [_IoT Services_](https://www.espruino.com/IoT+Services) section on Espruino.com there are few examples of how to use external services to push data.

The following code is in charge of pushing data via POST method to dweet.io.

```javascript
function putDweet(dweet_name, a, callback) {
  var data = "";
  for (var n in a) {
    if (data.length) data+="&";
    data += encodeURIComponent(n)+"="+encodeURIComponent(a[n]); 
  }
  var options = {
    host: 'dweet.io',
    port: '80',
    path:'/dweet/for/'+dweet_name+"?"+data,
    method:'POST'
  };
  require("http").request(options, function(res)  {
    var d = "";
    res.on('data', function(data) { d+=data; });
    res.on('close', function(data) {
      if (callback) callback(d);
    });
 }).end();
}
```

Now that we know how to send data over internet, we simply have to read data from the sensor and push it on a service online.

```javascript
pin=NodeMCU.D2;
var dht11 = require("DHT11").connect(pin);
```
Note that the data wire of the DHT11 sensor (yellow cable, usually) is connected to the pin 2 on the NodeMCU.
Required the DHT11 lib and connected it to the pin.

Next we have to pull data at some interval (in my case, every minute) and to push them mover internet.
```javascript
var dht11_read_test = function() {
  dht11.read(
    function(a){
      console.log("Temp is "+a.temp.toString()+ " and RH is "+a.rh.toString());
      var data = {
        temp: a.temp.toString(),
        rh:a.rh.toString()
      };
      putDweet("sparkfabrik-espruino", data, function(response) {
        console.log(response);
      });
     });
};
setInterval(dht11_read_test,60000);
```


Full script is:
```javascript
pin=NodeMCU.D2;
var dht11 = require("DHT11").connect(pin);
var dht11_read_test = function() {
  dht11.read(
    function(a){
      console.log("Temp is "+a.temp.toString()+ " and RH is "+a.rh.toString());
      var data = {
        temp: a.temp.toString(),
        rh:a.rh.toString()
      };
      putDweet("sparkfabrik-espruino", data, function(response) {
        console.log(response);
      });
     });
};
setInterval(dht11_read_test,60000);

function putDweet(dweet_name, a, callback) {
  var data = "";
  for (var n in a) {
    if (data.length) data+="&";
    data += encodeURIComponent(n)+"="+encodeURIComponent(a[n]); 
  }
  var options = {
    host: 'dweet.io',
    port: '80',
    path:'/dweet/for/'+dweet_name+"?"+data,
    method:'POST'
  };
  require("http").request(options, function(res)  {
    var d = "";
    res.on('data', function(data) { d+=data; });
    res.on('close', function(data) {
      if (callback) callback(d);
    });
 }).end();
}

save();
```
## Conclusion
It's very easy to build an IoT device nowadays as hardware for prototyping is becoming very cheap.
NodeMCU is one of those "essential" play-board that is affordable and it is great for fast prototyping.
At the end, for IoT device, what would you expect? A bunch of GPIO and a internet connection.

And what's more cool for a web-developer to code not just software, but hardware as well with Javascript? :)
I wanted to give it a try and it was easy and funny to build this very basic example.
There is plenty of documentation and examples online. For now, the list of supported [sensors](https://www.espruino.com/Sensors) is limited, 
but I'm pretty sure there are enough of them to get you started with it.

### Useful resources
- Espruino info on ESP8266 chip: http://www.espruino.com/EspruinoESP8266
- How to use espruino on ESP8266: http://crufti.com/getting-started-with-espruino-on-esp8266/
- ESP8266 flashing: http://www.espruino.com/ESP8266_Flashing
- Espruino JS reference: http://www.espruino.com/Reference
- Espruino sensors: https://www.espruino.com/Sensors
