#include "put.h"
void strap_print()
{
	static unsigned int count = 0;
	static unsigned int count_print = 0;
	count++;
	if(count >= 100000)
	{	
		count = 0;
		const char *s_msg = "[S] Supervisor Mode Timer Interrupt ";
		puts(s_msg);
		puti(count_print);
		puts("\n");
		count_print++;
	}
}

// void mtrap_print()
// {
// 	const char *m_msg = "[M] Machine Mode Timer Interrupt\n";
// 	puts(m_msg);
// }
