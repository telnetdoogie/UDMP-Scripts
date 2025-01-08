#!/bin/sh

# Check if the user provided an interface as an argument
if [ -z "$1" ]; then
  echo
  echo "Please provide your WAN interface."
  echo
  echo "Usage: $0 <network_interface>"
  echo "Example: $0 eth9"
  echo
  exit 1
fi

# Use the provided interface
INTERFACE=$1
echo
echo "Testing for GRO problem..."
echo
ethtool -K $INTERFACE gro on
echo "Testing with $(ethtool -k $INTERFACE | grep generic-receive)"
echo "Downloading File with GRO on"
curl -# -o /root/testfile_gro_on.bin http://fw-download.ubnt.com/data/udm/713a-udmpro-1.9.3-c467d3f8c4e74e4281ede75c58a9d3fb.bin
echo "Calculating Checksum..."
FILE1=`md5sum -z < /root/testfile_gro_on.bin | awk '{print $1}'`
echo "MD5 for GRO on = ${FILE1}"
echo " ..deleting file"
rm /root/testfile_gro_on.bin

echo

echo "Disabling GRO on $INTERFACE"
ethtool -K $INTERFACE gro off
echo "Testing with $(ethtool -k $INTERFACE | grep generic-receive)"
echo "Downloading File"
curl --progress-bar -o /root/testfile_gro_off.bin http://fw-download.ubnt.com/data/udm/713a-udmpro-1.9.3-c467d3f8c4e74e4281ede75c58a9d3fb.binecho "Calculating Checksum..."
FILE2=`md5sum -z < /root/testfile_gro_off.bin | awk '{print $1}'`
echo "MD5 for GRO off = ${FILE2}"
echo " ..deleting file"

echo

if [ "$FILE1" = "$FILE2" ]; then
    echo "Checksums are equal, you do not appear to have a GRO issue."
    echo "I will leave GRO on for $INTERFACE"
    ethtool -K $INTERFACE gro on
else
    echo "Checksums do not match, there is a GRO issue."
    echo "I will leave GRO off for $INTERFACE"
    echo " - note: this setting will not persist a reboot."
    echo "See https://github.com/telnetdoogie/UDMP-Scripts/blob/main/disable_gro.md for fix"
    ethtool -K $INTERFACE gro off
fi

echo
echo "Done. Exiting"
