
#cat final.txt | awk 'NR!="'$r'" {print}'
#cat final.txt | awk 'NR!="'$r'" {print $2}'

_row=`awk '{print $1}' final.txt`
let i=1
let j=1
for r in ${_row}; do
_col=`cat final.txt | awk 'NR="'$i'" {print}'`
for c in ${_col}; do
cat final.txt | awk 'NR="'$i'" {print "'$j'"}'
let j++
done
let i++
done
