# xbee-ha
Random hacking on the zigbee HA profile, via an Xbee series 2B device

# Device discovery

When a device connects, we want to do the following:

1. Remember the device capabilities sent in the announce message. 
1. Send a ZDO "active endpoint request", to get the list of endpoints.
1. For each endppoint:
    * Send a ZDO "simple descriptor request"
    * Send a read: "Application Version", Cluster 0x0000 (basic), attribute 0x0001
    * Send a reqd: "Manufacturer Name", Cluster 0x0000, attribute 0x0004
    * Send a read: "Model", Cluster 0x0000, attribute 0x0005
    

    