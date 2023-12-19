i = 0
target = ARGV[0].to_i.not_nil!
while i < target
  i = (i + 1) % 2000000000
end

puts i
