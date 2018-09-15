extern void asm_main();
#include <stdio.h>
#include <stdint.h>

int main()
{

 	asm_main();
    return 0;
}


char* printnum(int16_t NumberPrint)
{
	char a[6];
	sprintf(a, "%06d", NumberPrint);
	char* buffer = &a[0];
	return buffer;
}

int16_t mult(int16_t x, int16_t y)
{

	return x * y;
}

int16_t divide(int16_t x, int16_t y)
{

	int16_t tmp=x / y;
	return tmp;
}

int16_t modulus(int16_t x, int16_t y)
{

	return x % y;
}
