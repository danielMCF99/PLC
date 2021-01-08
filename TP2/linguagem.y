%{
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <glib.h>
#include <limits.h>

#define TAM 250
#define INPUT 123456789       // para quando for reconhecido o "ler()";                   
#define VALORNA -123456789    // valor inicial das variaveis (antes das atribuiçoes)

char mensagem[100];

void yyerror(char* s);
int yylex();

typedef struct variavel{
      GString * nome;
      int valor; 
}Variavel;

FILE* fp;
Variavel lista[TAM];
int erro = 0;
int posicao;         
int counter = 0;  //variavel que nos diz a ultima posiçao ocupada no array com todas as variaveis

int existe(char * var){
      int i = 0;
      int pos = -1;
      GString * aux = g_string_new(var);
      while (i<TAM && pos==-1){
            if(g_string_equal(aux, lista[i].nome) == TRUE){
                  pos = i;
            }
            i++;
      }
      return pos;
}

void declaraINT(char * nome){
      int res = existe(nome);

      if(res == -1){
            fprintf(fp,"%s\n","pushi 0");
            g_string_append(lista[counter++].nome,nome);
      }else{
            erro = 1;
      }
}

void declaraARR(char * nome, int x){
      int res = existe(nome);

      if(res == -1){
            fprintf(fp,"%s %d\n","pushn",x);
            int j = 0;
            while(j<x){
                  g_string_append(lista[counter++].nome,nome);
                  j++;
            }
      }else{
            erro = 1;
      }
}

void atribINT(char * nome , int valor, int pos){
      switch(valor){
            case INPUT:
                  fprintf(fp,"%s\n","read");
                  fprintf(fp,"%s\n","atoi");
                  fprintf(fp,"%s %d\n","storeg",pos);
                  break;
            default:
                  lista[pos].valor = valor;
                  fprintf(fp,"%s %d\n","pushi",valor);
                  fprintf(fp,"%s %d\n","storeg",pos);
                  break;
      }
}

int operacao(int pos1, int pos2, char op){
      int res;
      switch(op){
            case '+':
                  fprintf(fp,"%s %d\n","pushg",pos1);
                  fprintf(fp,"%s %d\n","pushg",pos2);
                  fprintf(fp,"%s\n","add");
                  res = lista[pos1].valor + lista[pos2].valor;
                  break;
            case '-':
                  fprintf(fp,"%s %d\n","pushg",pos1);
                  fprintf(fp,"%s %d\n","pushg",pos2);
                  fprintf(fp,"%s\n","sub");
                  res = lista[pos1].valor - lista[pos2].valor;
                  break;
            case '*':
                  break;
            case '/':
                  break;
      }
      return res;
}


%}

%union{
    int valI;   
    char * valS;
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

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM          { ; }
         ;

ListaDecls : Decl                                      { if(erro == 0) { fprintf(fp,"%s\n","start"); } 
                                                         else { yyerror("deu erro"); }   }                
           | Decl ListaDecls                           { ; } 
           ;

Decl : INTEIRO Variaveis ';'                           { ; }
     | ARRINTEIRO Variaveis ';'                        { ; }                    
     ;

Variaveis : Variavel                                   { ; }
          | Variaveis ',' Variavel                     { ; }
          ;

Variavel : ID                                          { declaraINT($1); if(erro == 1){printf("Esta a declarar uma variavel que ja foi declarada.\n");}} 
         | ID '<' NUM '>'                              { declaraARR($1,$3); }
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

Atrib : ID '<''-' ExprR ';'                                  { posicao = existe($1); if(posicao != -1) { atribINT($1,$4,posicao); } 
                                                                                      else{ sprintf(mensagem,"variavel %s nao declarada",$1);
                                                                                            yyerror(mensagem);}}
      | ID '<' ExprR '>' '<''-' ExprR ';'                    { posicao = existe($1); if(posicao != -1) { ; } 
                                                                                      else{ sprintf(mensagem,"variavel %s nao declarada",$1);
                                                                                            yyerror(mensagem);} }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { ; }
       | ESCREVER '(' ID ')' ';'                         { ; }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'            { ; }
            ;

Condicao : ExprR                           { ; }
         | Condicao E ExprR                { ; }
         | Condicao OU ExprR               { ; }
         ; 

ExprR : Expr                                { ; }
      | Expr EQ Expr                        { ; }
      | Expr NE Expr                        { ; }
      | Expr GE Expr                        { ; }
      | Expr GT Expr                        { ; }
      | Expr LE Expr                        { ; }
      | Expr LT Expr                        { ; }
      ;

Expr : Termo                                { $$ = $1; }
     | Expr '+' Termo                       { $$ = operacao($1,$3,'+'); }
     | Expr '-' Termo                       { $$ = operacao($1,$3,'-'); }
     ;

Termo : Fator                               { ; }
      | Termo '*' Fator                     { ; }
      | Termo '/' Fator                     { ; }

      ;     

Fator : NUM                                 { $$ = $1; }
      | '-' NUM                             { $$ = (-1) * $2; }
      | ID                                  { posicao = existe($1); if(posicao != -1 && lista[posicao].valor != VALORNA){ $$ = posicao; }
                                                                     else{ sprintf(mensagem,"variavel %s nao declarada",$1);
                                                                           yyerror(mensagem);} }
      | ID '<' NUM '>'                      { posicao = existe($1); if(posicao != -1 && lista[posicao + $3].valor != VALORNA){ $$ = posicao + $3; }
                                                                     else{ sprintf(mensagem,"variavel %s <%d> nao declarada",$1,$3);
                                                                           yyerror(mensagem);} }
      | ID '<' ID '>'                       { posicao = existe($1);int pos2 = existe($3); if(posicao != -1 && lista[posicao + lista[pos2].valor].valor != VALORNA){ $$ = posicao + pos2; }
                                                                     else{ sprintf(mensagem,"variavel %s<%s> nao declarada",$1,$3);
                                                                           yyerror(mensagem);} }
      | VERDADEIRO                          { $$ = 1; }
      | FALSO                               { $$ = 0; }
      | '(' Expr ')'                        { $$ = $2; }
      | LER '(' ')'                         { $$ = INPUT; }
      ;

%%

#include "lex.yy.c"

void yyerror(char* s){
    printf("Frase invalida: %s\n",s);
}

int main(){
      fp = fopen("exemplo.vm","w");

      for(int i=0;i<TAM;i++){
            lista[i].nome = g_string_new("");
            lista[i].valor = VALORNA;
      }

      printf("Inicio do parsing\n");
    
      yyparse();

      fclose(fp);

      printf("Fim do parsing\n");

      return 0;
}


