parser: lex.o  yacc.o
	g++ lex.o yacc.o -o parser

lex.o: lex.c  yacc.h  main.h
	g++ -c lex.c

yacc.o: yacc.c  main.h
	g++ -c yacc.c

yacc.c  yacc.h: yacc.y
	bison -d yacc.y

lex.c: lex.l
	flex lex.l

clean:
	@rm -f parser *.o yacc.c yacc.h lex.c
