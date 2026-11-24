%option noyywrap
%option yylineno
%{
    #include<stdio.h>
    #include<string.h>
    #include "A1.tab.h"
    #include<stdlib.h>
%}
%%

"class" {return CLASS;}
"extends" {return EXTENDS;}
"public" {return PUBLIC;}
"static" {return STATIC;}    
"void" {return VOID;}  
"main" {return MAIN;}  
"String" {return STRING;}  
"int" {return INT;}  
"boolean" {return BOOLEAN;}  
"if" {return IF;}  
"else" {return ELSE;}  
"while" {return WHILE;}  
"return" {return RETURN;}  
"true" {return TRUE;}  
"false" {return FALSE;}  
"this" {return THIS;}
"new" {return NEW;}   
"System.out.println" {return PRINT;}
"length" {return LENGTH;}

"#defineStmt" {return DEFINE_STMT;}
"#defineStmt0" {return DEFINE_STMT0;}
"#defineStmt1" {return DEFINE_STMT1;}
"#defineStmt2" {return DEFINE_STMT2;}
"#defineExpr" {return DEFINE_EXPR;}
"#defineExpr0" {return DEFINE_EXPR0;}
"#defineExpr1" {return DEFINE_EXPR1;}
"#defineExpr2" {return DEFINE_EXPR2;}

"&&" {return AND;}
"||" {return OR;}
"!=" {return NE;}
"<=" {return LE;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return MULT;}
"/" {return DIV;}
"=" {return ASSIGN;}
"!" {return NOT;}

"(" {return LPAREN;}
")" {return RPAREN;}
"{" {return LBRACE;}
"}" {return RBRACE;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
"," {return COMMA;}
"." {return DOT;}
";" {return SEMICOLON;}

[0-9]+ { 
    yylval.num=atoi(yytext);
    return INTEGER_LITERAL;
}

[a-zA-Z][a-zA-Z0-9_]* {
    yylval.id=strdup(yytext);
    return IDENTIFIER;
}

"//"[^\n]* {}
[ \t\r\n]+ {}
\/\*([^*]|\*+[^*/])*\*+\/  {}
. {
    return INVALID;
}

%%
