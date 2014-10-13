#include <cstdlib>

void foo()
{
	malloc(sizeof(int) * 1000);
	foo();
}

int main()
{
	foo();
	return 0;
}