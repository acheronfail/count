# run this with:

# catch program exit
catch syscall exit exit_group
python
# NOTE: for some reason we can't catch erlang's exit on its main thread, so we
# just catch the first exit. This is okay: testing locally shows that the count
# is completed before the first thread exits.
if not '/erl' in gdb.execute("show args", to_string=True):
  gdb.execute("condition 1 $_thread == 1")
end
run

# capture program pid
python
gdb.execute("set $pid = " + str(gdb.selected_inferior().pid))
end

# while it's still running, extract rss from /proc
eval "shell cat /proc/%d/smaps_rollup > rss.txt", $pid

# TODO: rather than just terminating here it would be nice to let the program
# continue and allow `-return-child-result` to set the exit code to catch any
# unexpected errors. But weird things happen with multithreaded programs.
# An alternative could be to check that the value in `$rdi` is `0`, since we're
# catching the exit syscalls.
quit
