let i = 0;
let target = parseInt(process.argv[2]);
while (i < target) i = (i + 1) | 1;
console.log(i);
