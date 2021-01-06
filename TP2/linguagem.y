%{
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <glib.h>
#include <limits.h>

void yyerror(char* s);
int yylex();

typedef struct variavel{
      GString * nome;
}Variavel;

FILE* fp;

Variavel lista[250];

int existe(GString * var){
      int i = 0;
      int pos = -1;
      while (i<250 && pos==-1){
            if(g_string_equal(var, lista[i]->nome) == TRUE){
                  pos = i;
            }
            i++;
      }
      return pos;
}


%}

%union{
    int valI;   
    GString * valS;
}
%token <valI>NUM 
%token <valS>ID 
%token <valI> VERDADEIRO FALSO
%token DECLARACOES INTEIRO ARRINTEIRO INICIO FIM SE PARA FAZER SENAO ATE
%token ESCREVER LER 
%token EQ NE GE GT LE LT
%token E OU  

%type <valI> Expr Termo Fator ExprR

%%

ListaProgs : Programa
           | ListaProgs Programa
           ;

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM          { escrever(ListaDecls) ; escrever(start) ; escrever(ListaInstrucoes); escrever(stop); }
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

Variavel : ID                                          { adicionarNomeAoArray($1); escrever(pushi 0); } 
         | ID '<' NUM '>'                              { adicionarNomeAoArray($1); escrever(pushn $3); }
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

Ciclo : PARA '(' ExprR ATE ExprR ')' FAZER '{' ListaInstrucoes '}'              { ; }
      ; 

Atrib : ID '<''-' ExprR ';'                                  { escrever($4); escrever(storeg ++ $1); }
      | ID '<' ExprR '>' '<''-' ExprR ';'                    { escrever($7); escrever(storeg ++ $1 + $3);; }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { escrever(ExprR); escrever(writeI ? writeS); }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'            { ; }
            ;

Condicao : ExprR                           { ; }
         | Condicao E ExprR                { ; }
         | Condicao OU ExprR               { ; }
         ; 

ExprR : Expr                                { ; }
      | Expr EQ Expr                        { escrever(expr); escrever(expr); escrever(equal); }
      | Expr NE Expr                        { escrever(expr); escrever(expr);  escrever(not); }
      | Expr GE Expr                        { escrever(expr); escrever(expr); escrever(supeq); }
      | Expr GT Expr                        { escrever(expr); escrever(expr); escrever(supl); }
      | Expr LE Expr                        { escrever(expr); escrever(expr); escrever(infeq); }
      | Expr LT Expr                        { escrever(expr); escrever(expr); escrever(inf); }
      ;

Expr : Termo                                { escrever(Termo); }
     | Expr '+' Termo                       { escrever(Expr); escrever(Termo); escrever("add"); }
     | Expr '-' Termo                       { escrever(EXpr); escrever(Termo); escrever("sub"); }
     ;

Termo : Fator                               { ; }
      | Termo '*' Fator                     { escrever(termo); escrever(fator); escrever("mult"); }
      | Termo '/' Fator                     { escrever(termo); escrever(fator); escrever("div"); }

      ;     

Fator : NUM                                 { $$ = $1; }
      | '-' NUM                             { $$ = (-1) * $2; }
      | ID                                  { int posicao = existe($1); if (posicao != -1) { $$ = posicao; } 
                                                      else {  printf("ERRO Semantico - ID de Variável Desconhecido \n"); 
                                                                  $$ = -1; erro = 1; 
                                                      } 
                                            }
      | ID '<' NUM '>'                      { int posicao = existe($1); if (posicao != -1) { $$ = posicao + $3; } 
                                                      else {  printf("ERRO Semantico - ID de Variável Desconhecido \n"); 
                                                                  $$ = -1; erro = 1; 
                                                      } 
                                            }
      | ID '<' ID '>'                       { int posicao = existe($1); if (posicao != -1) { $$ = posicao + $3; } 
                                                      else {  printf("ERRO Semantico - ID de Variável Desconhecido \n"); 
                                                                  $$ = -1; erro = 1; 
                                                      } 
                                            }
      | VERDADEIRO                          { $$ = 1; }
      | FALSO                               { $$ = 0; }
      | '(' Expr ')'                        { $$ = $2; }
      | LER '(' ')'                         { escrever(read); }
      ;

%%

#include "lex.yy.c"

void yyerror(char* s){
    printf("Frase invalida: %s\n",s);
}

int main(){
      fp = fopen("exemplo1.vm",w);

      printf("Inicio do parsing\n");
    
      yyparse();

      printf("Fim do parsing\n");

      return 0;
}

