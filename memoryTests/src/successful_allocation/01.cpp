#include <cstdlib>
#include <ctime>

int main()
{
    int* a = (int*) malloc(sizeof(int) * (int) 1e6);
    	clock_t goal = 500 + clock();

	while (goal > clock());
    
    return 0;
}