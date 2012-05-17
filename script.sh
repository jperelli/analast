#!/bin/bash

FIRST="2012-04-10"
DAYS=30
WHAT="$1"

echo WHAT=$WHAT
cat /var/log/wtmp* > /tmp/wtmp

MAX="0"

(for DAY in $(seq 1 $DAYS)
do
  TODAY=$(LANG=C date -d "$FIRST $DAY days" | tr -s " " | cut -d" " -f2,3,6)
  CANT=$(last -wRFf /tmp/wtmp | tr -s " " | cut -d"-" -f1 | cut -d" " -f1,4,5,7 | sort | uniq | grep "$WHAT" | grep "$TODAY" | wc -l)
  if [ "$CANT" > "$MAX" ]
  then
    MAX=$CANT
  fi
  DATE=$(date -d "$TODAY" +"%d/%m/%Y")
  echo $DATE $CANT
done) > /tmp/logins.dat

echo $MAX

gnuplot <<- EOP > logins.png
  set xdata time
  set timefmt "%d/%m/%y %H:%M"
  set format x "%d/%m"
  set yrange [0:50]
  #set xrange ["19/03/2012":"27/04/2012"]
  set terminal png
  plot "/tmp/logins.dat" using 1:2 with lines
EOP
