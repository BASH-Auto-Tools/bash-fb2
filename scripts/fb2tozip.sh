#!/bin/bash

#fb2tozip.sh
#Depends: dash, zip, unzip

sname="Fb2toZip"
sversion="0.20180810"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="file"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="zip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="unzip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

fhlp="false"
fzip="false"
fdzip="false"
while getopts ":cdo:h" opt
do
    case $opt in
        c) fzip="true"
            ;;
        d) fdzip="true"
            ;;
        o) tdest="$OPTARG"
            ;;
        h) fhlp="true"
            ;;
        *) echo "Unknown option -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift "$(($OPTIND - 1))"
src="$1";

if [ "x$src" = "x" -o "x$fhlp" = "xtrue" ]
then
    echo "Usage:"
    echo "$0 [options] book.fb2[.zip]"
    echo "Options:"
    echo "    -c        force compress book"
    echo "    -d        force decompress book"
    echo "    -o str    name pack/unpack file (default = [source.fb2].zip/[source].fb2)"
    echo "    -h        help"
    exit 0
fi

tname="book.fb2"
fcompr=$(file -b -i  "$src")
[ "x$fzip" = "xtrue" ] && fcompr="application/xml; charset=utf-8"
[ "x$fdzip" = "xtrue" ] && fcompr="application/zip; charset=binary"

if [ "x$fcompr" = "xapplication/zip; charset=binary" ]
then
    if [ "x$tdest" = "x" ]
    then
        tdest="${src%.zip}"
    fi
    if [ "x$tdest" = "x" -o "x$tdest" = "x$src" ]
    then
        tdest="$src.$$"
    fi
    unzip -cp "$src" > "$tdest" && echo "$src -> $tdest"
else
    if [ "x$tdest" = "x" ]
    then
        tdest="$src.zip"
    fi
    if [ "x$src" = "x$tname" ]
    then
        zip "$tdest" "$tname"
    else
        cp -fv "$src" "$tname"
        zip "$tdest" "$tname"
        rm -fv "$tname"
    fi
fi
