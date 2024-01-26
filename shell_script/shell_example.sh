# TO read csv file 

while IFS="," read f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
do 
	echo $f1
	echo $f2
	echo $f3
	echo $f4
	echo $f5
	echo $f6
	echo $f7
	echo $f8
	echo $f9
	echo $f10
done < cities.csv

while IFS="," read id name addr 
do 
	echo $id
	echo $name
	echo $addr

done < cities.csv

# new to read csv and skip first

cat cities.csv | awk 'NR!=1 {print}' | while IFS="," read f1 f2 f3 ; do echo $f1; done

----------------------------------------------------------
# argument in numbers 

#Number of orgument = $#
#Display all orgument = $@
# orgument : $1 $2 $3 ...

add (){

	local num1=$1
	local num2=$2

	let sum=$num1+$num2 # let is important otherwise output will be "2+3
echo "sum of number is $sum"

}

add 2 3

# "shift" used for to make alll remaining unused orgument as one orgument 

example_1 (){

echo "first arg = $1"
echo "Second arg = $2"
shift
echo "remaining orgument = $@"

}
example_1 one two three four five six

#USeful keyword 

basename return filename only from full file path
dirname  return dir path where file exit and skip file name
realpath return full path if file name given as orgument