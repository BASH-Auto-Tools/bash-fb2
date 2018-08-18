#!/bin/sh

#fb2toinfo.sh
#Depends: dash, sed, file, unzip, zcat

sname="Fb2toinfo"
sversion="0.20180819"

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

fauth="false"
fcnt="false"
fzip="false"
fhlp="false"
while getopts ":aco:zh" opt
do
    case $opt in
        a) fauth="true"
            ;;
        c) fcnt="true"
            ;;
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
    echo "    -a             list authors (default = false)"
    echo "    -c             list content (default = false)"
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
sedcmdc='/<title>/,/<\/title>/p;'
sedcmdu='s/<[^>]+>//g;/^[[:space:]]*$/d'
sedcmdua='s/<[^>]+>/ /g;/^[[:space:]]*$/d'
fcompr=$(file -b -i  "$src")
[ "x$fzip" = "xtrue" ] && fcompr="application/zip; charset=binary"

if [ "x$fcompr" = "xapplication/zip; charset=binary" ]
then
    if [ "x$fcnt" = "xtrue" ]
    then
        finfo=$(unzip -c "$src" | sed -n -e "$sedcmdc")
    else
        finfo=$(unzip -c "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds")
    fi
else
    if [ "x$fcnt" = "xtrue" ]
    then
        finfo=$(zcat "$src" | sed -n -e "$sedcmdc")
    else
        finfo=$(zcat "$src" | sed -e "$sedcmdf" | sed -n -e "$sedcmds")
    fi
fi
if [ "x$fauth" = "xtrue" ]
then
    finfo=$(echo "$finfo" | sed -n -e '/<author>/,/<\/author>/p' | sed -e 's/<author>//;s/<\/author>/ /' | sed -e :a -e '/>$/N; s/\n//; ta' | sed -e '/^ *$/d;' | sed -e 's/\(^.*\)\(<last-name>.*<\/last-name>\)/\2\1/' | sed -e 's/> *</></g')
    finfo=$(echo "$finfo" | sed -r "$sedcmdua" | sed -e 's/^ *//g;s/ *$//g;s/  / /g')
else
    finfo=$(echo "$finfo" | sed -r "$sedcmdu")
fi
if [ -z "$dst" ]
then
    echo "$finfo"
else
    echo "$finfo" > "$dst"
fi
