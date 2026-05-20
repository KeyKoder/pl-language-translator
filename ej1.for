PROGRAM prog1 ;
INTEGER, PARAMETER :: max_val = 100, min_val = -50;
REAL, PARAMETER :: pi = 3.1415, e = 2.71828, c = 2e-6;
CHARACTER(10), PARAMETER :: texto = 'a " b '' c', texto2 = "d "" e ' f";

INTEGER :: contador = 0, acumulador;
REAL :: promedio, total = 0.0;
CHARACTER(10) :: mensaje1 = 'Hola', mensaje2 = 'Mundo';


INTEGER :: var1, var2 = 24;
REAL :: var3;
CHARACTER :: var4, var5 = "-", var6;
CHARACTER (10):: var7, var8;


    INTERFACE

        SUBROUTINE ImprimirMensaje(texto)
            CHARACTER(10), INTENT(IN) texto;
        END SUBROUTINE ImprimirMensaje

        FUNCTION Sumar(a, b)
            INTEGER :: Sumar;
            INTEGER, INTENT(IN) a;
            INTEGER, INTENT(IN) b;
        END FUNCTION Sumar


        FUNCTION fun1 ( a, b )
            INTEGER :: fun1;
            INTEGER, INTENT (IN) a;
            CHARACTER(4), INTENT (IN) b;
        END FUNCTION fun1

        SUBROUTINE proc1 ( c, d , e )
            REAL, INTENT (OUT) c;
            INTEGER, INTENT (IN) d;
            INTEGER, INTENT (INOUT) e;
        END SUBROUTINE proc1

        SUBROUTINE proc2
        END SUBROUTINE proc2

    END INTERFACE

    contador = contador + 1;
    total = total + 45.6;
    CALL ImprimirMensaje('Bienvenido');
    promedio = total / 2.0;

END PROGRAM prog1

SUBROUTINE ImprimirMensaje(texto)
    CHARACTER(10), INTENT(IN) texto;
    CALL MostrarEnPantalla(texto);
END SUBROUTINE ImprimirMensaje

FUNCTION Sumar(a, b)
    INTEGER :: Sumar;
    INTEGER, INTENT(IN) a;
    INTEGER, INTENT(IN) b;

    INTEGER :: suma;
    suma = a + b;
    Sumar = suma;
END FUNCTION Sumar