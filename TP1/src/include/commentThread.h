#ifndef commentThread_h
#define commentThread_h

typedef struct commentThread *CommentThread;

CommentThread newCommentThread();

void freeCommentThread(CommentThread c);

void setID(CommentThread c,char* s);

void setUser(CommentThread c,char* s);

void setDate(CommentThread c,char* s);

void setTimeStamp(CommentThread c);

void setText(CommentThread c,char* s);

void setLikes(CommentThread c, char* s);

void setHasRepliesTRUE(CommentThread c);

void addNumberOfReplies(CommentThread c,int r);

void openFile(char * f);

CommentThread addnewComment(CommentThread head);

int getNumberOfReplies(CommentThread c);

CommentThread getReply(CommentThread c,int p);

CommentThread getCurrentReply(CommentThread c);

void testa(CommentThread c);

void formatToJSON(CommentThread c);
void formatToJsonHead(CommentThread c);
void ReplyToJSON(CommentThread c);

#endif