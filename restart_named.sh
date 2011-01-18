#!/usr/bin/env bash
BINPATH="`echo $0 | sed 's/\/restart_named.sh//'`";
source "$BINPATH/vars";

tmp_output="`$BINPATH/verify_all.sh`";
if [ "`echo "$tmp_output" | tail -1`" == "OK" ]; then
	echo "$tmp_output";
	# Reload the name server.
	pkill -HUP named;
	# Copy to other server and reload it too.
	# /usr/bin/scp -r $NAMED_PATH root@foobar:/var/named/
	# /usr/bin/ssh root@foobar -C "pkill -HUP named"
	echo "Restarted named.";
	echo "OK";
else
	echo "There were errors";
	echo "$tmp_output";
	exit 1;
fi;
