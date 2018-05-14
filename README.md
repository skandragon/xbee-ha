# xbee-ha
Random hacking on the zigbee HA profile, via an Xbee series 2B device.

The goal is to make this hardware agnostic, but still able to send and receive
ZCL commands, focusing on the home automation profile and supporting profiles.

Eventually this will be part of a general solution for a zigbee gateway,
which will allow local control as well as cloud-based contol.  It's critical that
all functionality be implemented locally, so automation and related
functionality works when no internet connection exists, or is down.

# Device discovery

When a device connects, we want to do the following:

1. Remember the device capabilities sent in the announce message. 
1. Send a ZDO "active endpoint request", to get the list of endpoints.
1. For each endppoint:
    * Send a ZDO "simple descriptor request"
    * Send a read: "Application Version", Cluster 0x0000 (basic), attribute 0x0001
    * Send a reqd: "Manufacturer Name", Cluster 0x0000, attribute 0x0004
    * Send a read: "Model", Cluster 0x0000, attribute 0x0005
