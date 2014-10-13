#include <cstdlib>

void foo()
{
    int *a = (int*) malloc(sizeof(int) * (int) 1e6);
}

int main()
{
    foo();
    return 0;
}