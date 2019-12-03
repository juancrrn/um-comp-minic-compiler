/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Representación de la lista de código generado (CodeList) */

#include "mccCodeList.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/**
 * Relacionados con la representación de instrucciones MIPS.
 */

Instruction newOpT4(char * op, char * res, char * arg1, char * arg2) {
    Instruction nueva;
    nueva.op = op;
    nueva.res = res;
    nueva.arg1 = arg1;
    nueva.arg2 = arg2;
    return nueva;
}

Instruction newOpT3(char * op, char * res, char * arg1) {
    return newOpT4(op, res, arg1, NULL);
}

Instruction newOpT2(char * op, char * res) {
    return newOpT3(op, res, NULL);
}

Instruction newOpT1(char * op) {
    return newOpT2(op, NULL);
}

/**
 * Relacionados con la representación de listas de código.
 */

struct CodeListPositionRep {
    Instruction dato;
    struct CodeListPositionRep * sig;
};

struct CodeListRep {
    CodeListPosition cabecera;
    CodeListPosition ultimo;
    int n;
    char * res;
};

typedef struct CodeListPositionRep * NodoPtr;

void private_LC_insert(CodeList codigo, CodeListPosition p, Instruction o) {
    NodoPtr nuevo = malloc(sizeof(struct CodeListPositionRep));
    nuevo->dato = o;
    nuevo->sig = p->sig;
    p->sig = nuevo;
    if (codigo->ultimo == p) {
        codigo->ultimo = nuevo;
    }
    (codigo->n)++;
}

/**
 * Relacionados con la manipulación de listas de código.
 */

/* Ocupación de registros temporales inicializado a 0. */
int temporaryRegisterOccupation[10] = { 0 };

/* Contador de etiquetas asignadas. */
int labelCounter = 1;

CodeList CodeListCreate() {
    CodeList nueva = malloc(sizeof(struct CodeListRep));
    nueva->cabecera = malloc(sizeof(struct CodeListPositionRep));
    nueva->cabecera->sig = NULL;
    nueva->ultimo = nueva->cabecera;
    nueva->n = 0;
    nueva->res = NULL;
    return nueva;
}

char * CodeListGetAvailableTemporaryRegister() {
    for (int i = 0; i < 10; i++) {
        if (temporaryRegisterOccupation[i] == 0) {
            temporaryRegisterOccupation[i] = 1;
            char aux[8];
            sprintf(aux, "$t%d", i);
            return strdup(aux);
        }
    }
    printf("Error de compilación: no hay registros temporales libres.\n");
    exit(1);
}

void CodeListReleaseTemporaryRegister(char * t) {
    int i = atoi(t + 2);
    temporaryRegisterOccupation[i] = 0;
}

void CodeListInsert(CodeList l, Instruction o) {
    private_LC_insert(l, l->ultimo, o);
}

void CodeListJoin(CodeList l1, CodeList l2) {
    NodoPtr aux = l2->cabecera;
    while (aux->sig != NULL) {
        private_LC_insert(l1, l1->ultimo,aux->sig->dato);
        aux = aux->sig;
    }
}

char * CodeListGenerateLabel() {
    char aux[16];
    sprintf(aux, "$l%d", labelCounter++);
    return strdup(aux);
}

void CodeListFree(CodeList l) {
    while (l->cabecera != NULL) {
        NodoPtr borrar = l->cabecera;
        l->cabecera = borrar->sig;
        free(borrar);
    }
    free(l);
}

void CodeListSetResultRegister(CodeList l, char * v) {
    l->res = v;
}

char * CodeListGetResultRegister(CodeList l) {
    return l->res;
}

/**
 * Relacionados con la lista de código general.
 */

void CodeListGeneralPrint() {
    printf("\t.text\n");
    printf("\t.globl main\n");
    printf("\n");
    printf("main:\n");
    
    CodeListPosition p = g->cabecera;
    Instruction current;
    while (p != g->ultimo) {
        assert(p != g->ultimo);
        current = p->sig->dato;
        if (!strcmp(current.op, "etiq")) {
            printf("%s:", current.res);
        } else {
            printf("\t%s",current.op);
            if (current.res) printf(" %s",current.res);
            if (current.arg1) printf(", %s",current.arg1);
            if (current.arg2) printf(", %s",current.arg2);
        }
        printf("\n");
        assert(p != g->ultimo);
        p = p->sig;
    }
    printf("\n");
    printf("\tjr $ra\n");
}

void CodeListGeneralFree() {
    CodeListFree(g);
}
