\ tip: use `.s CR` to print the stack
: count-fn  ( n -- n )
    0                       \ init "i"
    begin over over > while \ '>' pops 2 off stack, and `while` pops 1
        1+ 1 or
    repeat
    swap drop               \ return "i"
;

: main
    next-arg                \ Get the next argument from the command line
    s>number drop           \ Convert the string argument to a number and drop the string
    count-fn . CR           \ Call count-fn with the argument, print the result, and print a newline afterwards
;

main
bye
