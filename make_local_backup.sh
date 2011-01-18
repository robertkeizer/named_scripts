#!/usr/bin/env bash
BINPATH=`echo $0 | sed 's/\/make_local_backup.sh//'`;
source "$BINPATH/vars";

if [ "$#" -ne "1" ]; then
	echo "Usage: $0 [internal/external]";
	exit 1;
fi;
LOCATION=$1;
TIMESTAMP=`date +%s`;

if [ ! -d "$LOCAL_BACKUP_PATH" ]; then
	echo "Invalid backup path. Please configure vars.";
	exit 1;
fi;

cp -r $NAMED_PATH/$LOCATION $LOCAL_BACKUP_PATH/$LOCATION-$TIMESTAMP
