#!/bin/bash

# Cleanup script
# Removes the last n files from a directory listing
#
# Usage:
#
#   cleanup.sh <LIMIT> <BASENAME> <DIRECTORY>
# 
# Copyright: ZeyOS, Inc. 2016
# Author: Peter-Christoph Haider <peter.haider@zeyos.com>
# License: MIT

LIMIT="$1"
BASENAME="$2"
DIR=${3%/}

USAGE=$'\n\nUsage:\n  cleanup.sh <LIMIT> <BASENAME> <DIRECTORY>\n'

if [[ -z "$LIMIT" ]]; then
  echo "No limit defined!${USAGE}"
  exit 1
fi

if ! [[ $LIMIT =~ ^-?[0-9]+$ ]]; then
  echo "Limit is not a number!"
  exit 1
fi

if [[ -z "$BASENAME" ]]; then
  echo "No basename defined!${USAGE}"
  exit 1
fi

if [[ -z "$DIR" ]]; then
  echo "No directory defined!${USAGE}"
  exit 1
fi

if [ ! -d $DIR ]; then 
  echo "Target directory does not exist: ${DIR}"
  exit 1
fi

FILECOUNT=$(ls ${DIR} | grep "${BASENAME}" | wc -l)

if [ $FILECOUNT -lt $LIMIT ] ; then
  # Nothing to do
  exit 0
fi

# Loop over all files and remove the oldest ones
# Files are being sorted by name, so make sure your filename reflects
# the corresponding date

COUNTER=0
FILELIST=$(ls ${DIR} | grep "${BASENAME}" | sort -r)
for FILENAME in $FILELIST; do
  COUNTER=$((COUNTER+1))
  if [ $COUNTER -gt $LIMIT ] ; then
    rm -f $FILENAME
  fi  
done

exit 0
