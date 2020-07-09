
void func()
{
	int *i,*p;
	i=0xbfc0100;
	p=0xbfaff000;
	*i=10;
	while(*i--)
	{
		*p=0xff000000;
	}
}
