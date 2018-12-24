// C代码部分
%{
#include "main.h"
#include "yacc.h"
%}

// 正则式定义
C						([_A-Za-z])
D						([0-9])


%%
#include([^\n])*		{}
\/\*(\s|.)*?\*\/		{yylval.sIndex=getStrIndex(yytext);return(COMMENT);}
\/\/([^\n])*			{yylval.sIndex=getStrIndex(yytext);return(COMMENT);}
"for"					{return(FOR);}
"break"					{return(BREAK);}
"continue"				{return(CONTINUE);}
"while"					{return(WHILE);}

"if"					{return(IF);}
"else"					{return(ELSE);}

"int"					{yylval.iType=intType;return(INT);}
"char"					{yylval.iType=charType;return(CHAR);}
"double"				{yylval.iType=doubleType;return(DOUBLE);}
"return"				{return(RETURN);}
"printf"				{return(PRINTF);}
"gets"					{return(GETS);}
"strlen"				{return(STRLEN);}
"strcmp"				{return(STRCMP);}
"isdigit"				{return(ISDIGIT);}

{C}({C}|{D})*			{yylval.sIndex=getIDIndex(yytext);return(IDENTIFIER);}
{D}+					{yylval.iValue=atoi(yytext);return(INTEGER);}
'(\\.|[^\\'])+'			{yylval.sIndex=getChrIndex(yytext);return(CHARACTER);}
\"(\\.|[^\\"])*\"		{yylval.sIndex=getStrIndex(yytext);return(STRING);}

{D}*"."{D}+				{yylval.dValue=atof(yytext);return(DOUBLE_NUM);}
{D}+"."{D}*				{yylval.dValue=atof(yytext);return(DOUBLE_NUM);}

"&&"					{return(AND_OP);}
"||"					{return(OR_OP);}
"=="					{return(EQ_OP);}
"!="					{return(NE_OP);}
"++"					{return(INC_OP);}
"--"					{return(DEC_OP);}
">="					{return(GE_OP);}
"<="					{return(LE_OP);}
";"						{return(';');}
"{"						{return('{');}
"}"						{return('}');}
"="						{return('=');}
"("						{return('(');}
")"						{return(')');}
"["						{return('[');}
"]"						{return(']');}
"-"						{return('-');}
"+"						{return('+');}
"*"						{return('*');}
"/"						{return('/');}
"<"						{return('<');}
">"						{return('>');}
","						{return(',');}
"!"						{return('!');}

[\t\n\r\v\f]			{}

.						{cout<<"Unknowncharacter"<<endl;}


%%


int yywrap(void)
{
	return 1;
}