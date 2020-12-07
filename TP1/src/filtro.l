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

%}
%x ID USERNAME DATE TEXT LIKES DELETED
%%
(aria)\-(label)\=\"(List)[' '](of)[' '](Comments)\"                           { fst = newCommentThread(); }
\<(ul)[' '](class)\=\"(spcv)\_(children)\-(list)\"\>                          { resposta = 1; }
\<\/(ul)\>                                                                    { resposta = 0; curr = getCurrentReply(fst); }


(data)\-(message)\-(id)              { curr = addnewComment(giveThread()); BEGIN ID; }
<ID>\>                               { BEGIN INITIAL; }
<ID>[ ]                              { ; }
<ID>\"                               { ; }
<ID>\=                               { ; }
<ID>[\t\n\r]+                        { ; }
<ID>data\-spot\-im\-class            { ; }
<ID>message\-view                    { ; }
<ID>.                                { setID(curr,yytext); }

(spcv)\_(username)\"\>                        { ; }
(spcv)\_(username)\"[^>]*\>                   { BEGIN USERNAME; }
<USERNAME>\<\/(span)\>                        { BEGIN INITIAL; }
<USERNAME>\n                                  { ; }
<USERNAME>.                                   { setUser(curr,yytext); }

\<(time)[^>]*\>     { BEGIN DATE; }
<DATE>\<            { BEGIN INITIAL; }
<DATE>.             { setDate(curr,yytext); }


(class)\=\"(spcv)\_(is)\-(deleted)\"\>                   { BEGIN DELETED; }
<DELETED>\<(span)\>                                      { ; }
<DELETED>[\n\r]*                                         { ; }
<DELETED>[ ][ ]+                                         { ; }
<DELETED>\<\/(span)\>                                    { BEGIN INITIAL; }
<DELETED>.                                               { setText(curr,yytext); }

(data)\-(spot)\-im\-(class)\=\"(message)\-(text)\"              { BEGIN TEXT;}
<TEXT>\<\/(div)\>                                               { BEGIN INITIAL; }
<TEXT>\<\/*strong\>                                             { ; }
<TEXT>\>                                                        { ; }
<TEXT>[\t\n\r]+                                                 { setText(curr," "); }
<TEXT>[ ]{2}                                                    { ; }
<TEXT>\<[^>]*\>                                                 { ; }
<TEXT>.                                                         { setText(curr,yytext); }

\"(spcv)\_(number)\-(of)\-(votes)\"       { BEGIN LIKES; }
<LIKES>\<\/(span)\>                       { curr = getCurrentReply(fst); BEGIN INITIAL; }
<LIKES>\>                                 { ; }
<LIKES>[0-9]+                             { setLikes(curr,yytext);}                                  
<LIKES>.                                  { ; }

.|\n                                      { ; }

%%

int yywrap(){
  return(1);
}

int main(){
  yylex();
  
  openFile("dados.json");

  formatToJsonHead(fst);

  return 0;
}
