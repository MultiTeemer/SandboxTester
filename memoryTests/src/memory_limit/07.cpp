#include <windows.h>

static const int size = 1000000;

int main()
{
	GlobalAlloc(GMEM_FIXED, sizeof(int) * size);
	return 0;
}