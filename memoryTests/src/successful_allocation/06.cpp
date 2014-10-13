#include <cstdlib>

int main()
{
	for (int i = 0; i < 1000; ++i)
		malloc(sizeof(int) * (int) 1e6);
	return 0;
}