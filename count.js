let i = 0;
let target = parseInt(process.argv[2]);
while (i < target) i = (i + 1) % 2000000000;
console.log(i);
