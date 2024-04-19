command-1 || command-2 || command-3 || ... command-n
Each command executes in turn for as long as the previous command returns false.
 At the first true return, the command chain terminates (the first command returning true is the last one to execute). 
 This is obviously the inverse of the "and list".