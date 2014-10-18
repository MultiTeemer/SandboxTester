#include <cstdlib>

void foo()
{
	int a[100000];
	foo();
}

int main()
{
	foo();
	return 0;
}