#!/bin/bash
#
# Copyright (c) 2019 Kara Nance (knance@securityworks.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Script to install and create a basic configuration for a Ghidra
# server.
#
# Note that this configuration is suitable for development
# and experimentation purposes only.  If you are configuring a
# Ghidra server for production use you should carefully read the
# Ghidra server documentation found in the Ghidra distribution, and
# determine an appropriate configuration for your environment and
# specific use case.
#
# Updates and additions by Sam Pursglove 
# Last edit: 01 SEP 2023
#

# script usage message
if [ "$1" = "-h" -o $# -ne 3 -o $# -ne 4 ]; then
        echo "usage: ./ghidra.sh <ghidra_download_url> <file_sha256> <username> [<public_server_ip>]"
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

# check if the install directory already exists, in which case don't 
# install (see the server/svrREADME.html instructions for uninstalling 
# and upgrading Ghidra server)
if [ -e ${SVRROOT} ]; then
	echo "Exiting: ${SVRROOT} already exists"
	exit 1
fi

# update Ubuntu and install Java 17 (change the Java package version as necessary)
sudo apt update && sudo apt dist-upgrade -y && sudo apt install -y openjdk-17-jdk unzip

# download Ghidra and ensure it matches the SHA256 hash provided
wget ${GHIDRA_URL} -O ${GHIDRA_ZIP}
RESULT=$(echo "${GHIDRA_HASH} ${GHIDRA_ZIP}" | sha256sum --check | cut -d' ' -f2)             
if [ "${RESULT}" != "OK" ]; then                                                              	
        echo "Exiting: Ghidra download SHA256 does not match"
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

# -ip : allows you to set the public IP your client connects to
#        (likely required if you're using a cloud VPS)
# -a0 : use private user password authentication
# -u : allows user to specify a username when connecting
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
