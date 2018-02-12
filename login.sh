#!/bin/bash

# SETUP
browser="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6"
x_email="complimentary_wifi@gmail.com"
x_username="complimentary_xfinity"
x_password="XfinityFreeWifi"

# INIT
mkdir ./tmp
touch ./tmp/x_cookies.txt
touch ./tmp_x_cookiejar.txt

echo "Init Start Page Redirect"
#curl -# https://wifiondemand.xfinity.com/wod/#error/403 > ./tmp/x_403.htm
curl -# -L -b ./tmp/x_cookies.txt -c ./tmp/x_cookiejar.txt -i -H 'Connection: keep-alive' -A "$browser" www.yahoo.com > ./tmp/x_redirect.htm
URL=`cat ./tmp/x_redirect.htm | grep "Location:" | awk '{print $2}'`
echo $URL

echo "Submit Xfinity Login Credentials"
#curl -# -L -i -H 'Connection: keep-alive' -A "$browser" "$URL" > ./tmp/x_login.htm
curl -X POST -F "username=$x_username" -F "password=$x_password" -F "friendlyname=friendlyname" -F "javascript=false" -F "method=authentica$


#https://wifiondemand.xfinity.com/wod/static/welcome.html?c=e&macId=6c%3A9d%3Ad6%3A0d%3Ae4%3A91&location=Hotspot&apMacId=00%3A00%3A00%3A00%$

#https://wifiondemand.xfinity.com/wod/#error/403 -> sign in
#https://wifiondemand.xfinity.com/wod/#external/loginPage -> credentials & signin
#https://wifiondemand.xfinity.com/wod/static/welcome.html -> redirect
#https://wifiondemand.xfinity.com/wod/#devices -> delete this d3vice
#https://wifiondemand.xfinity.com/wod/#offerList -> pass & continue
#https://wifiondemand.xfinity.com/wod/#complete -> activate pass
#https://wifiondemand.xfinity.com/wod/#reactivate
#http://wifi.xfinity.com/

# CLEANUP
#rm -R ./tmp
