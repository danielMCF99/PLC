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

void setText(CommentThread c, char *s)
{
    for (int i = 0; i < strlen(s); i++)
    {
        if (s[i] == '"')
        {
            g_string_append(c->text, "'");
        }
        else
        {
            g_string_append(c->text, &s[i]);
        }
    }
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

void create_string_with_tabs(char *tabs, int numberOfTabs)
{
    //percorrer o numero de tabs e concatenar
    for (int i = 0; i < numberOfTabs; i++) tabs[i] = '\t';

}

void writeToJSON(CommentThread c, int numberOfTabs)
{
    char *cat;
    char *tabs = malloc(numberOfTabs * sizeof(char));
    
    create_string_with_tabs(tabs, numberOfTabs);
    cat = g_string_free(c->id, FALSE);
    fprintf(fp, "%s%s", tabs, "\"id\" : \"");
    fputs(cat, fp);
    fputs("\",\n", fp);

    cat = g_string_free(c->user, FALSE);
    fprintf(fp, "%s%s", tabs, "\"user\" : \"");
    fputs(cat, fp);
    fputs("\",\n", fp);

    cat = g_string_free(c->date, FALSE);
    fprintf(fp, "%s%s", tabs, "\"data\" : \"");
    fputs(cat, fp);
    fputs("\",\n", fp);

    cat = g_string_free(c->timestamp, FALSE);
    fprintf(fp, "%s%s", tabs, "\"timestamp\" : \"");
    fputs(cat, fp);
    fputs("\",\n", fp);

    cat = g_string_free(c->text, FALSE);
    fprintf(fp, "%s%s", tabs, "\"comment\" : \"");
    fputs(cat, fp);
    fputs("\",\n", fp);

    fprintf(fp, "%s%s", tabs, "\"numberOfLikes\" : ");
    fprintf(fp, "%d", c->likes);
    fputs(",\n", fp);

    fprintf(fp, "%s%s", tabs, "\"hasReplies\" : ");
    fprintf(fp, "%d", c->hasReplies);
    fputs(",\n", fp);

    fprintf(fp, "%s%s", tabs, "\"numberOfreplies\" : ");
    fprintf(fp, "%d", c->numberOfReplies);
    fputs(",\n", fp);

    
    fprintf(fp, "%s%s", tabs, "\"reply\" : [ ");
    free(tabs);
    for (int i = 0; i < c->numberOfReplies; i++)
    {
        char *tabs2 = malloc((i+2) * sizeof(char));
        create_string_with_tabs(tabs2, i+2);
        fputs("\n", fp);
        fprintf(fp, "%s%s", tabs2, "{\n");
        writeToJSON(c->replies[i], i+3);
        if (i < c->numberOfReplies - 1)
            fprintf(fp, "%s%s", tabs2, "},\n");
        else
            fprintf(fp, "%s%s", tabs2, "}\n");
        free(tabs2);
    }
    fputs("]\n", fp);
    fputs("\n", fp);
    fputs("\n", fp);
}

void formatToJsonHead(CommentThread c){
    fputs("[\n",fp);
    for(int i = 0; i < c->numberOfReplies;i++){
        fputs("{\n",fp);
        writeToJSON(c->replies[i], 0);
        if(i < c->numberOfReplies-1)
            fputs("},\n",fp);
        else 
            fputs("}\n",fp);
    }
    fputs("]\n",fp);

}




