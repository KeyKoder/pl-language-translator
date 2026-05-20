grammar Scientific;

@members {
    translation.Program p;
}


// prg
r : prg;

// Lexer tokens

STRING_CONST : DOUBLE_QUOTE_STRING | SIMPLE_QUOTE_STRING;

DOUBLE_QUOTE_STRING : '"' (~('"')|'""')* '"';
// DOUBLE_QUOTE_STRING : '"' PLAINTEXT* (('\'' | '""')* PLAINTEXT)* '"';

SIMPLE_QUOTE_STRING : '\'' (~('\'')|'\'\'')* '\'';
// SIMPLE_QUOTE_STRING : '\'' PLAINTEXT* (('"' | '\'\'')* PLAINTEXT)* '\'';


IDENT : [a-zA-Z] [a-zA-Z0-9_]*;

NUM_INT_CONST : '-'? DIGIT+;

NUM_REAL_CONST : NUM_FIXED_CONST | NUM_EXP_CONST | NUM_MIXED_CONST;

NUM_FIXED_CONST : '-'? DIGIT+ '.' DIGIT+;

NUM_EXP_CONST : '-'? DIGIT+ [eE] '-'? DIGIT+; 

NUM_MIXED_CONST : '-'? DIGIT+ '.' DIGIT+ [eE] '-'? DIGIT+;

//Parte opcional
NUM_INT_CONST_B : 'b' '\''[01]+'\'' {setText("0b" + getText().substring(2, getText().length() - 1));};
NUM_INT_CONST_O : 'o' '\''[0-7]+'\'' {setText("0o" + getText().substring(2, getText().length() - 1));};
NUM_INT_CONST_H : 'z' '\''[0-9A-F]+'\'' {setText("0x" + getText().substring(2, getText().length() - 1));};

//Fin de la parte opcional

COMMENTS : '!' PLAINTEXT NL;

WS : (' ' | '\t' | NL) -> skip;

// Syntax

/*
    Atributos de p:
    p.dcls: guarda los #define
    p.vars: guarda la declaración de las varibles globales
    p.functions: declaraciones de funciones y subrutinas
    p.main: guarda el codigo de la funcion main
    p.funimpl: guarda las funciones implementadas

*/

// TODO: una vez tengamos pasado sentlist usando la clase translation.Block (que devuelva un block, o que modifique el heredado utilizando la referencia al objeto),
//  cambiar la acción sintactica de "p.main = ..." a: {p.main.code = $sentlist.block;}

prg : 'PROGRAM' IDENT ';' {p = new translation.Program();} dcllist header sentlist {p.main = "void main(void)\n{\n" + $sentlist.lista + "}\n";} 'END' 'PROGRAM' IDENT subproglist {System.out.println(p);};
dcllist : | tipo dcl[$tipo.type]; //Le pasa el tipo a dcl para las declaraciones de variables, que es necesario escribirlo
header :  | 'INTERFACE' headlist 'END' 'INTERFACE';
headlist : decproc decsubprog | decfun decsubprog;
decsubprog :  | decproc decsubprog | decfun decsubprog;
sentlist returns [String lista]: sent sentlist_p {$lista = $sent.s + $sentlist_p.lista_p;}; //Devuelve un String con todas las sentencias ya procesadas y en un formato correcto (string = s1 \n s2 \n s3...)
sentlist_p returns [String lista_p]: {$lista_p = "";}| sent sl2=sentlist_p {$lista_p = $sent.s + $sl2.lista_p;};

// Syntax declarations (TODO: Creo que está terminado, revisar)
dcl [translation.Type type]: ',' 'PARAMETER' '::' IDENT '=' simpvalue {p.dcls.add("#define "+ $IDENT.text + " " + $simpvalue.val);} ctelist ';' dcllist | '::' varlist[new translation.Variables($type)] {p.vars.add($varlist.vars_s);} ';' dcllist;
//TODO: he creado un nuevo atributo p.vars porque todos los #define tienen que ir seguidos al final, pero la gramática permite que estén intercalados con las declaraciones de variables, así que hay que guardarlos en sitios distintos para conservar ese orden
//1: Hace el primer #define id xxx; y llama a laos demás del mismo tipo y al terminar al resto de constantes
//2: Hace las declaraciones de variables, escribe el tipo y llama al resto de vars de ese mismo tipo
ctelist :  | ',' IDENT '=' simpvalue {p.dcls.add("#define " + $IDENT.text + " "+ $simpvalue.val);} ctelist;
//Añade todos los #define del tipo anterior (en dcl)
simpvalue returns [String val]: NUM_INT_CONST {$val = $NUM_INT_CONST.text;} | NUM_REAL_CONST {$val = $NUM_REAL_CONST.text;} | STRING_CONST {$val = Utils.fixString($STRING_CONST.text);} | NUM_INT_CONST_B {$val = $NUM_INT_CONST_B.text;} | NUM_INT_CONST_O {$val = $NUM_INT_CONST_O.text;} | NUM_INT_CONST_H {$val = $NUM_INT_CONST_H.text;};
tipo returns [translation.Type type] : 'INTEGER' {$type = new translation.Type("int");} | 'REAL' {$type = new translation.Type("float");} | 'CHARACTER' charlength {$type = new translation.Type("char", $charlength.len);} ;
charlength returns [int len] : {$len = -1;} | '(' NUM_INT_CONST {$len = Integer.parseInt($NUM_INT_CONST.text);} ')';
varlist[translation.Variables vars_h] returns [translation.Variables vars_s] : IDENT {$vars_h.currentName = $IDENT.text;} init[$vars_h] {$vars_h.addCurrentVar();} varlist_p[$vars_h] {$vars_s = $vars_h;}; //Añade a las vars la primera del tipo anterior y llama a las siguientes
varlist_p[translation.Variables vars_h] : | ',' IDENT {$vars_h.currentName = $IDENT.text;} init[$vars_h] {$vars_h.addCurrentVar();} varlist_p[$vars_h]; //Añade la siguiente variable y continúa llamando a las siguientes
init[translation.Variables vars_h] : | '=' simpvalue {$vars_h.currentValue = $simpvalue.val;}; //Da valor inicial a las variables que lo tengan


// Syntax for subroutines
decproc : 'SUBROUTINE' procName=IDENT formal_paramlist dec_s_paramlist[new ArrayList<Pair<translation.Type, String>>()] 'END' 'SUBROUTINE' procNameEnd=IDENT {p.functions.put($procName.text, new translation.Function(new translation.Type("void"), $procName.text, $dec_s_paramlist.params_s));};
formal_paramlist :  | '(' nomparamlist ')';
nomparamlist : IDENT nomparamlist_p;
nomparamlist_p : | ',' nomparamlist;
dec_s_paramlist[List<Pair<translation.Type, String>> params_h] returns [List<Pair<translation.Type, String>> params_s] : {$params_s = $params_h;} | tipo ',' 'INTENT' '(' tipoparam ')' IDENT ';' dec_s_paramlist[$params_h] {$params_s = $dec_s_paramlist.params_s; $params_s.add(0, new Pair<translation.Type, String>($tipo.type, $IDENT.text));};
tipoparam returns [String val]: 'IN' {$val = "IN";} | 'OUT' {$val = "OUT";} | 'INOUT' {$val = "INOUT";}; //todo Esto es para los punteros (si nos da tiempo que no creo)
decfun : 'FUNCTION' funcName=IDENT '(' nomparamlist ')' tipo '::' funcNameType=IDENT ';' dec_f_paramlist[new ArrayList<Pair<translation.Type, String>>()] 'END' 'FUNCTION' funcNameEnd=IDENT {p.functions.put($funcName.text, new translation.Function($tipo.type, $funcName.text, $dec_f_paramlist.params_s));};
dec_f_paramlist[List<Pair<translation.Type, String>> params_h] returns [List<Pair<translation.Type, String>> params_s] : {$params_s = $params_h;} | tipo ',' 'INTENT' '(' 'IN' ')' IDENT ';' dec_f_paramlist[$params_h] {$params_s = $dec_f_paramlist.params_s; $params_s.add(0, new Pair<translation.Type, String>($tipo.type, $IDENT.text));};



//Syntax for assignations (TODO: Creo que está terminado, revisar)
//Cada línea añade lo que tiene, y el formato de cada tipo de sentencia se pone bien en cada uno (espacios, saltos de línea, etc)
sent returns [String s]: IDENT '=' exp ';' {$s = $IDENT.text + " = " + $exp.val + ";\n";}| proc_call ';' {$s = $proc_call.val + ";\n";} | 'IF' '(' expcond ')' sent_if[$expcond.val] {$s = $sent_if.val;} | 'DO' sent_do {$s = $sent_do.val;} |
    'SELECT' 'CASE' '(' exp ')' casos 'END' 'SELECT' {$s = "switch (" + $exp.val + ") {\n" + $casos.val + "}\n";};
exp returns [String val]: factor exp_p {$val = $factor.val + " " + $exp_p.val;};
exp_p returns [String val]: op exp exp_p  {$val = $op.val + " " + $exp.val + " " + $exp_p.val;} | {$val = "";};
op returns [String val]: '+' {$val = "+";} | '-' {$val = "-";} | '*' {$val = "*";} | '/' {$val = "/";};
factor returns [String val]: simpvalue {$val = $simpvalue.val;} | '(' exp ')' {$val = '(' + $exp.val + ')';} | IDENT subpparamlist {$val = $IDENT.text + " " + $subpparamlist.val;};
explist returns [String val]: ',' exp expl1=explist {$val = ", " + $exp.val + $expl1.val;}| {$val = "";};
proc_call returns [String val]: 'CALL' IDENT subpparamlist {$val = $IDENT.text + $subpparamlist.val;};
subpparamlist returns [String val]: '(' exp explist ')' {$val = '(' + $exp.val + $explist.val;} | {$val = "";};


//Syntax for flux control TODO falta meterlo en los objetos, pero la logica ya esta hecha
sent_if [String cond] returns [String val]: sent {$val = "if (" + $cond + ") {\n\t" + $sent.s + "}\n";} | 'THEN' sentlist sent_if_p {$val = "if (" + $cond + ") {\n" + $sentlist.lista + "}\n" + $sent_if_p.val;};
sent_if_p returns [String val]: 'ENDIF' {$val = ""}| 'ELSE' sentlist 'ENDIF' {$val = "else {\n" + $sentlist.lista + "}\n";};
sent_do returns [String val]: 'WHILE' '(' expcond ')' sentlist 'ENDDO' {$val = "while (" + $expcond.val + ") {\n" + $sentlist.lista + "}\n";} | IDENT '=' d1=doval ',' d2=doval ',' d3=doval sentlist 'ENDDO' {$val = "for (" + $IDENT.text + "=" + $d1.val + "; " + $IDENT.text + "!=" + $d2.val + "; " + $IDENT.text + "=" + $IDENT.text + "+" + $d3.val + ") {\n" + $sentlist.lista + "}\n";};
doval returns [String val]: NUM_INT_CONST {$val = $NUM_INT_CONST} | IDENT {$val = $IDENT};
casos returns [String val]: {$val = ""} | 'CASE' caso_p {$val = $caso_p.val;};
caso_p returns [String val]: '(' etiquetas ')' sentlist casos {$val = $etiquetas.val + "\n" + $sentlist.lista + "break;\n" + $casos.val;} | 'DEFAULT' sentlist {$val = "default:\n" + $sentlist.lista + "break;\n";};
etiquetas returns [String val]: simpvalue etiqueta_p[$simpvalue.val] {$val = $etiqueta_p.val;} | ':' simpvalue {$val = "case < " + $simpvalue.val + " :";};
etiqueta_p [String baseVal] returns [String val]: listaetiquetas {if ($listaetiquetas.val.isEmpty()) $val = "case " + $baseVal + " :"; else $val = "case " + $baseVal + " :\n" + $listaetiquetas.val;} |
    ':' etiqueta_secundaria {if ($etiqueta_secundaria.val.isEmpty()) $val = "case > " + $baseVal + " :\n"; else $val = "case " + $baseVal + " to " + $etiqueta_secundaria.val + ":\n";};
etiqueta_secundaria returns [String val]: {$val = "";} | simpvalue {$val = $simpvalue.val;};
listaetiquetas returns [String val]: {$val = "";} | ',' simpvalue l1=listaetiquetas {$val = "case " + $simpvalue.val + ":\n" + $l1.val;};
expcond returns [String val]: factorcond expcond_p {$val = $factorcond.val + $expcond_p.val;};
expcond_p returns [String val]: {$val = "";} | oplog factorcond e1=expcond_p {$val = " " + $oplog.val + " " + $factorcond.val + $e1.val;};
oplog returns [String val]: '.OR.' {$val = "||";} | '.AND.' {$val = "&&";} | '.EQV.' {$val = "!^";} | '.NEQV.' {$val = "^";};
factorcond returns [String val]: e1=exp opcomp e2=exp {$val = $e1.val + " " + $opcomp.val + " " + $e2.val;} | '(' expcond ')' {$val = "(" + $expcond.val + ")";} | '.NOT.' f1=factorcond {$val = "!" + $f1.val;} | '.TRUE.' {$val = "1";} | '.FALSE.' {$val = "0";};
opcomp returns [String val]: '<' {$val = "<";} | '>' {$val = ">";} | '<=' {$val = "<=";} | '>=' {$val = ">=";} | '==' {$val = "==";} | '/=' {$val = "!=";};



//Syntax for functions implementation
subproglist : codproc subproglist | codfun subproglist | ;
codproc : 'SUBROUTINE' IDENT formal_paramlist y1 sentlist 'END' 'SUBROUTINE' IDENT;
codfun : 'FUNCTION' IDENT '(' nomparamlist ')' tipo '::' IDENT ';' z1 sentlist IDENT '=' exp ';'
    'END' 'FUNCTION' IDENT;


y1 : | tipo y2[$tipo.type];
y2[translation.Type type] : ',' y3 | '::' varlist[new translation.Variables($type)] ';' dcllist;
y3 : 'INTENT' '(' tipoparam ')' IDENT ';' y1 | 'PARAMETER' '::' IDENT '=' simpvalue ctelist ';' dcllist;

z1 : | tipo z2[$tipo.type];
z2[translation.Type type] : ',' z3 | '::' varlist[new translation.Variables($type)] ';' dcllist;
z3 : 'INTENT' '(' 'IN' ')' IDENT ';' z1 | 'PARAMETER' '::' IDENT '=' simpvalue ctelist ';' dcllist;


fragment 
KEYWORD : 'PROGRAM'|'INTERFACE'|'END'|'PARAMETER'|'INTEGER'|'REAL'|'CHARACTER'|'SUBROUTINE'|'INTENT'|'IN'|'OUT'|'INOUT'|'FUNCTION'|'CALL';



// Generic fragments

fragment
NL : '\r'? '\n';

fragment
PLAINTEXT : .;

fragment
DIGIT : [0-9];
