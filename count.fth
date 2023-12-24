: count-fn  ( n -- n )
    0 swap                  \ Initialize 'i' and put 'target' on the top of the stack
    begin dup over >= until \ Begin a loop that continues while 'i' < 'target'
        1+ dup 1 or swap    \ Increment 'i', then bitwise OR with 1, duplicate it and swap
    drop                    \ Drop 'target', leaving the final 'i' on the stack
;

: main
    next-arg                \ Get the next argument from the command line
    s>number drop           \ Convert the string to a number and drop the string
    count-fn . CR           \ Call count-fn with the argument and print a newline afterwards
;

main                        \ Call our main function
bye
