#!/bin/sh

#if you run this at boot time, you'll need to sleep for 60 seconds so that network startup can complete before it runs.
# ('sleep 60 && ./thisfile.sh &' will run it in the background to make sure it doesn't block startup) 

#Remote endpoint used for your tunnel, HE calls this "Server IPv4 Address:" on tunnelbroker.net under Tunnel Details.
REMOTE_ENDPOINT=184.105.253.10

#Local IPV6 for tunnel, HE calls this "Client IPv6 Address:" on tunnelbroker.net under Tunnel Details
LOCAL_IPV6={redacted}/64

LOCAL_ENDPOINT=`/sbin/ip route get $REMOTE_ENDPOINT | awk -F"src " 'NR==1{split($2,a," ");print a[1]}'`

/sbin/ip tunnel add he-ipv6 mode sit remote $REMOTE_ENDPOINT local $LOCAL_ENDPOINT ttl 255
/sbin/ip link set he-ipv6 up

/sbin/ip addr add $LOCAL_IPV6 dev he-ipv6
/sbin/ip route add ::/0 dev he-ipv6

logger -s -t enable-he-ipv6 -p INFO HE-IPV6 enabled
