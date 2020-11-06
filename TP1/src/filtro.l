%{
/* Declaracoes C diversas */
#include <glib.h>
#include <stdio.h>
#include <string.h>

typedef struct commentThread {

    GString * id;
    GString * user;
    GString * date;
    GString * timestamp; //NA 
    GString * text; 
    int likes;
    int hasReplies;
    int numberOfReplies;
    CommentThread replies[]; 
}*CommentThread;

%}

%x ID USER TIMESTAMP TEXT 

%%

\<(ul)[' '](aria)\-(label)\=\"(List)[' '](of)[' '](Comments)\"[' '](class)\=\"(spcv)\_(messages)\-(list)\"\> { ; }

\<(li)[' '](aria)\-(label)\=\"(Comment)\" { ; }
    //<li aria-label="Comment" class="spcv_list-item">

\<(ul)[' '](class)\=\"(spcv)\_(children)\-(list)\"\>  { ; }//Indica que vem uma série de respostas ao comentário 
    //<ul class="spcv_children-list">

\<(li)[' '](aria)\-(label)\=\"(Comment)[' '](reply)\" { ; }

(data)\-(message)\-(id)\=\" { ; }
    //data-message-id="sp_9LMINbK9_1165460_c_cfjlPd_r_ZUxhy4"

\<(span)[' '](class)\=\"(spcv)\_(number)\-(of)\-(votes)\"\> { ; }
    //<span class="spcv_number-of-votes">5 Likes</span>

\<(div)[' '](class)\=\"(spcv)\_(entity)\_(text)\-(entity)\".*\> { ; }
    //<div class="spcv_entity spcv_text-entity" data-spot-im-class="message-text">Only because of the people that use it</div>
%%

int yywrap(){
  return(1);
}

int main(){
  yylex();
  return 0;
}