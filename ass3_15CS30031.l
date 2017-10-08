%{
	#include <stdio.h>
	#include <string.h>
	#define YYPRINT
	#include "ass3_15CS30031.tab.c"
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
integer-constant {nonzero-digit}{digit}*
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
{id}				{return IDENTIFIER;}
{constant}			{return CONSTANT;}
{string-literal} 	{return STRINGLITERAL;}
\{					{return opencurly;}
\}					{return closecurly;}
\[					{return opensq;}
\]					{return closesq;}
\(					{return openbrac;}
\)					{return closebrac;}
\.					{return fullstop;}
\-\>				{return arrow;}
\+\+				{return plusplus;}
\-\-				{return minusminus;}
\&					{return and;}
\*					{return multiply;}
\+					{return plus;}
\-					{return minus;}
\~					{return wave;}
\!					{return negate;}
\/					{return divide;}
\%					{return mod;}
\<\<				{return leftleft;}
\>\>				{return rightright;}
\<					{return less;}
\>					{return great;}
\<\=				{return lesseq;}
\>\=				{return greateq;}
\=\=				{return eq;}
\!\=				{return noteq;}
\^					{return cap;}
\|					{return or;}
\&\&				{return andand;}
\|\|				{return oror;}
\?					{return question;}
\:					{return colon;}
\;					{return semicolon;}
\=					{return assign;}
\*\=				{return mulass;}
\/\=				{return divass;}
\%\=				{return modass;}
\+\=				{return plusass;}
\-\=				{return minusass;}
\<\<\=				{return leftleftass;}
\>\>\=				{return rightrightass;}
\&\=				{return andass;}
\^\=				{return capass;}
\|\=				{return orass;}
\,					{return comma;}
\#					{return hash;}
\.\'				{return trans;}
\/\/				{BEGIN(singleline);}
<singleline>.*		{}
<singleline>\n 		{BEGIN(0);}
\/\*				{BEGIN(multiline);}
<multiline>[^*]		{}
<multiline>[*]*		{}
<multiline>\*\/		{BEGIN(0);}	
{ws}				/*do nothing*/	
%%
