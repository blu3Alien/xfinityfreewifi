#!/bin/bash

##### Variables
interactive=0
forwarding=0

x_wlan=

##### Functions
x_login()
{
  echo "Logging into Xfinity Portal"
  #watch -n 3600 $0
}

x_forward()
{
    #temppineapplegw=`netstat -nr | awk 'BEGIN {while ($3!="0.0.0.0") getline; print $2}'` #Usually correct by default
    temppineapplegw=172.20.20.1
    if [ "$interactive" = "1" ]; then
      echo -n "Pineapple Netmask [255.255.255.0]: "
      read pineapplenetmask
      echo -n "Pineapple Network [172.16.42.0/24]: "
      read pineapplenet
      echo -n "Interface between PC and Pineapple [eth0]: "
      read pineapplelan
      echo -n "Interface between PC and Internet [wlan0]: "
      read pineapplewan
      echo -n "Internet Gateway [$temppineapplegw]: "
      read pineapplegw
      echo -n "IP Address of Host PC [172.16.42.42]: "
      read pineapplehostip
      echo -n "IP Address of Pineapple [172.16.42.1]: "
      read pineappleip
    fi
    if [[ $pineapplenetmask == '' ]]; then 
    pineapplenetmask=255.255.255.0 #Default netmask for /24 network
    fi
    if [[ $pineapplenet == '' ]]; then 
    pineapplenet=172.16.42.0/24 # Pineapple network. Default is 172.16.42.0/24
    fi
    if [[ $pineapplelan == '' ]]; then 
    pineapplelan=eth0 # Interface of ethernet cable directly connected to Pineapple
    fi
    if [[ $pineapplewan == '' ]]; then 
    pineapplewan=wlan0 #i.e. wlan0 for wifi, ppp0 for 3g modem/dialup, eth0 for lan
    fi
    
    if [[ $pineapplegw == '' ]]; then 
    #pineapplegw=`netstat -nr | awk 'BEGIN {while ($3!="0.0.0.0") getline; print $2}'` #Usually correct by default
    pineapplegw=172.20.20.1
    fi
    if [[ $pineapplehostip == '' ]]; then 
    pineapplehostip=172.16.42.42 #IP Address of host computer
    fi
    if [[ $pineappleip == '' ]]; then 
    pineappleip=172.16.42.1 #Thanks Douglas Adams
    fi
    
    #Display settings
    echo ""
    echo "$(tput setaf 6)     _ .   $(tput sgr0)        $(tput setaf 7)___$(tput sgr0)          $(tput setaf 3)\||/$(tput sgr0)   Internet: $pineapplegw - $pineapplewan"
    echo "$(tput setaf 6)   (  _ )_ $(tput sgr0) $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 7)[___]$(tput sgr0)  $(tput setaf 2)<-->$(tput sgr0)  $(tput setaf 3),<><>,$(tput sgr0)  Computer: $pineapplehostip"
    echo "$(tput setaf 6) (_  _(_ ,)$(tput sgr0)       $(tput setaf 7)\___\\$(tput sgr0)        $(tput setaf 3)'<><>'$(tput sgr0) Pineapple: $pineapplenet - $pineapplelan"

    #Bring up Ethernet Interface directly connected to Pineapple
    ifconfig $pineapplelan $pineapplehostip netmask $pineapplenetmask up

    # Enable IP Forwarding
    echo '1' > /proc/sys/net/ipv4/ip_forward
    #echo -n "IP Forwarding enabled. /proc/sys/net/ipv4/ip_forward set to "
    #cat /proc/sys/net/ipv4/ip_forward

    #clear chains and rules
    iptables -X
    iptables -F
    #echo iptables chains and rules cleared

    #setup IP forwarding
    iptables -A FORWARD -i $pineapplewan -o $pineapplelan -s $pineapplenet -m state --state NEW -j ACCEPT
    iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A POSTROUTING -t nat -j MASQUERADE
    #echo IP Forwarding Enabled

    #remove default route
    route del default
    #echo Default route removed

    #add default gateway
    route add default gw $pineapplegw $pineapplewan
    #echo Pineapple Default Gateway Configured

    echo ""
    echo "Done forwarding internet."
    echo ""
}

x_check()
{
  # Check which wireless device to use
  wlan_default=`iw dev | grep "Interface" | awk '{print $2}'`
  if [ "$interactive" = "1" ]; then

    echo -n "Wireles Interface [$wlan_default]: "
    read x_wlan
    if [[ $x_wlan == '' ]]; then 
      x_wlan=$wlan_default #Default interface
    fi
  else
    if [[ $x_wlan == '' ]]; then
      x_wlan=$wlan_default #Default interface
    fi
  fi

  # Show IP Address after successful wifi association.
  if [ "$interactive" = "1" ]; then
    ifconfig $x_wlan | grep 'inet'
  fi
  #ping -c4 google.com | grep 'time'
  if nc -zw1 google.com 443; then
    echo "we have connectivity"
    if [ "$interactive" = "1" ]; then
      ping -c4 google.com
    fi
  else
    echo "no connectivity"
  fi
}

x_usage()
{
  clear
  echo "Usage: $0 [OPTIONS] { COMMAND | help }"
  echo " "
  echo "OPTIONS"
  echo "  -i | --interactive          interactive prompts"
  echo "  -f | --forward              forward wifi over lan"
  echo "  -c | --check                check internet connectivity"
  echo "  -h | --help                 display this usage"
}

##### Main
while [ "$1" != "" ]; do
    case $1 in
        -i | --interactive )    interactive=1
                                ;;
        -f | --forward )        forwarding=1
                                ;;
        -c | --check )          x_check
                                exit
                                ;;
        -h | --help )           x_usage
                                exit
                                ;;
        * )                     x_usage
                                exit 1
    esac
    shift
done

  echo "Started at... $(date)"


  if [ "$forwarding" = "1" ]; then
    x_forward
  fi

  # Check which wireless device to use
  wlan_default=`iw dev | grep "Interface" | awk '{print $2}'`
  if [ "$interactive" = "1" ]; then

    echo -n "Wireles Interface [$wlan_default]: "
    read x_wlan
    if [[ $x_wlan == '' ]]; then 
      x_wlan=$wlan_default #Default interface
    fi
  else
    x_wlan=$wlan_default #Default interface
  fi

  echo "Releasing DHCP and disconnecting wireless interface [$x_wlan]."
  # Release DHCP address
  dhclient -r $x_wlan &>/dev/null
  # Disconnect wireless link association
  #iw $x_wlan disconnect
  nmcli n off
  sleep 2
  nmcli n on
  sleep 3

  echo "Randomizing MAC Address."
  # Bring device down
  ifconfig $x_wlan down
  # Randomize MAC Address
  macchanger -r -b $x_wlan
  # Bring device back up
  ifconfig $x_wlan up

  echo -n "Verify link status: "
  # Make sure device is up and initialized
  ip link show $x_wlan | grep "DOWN" | awk '{print $9}'
  # Bring link interface up
  ip link set $x_wlan up
  # Establish wireless link
  iw $x_wlan link

  sleep 2

  echo "Scan for available Xfinity access points."
  # Make sure ssid is in range
  iw $x_wlan scan | grep "SSID: xfinitywifi"

  echo "Associating to access point."
  # Associate device to ssid
  #iw $x_wlan connect -w 'xfinitywifi'
  nmcli -p c up xfinitywifi > /dev/null
  # Wait for association to complete
  sleep 2

  echo "Requesting IP Address..."
  # Request IP Address manually
  #dhclient $x_wlan &>/dev/null

  x_login
  x_check
