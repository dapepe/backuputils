#!/bin/bash

# Xen Backup Script
# Creates a live snapshot for each virtual machine
#
# Usage:
#
#   xen-backup.sh <DIRECTORY> <VMNAME>
# 
# Copyright: ZeyOS, Inc. 2016
# Author: Peter-Christoph Haider <peter.haider@zeyos.com>
# License: MIT

# Initialize the target directory
DIR=${1%/}
VMSELECT="$2"

USAGE=$'\n\nUsage:\n  xen-backup.sh <DIR> <VMNAME>\n\nIf no <VMNAME> is provided, all VMs will be backed up\n'

if [ -z "$DIR" ]; then
  echo "No directory defined!${USAGE}"
  exit 1
fi

if [ ! -d $DIR ]; then 
  echo "Target directory does not exist: ${DIR}"
  exit 1
fi

# Fetching list UUIDs of all VMs running on XenServer
UUIDFILE=$DIR/uuids.txt
xe vm-list is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > $UUIDFILE

if [ ! -f $UUIDFILE ]; then 
  echo "No UUID list file found";
  exit 0
fi

DATE=`date +%y%m%d`
while read VMUUID
do
  VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`
  if [ ! -z "$VMSELECT" ]; then
    if [ "$VMSELECT" != "$VMNAME" ]; then
      continue
    fi
  fi

  echo "Backing up $VMNAME"

  SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="BACKUP-$VMNAME-$DATE"`
  xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPUUID
  xe vm-export vm=$SNAPUUID filename="$DIR/$DATE-$VMNAME.xva"
  xe vm-uninstall uuid=$SNAPUUID force=true

  if [ ! -z "$VMSELECT" ]; then
    exit 0
  fi
done < $UUIDFILE

exit 0
