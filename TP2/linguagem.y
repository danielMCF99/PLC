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
    GString* valS;
}
%token <valI>NUM 
%token <valS>ID 
%token <valI> VERDADEIRO FALSO
%token DECLARACOES INTEIRO ARRINTEIRO INICIO FIM SE PARA FAZER SENAO ATE
%token ESCREVER LER 
%token EQ GE GT LE LT 

%%

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM          { ; }
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

ListaInstrucoes : Instrucao                            { ; }
                | ListaInstrucoes Instrucao            { ; }
                |
                ;

Instrucao : Atrib                                     { ; } 
          | Funcao                                    { ; }
          | Condicional                               { ; }
          | Ciclo                                     { ; }
          ;

Ciclo : PARA '(' Atrib ATE NUM ')' FAZER '{' ListaInstrucoes '}'              { ; }
      | PARA '(' Atrib ATE ID ')' FAZER '{' ListaInstrucoes '}'               { ; }
      ; 

Atrib : ID '<''-' ExprR ';'                                  { ; }
      | ID '<' NUM '>' '<''-' ExprR ';'                      { ; }
      | ID '<' ID '>' '<''-' ExprR ';'                       { ; }
      | ID '<' NUM '>' '<''-' LER '(' ')' ';'                { ; }
      | ID '<' ID '>' '<''-' LER '(' ')' ';'                 { ; }
      | ID '<''-' LER '(' ')' ';'                            { ; }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { ; }
       | ESCREVER '(' ID ')' ';'                         { ; }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'            { ; }
            ;

Condicao : ExprR                            { ; }
         | Condicao '&' ExprR               { ; }
         | Condicao '|' ExprR               { ; }
         ; 

ExprR : Expr                                { ; }
      | Expr EQ Expr                        { ; }
      | Expr GE Expr                        { ; }
      | Expr GT Expr                        { ; }
      | Expr LE Expr                        { ; }
      | Expr LT Expr                        { ; }
      ;

Expr : Termo                                { ; }
     | Expr '+' Termo                       { ; }
     | Expr '-' Termo                       { ; }
     | Expr OU Termo                        { ; }
     ;

Termo : Fator                               { ; }
      | Termo '*' Fator                     { ; }
      | Termo '/' Fator                     { ; }
      | Termo E Fator                       { ; }
      ;     

Fator : NUM                                 { ; }
      | '-' NUM                             { ; }
      | ID                                  { ; }
      | ID '<' NUM '>'                      { ; }
      | ID '<' ID '>'                       { ; }
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

