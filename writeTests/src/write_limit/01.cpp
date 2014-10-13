#include <cstdio>

int main()
{
	FILE* out = fopen("bin/output.txt", "w");
	for (int i = 0; i < 10000000; ++i)
		fprintf(out, "%d\n", i);

	return 0;
}