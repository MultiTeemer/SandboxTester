#include <unistd.h>

int main() {

    execv("/bin/bash", NULL);
    execv("/bin/sh", NULL);
    execv("/bin/csh", NULL);
    execv("/bin/ksh", NULL);
    execv("/bin/pdksh", NULL);

    return 0;
}
