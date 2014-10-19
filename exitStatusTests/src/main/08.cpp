#include <cstdlib>

int main()
{
	int * a = (int*) malloc(256);
	int b = *(a + 100000);
	return 0;
}