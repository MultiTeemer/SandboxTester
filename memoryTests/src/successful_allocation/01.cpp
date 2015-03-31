#include <cstdlib>
#include <ctime>

int main()
{
    int* a = (int*) calloc(sizeof(int) * (int) 1e6, 1);
    	
    clock_t goal = 500 + clock();

	while (goal > clock());
    
    return 0;
}