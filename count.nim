import os, strutils

var i: int = 0
let target = parseInt(paramStr(1))
while i < target:
  i = (i + 1) or 1
echo i
