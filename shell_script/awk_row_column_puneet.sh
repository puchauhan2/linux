
cat final.txt | awk 'NR!="'$r'" {print}'
cat final.txt | awk 'NR!="'$r'" {print $2}'

_row=`wc -l final.txt | awk '{print $1}'`

for r in ${_row}; do
_col=`cat final.txt | awk 'NR!="'$r'" {print}'`
echo ${_col[@]}
for i in ${list_server}; do
cat final.txt | awk 'NR!="'$r'" {print "'$i'"}'

done
done
