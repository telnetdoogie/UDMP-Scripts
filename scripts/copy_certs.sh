#!/bin/bash

# Copies Letsencrypt certs to staging for network devices
# additionally, generates "keystore" JKS for alternative cert storage on Ubiquiti UDM Pro
# ...this is specifically written for a Synology NAS with generated LetsEncrypt certs
# depends on the installation of Java 8 in Synology package manager

SCP_USER={whichever user you'll pull the files as}
FILE_TO_CHECK=cert.pem
SYSTEM_CERT_PATH=/usr/syno/etc/certificate/system/default
DESTINATION_PATH={place_to_drop_certs for scp from UDMP}

CURRENT_VER=`md5sum $SYSTEM_CERT_PATH/$FILE_TO_CHECK | awk '{ print $1 }'`
PREVIOUS_VER=`md5sum $DESTINATION_PATH/$FILE_TO_CHECK | awk '{ print $1 }'`

if [ $CURRENT_VER == $PREVIOUS_VER ]; then
    echo "Certificates have not been updated, no action"
  else
    echo "Certificates have been updated; Copying to new location"
    cp /usr/syno/etc/certificate/system/default/* /var/services/homes/admin/ssl_certs/

    openssl pkcs12 -export -in $DESTINATION_PATH/cert.pem -inkey $DESTINATION_PATH/privkey.pem -out $DESTINATION_PATH/unifi.p12 -name unifi -CAfile $DESTINATION_PATH/fullchain.pem -caname root -password pass:aircontrolenterprise
    keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore $DESTINATION_PATH/keystore -srckeystore $DESTINATION_PATH/unifi.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -alias unifi -noprompt

    rm $DESTINATION_PATH/*.p12

    chown $SCP_USER $DESTINATION_PATH/*
    chmod 700 $DESTINATION_PATH/*
fi

exit 0
