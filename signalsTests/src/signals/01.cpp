#include <sys/types.h>
#include <signal.h>
#include <unistd.h>

int main() {
        kill(getpid(), SIGFPE);
        while (1) {
                sleep(1);
        }
        return 0;
}
