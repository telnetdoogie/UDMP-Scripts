#!/bin/sh

MY_SSH_KEY1="{paste key here}"
MY_SSH_KEY2="{paste key here}"
KEYS_FILE="/root/.ssh/authorized_keys"

# Places public key in ~/.ssh/authorized_keys if not present
if ! grep -Fxq "$MY_SSH_KEY1" "$KEYS_FILE"; then
    echo "$MY_SSH_KEY1" >> "$KEYS_FILE"
fi
if ! grep -Fxq "$MY_SSH_KEY2" "$KEYS_FILE"; then
    echo "$MY_SSH_KEY2" >> "$KEYS_FILE"
fi

# Convert ssh key to dropbear for shell interaction
# UDMP uses dropbear as the default ssh / scp client, so certs need
#   to be converted from dropbear to openssh format for use.
dropbearconvert openssh dropbear /mnt/data/ssh/id_rsa /root/.ssh/id_rsa
