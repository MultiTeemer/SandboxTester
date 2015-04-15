#include <exception>

using namespace std;

int main()
{
    try {
        throw exception();
    } catch (const exception& e) {

    }

    return 0;
}