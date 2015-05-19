#include <windows.h>
#include <cstdlib>

static const int size = 1000000;

int main()
{
	int* a = (int*)VirtualAlloc(NULL, sizeof(int) * size, MEM_COMMIT, PAGE_EXECUTE);
	memset(a, 0, sizeof(int) * size);
	return 0;
}