# Steps to disable GRO on UDM/UDMP devices
This solves file corruption issues with certain ISP devices on the WAN

The way this problem typically manifests itself is when you get failed downloads usually over SSL.
It's actually a problem with corrupted downloads always, however you may not notice them. 

The reason the SSL downloads most noticably fail is becuase the corruption will 'break' SSL and you'll see errors.
Other symptoms would be frequent disconnects from streaming movies etc., and obviously weird file corruptions, a failure to update your UDM/P etc.

## Testing for presence of the problem

To test for this problem, you can run the script [here](./scripts/test_gro.sh) on your UDM device.
If the output shows different MD5 checksums with GRO enabled and disabled, you have a GRO problem.

## Short term fix (done after each reboot)
The simplest way would be to just run `ethtool -K eth8 gro off` each time you reboot your device, but change eth8 for whichever interface is your WAN interface (run ifconfig and find the one with your WAN ip - also see the below table for examples)

## Typical WAN interfaces:
(let me know if you have corrections or updates to this)

| Model | Port | Interface |
| ----- | ---- | --------- |
| UDM | WAN | `eth4` |
| UDMP/SE | RJ45 WAN | `eth8` |
| UDMP/SE | SFP WAN (port 10) | `eth9` |
| UDMP/SE | SFP WAN (port 11) | `eth10` |

## Automating disable GRO on UDM OS 4 and above

add a file (make folders if necessary) `/data/scripts/disable_gro.sh` :

```bash
#!/bin/bash
WAN_INTERFACE=eth9        # edit this to match your WAN interface

echo disabling GRO for $WAN_INTERFACE...
/sbin/ethtool -K $WAN_INTERFACE gro off
echo GRO state for $WAN_INTERFACE is now:
echo "   $(ethtool -k ${WAN_INTERFACE} | grep generic-receive)"
```
_(change the `WAN_INTERFACE` to match your interface)_

make the file executable

```bash
chmod +x /data/scripts/disable_gro.sh
```

make a file, `/lib/systemd/system/disable_gro.service` :

```bash
[Unit]
Description=Disable GRO
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/data/scripts/disable_gro.sh
Type=oneshot
RemainAfterExit=true 
User=root

[Install]
WantedBy=multi-user.target
```

run the following:

```bash
systemctl enable disable_gro.service
systemctl start disable_gro.service
```

run `systemctl status disable_gro.service` to see what was output on execution.

It should show something like:

```
disabling GRO for eth9...
GRO state for eth9 is now:
   generic-receive-offload: off
```

you can also test to make sure it applied, and after each bootup by running:

```bash
ethtool -k eth9 | grep generic-receive
```

...again, replacing `eth9` with whatever interface is for your WAN

the output should show that gro is off :
```
$ ethtool -k eth9 | grep generic-receive
generic-receive-offload: off
```
