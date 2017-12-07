%{
	#include "ass4_15CS30031_translator.h"
	#include "ass4_15CS30031.tab.h"
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
%}
%option noyywrap

%x singleline multiline
/*regular expressions*/
ws [ \t\n\r]+

/*keywords*/ 


/*identifiers*/
digit [0-9]
nondigit [_A-Za-z]
id {nondigit}({nondigit}|{digit})*

/*constants*/
escape-seq ("\\’"|"\\”"|"\\?"|"\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v")
character-constant '([^'\n\\]|{escape-seq})+'
exponent-part [eE](\+|\-)?{digit}+
floating-constant ((({digit}*\.{digit}+)|({digit}+\.)){exponent-part}?)|({digit}+{exponent-part})
nonzero-digit [1-9]
integer-constant {digit}*
zero-constant 0
constant ({integer-constant}|{floating-constant}|{character-constant}|{zero-constant})

/*string literals*/
string-literal \"([^\"\n\\]|{escape-seq})*\"

/*punctuators*/

%%
"unsigned"			{return UNSIGNED;}
"break"				{return BREAK;}
"return"			{return RETURN;}
"void"				{return VOID;}
"case"				{return CASE;}
"float"				{return FLOAT;}
"short"				{return SHORT;}
"char"				{return CHAR;}
"for"				{return FOR;}
"signed"			{return SIGNED;}
"while"				{return WHILE;}
"goto"				{return GOTO;}
"Bool"				{return BOOL;}
"continue"			{return CONTINUE;}
"if"				{return IF;}
"default"			{return DEFAULT;}
"do"				{return DO;}
"int"				{return INT;}
"switch"			{return SWITCH;}
"double"			{return DOUBLE;}
"long"				{return LONG;}
"else"				{return ELSE;}
"Matrix"			{return MATRIX;}
{id}				{yylval.symbolEntryPointer = table->lookup(yytext);
					return IDENTIFIER;}
{character-constant}	{yylval.charval = yytext[1];
					return char_CONSTANT;}
{integer-constant}	{yylval.intval = atoi(yytext);
					return int_CONSTANT;}
{floating-constant}	{yylval.strval = yytext;
					return double_CONSTANT;}
{string-literal} 	{yylval.strval = yytext;
					return STRINGLITERAL;}
\{					{return OPENCURLY;}
\}					{return CLOSECURLY;}
\[					{return OPENSQ;}
\]					{return CLOSESQ;}
\(					{return OPENBRAC;}
\)					{return CLOSEBRAC;}
\.					{return FULLSTOP;}
\-\>				{return ARROW;}
\+\+				{return PLUSPLUS;}
\-\-				{return MINUSMINUS;}
\&					{return AND;}
\*					{return MULTIPLY;}
\+					{return PLUS;}
\-					{return MINUS;}
\~					{return WAVE;}
\!					{return NEGATE;}
\/					{return DIVIDE;}
\%					{return MOD;}
\<\<				{return LEFTLEFT;}
\>\>				{return RIGHTRIGHT;}
\<					{return LESS;}
\>					{return GREAT;}
\<\=				{return LESSEQ;}
\>\=				{return GREATEQ;}
\=\=				{return EQ;}
\!\=				{return NOTEQ;}
\^					{return CAP;}
\|					{return OR;}
\&\&				{return ANDAND;}
\|\|				{return OROR;}
\?					{return QUESTION;}
\:					{return COLON;}
\;					{return SEMICOLON;}
\=					{return ASSIGN;}
\*\=				{return MULASS;}
\/\=				{return DIVASS;}
\%\=				{return MODASS;}
\+\=				{return PLUSASS;}
\-\=				{return MINUSASS;}
\<\<\=				{return LEFTLEFTASS;}
\>\>\=				{return RIGHTRIGHTASS;}
\&\=				{return ANDASS;}
\^\=				{return CAPASS;}
\|\=				{return ORASS;}
\,					{return COMMA;}
\#					{return HASH;}
\.\'				{return TRANS;}
\/\/				{BEGIN(singleline);}
<singleline>.*		{}
<singleline>\n 		{BEGIN(0);}
\/\*				{BEGIN(multiline);}
<multiline>[^*]		{}
<multiline>[*]*		{}
<multiline>\*\/		{BEGIN(0);}	
{ws}				/*do nothing*/	
%%
