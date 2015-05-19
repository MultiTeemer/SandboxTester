#include <cstdlib>

static const int size = 1000000;

long long a[size];

int main()
{
	for (int i = 0; i < size; ++i)
	{
		a[i] = i;
	}
	return 0;
}