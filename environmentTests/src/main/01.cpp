#include <cstdio>

int main(int argc, char **argv, char** envp)
{
    char** env;

    int count = 0;
    for (env = envp; *env != 0; env++)
    {
        ++count;
    }

    printf("%d", count);
    return 0;
}