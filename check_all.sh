#!/usr/bin/env bash
vars="`echo $0 | sed 's/check_all.sh/vars/'`";
source $vars;

# Check the zones..
for master_slave in $MASTER_SLAVE; do
	for location in `ls $NAMED_PATH/$master_slave | egrep "$LOCATION_REGEX"`; do
		for file in `ls $NAMED_PATH/$master_slave/$location/ | egrep "$FILE_REGEX"`; do
			domain="`echo $file | sed 's/\.zone\.db$//'`";

			echo -n "$location: $domain ... ";
			named-checkzone -t $NAMED_PATH $domain /$master_slave/$location/$file >/dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo " failed.";
				exit 1;
			else
				echo " okay.";
			fi;
		done;
	done;
done;

echo -n "named config ...";
named-checkconf -t $NAMED_PATH >/dev/null 2>&1;
if [ $? -ne 0 ]; then
	echo " failed.";
	exit 1;
else
	echo " okay.";
fi;
