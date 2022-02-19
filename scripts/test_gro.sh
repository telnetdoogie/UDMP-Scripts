#!/bin/sh

echo "Enabling GRO"
ethtool -K eth9 gro on
echo `ethtool -k eth9 | grep generic-receive`
echo "Downloading File"
curl -o /root/testfile_gro_on.bin http://fw-download.ubnt.com/data/udm/713a-udmpro-1.9.3-c467d3f8c4e74e4281ede75c58a9d3fb.bin
echo "Disabling GRO"
ethtool -K eth9 gro off
echo `ethtool -k eth9 | grep generic-receive`
echo "Downloading File"
curl -o /root/testfile_gro_off.bin http://fw-download.ubnt.com/data/udm/713a-udmpro-1.9.3-c467d3f8c4e74e4281ede75c58a9d3fb.bin
echo "MD5Sum..."
md5sum /root/testfile_gro_*

rm /root/testfile_gro* 
ethtool -K eth9 gro off
