#include <cstdio>

int main()
{
	FILE *out1, *out2;
	out1 = fopen("output1.txt", "w");
	out2 = fopen("output2.txt", "w");
	for (int i = 0; i < 600; ++i)
	{
		fprintf(out1, "a");
		fprintf(out2, "a");
	}
	return 0;
}