#include <cstdlib>
#include <ctime>

int a[(int)1e6];

int main()
{
	clock_t goal = 500 + clock();

	while (goal > clock());
    
    return 0;
}