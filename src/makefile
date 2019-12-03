# MiniC Compiler
# Juan Francisco Carrión Molina

# Directivas de compilación (Makefile)

mcc : mccSyntacticAnalyzer.tab.c lex.yy.c mccMain.c mccSymbolTable.c mccCodeList.c
	gcc mccSyntacticAnalyzer.tab.c lex.yy.c mccMain.c mccSymbolTable.c mccCodeList.c -lfl -o mcc

lex.yy.c : mccLexicalAnalyzer.l mccSyntacticAnalyzer.tab.h
	flex mccLexicalAnalyzer.l

mccSyntacticAnalyzer.tab.h mccSyntacticAnalyzer.tab.c : mccSyntacticAnalyzer.y mccSymbolTable.h mccCodeList.h
	bison -d -v mccSyntacticAnalyzer.y

clear : 
	rm -f mccSyntacticAnalyzer.output mccSyntacticAnalyzer.tab.* lex.yy.c mcc

run : mcc test.mc
	./mcc test.mc > test.s
