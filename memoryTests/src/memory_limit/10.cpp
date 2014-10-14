#include <windows.h>
#include <cstdlib>

static const int size = 1000000;

int main()
{
	VirtualAlloc(NULL, sizeof(int) * size, MEM_COMMIT, PAGE_EXECUTE);
	return 0;
}