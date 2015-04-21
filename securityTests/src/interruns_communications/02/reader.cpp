#include <iostream>
#include <Windows.h>

using namespace std;

int main()
{
    HKEY hKey;

    LPSTR var = "SOFTWARE\\OtherTestSoftware";

    RegCreateKeyExA(HKEY_CURRENT_USER, var, 0, NULL, 0, KEY_ALL_ACCESS, NULL, &hKey, NULL);

    DWORD type;
    char* buffer = (char*)malloc(sizeof(char) * 100);
    DWORD size = 100;

    RegQueryValueExA(hKey, var, NULL, &type, (LPBYTE)buffer, &size);

    printf("%s", buffer);

    return 0;
}