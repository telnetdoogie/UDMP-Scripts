#!/bin/sh
# run this as a cron job; iptables is updated after a UI change, so running frequently will ensure recovery
# if your primary interface is eth8 vs eth9, switch the two around here
# if you're using both interfaces, change the '/d' removal with a replacement to the updated interface name

# export ip6tables, remove eth8 entries, replace eth9 entries with he-ipv6

if /usr/sbin/ip6tables-save | grep -Fq "eth9" ; then
    echo "Updating ip6tables to replace eth9 with he-ipv6..."
    /usr/sbin/ip6tables-save | sed '/eth8/d' | sed 's/eth9/he-ipv6/g' | /usr/sbin/ip6tables-restore
fi
