#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[]) {
  int i = 0;
  int target = std::atoi(argv[1]);
  while(i < target) {
    i = (i + 1) | 1;
  }
  std::cout << i << std::endl;
  return 0;
}
