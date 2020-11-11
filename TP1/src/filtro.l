%{
/* Declaracoes C diversas */
#include "commentThread.h"
#include <stdio.h>
#include <glib.h>

CommentThread fst;
CommentThread curr;

int resposta;

CommentThread giveThread(){
    if(resposta == 0){
        return fst;
    }else{
        return curr;
    }
}

//PERGUNTAR AO PROF A PARTE DO \n NO TEXTO

%}
%x ID USERNAME DATE TEXT LIKES
%%
(aria)\-(label)\=\"(List)[' '](of)[' '](Comments)\"                           { fst = newCommentThread(); }
\<(ul)[' '](class)\=\"(spcv)\_(children)\-(list)\"\>                          { resposta = 1; }
\<\/(ul)\>                                                                    { resposta = 0;  }

(aria)\-(label)\=\"(Comment)         { ; }

(data)\-(message)\-(id)              { BEGIN ID; }
<ID>\>                               { BEGIN INITIAL; }
<ID>[' ']                            { ; }
<ID>\"                               { ; }
<ID>\=                               { ; }
<ID>\n                               { ; }
<ID>data\-spot\-im\-class            { ; }
<ID>message\-view                    { ; }
<ID>.                                { setID(fst,yytext); }

(spcv)\_(username)\"[^>]*\>                   { BEGIN USERNAME; }
<USERNAME>\<\/(span)\>                        { BEGIN INITIAL; }
<USERNAME>\n                                  { ; }
<USERNAME>.                                   { setUser(fst,yytext); }

\<(time)[^>]*\>     { BEGIN DATE; }
<DATE>\<            { BEGIN INITIAL; }
<DATE>.             { setDate(fst,yytext); }

(data)\-(spot)\-im\-(class)\=\"(message)\-(text)\"              { BEGIN TEXT;}
<TEXT>\<\/(div)\>                                               { BEGIN INITIAL; }
<TEXT>\>                                                        { ; }
<TEXT>\n                                                        { ; }
<TEXT>[' ']{2}                                                  { ; }
<TEXT>.                                                         { setText(fst,yytext); }

\"(spcv)\_(number)\-(of)\-(votes)\"       { BEGIN LIKES; }
<LIKES>\<\/(span)\>                       { BEGIN INITIAL; }
<LIKES>\>                                 { ; }
<LIKES>[0-9]+                             { ; }                                  
<LIKES>.                                  { ; }

.|\n                                 { ; }

%%

int yywrap(){
  return(1);
}

int main(){
  yylex();
  
  testa(fst);

  return 0;
}
