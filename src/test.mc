func prueba () {
    const a = 1;
    const b = 2 * 3;
    var c;
    var d = 5 + 2, e = 9 / 3;

    print "Inicio del programa\n";

    print "Introduce el valor de \"c\":\n";
    read c;

    if (c) print "\"c\" no era nulo.", "\n";
    else print "\"c\" si era nulo.", "\n";

    /* Imprimir d */
    while (d) {
        print "\"d\" vale", d, "\n";
        d = d - 1;
    }

    /* Imprimir e */
    do {
        print "\"e\" vale", e, "\n";
        e = e - 1;
    } while(e);
    
	print "Final","\n";
}
