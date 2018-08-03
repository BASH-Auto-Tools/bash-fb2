#!/bin/sh

#fb2encode.sh
#Depends: dash, grep, sed, iconv

sname="Fb2Encode"
sversion="0.20180803"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="grep"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="sed"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="iconv"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

dc="utf-8"
fhlp="false"
while getopts ":c:o:h" opt
do
    case $opt in
        c) dc="$OPTARG"
            ;;
        o) dst="$OPTARG"
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
    echo "    -c str         dest code (default = utf-8)"
    echo "    -o name.fb2    name encode file (default = source file)"
    echo "    -h             help"
    exit 0
fi

if [ "x$dst" = "x" ]
then
    dst="$src"
fi

if [ -f "$src" ]
then
    nc=$(cat "$src" | grep -m 1 -no "<?xml " | sed 's/\:.*$//')
    if [ "x$nc" != "x" ]
    then
        tc=$(cat "$src" | grep -m 1 -n "<?xml " | sed -e 's/>/&\n/g' | grep -m 1 -n "<?xml " | sed -e 's/^.*encoding=\"//;s/\".*$//')
        if [ "x$tc" != "x" -a "x$tc" != "x$dc" ]
        then
            echo "$tc -> $dc = $src.$dc"
            iconv -c -f "$tc" -t "$dc" "$src" > "$src.$dc"
            sed -i -e "${nc}s/$tc/$dc/;s/\x0D$//" "$src.$dc"
            mv -fv "$src.$dc" "$dst"
        fi
    else
        echo "$src not fb2 file!" >&2
    fi
fi
