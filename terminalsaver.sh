#!/bin/sh

DIR=$(dirname "$1" | sed 's/\ /\\\ /g')'/'
BASE=$(basename "$1" .txt | sed 's/\ /\\\ /g')
FULL=$DIR$BASE

LINECOUNTER=1
CYCLERA=1
CYCLERB=2
BOOKMARK=0
BUFFER=''
THRESHOLD=5

if [ -v $2 ]
	then THRESHOLD=5
else
	THRESHOLD=$2
fi

touch .tmp
> .tmp
touch $BASE-Annotated.R
> $BASE-Annotated.R
grep -n '^>' $1 | cut -d : -f 1 > .tmp

LENGTH=$(cat $1 | wc -l | cut -f 1)
LAST=$(tail -n 1 .tmp)
LAST=$(( $LAST + $LAST ))
# echo $LENGTH >> .tmp
echo $LAST >> .tmp
LINECOUNTER=$(head -n 1 .tmp)
while [ $LINECOUNTER -lt $LENGTH ]
do
	BUFFER=$(head -n $LINECOUNTER $1 | tail -n 1 | grep '^>')
	
	if [ "$BUFFER" != $'' ]
	then
		BUFFER=$(head -n $LINECOUNTER $1 | tail -n 1 | sed 's/^> //')
		echo $BUFFER >> $BASE-Annotated.R
		echo "Printing line "$LINECOUNTER':' $BUFFER
		LINECOUNTER=$(( $LINECOUNTER + 1 ))
	else
		CURRENT=$(head -n $CYCLERA .tmp | tail -n 1)
		NEXT=$(head -n $CYCLERB .tmp | tail -n 1)
		DIFF=$(( $NEXT - $CURRENT ))
		if  [ $DIFF -lt $THRESHOLD ]
		then
			DIFF=$(( $DIFF - 1 ))
			LINECOUNTER=$(( $LINECOUNTER + $DIFF - 1 ))
			head -n $LINECOUNTER $1 | tail -n $DIFF | sed 's/^/#/' >> $BASE-Annotated.R
			CYCLERA=$(( $CYCLERA + 1 ))
			CYCLERB=$(( $CYCLERB + 1 ))
			echo "Printing "$DIFF" line(s) of output and stopping at line "$LINECOUNTER
			LINECOUNTER=$(( $LINECOUNTER + 1 ))
		else
			BOOKMARK=$(( $LINECOUNTER + 5 ))
			LINECOUNTER=$(( $LINECOUNTER + $DIFF - 1 ))
			head -n $BOOKMARK $1 | tail -n 6 | sed $'s/^/#\t/' >> $BASE-Annotated.R
			CYCLERA=$(( $CYCLERA + 1 ))
			CYCLERB=$(( $CYCLERB + 1 ))
			echo "Printing first 5 lines of output, omitting "$(( $DIFF - 5 ))", and stopping at line "$(( $LINECOUNTER - 1 ))
		fi
	fi
done
rm .tmp
grep -v '^#' $BASE-Annotated.R > $BASE.R
