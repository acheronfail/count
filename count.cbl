identification division.
program-id. count.

data division.
working-storage section.
01 i pic 9(10) value 0 usage comp-5.
01 target pic 9(10).
01 len pic 9(10) value 1.
01 or-result pic 9(10).
01 result pic z(10).

procedure division.
accept target from command-line
perform until i >= target
    add 1 to i
    call "CBL_OR" using 1 i by value len returning or-result end-call
end-perform.
move i to result
display result
stop run.
