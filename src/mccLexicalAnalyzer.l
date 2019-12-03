/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Analizador léxico (Flex) */

%{
    /* Preprocesador */
    #include "mccSyntacticAnalyzer.tab.h" // Generado por Bison

    /* Variables para el análisis */
    int commentStart;
    int lexErrN = 0; // Número de errores léxicos

    /* Funciones auxiliares */
    int verifyInteger(char * d);
    int verifyIdentifierLength(int l);
%}

digito                              [0-9]
entero                              {digito}+
letra                               [a-zA-Z]
panico                              [^ \r\n\t/a-zA-Z_0-9(){};,=+"*-]+

%x comment

%option yylineno

%%

[ \r\n\t]+                          ;
"//"(.*)[\n]                        ;

"/*"                                {
                                        yymore();
                                        commentStart = yylineno;
                                        BEGIN(comment);
                                    }

<comment>([^*]|[*]+[^*/])*          ;
<comment>[*]+"/"                    BEGIN(INITIAL);
<comment><<EOF>>                    {
                                        lexErrN++;
                                        fprintf(stderr, "Error léxico (línea %d): comentario sin cerrar\n", commentStart);
                                        return 0;
                                    }

\"([^\"\n]|\\+\")*\"                {
                                        yylval.str = strdup(yytext);
                                        return T_LITSTR;
                                    }
\"([^\"\n]|\\+\")*                  {
                                        lexErrN++;
                                        fprintf(stderr, "Error léxico (línea %d): cadena sin cerrar\n", yylineno);
                                    }

func                                return T_FUNC;
var                                 return T_VAR;
const                               return T_CONST;
if                                  return T_IF;
else                                return T_ELSE;
do                                  return T_DO;
while                               return T_WHILE;
print                               return T_PRINT;
read                                return T_READ;
";"                                 return T_SMCLN;
","                                 return T_COMMA;
"+"                                 return T_PLUS;
"-"                                 return T_SUBS;
"*"                                 return T_MULT;
"/"                                 return T_DIVI;
"="                                 return T_ASSIGN;
"("                                 return T_PARL;
")"                                 return T_PARR;
"{"                                 return T_BRKL;
"}"                                 return T_BRKR;

({letra}|_)({letra}|{digito}|_)*    {
                                        if (verifyIdentifierLength(yyleng)) {
                                            yylval.str = strdup(yytext);
                                            return T_ID;
                                        } else {
                                            lexErrN++;
                                            fprintf(stderr, "Error léxico (línea %d): identificador demasiado largo \"%s\"\n", yylineno, yytext);
                                            return T_ID;
                                        }
                                    }

{entero}                            {
                                        if (verifyInteger(yytext)) {
                                            yylval.str = strdup(yytext);
                                            return T_LITINT;
                                        } else {
                                            lexErrN++;
                                            fprintf(stderr, "Error léxico (línea %d): entero demasiado grande \"%s\"\n", yylineno, yytext);
                                            return T_LITINT;
                                        }
                                    }

{panico}                            {
                                        lexErrN++;
                                        fprintf(stderr, "Error léxico (línea %d): caracteres no válidos \"%s\"\n", yylineno, yytext);
                                    }

%%

int verifyInteger(char * d) {
    long int i = atol(d);
    if (i > 2147483648) {
        return 0;
    } else {
        return 1;
    }
}

int verifyIdentifierLength(int l) {
    if (l > 16) {
        return 0;
    } else {
        return 1;
    }
}
