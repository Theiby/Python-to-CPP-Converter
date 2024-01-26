digit	[0-9]
letter	[A-Za-z]
%{
#include "y.tab.h"
int tabcount = 0;
unsigned int linenumber=1;
%}
%%

elif {  return ELIF ;}
if { return IF ;}
else { return ELSE;}

(<|>|<=|>=|==|!=) {yylval.str = strdup(yytext);return CONDITION;}
{letter}({letter}|{digit})*  { yylval.str = strdup(yytext); return VARIABLE;}

[*/+-]  {yylval.str = strdup(yytext);return OPERATOR;}
-?{digit}+\.{digit}+ { yylval.str = strdup(yytext);return FLT;}
-?{digit}+  { yylval.str = strdup(yytext);return INT;}
\"({letter}|{digit})*\" { yylval.str = strdup(yytext); return STR;}


\n {linenumber++; return LINENUMBER;}
:  return COLUMN;
=  return EQUAL;


(\t|[ ]{4})+ { //Pythonda bir tab 4 boşluğa eşit olduğundan 4 kullanıldı.
    tabcount =0;
    for(int i =0;i<=strlen(yytext);i++)
        if(yytext[i]=='\t')
            tabcount++;
    yylval.tab = tabcount;
    return TAB; //Koddaki tab sayısını döndürüyor
} 


[ ] //space



%%
