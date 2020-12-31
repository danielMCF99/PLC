%{
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <glib.h>

void yyerror(char* s);
int yylex();

int tabID[25];
%}


%union{
    int valI;  
    int* valLI; 
    GString* valS;
}
%token <valI>NUM 
%token <valS>ID 
%token <valLI>LI
%token <valI> VERDADEIRO FALSO
%token DECLARACOES INTEIRO ARRINTEIRO INICIO FIM SE PARA FAZER SENAO 
%token ESCREVER LER 
%token E OU EQ GE GT LE LT 

%%

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM
         ;

ListaDecls : Decl                                      { ; }                
           | ListaDecls Decl                           { ; } 
           ;

Decl : INTEIRO Variaveis ';'                           { ; }
     | ARRINTEIRO Variaveis ';'                        { ; }                    
     ;

Variaveis : Variavel                                   { ; }
          | Variaveis ',' Variavel                     { ; }
          ;

Variavel : ID                                          { ; } 
         | ID '<' NUM '>'                              { ; }
         ; 

ListaInstrucoes : Instrucao
                | ListaInstrucoes Instrucao
                ;

Instrucao : Atrib                                     { ; } 
          | Funcoes
          ;

Atrib : ID '<''-' ExprR ';'                            { ; }
      | ID '<' NUM '>' '<''-' ExprR ';'                { ; }
      | ID '<''-' LER '(' ')' ExprR ';'                { ; }
      ;

ExprR : Expr 
      | Expr EQ Expr
      | Expr GE Expr
      | Expr GT Expr
      | Expr LE Expr
      | Expr LT Expr
      ;

Expr :
     | Termo
     | Expr '+' Termo
     | Expr '-' Termo
     | Expr OU Termo
     ;

Termo : Fator 
      | Termo '*' Fator
      | Termo '/' Fator
      | Termo E Fator 
      ;

Fator : NUM
      | '-' NUM 
      | ID
      | VERDADEIRO                          { ; }
      | FALSO                               { ; }
      | '(' Expr ')'                        { ; }
      ;

%%

#include "lex.yy.c"

void yyerror(char* s){
    printf("Frase invalida: %s\n",s);
}

int main(){

    printf("Inicio do parsing\n");
    
    yyparse();

    printf("Fim do parsing\n");

    return 0;
}

