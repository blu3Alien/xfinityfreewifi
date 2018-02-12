#!/bin/bash
clear

echo "Started at... $(date)"

# Check which wireless device to use
wlan_default=`iw dev | grep "Interface" | awk '{print $2}'`
echo -n "Wireles Interface [$wlan_default]: "
read x_wlan
if [[ $x_wlan == '' ]]; then 
x_wlan=$wlan_default #Default interface
fi

echo "Releasing DHCP and disconnecting wireless interface [$x_wlan]."
# Release DHCP address
dhclient -r $x_wlan &>/dev/null
# Disconnect wireless link association
#iw $x_wlan disconnect
nmcli n off
nmcli n on
sleep 5

echo "Randomizing MAC Address."
# Bring device down
ifconfig $x_wlan down
# Randomize MAC Address
macchanger -r -b $x_wlan
# Bring device back up
ifconfig $x_wlan up

echo "Verify link status: "
# Make sure device is up and initialized
ip link show $x_wlan | grep "DOWN" | awk '{print $9}'
# Bring link interface up
ip link set $x_wlan up
# Establish wireless link
iw $x_wlan link

echo "Scan for available Xfinity access points."
# Make sure ssid is in range
iw $x_wlan scan | grep "SSID: xfinitywifi"

echo "Associating to access point."
# Associate device to ssid
#iw $x_wlan connect -w 'xfinitywifi'
nmcli c up xfinitywifi
# Wait for association to complete
sleep 5

echo "Requesting IP Address..."
# Request IP Address manually
#dhclient $x_wlan &>/dev/null
# Show IP Address after successful wifi association.
ifconfig $x_wlan | grep 'inet'

# Captive Portal Login
#echo "Trying Captive Portal Login"
#./login.sh
