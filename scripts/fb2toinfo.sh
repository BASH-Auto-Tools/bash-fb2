#!/bin/sh

#fb2toinfo.sh
#Depends: dash, sed, file, unzip, zcat

sname="Fb2toinfo"
sversion="0.20180806"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="sed"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="file"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="unzip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="zcat"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

fzip="false"
fhlp="false"
while getopts ":o:zh" opt
do
    case $opt in
        o) dst="$OPTARG"
            ;;
        h) fhlp="true"
            ;;
        z) fzip="true"
            ;;
        *) echo "Unknown option -$OPTARG"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND - 1))"
src="$1";

if [ "x$src" = "x" -o "x$fhlp" = "xtrue" ]
then
    echo "Usage:"
    echo "$0 [options] book.fb2"
    echo "Options:"
    echo "    -o name.txt    name text file (default = stdout)"
    echo "    -z             force unzip (default = false)"
    echo "    -h             help"
    exit 0
fi

if [ ! -f "$src" ]
then
    echo "Not found $src!" >&2
    exit 1
fi

if [ "x$src" = "x$dst" ]
then
    dst="$dst.txt"
fi

sedcmdf='s/<body>/\n&\n/;s/<\/body>/\n&\n/;'
sedcmds='/<description/,/<\/description>/p;'
sedcmdu='s/<[^>]+>//g;/^[[:space:]]*$/d'
fcompr=$(file -b -i  "$src")
[ "x$fzip" = "xtrue" ] && fcompr="application/zip; charset=binary"
[ "x$fgzip" = "xtrue" ] && fcompr="application/gzip; charset=binary"

if [ "x$fcompr" = "xapplication/zip; charset=binary" ]
then
    if [ -z "$dst" ]
    then
        unzip -c "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds" | sed -r "$sedcmdu"
    else
        unzip -c "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds" | sed -r "$sedcmdu" > "$dst"
    fi
else
    if [ -z "$dst" ]
    then
        zcat "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds" | sed -r "$sedcmdu"
    else
        zcat "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds" | sed -r "$sedcmdu" > "$dst"
    fi
fi
