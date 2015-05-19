#include <windows.h>

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