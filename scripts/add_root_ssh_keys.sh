#!/bin/bash

#####################################################
# ADD RSA KEYS AS BELOW - CHANGE BEFORE RUNNING     #
#####################################################
# set -- "ssh-rsa first key here all keys quoted" \ #
#        "ssh-rsa each line appended with slash " \ #
# 	 "ssh-rsa last one has no backslash"        #
#####################################################
set --	"ssh-rsa AAABUNCHOFNONSENSE random Keyname" \
	"ssh-rsa AAAAOTHERMAGICWORDS user@host"

KEYS_FILE="/root/.ssh/authorized_keys"

counter=0
for key in "$@"
do
	## Places public key in ~/.ssh/authorized_keys if not present
	if ! grep -Fxq "$key" "$KEYS_FILE"; then
		let counter++
		echo "$key" >> "$KEYS_FILE"
	fi
done

echo $counter keys added to $KEYS_FILE

# removed for 2.4 - no dropbear
#echo Converting SSH private key to dropbear format 
#convert ssh key to dropbear for shell interaction
#dropbearconvert openssh dropbear /data/ssh/id_rsa /root/.ssh/id_dropbear

exit 0;
