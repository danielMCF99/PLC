EXEC := linguagem

CXX := gcc
FLAGS := -std=c11 -g -Ofast -D_XOPEN_SOURCE=700
GLIB := `pkg-config --cflags --libs glib-2.0`

all:
	flex linguagem.l 
	yacc -d linguagem.y 
	$(CXX) -o $(EXEC) y.tab.c $(FLAGS) $(GLIB) 

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h exemplo.vm $(EXEC)