#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

int main() {
    int s;
    s = socket(AF_INET, SOCK_STREAM, 0);

    return 0;
}
