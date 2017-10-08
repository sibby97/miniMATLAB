#include <stdio.h>
#include "lex.yy.c"

int main(){
	printf("------------------TESTING THE PARSER-----------------\n\n");
	int p=yyparse();
	if(!p){
		printf("\n---------------------WORKING CORRECTLY-------------------\n");
	}
	else{
		printf("\n--------------------UNSUCCESSFUL--------------------\n");
	}
	return 0;
}