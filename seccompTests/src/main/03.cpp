#include <stdio.h>
#include <unistd.h>

int main() {
    FILE *f;

    f = tmpfile();

    return 0;
}
