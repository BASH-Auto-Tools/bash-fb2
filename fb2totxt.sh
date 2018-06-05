#!/bin/sh

#fb2totext.sh
#Depends: dash, sed, file, less, unzip, zcat

sname="Fb2totxt"
sversion="0.20180605"

echo "$sname $sversion"

tnocomp=""
tcomp="sed"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="file"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="less"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="unzip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="zcat"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!"
    echo ""
    exit 1
fi

fless="false"
fzip="false"
fgzip="false"
fhlp="false"
while getopts ":lo:gzh" opt
do
    case $opt in
        l) fless="true"
            ;;
        o) dst="$OPTARG"
            ;;
        h) fhlp="true"
            ;;
        g) fgzip="true"
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
    echo "    -l             less (default = false)"
    echo "    -o name.txt    name text file (default = stdout)"
    echo "    -g             force gunzip (default = false)"
    echo "    -z             force unzip (default = false)"
    echo "    -h             help"
    exit 0
fi

if [ ! -f "$src" ]
then
    echo "Not found $src!"
    exit 1
fi

if [ "x$src" = "x$dst" ]
then
    dst="$dst.txt"
fi

sedcmd='s/<body>/\n&\n/;s/<\/body>/\n&\n/;1,/<body>/d;/<\/body>/,$d;s/<[^>]+>//g;/^[[:space:]]*$/d'
fcompr=$(file -b -i  "$src")
[ "x$fzip" = "xtrue" ] && fcompr="application/zip; charset=binary"
[ "x$fgzip" = "xtrue" ] && fcompr="application/gzip; charset=binary"

if [ "x$fcompr" = "xapplication/zip; charset=binary" ]
then
    if [ "x$fless" = "xtrue" ]
    then
        unzip -c "$src" | sed -r "$sedcmd" | less
    else
        if [ -z "$dst" ]
        then
            unzip -c "$src" | sed -r "$sedcmd"
        else
            unzip -c "$src" | sed -r "$sedcmd" > "$dst"
        fi
    fi
elif [ "x$fcompr" = "xapplication/gzip; charset=binary" ]
then
    if [ "x$fless" = "xtrue" ]
    then
        zcat "$src" | sed -r "$sedcmd" | less
    else
        if [ -z "$dst" ]
        then
            zcat "$src" | sed -r "$sedcmd"
        else
            zcat -c "$src" | sed -r "$sedcmd" > "$dst"
        fi
    fi
else
    if [ "x$fless" = "xtrue" ]
    then
        sed -r "$sedcmd" "$src" | less
    else
        if [ -z "$dst" ]
        then
            sed -r "$sedcmd" "$src"
        else
            sed -r "$sedcmd" "$src" > "$dst"
        fi
    fi
fi
