#!/bin/bash

# MySQL Backup Script
# Creates a backup for all MySQL databases
#
# Usage:
#
#   mysql-backupall.sh <DIRECTORY>
# 
# Copyright: ZeyOS, Inc. 2016
# Author: Peter-Christoph Haider <peter.haider@zeyos.com>
# License: MIT

# You should create a backup user that only has read priviledges
USER=root
PASSWORD=

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

# List the databases
DATABASES=$(mysql --user=${USER} --password=${PASS} -Bse 'show databases')

for DATABASE in $DATABASES; do
  FILENAME=`date +"+%Y-%m-%d"`-${DATABASE}.sql
  mysqldump --opt --user=${USER} --password=${PASSWORD} ${DATABASE} > ${DIR}/${FILENAME}
done

exit 0
