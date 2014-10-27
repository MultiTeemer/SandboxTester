#include <cstdlib>

int main()
{
	int* p = (int*) malloc(sizeof(int) * 1000000);
	free(p);
	return 0;
}