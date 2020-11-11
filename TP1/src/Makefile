EXEC := teste

CXX := gcc
FLAGS := -std=c11 -g -Ofast
GLIB := `pkg-config --cflags --libs glib-2.0`

all:
	@flex teste.l
	$(CXX) -o $(EXEC) commentThread.c lex.yy.c $(FLAGS) $(GLIB)  commentThread.h

clean:
	rm -rf lex.yy.c $(EXEC)

