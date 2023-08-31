#!/bin/bash
# script usage message
if [ "$1" = "-h" -o $# -ne 3 -o $# -ne 4 ]; then
        echo "usage: ./ghidra.sh <http_ghidra_download_url> <file_sha256_hash> <username> [<ghidra_public_server_ip>]"
        exit 1
fi

# define some environment variables
OWNER=ghidrasrv
SVRROOT=/opt/${OWNER}
REPODIR=/opt/ghidra-repos
GHIDRA_URL=$1
GHIDRA_HASH=$2
GHIDRA_USER=$3
GHIDRA_SVR_IP=$4
GHIDRA_ZIP=/tmp/ghidra.zip

# update Ubuntu and install Java
sudo apt update && sudo apt dist-upgrade -y && sudo apt install -y openjdk-17-jdk unzip

# download Ghidra and ensure it matches the SHA256 hash provided
wget ${GHIDRA_URL} -O ${GHIDRA_ZIP}
RESULT=$(echo "${GHIDRA_HASH} ${GHIDRA_ZIP}" | sha256sum --check | cut -d' ' -f2)             
if [ "${RESULT}" != "OK" ]; then                                                              	
        echo "Exiting: Incorrect GHIDRA zip SHA256"                                                   
        exit 1                                                                                
fi  

# unzip the Ghidra download in a temp directory then move to the designated 
# ghidra server root directory, delete the Ghidra zip download and all the 
# temp directory files
mkdir /tmp/ghidra && cd /tmp/ghidra && unzip ${GHIDRA_ZIP}
sudo mv ghidra_* ${SVRROOT}
cd /tmp && rm -f ${GHIDRA_ZIP} && rmdir ghidra

# create a nonprivileged user to run the server and create a directory for
# hosting shared Ghidra repos outside the directory in which Ghidra server
# was installed (Ghidra docs recommend this)
sudo useradd -r -m -d /home/${OWNER} -s /usr/sbin/nologin -U ${OWNER}
sudo mkdir ${REPODIR}
sudo chown ${OWNER}.${OWNER} ${REPODIR}

# create a backup of the original server config file and change the location
# where the repos will be saved
cd ${SVRROOT}/server && cp server.conf server.conf.orig
REPOVAR=ghidra.repositories.dir
sed -i "s@^$REPOVAR=.*\$@$REPOVAR=$REPODIR@g" server.conf

# -u option allows you to specify a username when connecting
# -ip option allows you to set the (public) IP your client should connect to
#        this is likely required if you're using a cloud VPS
# Some versions of Ghidra expect the repository path to be the last command
# line parameter so that is why it is moved to the end
PARM=wrapper.app.parameter.
sed -i "s/^${PARM}2=/${PARM}3=/" server.conf
sed -i "/^${PARM}3=/i ${PARM}2=-u" server.conf

# change the ownership of the Ghidra server process and directory to
# the Ghidra user
ACCT=wrapper.app.account
sed -i "s/^.*$ACCT=.*/$ACCT=$OWNER/" server.conf
sudo chown -R ${OWNER}.${OWNER} ${SVRROOT}

# install Ghidra server and add one user
sudo ./svrInstall
sudo ${SVRROOT}/server/svrAdmin -add ${GHIDRA_USER}   # default pw: changeme (change w/in 24hrs or acct locks)
