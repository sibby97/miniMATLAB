all program:lexer.out parser.out
parser.out: ass3_15CS30031_parser.c lex.yy.c ass3_15CS30031.tab.c
	gcc -o $@ ./ass3_15CS30031_parser.c -o ./parser.out

lexer.out: ass3_15CS30031_lexer.c lex.yy.c
	gcc -o $@ ./ass3_15CS30031_lexer.c -o ./lexer.out

lex.yy.c: ass3_15CS30031.l ass3_15CS30031.tab.c
	flex ./ass3_15CS30031.l

ass3_15CS30031.tab.c: ass3_15CS30031.y
	bison -d ./ass3_15CS30031.y
clean:
	rm lexer.out parser.out lex.yy.c ass3_15CS30031.tab.c ass3_15CS30031.tab.h
