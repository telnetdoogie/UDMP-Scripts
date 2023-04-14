#!/bin/bash

# this script intended to add speedtest to the root path / .profile each boot
# add to /data/on_boot.d as something like 25-add-speedtest-to-profile.sh and add execute permissions
#
# to initially install speedtest on UDMP:
#
#   curl -o speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz
#   mkdir /data/speedtest
#   tar -xvf speedtest.tgz -C /data/speedtest
#   rm speedtest.tgz
#
 
SPEEDTEST_PATH="/data/speedtest/"
PROFILE_FILE="/root/.profile"

if grep -Fsq "$SPEEDTEST_PATH" $PROFILE_FILE;  then 
  echo "speedtest path already present in path in '$PROFILE_FILE'"
else
  echo "Adding '$SPEEDTEST_PATH' to path in '$PROFILE_FILE'"    
  echo "export PATH=\$PATH:$SPEEDTEST_PATH" >> $PROFILE_FILE
fi

chmod 600 $PROFILE_FILE 

exit 0
