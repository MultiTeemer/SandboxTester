#include <cstdio>

int main()
{
	int a;
	scanf("%d", &a);
	FILE* out = fopen("output.txt", "w");
	fprintf(out, "%d", a);
	return 0;
}