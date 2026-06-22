import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.misc.Pair;
import translation.Function;
import translation.Program;
import translation.Type;
import translation.Variables;
import translation.statements.*;

import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/*
El nombre ClasePrincipal es arbitrario, escoge el que prefieras.
Sustituye Numbers por el nombre del fichero que contiene la especificación de la gramática ANTLR
(extensión .g4)
*/
public class Main {
	public static void main(String[] args) {
		try{
			// Preparar el fichero de entrada para asignarlo al analizador léxico
			CharStream input = CharStreams.fromFileName(args[0]);
			// Crear el objeto correspondiente al analizador léxico con el fichero de
			// entrada
			ScientificLexer analex = new ScientificLexer(input);
			// Identificar al analizador léxico como fuente de tokens para el
			// sintactico
			CommonTokenStream tokens = new CommonTokenStream(analex);
			// Crear el objeto correspondiente al analizador sintáctico
			ScientificParser anasint = new ScientificParser(tokens);

            /*
            Si se quiere pasar al analizador algún objeto externo con el que trabajar,
            este deberá ser de una clase del mismo paquete
            Aquí se le llama "sintesis", pero puede ser cualquier nombre.
            NumbersParser anasint = new NumbersParser(tokens, new sintesis());
            */
            /*
            Comenzar el análisis llamando al axioma de la gramática
            Atención, sustituye "AxiomaDeLaGramatica" por el nombre del axioma de tu
            gramática
            */

			Program p = anasint.r().prog;
			try (FileWriter fw = new FileWriter(args[0].replace(".for", ".c"))) {
				fw.write(p.toString());
			}
		} catch (org.antlr.v4.runtime.RecognitionException e) {
			//Fallo al reconocer la entrada
			System.err.println("REC " + e.getMessage());
		} catch (IOException e) {
			//Fallo de entrada/salida
			System.err.println("IO " + e.getMessage());
		} catch (RuntimeException e) {
			//Cualquier otro fallo
			System.err.println("RUN " + e.getMessage());
		}


		/*
		Small example of how a function is created (to serve as reference)
	 	Original code would be something like:

		FUNCTION foo(myFloat, longText)
			INTEGER :: foo;
			REAL, INTENT(IN) myFloat;
			CHARACTER(30), INTENT(IN) longText;

			INTEGER :: bar = 3, baz = 77;
			foo = (bar * 2 - baz) / myFloat;
		END FUNCTION foo


		Resulting java code (plus a print at the beginning and end in case we wanna run it for testing).


		System.out.println("-".repeat(10) + " TESTING " + "-".repeat(10));

		List<Pair<Type, String>> params = new ArrayList<Pair<Type, String>>();
		params.add(new Pair<Type, String>(new Type("float"), "myFloat"));
		params.add(new Pair<Type, String>(new Type("char", 30), "longText"));
		Function f = new Function(new Type("int"), "foo", params);

		Variables vars = new Variables(new Type("int"), "bar", "3");
		vars.addCurrentVar();
		vars.currentName = "baz";
		vars.currentValue = "77";
		vars.addCurrentVar();

		f.code.statements.add(new VarDeclarationStatement(vars));
		f.code.statements.add(new AssignStatement("foo", new ExprStatement("(bar * 2 - baz) / myFloat"))); // this will be converted to a return statement by the function's toString

		System.out.println(f.toString());
		 */
	}
}
