int main()
{
	asm("out %eax, $0x70");
	return 0;
}