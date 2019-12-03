/* MiniC Compiler */
/* Juan Francisco Carrión Molina */

/* Programa principal que lanza el análisis y la generación de código */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE * yyin;
extern int yyparse();
extern int lexErrN;
extern int sinErrN;
extern int semErrN;

/* Tabla de símbolos. */
extern void SymbolTablePrint();
extern void SymbolTableFree();
/* Lista de código general. */
extern void CodeListGeneralPrint();
extern void CodeListGeneralFree();

FILE * fich;

int main(int argc, char * argv[]) {
    int i;

    if (argc != 2) {
	printf("Uso: %s fichero.txt\n", argv[0]);
	exit(1);
    }
    
    if ((fich = fopen(argv[1], "r")) == NULL) {
        printf("Error al abrir el fichero.\n");
	perror("Error al leer el fichero.");
        exit(1);		
    }

    yyin = fich;

    yyparse();
    fclose(fich);

    /* Generación final del código tras el análisis */
    if (lexErrN == 0 && sinErrN == 0 && semErrN == 0) {
        /* Imprimir la tabla de símbolos. */
        SymbolTablePrint();
        SymbolTableFree();
        /* Imprimir la lista de código general.. */
        CodeListGeneralPrint();
        CodeListGeneralFree();
    } else {
        printf("No se pudo completar la compilación porque existen errores.\n");
        if (lexErrN != 0) {
            printf("Errores léxicos: %d.\n", lexErrN);
        }
        if (sinErrN != 0) {
            printf("Errores sintácticos: %d.\n", sinErrN);
        }
        if (semErrN != 0) {
            printf("Errores semánticos: %d.\n", semErrN);
        }
    }

    return 0;
}
