%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <glib.h>

#define TAM 500 

void yyerror(char* s);

int yylex();

FILE* fp;
char * mensagem;
char * erroMensagem = "tentou usar uma variavel que nao esta declarada ou nao tem um valor atribuido";

typedef struct variavel{
      GString * nome;
      int valor; 
}Variavel;

Variavel lista[TAM];
int erro = 0; 
int posicao;      
int posicao2;  
int counter = 0;  //variavel que nos diz a ultima posiçao ocupada no array com todas as variaveis
int contaIF = 0;
int contaFOR = 0; 
int acc;


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

void declara(char * nome, int x){
      int res = existe(nome);
      int r;
      if(res == -1){
            if(x == 0){
                  g_string_append(lista[counter++].nome,nome); 
            }
            else{
                  if(x > 0){
                        int j = 0;
                        while(j<x){
                              g_string_append(lista[counter++].nome,nome);
                              j++;
                        }
                  }
                  else{
                        acc = asprintf(&mensagem,"O array %s esta a ser declarado com tamanho negativo",nome);
                        erro = 1;
                  }     
            }
      }
      else{
            acc = asprintf(&mensagem,"A variavel %s ja foi declarada",nome);
            erro = 1;
      }
}

%}

%union{
    int valI;   
    char * valS;
}
%token <valI>NUM 
%token <valS>ID
%token <valS>FRASE 
%token <valI> VERDADEIRO FALSO
%token DECLARACOES INTEIRO ARRINTEIRO INICIO FIM SE PARA FAZER SENAO ATE
%token ESCREVER LER 
%token EQ NE GE GT LE LT
%token E OU  

%type <valS> Expr Termo Fator ExprR Condicao Condicional ListaInstrucoes Programa ListaDecls Decl Variaveis Variavel Instrucao Atrib Funcao Ciclo 

%%

ListaProgs : Programa
           | ListaProgs Programa
           ;

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM       { if(erro == 0){ acc = asprintf(&$$,"%s%sSTOP", $3, $6); fprintf(fp,"%s",$$); } }
         ;

ListaDecls : Decl                                      { if(erro == 0) { acc = asprintf(&$$, "%sSTART\n", $1); } }               
           | Decl ListaDecls                           { if(erro == 0) { acc = asprintf(&$$,"%s%s",$1 ,$2); } }
           ;

Decl : INTEIRO Variaveis ';'                           { if(erro == 0) { acc = asprintf(&$$, "%s", $2);  } }
     | ARRINTEIRO Variaveis ';'                        { if(erro == 0) { acc = asprintf(&$$, "%s", $2);  } }                  
     ;

Variaveis : Variavel                                   { if(erro == 0) { acc = asprintf(&$$, "%s", $1); } }
          | Variaveis ',' Variavel                     { if(erro == 0) { acc = asprintf(&$$, "%s%s", $1, $3); } }
          ;

Variavel : ID                                          { if(erro == 0){ declara($1,0); if(erro == 0){ acc = asprintf(&$$, "PUSHI 0\n"); }
                                                                                          else { yyerror(mensagem); free(mensagem); } } }
         | ID '<' NUM '>'                              { if(erro == 0){ declara($1,$3); acc = asprintf(&$$, "PUSHN %d\n", $3); } }
         ; 

ListaInstrucoes : Instrucao                            { if(erro == 0){ acc = asprintf(&$$,"%s",$1); } }
                | ListaInstrucoes Instrucao            { if(erro == 0){ acc = asprintf(&$$,"%s%s",$1 ,$2); } }
                ;

Instrucao : Atrib                                     { if(erro == 0){ acc = asprintf(&$$,"%s",$1); } } 
          | Funcao                                    { if(erro == 0){ acc = asprintf(&$$,"%s",$1); } }
          | Condicional                               { if(erro == 0){ acc = asprintf(&$$,"%s",$1); } } 
          | Ciclo                                     { if(erro == 0){ acc = asprintf(&$$,"%s",$1); } }
          ;

Ciclo : PARA '(' ExprR ATE ExprR ')' FAZER '{' ListaInstrucoes '}'       { if(erro == 0) { 
                                    acc = asprintf(&$$, "FOR%d :\n%s%sINFEQ\nJZ ENDFOR%d\n%sJUMP FOR%d\nENDFOR%d :\n", contaFOR, $3, $5, contaFOR, $9, contaFOR ,contaFOR); } }
      ; 

Atrib : ID '<''-' ExprR ';'                     { if(erro == 0) { posicao = existe($1); if(posicao != -1) { 
                                                      lista[posicao].valor = 1; acc = asprintf(&$$,"%sSTOREG %d\n",$4,posicao); } } }
      | ID '<' ExprR '>' '<''-' ExprR ';'       { if(erro == 0) { posicao = existe($1); if(posicao != -1 && posicao2 != -1) { 
                                                            lista[posicao+posicao2].valor = 1; acc = asprintf(&$$,"PUSHGP \nPUSHI %d\n%sADD\n%sSTOREN\n",posicao ,$3 ,$7); } 
                                                                                         else{ erro = 1; yyerror("Ocorreu um erro numa atribuicao num array"); } } }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { if(erro == 0) { acc = asprintf(&$$, "%s%s\n", $3, "WRITEI"); } }
       | ESCREVER '(' FRASE ')' ';'                      { if(erro == 0) { acc = asprintf(&$$, "PUSHS %s\n%s\n", $3, "WRITES"); } }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'         { if(erro == 0) { 
                                                acc = asprintf(&$$, "%sJZ ELSE%d\n%sJUMP FIM%d\nELSE%d :\n%sFIM%d :\n", $3, contaIF, $6, contaIF, contaIF, $10 ,contaIF); } }
            ;

Condicao : ExprR                   { if(erro == 0) { acc = asprintf(&$$, "%s", $1); } }
         | ExprR E Condicao        { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3 ,"MUL"); } }
         | ExprR OU Condicao       { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3 ,"ADD"); } }
         ; 

ExprR : Expr                       { if(erro == 0) { acc = asprintf(&$$, "%s", $1); } }
      | Expr EQ Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "EQUAL"); } } 
      | Expr NE Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "EQUAL"); } }
      | Expr GE Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "SUPEQ"); } }
      | Expr GT Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "SUP"); } }
      | Expr LE Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "INFEQ"); } }
      | Expr LT Expr               { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n",$1 ,$3, "INF"); } }
      ;

Expr : Termo                       { if(erro == 0) { acc = asprintf(&$$, "%s", $1); } }
     | Expr '+' Termo              { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n", $1, $3, "ADD"); } }
     | Expr '-' Termo              { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n", $1, $3, "SUB"); } }
     ;

Termo : Fator                      { if(erro == 0) { acc = asprintf(&$$, "%s", $1); } }
      | Termo '*' Fator            { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n", $1, $3, "MUL" ); } }
      | Termo '/' Fator            { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n", $1, $3, "DIV" ); } }
      | Termo '%' Fator            { if(erro == 0) { acc = asprintf(&$$, "%s%s%s\n", $1, $3, "MOD" ); } }
      ;     

Fator : NUM                        { if(erro == 0) { acc = asprintf(&$$,"PUSHI %d\n",$1); } }
      | '-' NUM                    { if(erro == 0) { posicao2 = -1; acc = asprintf(&$$,"PUSHI %d\n",-1 * $2); } }
      | ID                         { if(erro == 0) { posicao = existe($1); if(posicao >= 0 && lista[posicao].valor == 1){ acc = asprintf(&$$,"PUSHG %d\n",posicao); } 
                                                                              else{ erro = 1; yyerror(erroMensagem); } } } 
      | ID '<' NUM '>'             { if(erro == 0) { posicao = existe($1); posicao2 = $3; if(posicao >= 0 && posicao2 >= 0 && lista[posicao+posicao2].valor == 1){ 
                                                                                                      acc = asprintf(&$$,"PUSHG %d\n",posicao + posicao2); }
                                                                                          else{ erro = 1; yyerror(erroMensagem); } } } 
      | ID '<' ID '>'              { if(erro == 0) { posicao = existe($1); posicao2 = existe($3); if(posicao >= 0 && posicao2 >= 0 && lista[posicao+posicao2].valor == 1) { 
                                                                                                  acc = asprintf(&$$,"PUSHGP\nPUSHI %d\nPUSHG %d\nADD\nLOADN\n",posicao,posicao2); }
                                                                                                 else{ erro = 1; yyerror(erroMensagem); } } } 
      | VERDADEIRO                 { if(erro == 0) { acc = asprintf(&$$,"PUSHI %d\n",1); } } 
      | FALSO                      { if(erro == 0) { acc = asprintf(&$$,"PUSHI %d\n",0); } }
      | '(' Expr ')'               { if(erro == 0) { acc = asprintf(&$$,"%s\n", $2); } }
      | LER '(' ')'                { if(erro == 0) { acc = asprintf(&$$,"READ\n ATOI\n"); } } 
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
            lista[i].valor = 0;
      }

      printf("Inicio do parsing\n");
    
      yyparse();

      fclose(fp);

      printf("Fim do parsing\n");

      return 0;
}


