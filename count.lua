local target = tonumber(arg[1])
local i = 0
while i < target do
   i = ((i + 1) | 1)
end
print(i)
