
compiler: lex.yy.o ass4_15CS30031.tab.o ass4_15CS30031_translator.o ass4_15CS30031_translator.o
	g++ lex.yy.o ass4_15CS30031.tab.o ass4_15CS30031_translator.o \

ass4_15CS30031_translator.o: ass4_15CS30031_translator.cxx ass4_15CS30031_translator.h
	g++ -c ass4_15CS30031_translator.h
	g++ -c ass4_15CS30031_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

ass4_15CS30031.tab.o: ass4_15CS30031.tab.c
	g++ -c ass4_15CS30031.tab.c

lex.yy.c: ass4_15CS30031.l ass4_15CS30031.tab.h ass4_15CS30031_translator.h
	flex ass4_15CS30031.l

ass4_15CS30031.tab.c: ass4_15CS30031.y
	bison -dtv ass4_15CS30031.y -W

ass4_15CS30031.tab.h: ass4_15CS30031.y
	bison -dtv ass4_15CS30031.y -W

clean:
	rm lex.yy.c ass4_15CS30031.tab.c ass4_15CS30031.tab.h lex.yy.o ass4_15CS30031.tab.o ass4_15CS30031_translator.o a.out ass4_15CS30031_translator.h.gch ass4_15CS30031.output 

