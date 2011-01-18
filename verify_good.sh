#!/usr/bin/env bash
BINPATH=`echo $0 | sed 's/\/verify_good.sh//'`;
source "$BINPATH/vars";

if [ "$#" -ne "2" ]; then
	echo "Usage: $0 [internal/external] [domain]";
	exit 1;
fi;

LOCATION=$1;
DOMAIN=$2;

if [ -z "`echo $LOCATION | egrep "^(internal|external)$"`" ]; then
	echo "Invalid location specified.";
	exit 1;
fi;

if [ ! -w "$NAMED_PATH/$LOCATION/$DOMAIN.zone.db" ]; then
	echo "Zone file was not found.";
	exit 1;
fi;

ZONEFILE="$NAMED_PATH/$LOCATION/$DOMAIN.zone.db";

if [ "`/usr/bin/env named-checkzone $DOMAIN $ZONEFILE | tail -1`" == "OK" ]; then
	echo "OK";
	exit 0;
else
	echo "There were errors in the zone file.";
	echo "`/usr/bin/env named-checkzone $DOMAIN $ZONEFILE`";
	echo "BAD";
	exit 1;
fi;
