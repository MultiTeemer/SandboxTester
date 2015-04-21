#include <iostream>
#include <Windows.h>

using namespace std;

int main()
{
    HKEY hKey;

    LPSTR var = "SOFTWARE\\OtherTestSoftware";

    RegCreateKeyExA(HKEY_CURRENT_USER, var, 0, NULL, 0, KEY_ALL_ACCESS, NULL, &hKey, NULL);

    RegSetValueExA(hKey, var, 0, REG_SZ, (const LPBYTE)"some data", 10);

    return 0;
}