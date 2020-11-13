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
    CommentThread ct = malloc(28 * sizeof(struct commentThread));
    ct->id = g_string_new("");
    ct->user = g_string_new("");
    ct->date = g_string_new("");
    ct->timestamp = g_string_new("NA"); 
    ct->text = g_string_new("");
    ct->likes = 0;
    ct->hasReplies = FALSE;
    ct->numberOfReplies = 0; 
    return ct;
}

void freeCommentThread(CommentThread c){
    g_string_free(c->id,TRUE);
    g_string_free(c->user,TRUE);
    g_string_free(c->date,TRUE);
    g_string_free(c->timestamp,TRUE);
    g_string_free(c->text,TRUE);
    c->likes = 0;
    c->hasReplies = FALSE;
    c->numberOfReplies = 0;
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

void openFile(char * f){
    fp = fopen(f,"w+");
}


void formatToJsonHead(CommentThread c){
    fputs("\"commentThread\" : [\n",fp);
    for(int i = 0; i < c->numberOfReplies;i++){
        fputs("{\n",fp);
        formatToJSON(c->replies[i]);
        if(i < c->numberOfReplies-1)
            fputs("},\n",fp);
        else 
            fputs("}\n",fp);
    }
    fputs("]\n",fp);

}




void formatToJSON(CommentThread c){
    char *cat;

    cat = g_string_free(c->id, FALSE);
    fputs("     \"id\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);
    
    cat = g_string_free(c->user, FALSE);
    fputs("     \"user\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->date, FALSE);
    fputs("     \"data\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->timestamp, FALSE);
    fputs("     \"timestamp\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->text, FALSE);
    fputs("     \"comment\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    
    fputs("     \"Nº likes\" : \"",fp);
    fprintf(fp,"%d",c->likes);
    fputs("\"\n",fp);

    fputs("     \"Has replies\" : \"",fp);
    fprintf(fp,"%d",c->hasReplies);
    fputs("\"\n",fp);

    fputs("     \"Nº respostas\" : \"",fp);
    fprintf(fp,"%d",c->numberOfReplies);
    fputs("\"\n",fp);


    fputs("     \"reply\" : [ ",fp);
    for(int i = 0; i < c->numberOfReplies;i++){
        fputs("\n",fp);
        fputs("             {\n",fp);
        if (c->id != NULL)
            ReplyToJSON(c->replies[i]);
        if(i < c->numberOfReplies-1)
            fputs("             },",fp);
        else 
            fputs("             }\n",fp);
    }
    fputs("     ] \n",fp);
    fputs("\n",fp);
    fputs("\n",fp);
}

void ReplyToJSON(CommentThread c){
    char *cat;

    cat = g_string_free(c->id, FALSE);
    fputs("             \"id\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);
    
    cat = g_string_free(c->user, FALSE);
    fputs("             \"user\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->date, FALSE);
    fputs("             \"data\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->timestamp, FALSE);
    fputs("             \"timestamp\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    cat = g_string_free(c->text, FALSE);
    fputs("             \"comment\" : \"",fp);
    fputs(cat,fp);
    fputs("\"\n",fp);

    fputs("             \"Nº likes\" : \"",fp);
    fprintf(fp,"%d",c->likes);
    fputs("\"\n",fp);

    fputs("             \"has replies\" : \"",fp);
    fprintf(fp,"%d",c->hasReplies);
    fputs("\"\n",fp);

    fputs("             \"Nº respostas\" : \"",fp);
    fprintf(fp,"%d",c->numberOfReplies);
    fputs("\"\n",fp);

    fputs("             \"reply\" : [ ",fp);
    for(int i = 0; i < c->numberOfReplies;i++){
        fputs("\n",fp);
        fputs("             {\n",fp);
        ReplyToJSON(c->replies[i]);
        if(i < c->numberOfReplies-1)
            fputs("             },",fp);
        else 
            fputs("             }\n",fp);
    }
    fputs("     ] \n",fp);
    fputs("\n",fp);
    fputs("\n",fp);



}

