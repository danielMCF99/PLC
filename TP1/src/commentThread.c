#include <glib.h>
#include <stdio.h>
#include <string.h>
#include <commentThread.h>

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

FILE* fp;

CommentThread newCommentThread(){
    CommentThread ct = malloc(sizeof(struct CommentThread));
    ct->id = g_string_new("");
    ct->user = g_string_new("");
    ct->date = g_string_new("");
    ct->timestamp = g_string_new(""); 
    ct->comentTxt = g_string_new("");
    ct->hasReplies = FALSE;
    ct->numberOfReplies = 0; 
    //ct->replies = newCommentThread();
    return ct;
}

void freeCommentThread(CommentThread c){
    g_string_free(c->id,TRUE);
    g_string_free(c->user,TRUE);
    g_string_free(c->date,TRUE);
    g_string_free(c->timestamp,TRUE);
    g_string_free(c->comentTxt,TRUE);
    c->hasReplies = FALSE;
    c->numberOfReplies = 0;
    //g_list_free(c->replies);
}

void setUser(CommentThread c,char* s){
    g_string_append(c->user,s);
}

void setDate(CommentThread c,char* s){
    g_string_append(c->date,s);
}

void setTimeStamp(CommentThread c,char* t){
    g_string_append(c->timestamp,t);
}

void addCommentTxt(CommentThread c,char* s){
    g_string_append(c->comentTxt,s);
}

void setHasReplaiesTRUE(CommentThread c){
    c->hasReplies = TRUE;
}

void addNumberOfReplies(CommentThread c,int r){
    c->numberOfReplies += r;
}

void openFile(char * f){
    fp = fopen(f,"w+");
}
CommentThread addnewComment(CommentThread head){
    head->hasReplies = TRUE;
    head->replies[head->numberOfReplies] = newCommentThread();
    CommentThread curr = head->replies[head->numberOfReplies];
    head->numberOfReplies++;
    return curr;

}


int getNumberOfReplies(CommentThread c){
    return c->numberOfReplies;
}

CommentThread getReply(CommentThread c,int p){
    return c->replies[p];
}

CommentThread getCurrentReply(CommentThread c){
    int tmp = c->numberOfReplies - 1 ;
    return c->replies[tmp];
}


