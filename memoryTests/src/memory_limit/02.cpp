#include <cstdlib>

static const int size = 10000;

long long a[size];

int main()
{
	//malloc(sizeof(int) * size * size);
	for (int i = 0; i < size; ++i)
		for (int j = 0; j < size; ++j)
			if (a[i] <= a[j])
			{
				long long t = a[i];
				a[i] = a[j];
				a[j] = t;
			}
	return 0;
}