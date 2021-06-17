#!/bin/sh
# Updates installed certs if new certs are present on a known SCP host
# Schedule as a daily cron job

SRC_USER={username for SCP Host}
SRC_HOST={SCP hostname}
SRC_FOLDER='{SCP host folder for certs}'

WORKING_PATH=/mnt/data/ssl_certs
if [[ ! -d $WORKING_PATH ]]
then
    echo "\$WORKING_PATH '$WORKING_PATH' folder doesn't exist! exiting."
    exit 1
fi

#filename on the source for the keyfile
SRC_KEY=privkey.pem
#filename on the source for the cert
SRC_CERT=cert.pem
#filename on the source for the keystore
SRC_KEYSTORE=keystore

DEST_PATH=/mnt/data/unifi-os/unifi-core/config
DEST_KEYSTORE_PATH=/mnt/data/unifi-os/unifi/data
DEST_KEY=unifi-core.key
DEST_CERT=unifi-core.crt
DEST_KEYSTORE=keystore

#Copy certs from SRC_HOST
scp -i /root/.ssh/id_rsa $SRC_USER@$SRC_HOST:$SRC_FOLDER/$SRC_CERT $WORKING_PATH/$SRC_CERT > /dev/null 2>&1
scp -i /root/.ssh/id_rsa $SRC_USER@$SRC_HOST:$SRC_FOLDER/$SRC_KEY $WORKING_PATH/$SRC_KEY > /dev/null 2>&1
scp -i /root/.ssh/id_rsa $SRC_USER@$SRC_HOST:$SRC_FOLDER/$SRC_KEYSTORE $WORKING_PATH/$SRC_KEYSTORE > /dev/null 2>&1

if [[ ! -f $WORKING_PATH/$SRC_CERT ]]
then
    echo "Certificate file '$SRC_CERT' not copied from host! exiting"
    exit 1
fi
if [[ ! -f $WORKING_PATH/$SRC_KEY ]]
then
    echo "Key file '$SRC_KEY' not copied from host! exiting"
    exit 1
fi
if [[ ! -f $WORKING_PATH/$SRC_KEYSTORE ]]
then
    echo "Keystore file '$SRC_KEYSTORE' not copied from host! exiting"
    exit 1
fi

chmod 644 $WORKING_PATH/$SRC_KEY
chmod 644 $WORKING_PATH/$SRC_CERT
chmod 644 $WORKING_PATH/$SRC_KEYSTORE

#Compare versions to see if an update is needed
SRC_VER=`md5sum $WORKING_PATH/$SRC_CERT | awk '{ print $1 }'`
DEST_VER=`md5sum $DEST_PATH/$DEST_CERT | awk '{ print $1 }'`

if [ $SRC_VER == $DEST_VER ]; then
    echo "LE Certificates match system; no action needed"
  else
    # Update is needed; move files and restart unifi
    echo "LE Certificates are new; updating system certs"

    # Backup previous files
    echo "Backing Up $DEST_PATH/$DEST_KEY to $DEST_PATH/$DEST_KEY.bkup"
    cp $DEST_PATH/$DEST_KEY $DEST_PATH/$DEST_KEY.bkup
    echo "Backing Up $DEST_PATH/$DEST_CERT to $DEST_PATH/$DEST_CERT.bkup"
    cp $DEST_PATH/$DEST_CERT $DEST_PATH/$DEST_CERT.bkup
    echo "Backing Up $DEST_KEYSTORE_PATH/$DEST_KEYSTORE to $DEST_KEYSTORE_PATH/$DEST_KEYSTORE.bkup"
    cp $DEST_KEYSTORE_PATH/$DEST_KEYSTORE $DEST_KEYSTORE_PATH/$DEST_KEYSTORE.bkup

    # Update certs
    echo "Overwriting $DEST_PATH/$DEST_KEY"
    cp $WORKING_PATH/$SRC_KEY $DEST_PATH/$DEST_KEY
    echo "Overwriting $DEST_PATH/$DEST_CERT"
    cp $WORKING_PATH/$SRC_CERT $DEST_PATH/$DEST_CERT

    # Update keystore
    echo "Overwriting $DEST_KEYSTORE_PATH/$DEST_KEYSTORE"
    cp $WORKING_PATH/$SRC_KEYSTORE $DEST_KEYSTORE_PATH/$DEST_KEYSTORE

    # Restart unifi-os
    unifi-os restart
fi

#cleaning up
rm $WORKING_PATH/$SRC_KEY
rm $WORKING_PATH/$SRC_CERT
rm $WORKING_PATH/$SRC_KEYSTORE

exit 0
