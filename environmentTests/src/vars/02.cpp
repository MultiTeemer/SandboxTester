#include <cstdio>
#include <cstdlib>

int main(int argc, char** argv)
{
    printf("%s", getenv(argv[1]));

    return 0;
}