i = 0
target = parse(Int, ARGS[1])
while i < target
  global i = (i + 1) | 1
end
println(i)
