#include <windows.h>

static const int size = 1000000;

int main()
{
	LocalAlloc(LMEM_FIXED, sizeof(int) * size);
	return 0;
}