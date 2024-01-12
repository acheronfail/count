# run this with:

# catch program exit
catch syscall exit
run

# capture program pid
python
gdb.execute("set $pid = " + str(gdb.selected_inferior().pid))
end

# while it's still running, extract rss from /proc
eval "shell cat /proc/%d/smaps_rollup > rss.txt", $pid

# allow program to exit, and exit gdb
# when gdb is run with the `-return-child-result` flag it will cause gdb to exit
# with the same code the child did
continue
exit
