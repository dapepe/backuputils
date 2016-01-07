#!/bin/bash

# Xen Backup Script
# Creates a live snapshot for each virtual machine
#
# Usage:
#
#   xen-backupall.sh <DIRECTORY>
# 
# Copyright: ZeyOS, Inc. 2016
# Author: Peter-Christoph Haider <peter.haider@zeyos.com>
# License: MIT

# Initialize the target directory
DIR=${1%/}

if [[ -z "$DIR" ]]; then
  echo "No directory defined!${USAGE}"
  exit 1
fi

if [ ! -d $DIR ]; then 
  echo "Target directory does not exist: ${DIR}"
  exit 1
fi

DATE=`date +%y%m%d`
UUIDFILE=$DIR/uuids.txt

BACKUPPATH=$DIR/$DATE
mkdir -p $BACKUPPATH
if [ ! -d $BACKUPPATH ]; then
	echo "No backup directory found"; 
	exit 0
fi

# Fetching list UUIDs of all VMs running on XenServer
xe vm-list is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > $UUIDFILE

if [ ! -f $UUIDFILE ]; then 
	echo "No UUID list file found";
	exit 0
fi

while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`
	SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMNAME-$DATE"`
	xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPUUID
	xe vm-export vm=$SNAPUUID filename="$BACKUPPATH/$VMNAME-$DATE.xva"
	xe vm-uninstall uuid=$SNAPUUID force=true
done < $UUIDFILE

exit 0
