#include <glib.h>
#include <stdio.h>
#include <string.h>
#include "commentThread.h"

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
    CommentThread ct = malloc(sizeof(struct commentThread));
    ct->id = g_string_new("");
    ct->user = g_string_new("");
    ct->date = g_string_new("");
    ct->timestamp = g_string_new("NA"); 
    ct->text = g_string_new("");
    ct->likes = 0;
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
    g_string_free(c->text,TRUE);
    c->hasReplies = FALSE;
    c->numberOfReplies = 0;
    c->likes = 0;
    //freeCommentThread(c->replies);
}

void setID(CommentThread c,char* s){
    g_string_append(c->id,s);
}

void setUser(CommentThread c,char* s){
    g_string_append(c->user,s);
}

void setDate(CommentThread c,char* s){
    g_string_append(c->date,s);
}

void setTimeStamp(CommentThread c){
    g_string_append(c->timestamp,"NA");
}

void setText(CommentThread c,char* s){
    g_string_append(c->text,s);
}

void setLikes(CommentThread c, char* s){
    c->likes = atoi(s);
}

void setHasRepliesTRUE(CommentThread c){
    c->hasReplies = TRUE;
}

void setNumberOfReplies(CommentThread c,int r){
    c->numberOfReplies += r;
}

CommentThread addnewComment(CommentThread head){
    //printf("ENTROU NO ADDNEWCOMMENT");
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
    //printf("ENTROU NO GETCURRENTREPLY");
    int tmp = c->numberOfReplies - 1 ;
    return c->replies[tmp];
}

void openFile(char * f){
    fp = fopen(f,"w+");
}

void testa(CommentThread c){
    char* cat;
    cat = g_string_free(c->text, FALSE);
    printf("%s",cat);
    //printf("%d",c->hasReplies);
}
