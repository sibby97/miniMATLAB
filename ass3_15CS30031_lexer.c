#include "lex.yy.c"

int main(){
	int token;
	int i;
	while(token=yylex())
	{
		if(token==IDENTIFIER)
			printf("<IDENTIFIER,%d,%s>\n",token,yytext);
		else if(token==CONSTANT)
			printf("<CONSTANT,%d,%s>\n",token,yytext);
		else if(token==STRINGLITERAL)
			printf("<STRINGLITERAL,%d,%s>\n",token,yytext);
		else if(token>=opencurly && token<=trans)
			printf("<PUNCTUATOR,%d,%s>\n",token,yytext);
		else if(token>=UNSIGNED && token<=MATRIX)
			printf("<KEYWORD,%d,%s>\n",token,yytext);
	}
	return 0;
}