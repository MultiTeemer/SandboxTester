#include <cstdlib>
#include <cstdio>

int main(int argc, char* argv[])
{
	long long limit = atoll(argv[1]);

	printf("%ld", limit);	

	malloc(limit);

	return 0;
}