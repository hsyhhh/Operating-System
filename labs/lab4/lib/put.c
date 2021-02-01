#include"put.h"
int puts(const char *s)
{
    while (*s != '\0')
    {
        *UART16550A_DR = (unsigned char)(*s);
        s++;
    }
    return 0;
}
static char itoch(int x)
{
    if (x >= 0 && x <= 9)
    {
        return (char)(x + 48);
    }
    else if (x == 10)
        return 'a';
    else if (x == 11)
        return 'b';
    else if (x == 12)
        return 'c';
    else if (x == 13)
        return 'd';
    else if (x == 14)
        return 'e';
    else if (x == 15)
        return 'f';
    return 0;
}
void puti(int x)
{
    int digit = 1, tmp = x;
    while (tmp >= 10)
    {
        digit *= 10;
        tmp /= 10;
    }
    while (digit >= 1)
    {
        *UART16550A_DR = (unsigned char)itoch(x/digit);
        x %= digit;
        digit /= 10;
    }
    return;
}
void putlonglong(unsigned long long x)
{
    unsigned long long digit = 1, tmp = x;
    while (tmp >= 16)
    {
        digit *= 16;
        tmp /= 16;
    }
    *UART16550A_DR = (unsigned char)'0';
    *UART16550A_DR = (unsigned char)'x';
    while (digit >= 1)
    {
        *UART16550A_DR = (unsigned char)itoch(x/digit);
        x %= digit;
        digit /= 16;
    }
    return;
}
