#!/bin/bash

# Copies Letsencrypt certs to staging for network devices
# additionally, generates "keystore" JKS for alternative cert storage on Ubiquiti UDM Pro
# ...this is specifically written for a Synology NAS with generated LetsEncrypt certs
# depends on the installation of Java 8 in Synology package manager

SCP_USER={user for SCP}
FILE_TO_CHECK=cert.pem
SYSTEM_CERT_PATH=/usr/syno/etc/certificate/system/default
DESTINATION_PATH={place_to_drop_certs for scp from UDMP}
KEYTOOL_PATH=/var/packages/Java8/target/j2sdk-image/bin/

# default keystorepass for Unifi, change if generating for some other system
# KEYSTORE_PASS=aircontrolenterprise
KEYSTORE_PASS=aircontrolenterprise
# default alias for Unifi, change if generaing for some other system
# KEYSTORE_ALIAS=unifi
KEYSTORE_ALIAS=unifi

CURRENT_VER=`md5sum $SYSTEM_CERT_PATH/$FILE_TO_CHECK | awk '{ print $1 }'`
PREVIOUS_VER=`md5sum $DESTINATION_PATH/$FILE_TO_CHECK | awk '{ print $1 }'`

if [ $CURRENT_VER == $PREVIOUS_VER ]; then
  echo "Certificates have not been updated, no action"
  #this is the expected default action
  exit 0
else
  echo "Certificates have been updated; Copying to new location"
  cp $SYSTEM_CERT_PATH/* $DESTINATION_PATH/

  openssl pkcs12 -export -in $DESTINATION_PATH/cert.pem -inkey $DESTINATION_PATH/privkey.pem \
     -out $DESTINATION_PATH/temp.p12 -name $KEYSTORE_ALIAS -CAfile $DESTINATION_PATH/fullchain.pem \
     -caname root -password pass:$KEYSTORE_PASS

  $KEYTOOL_PATH/keytool -importkeystore -deststorepass $KEYSTORE_PASS -destkeypass $KEYSTORE_PASS \
     -destkeystore $DESTINATION_PATH/keystore -srckeystore $DESTINATION_PATH/temp.p12 \
     -srcstoretype PKCS12 -srcstorepass $KEYSTORE_PASS -alias $KEYSTORE_ALIAS -noprompt

  rm $DESTINATION_PATH/temp.p12
  chown $SCP_USER $DESTINATION_PATH/*
  chmod 700 $DESTINATION_PATH/*

fi
#returning an exit code of 1 allows to only send email updates when certs were updated
exit 1
