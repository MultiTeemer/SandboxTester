int main()
{
  int a[5];

  asm("bound %0, 10" : : "r"(a));

  return 0;
}
