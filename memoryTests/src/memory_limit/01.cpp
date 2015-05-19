#include <cstdlib>

int main()
{
	int size = (int)1e6;
	int* p = (int*)malloc(sizeof(int) * size);
	for (int i = 0; i < size; ++i)
	{
		p[i] = 0;
	}
	return 0;
}