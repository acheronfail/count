var i = 0
let target = Int(CommandLine.arguments[1])!
while i < target {
  i = (i + 1) | 1;
}

print("\(i)")