int foo(int a)
{
    return a;
}

int main()
{
    for (int i = 0; i < 100; ++i)
        foo(i) + foo(i) * foo(i);
    return 0;
}