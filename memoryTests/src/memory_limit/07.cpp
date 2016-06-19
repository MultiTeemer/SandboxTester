#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#else
#include <stdlib.h>
#define HeapAlloc(A, B, C) malloc(C)
#endif

static const int size = 1000000;

int main()
{
	int* a = (int*)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, sizeof(int) * size);
	for (int i = 0; i < size; ++i)
	{
		a[i] = 0;
	}
	return 0;
}
