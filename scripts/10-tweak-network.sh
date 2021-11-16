#!/bin/sh

# file placed in /mnt/data/on_boot.d/10-tweak-network.sh with 755 owned by root
# see https://github.com/boostchicken/udm-utilities/blob/master/on-boot-script/README.md

# to fix my own problem with GRO breaking SSL downloads
# we will disable GRO for WAN interfaces (eth8 eth9)

#
 echo disabling GRO for RJ45 WAN port...
 /usr/sbin/ethtool -K eth8 gro off
 echo disabling GRO for SFP+ WAN port...
 /usr/sbin/ethtool -K eth9 gro off

exit 0
