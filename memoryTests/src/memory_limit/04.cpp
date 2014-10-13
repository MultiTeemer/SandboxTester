#include <cstdlib>

void foo()
{
	int a[1000];
	for (int i = 0; i < 1000; ++i)
		a[i] = -i;
	foo();
}

int main()
{
	foo();
	return 0;
}