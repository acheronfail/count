set i 0
set target [lindex $argv 0]
while {$i < $target} {
    set i [expr {$i + 1} | 1]
}
puts $i
