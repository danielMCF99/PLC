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
int contaIF = 0;
int tp = -1;
int senao = 1; 

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

      if(res == -1){
            if(x == 0){
            fprintf(fp,"%s\n","pushi 0");
            g_string_append(lista[counter++].nome,nome); 
            }
            else{
                  if(x > 0){
                        fprintf(fp,"%s %d\n","pushn",x);
                        int j = 0;
                        while(j<x){
                              g_string_append(lista[counter++].nome,nome);
                              j++;
                        }
                  }
                  else{
                        erro = 1;
                  }     
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

%}

%union{
    int valI;   
    char * valS;
    char valC;
}
%token <valI>NUM 
%token <valS>ID 
%token <valI> VERDADEIRO FALSO
%token DECLARACOES INTEIRO ARRINTEIRO INICIO FIM SE PARA FAZER SENAO ATE
%token ESCREVER LER 
%token EQ NE GE GT LE LT
%token E OU  

%type <valI> Expr Termo Fator ExprR Condicao Condicional ListaInstrucoes

%%

ListaProgs : Programa
           | ListaProgs Programa
           ;

Programa : DECLARACOES '{' ListaDecls '}' INICIO ListaInstrucoes FIM          { if(erro == 0) { printf("Funcionou tudo corretamente!\n"); fprintf(fp,"%s\n","stop"); } ; }
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

Variavel : ID                                          { if(erro == 0){ declara($1,0); if(erro == 1){ sprintf(mensagem,"variavel '%s' ja declarada",$1);
                                                                                            yyerror(mensagem); } }; }
         | ID '<' NUM '>'                              { if(erro == 0){ declara($1,$3); if(erro == 1){ sprintf(mensagem,"variavel '%s' ja declarada",$1);
                                                                                            yyerror(mensagem); } }; }
         ; 

ListaInstrucoes : Instrucao                            { if(erro == 0){ ; }; }
                | Instrucao ListaInstrucoes            { ; }
                |                                      { ; }
                ;

Instrucao : Atrib                                     { ; } 
          | Funcao                                    { ; }
          | Condicional                               { if(erro == 0) { ; } } 
          | Ciclo                                     { ; }
          ;

Ciclo : PARA '(' ExprR ATE ExprR ')' FAZER '{' ListaInstrucoes '}'              { ; }
      ; 

Atrib : ID '<''-' ExprR ';'                                  { if(erro == 0) { posicao = existe($1); if(posicao != -1) { if(senao == 1) { atribINT($1,$4,posicao); calculado = 0;}; }; }; }
      | ID '<' ExprR '>' '<''-' ExprR ';'                    { if(erro == 0) { posicao = existe($1); if(posicao != -1) { if(senao == 1) { atribINT($1,$7,posicao+$3); calculado = 0;}; }; }; }
      ;

Funcao : ESCREVER '(' ExprR ')' ';'                      { if(erro == 0){ fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","writei"); }; }
       ;

Condicional : SE '(' Condicao ')' '{' ListaInstrucoes '}' SENAO '{' ListaInstrucoes '}'            { senao = 1; fprintf(fp,"%s%d :\n%s\n","FIM",contaIF,"nop"); } 
            ;

Condicao : ExprR                          { if(erro == 0) { $$ = $1; if(tp == 1) { fprintf(fp,"%s\n","mul"); };
                                                                        if(tp == 2) { fprintf(fp,"%s\n","add"); }; 
                                                                        fprintf(fp,"%s %s%d\n","jz","ELSE",contaIF); }; }
         | ExprR E Condicao               { if(erro == 0) { $$ = $1 && $3; }; }
         | ExprR OU Condicao              { if(erro == 0) { $$ = $1 || $3; }; }
         ; 

ExprR : Expr                                { if(erro == 0) { ; }; }
      | Expr EQ Expr                        { if(erro == 0) { $$ = $1 == $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","equal"); } }
      | Expr NE Expr                        { if(erro == 0) { $$ = $1 != $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","not"); } }
      | Expr GE Expr                        { if(erro == 0) { $$ = $1 >= $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","supeq"); } }
      | Expr GT Expr                        { if(erro == 0) { $$ = $1 > $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","sup"); } }
      | Expr LE Expr                        { if(erro == 0) { $$ = $1 <= $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","infeq"); } }
      | Expr LT Expr                        { if(erro == 0) { $$ = $1 < $3; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","inf"); } }
      ;

Expr : Termo                                { if(erro == 0) { $$ = $1; }; }
     | Expr '+' Termo                       { if(erro == 0) { $$ = $1 + $3; calculado = 1; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","add"); } }
     | Expr '-' Termo                       { if(erro == 0) { $$ = $1 - $3; calculado = 1; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","sub"); } }
     ;

Termo : Fator                               { if(erro == 0) { $$ = $1; } }
      | Termo '*' Fator                     { if(erro == 0) { $$ = $1 * $3; calculado = 1; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","mul"); } }
      | Termo '/' Fator                     { if(erro == 0) { if($3 != 0) { $$ = $1 / $3; calculado = 1; fprintf(fp,"%s %d\n","pushi",$1); fprintf(fp,"%s %d\n","pushi",$3); fprintf(fp,"%s\n","div"); }
                                                                  else{ erro = 1; yyerror("Tentou fazer uma divisão de um numero por 0(zero)"); }; }; }
      ;     

Fator : NUM                                 { if(erro == 0) { $$ = $1; } }
      | '-' NUM                             { if(erro == 0) { $$ = -1 * $2; } }
      | ID                                  { if(erro == 0) { posicao = existe($1); if(posicao >= 0 && lista[posicao].valor != VALORNA){ $$ = lista[posicao].valor; }
                                                                                    else{ erro = 1; yyerror("tentou usar uma variavel que nao esta declarada ou nao tem um valor atribuido");} } } 
      | ID '<' NUM '>'                      { if(erro == 0) { posicao = existe($1); if(posicao >= 0 && lista[posicao+$3].valor != VALORNA){ $$ = lista[posicao+$3].valor; }
                                                                                    else{ erro = 1; yyerror("tentou usar uma variavel que nao esta declarada ou nao tem um valor atribuido");} } } 
      | ID '<' ID '>'                       { if(erro == 0) { posicao = existe($1); int pos2 = existe($3); if(posicao >= 0 && pos2 >= 0 && lista[posicao+pos2].valor != VALORNA){ $$ = lista[posicao+pos2].valor; }
                                                                                    else{ erro = 1; yyerror("tentou usar uma variavel que nao esta declarada ou nao tem um valor atribuido");} } } 
      | VERDADEIRO                          { if(erro == 0) { $$ = 1; } } 
      | FALSO                               { if(erro == 0) { $$ = 0; } }
      | '(' Expr ')'                        { if(erro == 0) { $$ = $2; } }
      | LER '(' ')'                         { if(erro == 0) { $$ = INPUT; } } 
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


