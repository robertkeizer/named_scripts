#!/usr/bin/env bash
NAMED_SCRIPTS_ROOT="`echo $0 | sed 's/restart_named.sh//'`";
source $NAMED_SCRIPTS_ROOT/vars;

$NAMED_SCRIPTS_ROOT/check_all.sh
if [ $? -ne 0 ]; then
	echo "Will not restart named since you have errors.";
	exit 1;
fi;

for master_slave in $MASTER_SLAVE; do
	for location in `ls $NAMED_PATH/$master_slave | egrep "$LOCATION_REGEX"`; do
		echo -n "Transferring: $location ...";
		scp -P$REMOTE_PORT -i$REMOTE_KEY -r $NAMED_PATH/$master_slave/$location $REMOTE_USER@$REMOTE_SERVER:$NAMED_PATH/$master_slave >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo " failed.";
			exit 1;
		else
			echo " okay.";
		fi;
	done;
done;

echo -n "Transferring: $NAMED_PATH/etc ...";
scp -P$REMOTE_PORT -i$REMOTE_KEY -r $NAMED_PATH/etc $REMOTE_USER@$REMOTE_SERVER:$NAMED_PATH/ >/dev/null 2>&1;
if [ $? -ne 0 ]; then
	echo " failed.";
	exit 1;
else
	echo " okay.";
fi;

echo -n "Reloading local ...";
pkill -HUP named;
if [ $? -ne 0 ]; then
	echo " failed.";
	exit 1;
else
	echo " okay.";
fi;

echo -n "Reloading remote ...";
ssh -p$REMOTE_PORT -i$REMOTE_KEY $REMOTE_USER@$REMOTE_SERVER -C "pkill -HUP named";
if [ $? -ne 0 ]; then
	echo " failed.";
	exit 1;
else
	echo " okay.";
fi;
