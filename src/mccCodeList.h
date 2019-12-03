/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Representación de la lista de código generado (CodeList) */

#ifndef __MCC_CODE_LIST__
#define __MCC_CODE_LIST__

/**
 * Relacionados con la representación de instrucciones MIPS.
 */

/* Estructura para almacenar instrucciones MIPS. */
typedef struct {
    char * op;
    char * res;
    char * arg1;
    char * arg2;
} Instruction;

/* Instrucciones de tipo "op res, arg1, arg2" (operaciones aritméticas). */
Instruction newOpT4(char * op, char * res, char * arg1, char * arg2);

/* Instrucciones de tipo "op res, arg1" (carga y almacenamiento). */
Instruction newOpT3(char * op, char * res, char * arg1);

/* Instrucciones de tipo "op res" (etiquetas). */
Instruction newOpT2(char * op, char * res);

/* Instrucciones de tipo "op" (llamadas al sistema). */
Instruction newOpT1(char * op);

/**
 * Relacionados con la representación de listas de código.
 */

/* CodeList es una lista enlazada de código, que contiene instancias de Instruction. */
typedef struct CodeListRep * CodeList;
typedef struct CodeListPositionRep * CodeListPosition;

/**
 * Relacionados con la manipulación de listas de código.
 */

/* Crea una lista de código. */
CodeList CodeListCreate();

/* Devuelve un registro temporal libre. */
char * CodeListGetAvailableTemporaryRegister();

/* Libera un registro temporal. */
void CodeListReleaseTemporaryRegister(char * t);

/* Concatena dos listas de código. La primera lista se modifica para formar el resultado. */
void CodeListJoin(CodeList a, CodeList b);

/* Inserta una instrucción al final de una lista de código. */
void CodeListInsert(CodeList l, Instruction o);

/* Devuelve una etiqueta libre. */
char * CodeListGenerateLabel();

/* Libera una lista de código. */
void CodeListFree(CodeList l);

/* Almacena el registro resultado de una lista de código. */
void CodeListSetResultRegister(CodeList codigo, char *res);

/* Recupera el registro resultado de una lista de código. */
char * CodeListGetResultRegister(CodeList codigo);

/**
 * Relacionados con la lista de código general.
 */

/* Lista de código general. */
CodeList g;

/* Imprime la lista de código general. */
void CodeListGeneralPrint();

/* Libera la lista de código general. */
void CodeListGeneralFree();

#endif
