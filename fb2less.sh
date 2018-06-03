#!/bin/sh

if [ -z "$1" ]
then
	echo "USAGE: bash $0 fb2"
	exit 1
else
	src="$1"
fi

sed -r 's/<body>/\n&\n/;s/<\/body>/\n&\n/;1,/<body>/d;/<\/body>/,$d;s/<[^>]+>//g;/^[[:space:]]*$/d' "$src" | less
