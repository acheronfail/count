i = 0
target = ARGV[0].to_i
while i < target do
  i = (i + 1) % 2000000000
end

puts i
