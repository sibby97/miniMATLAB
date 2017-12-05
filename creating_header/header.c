#include "header.h"
#define B_SIZE 20		//Buffer size
#define ERR 1
#define OK 0

int printInt(int n){		//for printing we will have to make a system call - using assembly code
	char b[B_SIZE];
	char zero = '0';
	int i=0;
	char temp;
	int p;
	int t = n;
	int size;
	if(n == 0){
		b[i] = zero;
		i++;
	}
	else{
		if(n<0){
			b[i] = '-';
			n = -n;
			i++;
		}
		while(n){		//put the integer in the buffer array
			t = n%10;
			b[i] = t + zero;
			n = n/10;
			i++;
		}
		t = i-1;
		size = i;
		if(b[0] == '-'){
			i = 1;
		}
		else{
			i = 0;
		}
		while(i<t){		//reversing the order of the array, since the integer was stored backwards
			temp = b[i];
			b[i] = b[t];
			b[t] = temp;
			i++;
			t--;
		}
	}
	b[size] = '\n';		
	size = size+1;

	__asm__ __volatile__(
			"movl $1, %%eax \n\t"
			"movq $1, %%rdi \n\t"
			"syscall \n\t"
			:"=a"(p)
			:"S"(b),"d"(size)
		);
	if(p<=0){
		return ERR;
	}
	else{
		return p;
	}


}