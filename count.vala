int main(string[] args) {
  int target = int.parse(args[1]);
  int i = 0;
  while (i < target) {
    i = (i + 1) | 1;
  }

  stdout.printf("%d\n", i);
  return 0;
}
