import sys

i = 0
target = int(sys.argv[1])
while i < target:
  i = (i + 1) % 2000000000

print(i)
