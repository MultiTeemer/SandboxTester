#include <cstdio>

int main()
{
	FILE* out = fopen("output.txt", "w");

	while (1)
		fprintf(out, "abcd");

	return 0;
}