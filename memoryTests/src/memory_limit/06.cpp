#include <windows.h>

static const int size = 1000000;

int main()
{
	int* a = (int*)LocalAlloc(LMEM_FIXED, sizeof(int) * size);
	for (int i = 0; i < size; ++i)
	{
		a[i] = 0;
	}
	return 0;
}