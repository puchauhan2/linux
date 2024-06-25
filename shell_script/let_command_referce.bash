
comma operator. The comma operator [1] links together a series of arithmetic operations. All are evaluated, but only the last one is returned.


let "t2 = ((a = 9, 15 / 3))"  # Set "a = 9" and "t2 = 15 / 3"

let "t2 = ((a = 9, 15*a / 3))" # t2 will be value of 45 


