str="abcdefghijklmnopqrstuvwxyz"
len=${#str}
echo "Sting lenght ${len}"

reversed_string=""

for (( i=$len-1; i>=0; i-- ))
do
   reversed_string="$reversed_string${str:$i:1}"
done

echo "$reversed_string"