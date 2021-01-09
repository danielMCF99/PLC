%{
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <glib.h>
#include <limits.h>

#define TAM 500
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
int calculado = 0;

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
      if (calculado == 1){
            fprintf(fp,"%s %d\n","storeg",pos);
            lista[pos].valor = valor;
            calculado = 0;
      }else{
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
}

int operacao(int pos1, int pos2, char op){
      int res;
      switch(op){
            case '+':
                  if(lista[pos1].valor != VALORNA && lista[pos2].valor != VALORNA){
                        fprintf(fp,"%s %d\n","pushg",pos1);
                        fprintf(fp,"%s %d\n","pushg",pos2);
                        fprintf(fp,"%s\n","add");
                        res = lista[pos1].valor + lista[pos2].valor;
                  }
                  else{
                        erro = 1;
                        yyerror("Uma das variaveis usadas nao tem um valor previamente atribuido."); 
                  }
                  break;
            case '-':
                  if(lista[pos1].valor != VALORNA && lista[pos2].valor != VALORNA){
                        fprintf(fp,"%s %d\n","pushg",pos1);
                        fprintf(fp,"%s %d\n","pushg",pos2);
                        fprintf(fp,"%s\n","sub");
                        res = lista[pos1].valor - lista[pos2].valor;
                  }
                  else{
                        erro = 1;
                        yyerror("Uma das variaveis usadas nao tem um valor previamente atribuido."); 
                  }
                  break;
            case '*':
                  if(lista[pos1].valor != VALORNA && lista[pos2].valor != VALORNA){
                        fprintf(fp,"%s %d\n","pushg",pos1);
                        fprintf(fp,"%s %d\n","pushg",pos2);
                        fprintf(fp,"%s\n","mul");
                        res = lista[pos1].valor * lista[pos2].valor;
                  }
                  else{
                        erro = 1;
                        yyerror("Uma das variaveis usadas nao tem um valor previamente atribuido."); 
                  }
                  break;
            case '/':
                  if(lista[pos1].valor != VALORNA && lista[pos2].valor != VALORNA){
                        if(lista[pos2].valor != 0){
                              fprintf(fp,"%s %d\n","pushg",pos1);
                              fprintf(fp,"%s %d\n","pushg",pos2);
                              fprintf(fp,"%s\n","div");
                              res = lista[pos1].valor / lista[pos2].valor;
                        }
                        else{
                              erro = 1;
                              yyerror("Tentou fazer a divisao de um inteiro por 0"); 
                        }
                  }
                  else{
                        erro = 1;
                        yyerror("Uma das variaveis usadas nao tem um valor previamente atribuido."); 
                  }
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

%type <valI> Expr Termo Fator ExprR Condicao

%%

ListaProgs : Programa
           | ListaProgs Programa
           ;

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM          { ; }
         ;

ListaDecls : Decl                                      { if(erro == 0) { fprintf(fp,"%s\n","start"); } 
                                                         else { yyerror("Ocorreu um erro nas declaraçoes e por isso nao escreveu o comando start"); };   }                
           | Decl ListaDecls                           { ; } 
           ;

Decl : INTEIRO Variaveis ';'                           { ; }
     | ARRINTEIRO Variaveis ';'                        { ; }                    
     ;

Variaveis : Variavel                                   { ; }
          | Variaveis ',' Variavel                     { ; }
          ;

Variavel : ID                                          { if(erro == 0){ declaraINT($1); if(erro == 1){ sprintf(mensagem,"variavel '%s' ja declarada",$1);
                                                                                            yyerror(mensagem); } }; }
         | ID '<' NUM '>'                              { if(erro == 0){ declaraARR($1,$3); if(erro == 1){ sprintf(mensagem,"variavel '%s' ja declarada",$1);
                                                                                            yyerror(mensagem); } }; }
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

Atrib : ID '<''-' ExprR ';'                                  { if(erro == 0) { posicao = existe($1); if(posicao != -1) { atribINT($1,$4,posicao); } 
                                                                                      else{ sprintf(mensagem,"variavel '%s' nao declarada",$1);
                                                                                            yyerror(mensagem);} }; }
      | ID '<' ExprR '>' '<''-' ExprR ';'                    { if(erro == 0) { posicao = existe($1); if(posicao != -1) { ; } 
                                                                                      else{ sprintf(mensagem,"variavel '%s' nao declarada",$1);
                                                                                            yyerror(mensagem);} }; }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { ; }
       | ESCREVER '(' ID ')' ';'                         { ; }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'            { ; }
            ;

Condicao : ExprR                           { if(erro == 0) { $$ = $1; }; }
         | Condicao E ExprR                { if(erro == 0) { $$ = $1 && $3; }; }
         | Condicao OU ExprR               { if(erro == 0) { $$ = $1 || $3; }; }
         ; 

ExprR : Expr                                { if(erro == 0) { $$ = $1; }; }
      | Expr EQ Expr                        { if(erro == 0) { $$ = operacao($1,$3,'='); }; }
      | Expr NE Expr                        { ; }
      | Expr GE Expr                        { ; }
      | Expr GT Expr                        { ; }
      | Expr LE Expr                        { ; }
      | Expr LT Expr                        { ; }
      ;

Expr : Termo                                { if(erro == 0) { $$ = $1; } } 
     | Expr '+' Termo                       { if(erro == 0) { $$ = operacao($1,$3,'+'); calculado = 1;} }
     | Expr '-' Termo                       { if(erro == 0) { $$ = operacao($1,$3,'-'); calculado = 1;} }
     ;

Termo : Fator                               { $$ = $1; }
      | Termo '*' Fator                     { if(erro == 0) { $$ = operacao($1,$3,'*'); calculado = 1;}; }
      | Termo '/' Fator                     { if(erro == 0) { $$ = operacao($1,$3,'/'); calculado = 1;}; }

      ;     

Fator : NUM                                 { if(erro == 0) { $$ = $1; } }
      | '-' NUM                             { if(erro == 0) { $$ = (-1) * $2; } }
      | ID                                  { if(erro == 0) { posicao = existe($1); if(posicao != -1){ $$ = posicao; }
                                                                     else{ sprintf(mensagem,"variavel '%s' nao tem valor atribuido",$1);
                                                                           yyerror(mensagem);} }; }
      | ID '<' NUM '>'                      { if(erro == 0) {posicao = existe($1); if(posicao != -1 && lista[posicao + $3].valor != VALORNA){ $$ = posicao + $3; }
                                                                     else{ sprintf(mensagem,"variavel '%s<%d>'' nao tem valor atribuido",$1,$3);
                                                                           yyerror(mensagem);} }; }
      | ID '<' ID '>'                       { if(erro == 0) { posicao = existe($1);int pos2 = existe($3); if(posicao != -1 && lista[posicao + lista[pos2].valor].valor != VALORNA){ $$ = posicao + pos2; }
                                                                     else{ sprintf(mensagem,"variavel '%s<%s>'' nao tem valor atribuido",$1,$3);
                                                                           yyerror(mensagem);} }; }
      | VERDADEIRO                          { if(erro == 0) { $$ = 1; }; } 
      | FALSO                               { if(erro == 0) { $$ = 0; }; }
      | '(' Expr ')'                        { if(erro == 0) { $$ = $2; }; }
      | LER '(' ')'                         { if(erro == 0) { $$ = INPUT; }; } 
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


