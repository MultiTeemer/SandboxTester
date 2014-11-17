#include <cstdlib>
#include <ctime>

int main()
{
	const int size = (int) 1e6;
	int* a[10];
	for (int i = 0; i < 10; ++i)
		a[i] = (int*) malloc(sizeof(int) * size);
	
	return 0;
}