#!/usr/bin/env bash
BINPATH=`echo $0 | sed 's/\/add_to_named.sh//'`;
source "$BINPATH/vars";

if [ -z `echo "$#" | egrep "(4|5)"` ]; then
	echo "Usage: $0 [internal/external] [optional:CNAME/A] [domain:bluerack.ca] [name in name.bluerack.ca] [address]";
	exit 1;
fi;

# Check the number of args and set the vars correctly..

LOCATION=$1;
if [ "$#" -eq "4" ]; then
	DOMAIN=$2;
	NAME=$3;
	ADDR=$4;
else
	TYPE=$2;
	DOMAIN=$3;
	NAME=$4;
	ADDR=$5;
fi;

if [ -n "$TYPE" ]; then
	if [ -z "`echo $TYPE | egrep "(A|CNAME)"`" ]; then
		echo "Invalid optional type specified.";
		exit 1;
	fi;
else
	TYPE="A";
fi;

# Check for valid internal/external
if [ -z "`echo $LOCATION | egrep "(internal|external)"`" ]; then
	echo "Invalid internal/external specified.";
	exit 1;
fi;

# Check for the zone file
if [ ! -w "$NAMED_PATH/$LOCATION/$DOMAIN.zone.db" ]; then
	echo "Invalid domain specified.";
	echo "Valid domains are:"; 
	for domain in `ls $NAMED_PATH/$LOCATION/ | grep zone.db$ | sed 's/\.zone\.db//'`; do
		echo "	$domain";
	done;
	exit 1;
fi;

DOMAIN_FILE="$NAMED_PATH/$LOCATION/$DOMAIN.zone.db";

# Check for duplicates
if [ -n "`grep ^$NAME\.$DOMAIN $DOMAIN_FILE`" ]; then
	echo "Address already exists:"
	echo "	`cat $DOMAIN_FILE | grep ^$NAME\.$DOMAIN`";
	exit 1;
fi;

# Check the address depending on the type
if [ "$TYPE" == "A" ]; then
	if [ -z "`echo $ADDR | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"`" ]; then
		echo "Invalid address specified.";
		exit 1;
	fi;
else
	if [ -z "`echo "$ADDR" | grep "^[\.a-zA-Z0-9-]*\.[a-zA-Z]\{2,3\}$"`" ]; then
		echo "Invalid address specified.";
		exit 1;
	fi;
fi;

# Check the name
if [ -z "`echo $NAME | grep "^[a-zA-Z0-9-]*$"`" ]; then
	echo "Invalid name specified.";
	exit 1;
fi;

# Backup the files were going to modify..
`$BINPATH/make_local_backup.sh $LOCATION`;

if [ "$TYPE" == "A" ]; then
	echo "$NAME.$DOMAIN.	IN	A	$ADDR" >> $DOMAIN_FILE;
else
	echo "$NAME.$DOMAIN.	CNAME		$ADDR" >> $DOMAIN_FILE;
fi;

if [ "`$BINPATH/verify_good.sh $LOCATION $DOMAIN | tail -1`" == "OK" ]; then
	echo "Verified as good zonefile.";
	exit 0;
else
	echo "There was an error in the name file..";
	echo "`$BINPATH/verify_good.sh $LOCATION $DOMAIN`";
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
	echo "!! The latest backup is	!!";
	echo "!! in $LOCAL_BACKUP_PATH	!!";
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
	exit 1;
fi;
