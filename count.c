#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int i = 0;
  int target = atoi(argv[1]);
  while(i < target) i++;
  printf("%d\n", i);
  return 0;
}
