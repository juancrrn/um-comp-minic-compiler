/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Representación de la tabla de símbolos (SymbolTable) */

#ifndef __MCC_SYMBOL_TABLE__
#define __MCC_SYMBOL_TABLE__

/**
 * Relacionados con la representación de símbolos.
 */

/* Representa el tipo de un símbolo. */
typedef enum {
    SYMVAR, /* Tipo "var" (variable). */
    SYMCONST, /* Tipo "const" (constante). */
    SYMSTR /* Cadena de caracteres. */
} SymbolType;

typedef struct Nodo {
    char * nombre; /* Cadena de caracteres del identificador */
    SymbolType tipo; /* De qué tipo es el símbolo: var o const */
    int valor; /* Guardar 0 */
} Symbol;

/**
 * Relacionados con la representación de la tabla de símbolos.
 */

/* SymbolTable es una lista enlazada que representa la tabla de símbolos y que contiene instancias de Symbol. */
typedef struct ListaRep * Lista;
typedef struct PosicionListaRep * PosicionLista;

/**
 * Relacionados con la manipulación de la tabla de símbolos.
 */

/* Establece el tipo del último identificador que fue reconocido. */
void SymbolTableSetCurrentType(SymbolType t);

/* Crea la tabla de símbolos. */
void SymbolTableCreate();

/* Imprime la tabla de símbolos. */
void SymbolTablePrint();

/* Libera la tabla de símbolos. */
void SymbolTableFree();

/* Comprueba si un símbolo está en la tabla. */
int SymbolTableContains(char * symbol);

/* Inserta un símbolo en la tabla. */
void SymbolTableInsert(char * symbol);

/* Inserta una cadena en la tabla y devuelve su identificador. */
int SymbolTableInsertString(char * symbol);

/* Comprueba si un símbolo existente en la tabla es de tipo constante. */
int SymbolTableCheckConstant(char * symbol);

#endif
