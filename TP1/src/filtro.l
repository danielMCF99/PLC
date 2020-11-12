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
\<\/(ul)\>                                                                    { resposta = 0; curr = getCurrentReply(fst); }


(data)\-(message)\-(id)              { curr = addnewComment(giveThread()); BEGIN ID; }
<ID>\>                               { BEGIN INITIAL; }
<ID>[' ']                            { ; }
<ID>\"                               { ; }
<ID>\=                               { ; }
<ID>\n                               { ; }
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

(data)\-(spot)\-im\-(class)\=\"(message)\-(text)\"              { BEGIN TEXT;}
<TEXT>\<\/(div)\>                                               { BEGIN INITIAL; }
<TEXT>\<\/*strong\>                                             { ; }
<TEXT>\>                                                        { ; }
<TEXT>\n                                                        { ; }
<TEXT>[' ']{2}                                                  { ; }
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
  
  openFile("output.json");

  formatToJsonHead(fst);

  return 0;
}
