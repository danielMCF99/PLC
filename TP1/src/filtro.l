%{
/* Declaracoes C diversas */
#include <commentThread.h>
#include <stdio.h>
#include <glib.h>

CommentThread fst;
CommentThread curr;

int resposta = 0;

CommentThread giveThread(){
    if(resposta == 0){
        return fst;
    }else{
        return curr;
    }
}

//COMENTARIO QUALQUER

%}
%x ID USERNAME DATE TEXT 

%%
\<(ul)[' '](aria)\-(label)\=\"(List)[' '](of)[' '](Comments)\"[' '](class)\=\"(spcv)\_(messages)\-(list)\"\> { fst = newCommentThread(); }
\<(ul)[' '](class)\=\"(spcv)\_(children)\-(list)\"\>                                                         { resposta = 1; }
\<\/(ul)\>                                                                                                   { resposta = 0; curr = getCurrentReply(head); }

.*(data)\-(message)\-(id)            { BEGIN ID; }
<ID>\>                               { BEGIN INITIAL; }
<ID>[' ']                            { ; }
<ID>\"                               { ; }
<ID>\=                               { ; }
<ID>\n                               { ; }
<ID>data\-spot\-im\-class            { ; }
<ID>message\-view                    { ; }
<ID>.                                { ; }

(.*)=\"(spcv)\_(username)\"([' ']*\w*)*\>     { BEGIN USERNAME; }
<USERNAME>\<\/(span)\>                        { BEGIN INITIAL; }
<USERNAME>.                                   { ; }

\<(time)[^>]*\>     { BEGIN DATE; printf("\n"); }
<DATE>\<            { BEGIN INITIAL; }
<DATE>.             { ; }


(.*)(data)\-(spot)\-im\-(class)\=\"(message)\-(text)\"          { BEGIN TEXT; }
<TEXT>\<\/(div)\>                                               { BEGIN INITIAL; }
<TEXT>\>                                                        { ; }
<TEXT>[' ']{2}                                                  { ; }
<TEXT>.                                                         { printf("%s",yytext); }













.|\n                                 { ; }

%%

int yywrap(){
  return(1);
}

int main(){
  yylex();
  return 0;
}