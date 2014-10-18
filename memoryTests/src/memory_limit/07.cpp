#include <windows.h>

static const int size = 1000000;

int main()
{
	HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, sizeof(int) * size);
	return 0;
}