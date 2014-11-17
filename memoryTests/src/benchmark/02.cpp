#include <ctime>

int main()
{
	clock_t goal = 500 + clock();

	while (goal > clock());

	return 0;
}