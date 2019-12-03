/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Representación de la tabla de símbolos (SymbolTable) */

#include "mccSymbolTable.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/**
 * Relacionados con la representación de la tabla de símbolos.
 */

struct PosicionListaRep {
    Symbol dato;
    struct PosicionListaRep * sig;
};

struct ListaRep {
    PosicionLista cabecera;
    PosicionLista ultimo;
    int n;
};

typedef struct PosicionListaRep * NodoPtr;

/* Función privada para el manejo de la representación interna. */
void private_LS_insert(Lista lista, PosicionLista p, Symbol s) {
    NodoPtr nuevo = malloc(sizeof(struct PosicionListaRep));
    nuevo->dato = s;
    nuevo->sig = p->sig;
    p->sig = nuevo;
    if (lista->ultimo == p) {
        lista->ultimo = nuevo;
    }
    (lista->n)++;
}

/* Función privada para el manejo de la representación interna. */
Symbol private_LS_retrieve(Lista lista, PosicionLista p) {
    assert(p != lista->ultimo);
    return p->sig->dato;
}

/* Función privada para el manejo de la representación interna. */
PosicionLista private_LS_search(Lista lista, char *nombre) {
    NodoPtr aux = lista->cabecera;
    while (aux->sig != NULL && strcmp(aux->sig->dato.nombre,nombre) != 0) {
        aux = aux->sig;
    }
    return aux;
}

/**
 * Relacionados con la manipulación de la tabla de símbolos.
 */

/* Tabla de símbolos general. */
Lista GeneralSymbolList;

/* Contador de cadenas para la generación de código. */
int strCount = 0;

/* Almacena el tipo del último identificador que fue reconocido. */
SymbolType currentSymbolType;

void SymbolTableSetCurrentType(SymbolType t) {
    currentSymbolType = t;
}

void SymbolTableCreate() {
    Lista nueva = malloc(sizeof(struct ListaRep));
    nueva->cabecera = malloc(sizeof(struct PosicionListaRep));
    nueva->cabecera->sig = NULL;
    nueva->ultimo = nueva->cabecera;
    nueva->n = 0;
    GeneralSymbolList = nueva;
}

void SymbolTablePrint() {
    PosicionLista p;

    printf("\t.data\n");

    /* Imprimir cadenas del programa. */
    p = GeneralSymbolList->cabecera;
    int currentString = 1;
    while (p != GeneralSymbolList->ultimo) {
        Symbol aux = private_LS_retrieve(GeneralSymbolList, p);
        if (aux.tipo == SYMSTR) {
            printf("$str%d:\n", currentString);
            printf("\t.asciiz \"%s\"\n", aux.nombre);
            currentString++;
        }
        assert(p != GeneralSymbolList->ultimo);
        p = p->sig;
    }

    /* Imprimir variables globales. */
    p = GeneralSymbolList->cabecera;
    while (p != GeneralSymbolList->ultimo) {
        Symbol aux = private_LS_retrieve(GeneralSymbolList, p);
        if (aux.tipo == SYMVAR || aux.tipo == SYMCONST) {
            printf("_%s:\n", aux.nombre);
            printf("\t.word 0\n");
        }
        assert(p != GeneralSymbolList->ultimo);
        p = p->sig;
    }

    printf("\n");
}

void SymbolTableFree() {
    while (GeneralSymbolList->cabecera != NULL) {
        NodoPtr borrar = GeneralSymbolList->cabecera;
        GeneralSymbolList->cabecera = borrar->sig;
        free(borrar);
    }
    free(GeneralSymbolList);
}

int SymbolTableContains(char * symbol) {
    PosicionLista p = private_LS_search(GeneralSymbolList, symbol);
    return (p != GeneralSymbolList->ultimo);
}

void SymbolTableInsert(char * symbol) {
    Symbol aux;
    aux.nombre = symbol;
    aux.tipo = currentSymbolType;
    aux.valor = 0;
    private_LS_insert(GeneralSymbolList, GeneralSymbolList->ultimo, aux);
}

int SymbolTableInsertString(char * symbol) {
    char * trimmed = strdup(symbol);
    trimmed++; /* Quitar comillas del principio. */
    trimmed[strlen(trimmed) - 1] = 0; /* Quitar comillas del final. */

    /* Comprobar si la cadena existe. */
    PosicionLista p = GeneralSymbolList->cabecera;
    int strId = 0;
    int encontrado = 0;
    while (p != GeneralSymbolList->ultimo && encontrado == 0) {
        Symbol aux = private_LS_retrieve(GeneralSymbolList, p);
        if (aux.tipo == SYMSTR) {
            strId++;

            if (strcmp(aux.nombre, trimmed) == 0) {
                encontrado = 1;
            }
        }
        assert(p != GeneralSymbolList->ultimo);
        p = p->sig;
    }

    if (encontrado == 0) {
        strCount++;

        Symbol aux;
        aux.nombre = trimmed;
        aux.tipo = SYMSTR;
        aux.valor = strCount;
        private_LS_insert(GeneralSymbolList, GeneralSymbolList->ultimo, aux);

        return strCount;
    } else {
        return strId;
    }
}

int SymbolTableCheckConstant(char * symbol) {
    PosicionLista p = private_LS_search(GeneralSymbolList, symbol);
    if (p != GeneralSymbolList->ultimo) {
        Symbol aux = private_LS_retrieve(GeneralSymbolList, p);
        return aux.tipo == SYMCONST;
    } else {
        return 0;
    }
}
