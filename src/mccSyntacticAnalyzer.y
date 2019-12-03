/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Analizador sintáctico (Bison) */

%{
    /* Opciones de Yacc. */
    extern int yylex();
    extern int yylineno;
    void yyerror(const char * s);
    extern char * yytext;

    /* Análisis. */
    int sinErrN = 0; /* Número de errores sintácticos. */
    int semErrN = 0; /* Número de errores semánticos. */

    /* Tabla de símbolos. */
    #include "mccSymbolTable.h"

    /* Lista de código. */
    #include "mccCodeList.h"

    /* Otros. */
    #include <stdio.h> /* Para impresión por pantalla. */
    #include <string.h> /* Para la concatenación de cadenas. */
    char * StringJoin(char * a, char * b);
%}

/* Tipos de datos para token y no terminales. */
%union {
    char * str; /* Accesible en el analizador léxico con yylval.str. */
    CodeList codigo; /* Para las listas de código de los no terminales. */
}

/* Para incluir en el léxico (mccSyntacticAnalyzer.tab.h) la definición de CodeList. */
%code requires {
    #include "mccCodeList.h"
}

/* Definición del tipo de no terminales. */
%type <codigo> declarations identifier_list asig expression statement statement_list print_list print_item read_list

/* Declaración de tokens. */
/* El valor entre comillas nos permitiría usarlo directamente para referenciar al token, pero en este caso se ha preferido usar el nombre de macro. */
%token <str> T_ID                     "id"
%token <str> T_LITINT                 "int"
%token <str> T_LITSTR                 "string";
%token T_FUNC                         "func"
%token T_VAR                          "var"
%token T_CONST                        "const"
%token T_IF                           "if"
%token T_ELSE                         "else"
%token T_WHILE                        "while"
%token T_DO                           "do"
%token T_PRINT                        "print"
%token T_READ                         "read"
%token T_SMCLN                        ";"
%token T_COMMA                        ","
%token T_PLUS                         "+"
%token T_SUBS                         "-"
%token T_MULT                         "*"
%token T_DIVI                         "/"
%token T_ASSIGN                       "="
%token T_PARL                         "("
%token T_PARR                         ")"
%token T_BRKL                         "{"
%token T_BRKR                         "}"

/* Asociatividad y precedencia de operadores. */
%left T_PLUS T_SUBS
%left T_MULT T_DIVI
%left T_SUBX

/* Otras opciones. */
%define parse.error verbose
%define lr.type lalr
%define lr.default-reduction accepting
%define parse.trace

/* Aceptación de conflictos. */
%expect 1

%%

/* Reglas de producción de la gramática. */
program                             :   {
                                            yydebug = 0;
                                        }
                                      "func" "id" "(" ")" "{" declarations statement_list "}"
                                        {
                                            g = CodeListCreate();
                                            CodeListJoin(g, $7);
                                            CodeListFree($7);
                                            CodeListJoin(g, $8);
                                            CodeListFree($8);
                                        }
                                    ;

declarations                        : declarations "var"
                                        {
                                            SymbolTableSetCurrentType(SYMVAR);
                                        }
                                      identifier_list ";"
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListFree($1);
                                            CodeListJoin($$, $4);
                                            CodeListFree($4);
                                        }
                                    | declarations "const"
                                        {
                                            SymbolTableSetCurrentType(SYMCONST);
                                        }
                                      identifier_list ";"
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListFree($1);
                                            CodeListJoin($$, $4);
                                            CodeListFree($4);
                                        }
                                    | /* Lambda. */
                                        {
                                            $$ = CodeListCreate();

                                            /* Creamos la tabla de símbolos en la sección de declaraciones. */
                                            SymbolTableCreate();
                                        }
                                    | declarations "var" error ";"
                                        {
                                            /* Recuperar errores de declaraciones. */
                                            $$ = CodeListCreate();
                                        }
                                    | declarations "const" error ";"
                                        {
                                            /* Recuperar errores de declaraciones. */
                                            $$ = CodeListCreate();
                                        }
                                    ;

identifier_list                     : asig
                                        {
                                            $$ = $1;
                                        }
                                    | identifier_list "," asig
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListJoin($$, $3);
                                        }
                                    ;

asig                                : "id"
                                        {
                                            if (! SymbolTableContains($1)) {
                                                SymbolTableInsert($1);
                                            } else {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" ya está declarada\n", yylineno, $1);
                                            }

                                            $$ = CodeListCreate();
                                        }
                                    | "id" "=" expression
                                        {
                                            if (! SymbolTableContains($1)) {
                                                SymbolTableInsert($1);
                                            } else {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" ya está declarada\n", yylineno, $1);
                                            }

                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $3);
                                            /* sw $t0, _x */
                                            Instruction i = newOpT3("sw", CodeListGetResultRegister($3), StringJoin("_", $1));
                                            CodeListInsert($$, i);
                                            CodeListReleaseTemporaryRegister(i.res);

                                            CodeListFree($3);
                                        }
                                    ;

statement_list                      : statement_list statement
                                        {
                                            $$ = $1;
                                            CodeListJoin($$, $2);

                                            CodeListFree($2);
                                        }
                                    | /* Lambda. */
                                        {
                                            $$ = CodeListCreate();
                                        }
                                    ;

statement                           : "id" "=" expression ";"
                                        {
                                            if (! SymbolTableContains($1)) {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" no está declarada\n", yylineno, $1);
                                            } else {
                                                if (SymbolTableCheckConstant($1)) {
                                                    semErrN++;
                                                    fprintf(stderr, "Error semántico (linea %d): \"%s\" es una constante\n", yylineno, $1);
                                                }
                                            }

                                            $$ = $3;

                                            /* sw $t0, _x */
                                            Instruction i = newOpT3("sw", CodeListGetResultRegister($3), StringJoin("_", $1));
                                            CodeListInsert($$, i);
                                            CodeListReleaseTemporaryRegister(i.res);
                                        }
                                    | "{" statement_list "}"
                                        {
                                            /* La función de las llaves es solo sintáctica. */
                                            $$ = $2;
                                        }
                                    | "if" "(" expression ")" statement "else" statement
                                        {
                                            $$ = $3;
                                            Instruction i;

                                            /* beqz $ti, $endIfLabel */
                                            char * endIfLabel = CodeListGenerateLabel();
                                            char * beqzTempReg = CodeListGetResultRegister($3);
                                            i = newOpT3("beqz", beqzTempReg, endIfLabel);
                                            CodeListReleaseTemporaryRegister(beqzTempReg);
                                            CodeListInsert($$, i);

                                            /* Código para $ti != 0. */
                                            CodeListJoin($$, $5);

                                            /* b $endIfLabel */
                                            char * endElseLabel = CodeListGenerateLabel();
                                            i = newOpT2("b", endElseLabel);
                                            CodeListInsert($$, i);

                                            /* Código para $ti == 0. */
                                            i = newOpT2("etiq", endIfLabel);
                                            CodeListInsert($$, i);
                                            CodeListJoin($$, $7);

                                            /* $endElseLabel */
                                            i = newOpT2("etiq", endElseLabel);
                                            CodeListInsert($$, i);

                                            CodeListFree($5);
                                            CodeListFree($7);
                                        }
                                    | "if" "(" expression ")" statement
                                        {
                                            $$ = $3;
                                            Instruction i;

                                            /* beqz $ti, $endIfLabel */
                                            char * endIfLabel = CodeListGenerateLabel();
                                            char * beqzTempReg = CodeListGetResultRegister($3);
                                            i = newOpT3("beqz", beqzTempReg, endIfLabel);
                                            CodeListReleaseTemporaryRegister(beqzTempReg);
                                            CodeListInsert($$, i);

                                            /* Código para $ti != 0. */
                                            CodeListJoin($$, $5);

                                            /* Código para $ti == 0 y el resto. */
                                            i = newOpT2("etiq", endIfLabel);
                                            CodeListInsert($$, i);

                                            CodeListFree($5);
                                        }
                                    | "while" "(" expression ")" statement
                                        {
                                            $$ = CodeListCreate();
                                            Instruction i;

                                            /* $beginWhileLabel */
                                            char * beginWhileLabel = CodeListGenerateLabel();
                                            i = newOpT2("etiq", beginWhileLabel);
                                            CodeListInsert($$, i);

                                            /* Evaluación de la expresión de condición. */
                                            CodeListJoin($$, $3);

                                            /* beqz $ti, $endWhileLabel */
                                            char * endWhileLabel = CodeListGenerateLabel();
                                            char * beqzTempReg = CodeListGetResultRegister($3);
                                            i = newOpT3("beqz", beqzTempReg, endWhileLabel);
                                            CodeListReleaseTemporaryRegister(beqzTempReg);
                                            CodeListInsert($$, i);

                                            /* Código para $ti != 0 (cuerpo del bucle). */
                                            CodeListJoin($$, $5);

                                            /* b $beginWhileLabel */
                                            i = newOpT2("b", beginWhileLabel);
                                            CodeListInsert($$, i);

                                            /* $endWhileLabel */
                                            i = newOpT2("etiq", endWhileLabel);
                                            CodeListInsert($$, i);

                                            CodeListFree($3);
                                            CodeListFree($5);
                                        }
                                    | "do" statement "while" "(" expression ")" ";"
                                        {
                                            $$ = CodeListCreate();
                                            Instruction i;

                                            /* $beginDoWhileLabel */
                                            char * beginDoWhileLabel = CodeListGenerateLabel();
                                            i = newOpT2("etiq", beginDoWhileLabel);
                                            CodeListInsert($$, i);

                                            /* Código para primera iteración y $ti != 0 (cuerpo del bucle). */
                                            CodeListJoin($$, $2);

                                            /* Evaluación de la expresión condición. */
                                            CodeListJoin($$, $5);

                                            /* bnez $ti, $beginDoWhileLabel */
                                            char * bnezTempReg = CodeListGetResultRegister($5);
                                            i = newOpT3("bnez", bnezTempReg, beginDoWhileLabel);
                                            CodeListReleaseTemporaryRegister(bnezTempReg);
                                            CodeListInsert($$, i);

                                            CodeListFree($2);
                                            CodeListFree($5);
                                        }
                                    | "print" print_list ";"
                                        {
                                            $$ = $2;
                                        }
                                    | "read" read_list ";"
                                        {
                                            $$ = $2;
                                        }
                                    | error ";"
                                        {
                                            /* Recuperar errores de sentencias. */
                                            $$ = CodeListCreate();
                                        }
                                    ;

print_list                          : print_item
                                        {
                                            $$ = $1;
                                        }
                                    | print_list "," print_item
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListFree($1);
                                            CodeListJoin($$, $3);
                                            CodeListFree($3);
                                        }
                                    ;

print_item                          : expression
                                        {
                                            $$ = $1;

                                            /* move $a0, $t0 */
                                            char * tempReg = CodeListGetResultRegister($1);
                                            CodeListInsert($$, newOpT3("move", "$a0", tempReg));
                                            CodeListReleaseTemporaryRegister(tempReg);

                                            /* li $v0, 4 */
                                            CodeListInsert($$, newOpT3("li", "$v0", "1"));

                                            /* syscall */
                                            CodeListInsert($$, newOpT1("syscall"));
                                        }
                                    | "string"
                                        {
                                            int strId = SymbolTableInsertString($1);
                                            $$ = CodeListCreate();

                                            /* la $a0, $str1 */
                                            char * aux = (char *) malloc(4 + 4 + 1); /* "$str" + "9999" + 0 */ 
                                            sprintf(aux, "$str%d", strId);
                                            CodeListInsert($$, newOpT3("la", "$a0", aux));

                                            /* li $v0, 4  */
                                            CodeListInsert($$, newOpT3("li", "$v0", "4"));

                                            /* syscall */
                                            CodeListInsert($$, newOpT1("syscall"));
                                        }
                                    ;

read_list                           : "id"
                                        {
                                            if (! SymbolTableContains($1)) {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" no está declarada\n", yylineno, $1);
                                            } else {
                                                if (SymbolTableCheckConstant($1)) {
                                                    semErrN++;
                                                    fprintf(stderr, "Error semántico (linea %d): \"%s\" es una constante\n", yylineno, $1);
                                                }
                                            }

                                            $$ = CodeListCreate();

                                            /* li $v0, 5 */
                                            CodeListInsert($$, newOpT3("li", "$v0", "5"));

                                            /* syscall */
                                            CodeListInsert($$, newOpT1("syscall"));

                                            /* sw $v0, _x */
                                            CodeListInsert($$, newOpT3("sw", "$v0", StringJoin("_", $1)));
                                        }
                                    | read_list "," "id"
                                        {
                                            if (! SymbolTableContains($3)) {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" no está declarada\n", yylineno, $3);
                                            } else {
                                                if (SymbolTableCheckConstant($3)) {
                                                    semErrN++;
                                                    fprintf(stderr, "Error semántico (linea %d): \"%s\" es una constante\n", yylineno, $3);
                                                }
                                            }

                                            $$ = $1;
                                        }
                                    ;

expression                          : expression "+" expression
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListJoin($$, $3);

                                            /* add $t2, $t1, $t0 */
                                            Instruction i = newOpT4("add", CodeListGetAvailableTemporaryRegister(), CodeListGetResultRegister($1), CodeListGetResultRegister($3));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListReleaseTemporaryRegister(i.arg1);
                                            CodeListReleaseTemporaryRegister(i.arg2);
                                            CodeListInsert($$, i);

                                            CodeListFree($1);
                                            CodeListFree($3);
                                        }
                                    | expression "-" expression
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListJoin($$, $3);

                                            /* sub $t2, $t1, $t0 */
                                            Instruction i = newOpT4("sub", CodeListGetAvailableTemporaryRegister(), CodeListGetResultRegister($1), CodeListGetResultRegister($3));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListReleaseTemporaryRegister(i.arg1);
                                            CodeListReleaseTemporaryRegister(i.arg2);
                                            CodeListInsert($$, i);

                                            CodeListFree($1);
                                            CodeListFree($3);
                                        }
                                    | expression "*" expression
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListJoin($$, $3);

                                            /* mul $t2, $t1, $t0 */
                                            Instruction i = newOpT4("mul", CodeListGetAvailableTemporaryRegister(), CodeListGetResultRegister($1), CodeListGetResultRegister($3));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListReleaseTemporaryRegister(i.arg1);
                                            CodeListReleaseTemporaryRegister(i.arg2);
                                            CodeListInsert($$, i);

                                            CodeListFree($1);
                                            CodeListFree($3);
                                        }
                                    | expression "/" expression
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $1);
                                            CodeListJoin($$, $3);

                                            /* mul $t2, $t1, $t0 */
                                            Instruction i = newOpT4("div", CodeListGetAvailableTemporaryRegister(), CodeListGetResultRegister($1), CodeListGetResultRegister($3));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListReleaseTemporaryRegister(i.arg1);
                                            CodeListReleaseTemporaryRegister(i.arg2);
                                            CodeListInsert($$, i);

                                            CodeListFree($1);
                                            CodeListFree($3);
                                        }
                                    | "-" expression %prec T_SUBX
                                        {
                                            $$ = CodeListCreate();
                                            CodeListJoin($$, $2);

                                            /* neg $t1, $t0 */
                                            Instruction i = newOpT3("neg", CodeListGetAvailableTemporaryRegister(), CodeListGetResultRegister($2));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListReleaseTemporaryRegister(i.arg1);
                                            CodeListInsert($$, i);

                                            CodeListFree($2);
                                        }
                                    | "(" expression ")"
                                        {
                                            /* La función de los paréntesis es solo sintáctica. */
                                            $$ = $2;
                                        }
                                    | "id"
                                        {
                                            if (! SymbolTableContains($1)) {
                                                semErrN++;
                                                fprintf(stderr, "Error semántico (linea %d): \"%s\" no está declarada\n", yylineno, $1);
                                            }

                                            $$ = CodeListCreate();

                                            /* lw $t0, _id */
                                            Instruction i = newOpT3("lw", CodeListGetAvailableTemporaryRegister(), StringJoin("_", $1));
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListInsert($$, i);
                                        }
                                    | "int"
                                        {
                                            $$ = CodeListCreate();

                                            /* li $t0, 9 */
                                            Instruction i = newOpT3("li", CodeListGetAvailableTemporaryRegister(), $1);
                                            CodeListSetResultRegister($$, i.res);
                                            CodeListInsert($$, i);
                                        }
                                    ;
%%

/* Otros. */
void yyerror(const char * s) {
    sinErrN++;
    fprintf(stderr, "Error sintáctico (línea %d): (yyerror) %s \n", yylineno, s);
}

char * StringJoin(char * a, char * b) {
    int l = strlen(a) + strlen(b) + 1;
    char * aux = (char *) malloc(l);
    sprintf(aux, "%s%s", a, b);
    return aux;
}
