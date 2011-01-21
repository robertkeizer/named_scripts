#!/usr/bin/env bash
BINPATH=`echo $0 | sed 's/\/verify_all.sh//'`;
source "$BINPATH/vars";
echo "Starting to check zone files..";
for location in internal external; do
	for file in `ls $NAMED_PATH/$location/ | grep \.zone\.db$`; do
		domain=`echo $file | sed 's/\.zone\.db//'`;
		echo -n "$location: $domain ";
		if [ "`$BINPATH/verify_good.sh $location $domain | tail -1`" == "OK" ]; then
			echo "okay.";
		else
			echo "";
			echo "Bad zone file found:";
			echo "`$BINPATH/verify_good.sh $location $domain`";
			exit 1;
		fi;
	done;
done;

echo "All zone files verified good..";
echo "OK";
