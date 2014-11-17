#include <ctime>
#include <cstdlib>

void foo()
{
    int *a = (int*) malloc(sizeof(int) * (int) 1e6);
}

int main()
{
    foo();
	
	clock_t goal = 500 + clock();

	while (goal > clock());
    
    return 0;
}