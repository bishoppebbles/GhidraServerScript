#!/bin/bash
if [ "$1" = "-h" -o $# -ne 2 ]; then
        echo "usage: ./ghidra.sh <http_ghidra_download_url> <file_sha256_hash>"
        exit 1
fi

OWNER=ghidrasrv
SVRROOT=/opt/${OWNER}
REPODIR=/opt/ghidra-repos
GHIDRA_URL=$1
GHIDRA_HASH=$2
GHIDRA_ZIP=/tmp/ghidra.zip

sudo apt update && sudo apt install -y openjdk-17-jdk unzip

wget ${GHIDRA_URL} -O ${GHIDRA_ZIP}
RESULT=$(echo "${GHIDRA_HASH} ${GHIDRA_ZIP}" | sha256sum --check | cut -d' ' -f2)             
if [ "${RESULT}" != "OK" ]; then                                                              	
        echo "Exiting: Incorrect GHIDRA zip SHA256"                                                   
        exit 1                                                                                
fi  

mkdir /tmp/ghidra && cd /tmp/ghidra && unzip ${GHIDRA_ZIP}
sudo mv ghidra_* ${SVRROOT}
cd /tmp && rm -f ${GHIDRA_ZIP} && rmdir ghidra

sudo useradd -r -m -d /home/${OWNER} -s /usr/sbin/nologin -U ${OWNER}
sudo mkdir ${REPODIR}
sudo chown ${OWNER}.${OWNER} ${REPODIR}

cd ${SVRROOT}/server && cp server.conf server.conf.orig
REPOVAR=ghidra.repositories.dir
sed -i "s@^$REPOVAR=.*\$@$REPOVAR=$REPODIR@g" server.conf

PARM=wrapper.app.parameter.
sed -i "s/^${PARM}2=/${PARM}3=/" server.conf
sed -i "/^${PARM}3=/i ${PARM}2=-u" server.conf

ACCT=wrapper.app.account
sed -i "s/^.*$ACCT=.*/$ACCT=$OWNER/" server.conf
sudo chown -R ${OWNER}.${OWNER} ${SVRROOT}

sudo ./svrInstall
sudo ${SVRROOT}/server/svrAdmin -add sam   # default (change w/in 24hrs): changeme
#sudo ${SVRROOT}/server/svrAdmin -add user2   
