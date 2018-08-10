#!/bin/sh

#fb2encode.sh
#Depends: dash, xmlstarlet

sname="Fb2XMLFix"
sversion="0.20180810"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="xmlstarlet"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

fhlp="false"
fquiet="false"
while getopts ":o:qh" opt
do
    case $opt in
        o) dst="$OPTARG"
            ;;
        q) fquiet="true"
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
    echo "$0 [options] book.fb2"
    echo "Options:"
    echo "    -o name.fb2    name fix book (default = source file)"
    echo "    -h             help"
    exit 0
fi

if [ "x$dst" = "x" ]
then
    dst="$src"
fi

if [ -f "$src" ]
then
    if [ "x$fquiet" = "xtrue" ]
    then
        xmlstarlet fo -R -Q "$src" > "verify.$$.xml"
    else
        xmlstarlet fo -R "$src" > "verify.$$.xml"
    fi
    if [ -s "verify.$$.xml" ]
    then
        mv -fv "verify.$$.xml" "$dst"
    else
        rm -fv "verify.$$.xml"
        echo " $src not parse!" >&2
    fi
else
    echo "$src not fb2 file!" >&2
fi
