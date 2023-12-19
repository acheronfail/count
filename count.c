#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int i = 0;
  int target = atoi(argv[1]);
  while(i < target) {
    i = (i + 1) % 2000000000;
  }
  printf("%d\n", i);
  return 0;
}
