ls *.* > files

files=$(ls *.*)

contentNum=$(ls *.* | wc -l files | awk '{print $1}')

#filename=$(sed 's/\./ /g' files | awk '{print $1}')

extention=$(sed 's/\./ /g' files | awk '{print $2}')

echo $contentNum

for r in `seq 1 $contentNum`
do
  
 name=$( echo $files | awk '{printf $"'$r'"}' )
 type=$( echo $extention | awk '{printf $"'$r'"}' )
  
  echo $name
  echo $type

done


# cat pkg_install  | sed 's/\// /g'  | awk '{print $1}'

