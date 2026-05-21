grammar Scientific;

/*
   RAZONAMIENTO SOBRE POR QUE UTILIZAMOS @members
   Podríamos haber ido pasando blockDepth hacia abajo partiendo desde sentlist hasta las producciones/reglas
   que lo necesitaran utilizando atributos heredados, pero pensamos que sería más limpio hacerlo de esta manera
   en vez de llenar todas las producciones/reglas con un atributo que la mayoría no utilizaría.

   El mismo razonamiento aplica a tener Program aquí, no querer añadir un atributo extra a básicamente todas las reglas de la gramática.
   --------------------------------
   REASONING AS TO WHY WE USED @members
   This could also be done by passing the current blockDepth down from sentlist to the rules that need them using inherited attributes,
   but we felt it looks cleaner doing it this way instead of bloating the rules with an attribute most of them wont use.

   same reasoning with having Program here, not wanting to add an extra attribute to basically every rule in the grammar.
*/
@members {
    translation.Program p;
    int blockDepth = 0;
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

COMMENTS : ('!' PLAINTEXT*? (NL|EOF)) -> skip;

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

prg : 'PROGRAM' IDENT ';' {p = new translation.Program();} dcllist header sentlist[p.main.code]  'END' 'PROGRAM' IDENT {blockDepth--;} subproglist {System.out.println(p);};
dcllist : | tipo dcl[$tipo.type]; //Le pasa el tipo a dcl para las declaraciones de variables, que es necesario escribirlo
header :  | 'INTERFACE' headlist 'END' 'INTERFACE';
headlist : decproc decsubprog | decfun decsubprog;
decsubprog :  | decproc decsubprog | decfun decsubprog;
sentlist[translation.Block block] : {block.depth = blockDepth++;} sent {$block.statements.add($sent.statement);} sentlist_p[$block]; //Devuelve un String con todas las sentencias ya procesadas y en un formato correcto (string = s1 \n s2 \n s3...)
sentlist_p[translation.Block block] : | sent {$block.statements.add($sent.statement);} sl2=sentlist_p[$block];

// Syntax declarations (TODO: Creo que está terminado, revisar)
dcl [translation.Type type]: ',' 'PARAMETER' '::' IDENT '=' simpvalue {p.dcls.add("#define "+ $IDENT.text + " " + $simpvalue.val);} ctelist ';' dcllist | '::' varlist[new translation.Variables($type)] {p.vars.add($varlist.vars_s);} ';' dcllist;
//TODO: he creado un nuevo atributo p.vars porque todos los #define tienen que ir seguidos al final, pero la gramática permite que estén intercalados con las declaraciones de variables, así que hay que guardarlos en sitios distintos para conservar ese orden
//1: Hace el primer #define id xxx; y llama a laos demás del mismo tipo y al terminar al resto de constantes
//2: Hace las declaraciones de variables, escribe el tipo y llama al resto de vars de ese mismo tipo
ctelist :  | ',' IDENT '=' simpvalue {p.dcls.add("#define " + $IDENT.text + " "+ $simpvalue.val);} ctelist;
//Añade todos los #define del tipo anterior (en dcl)
simpvalue returns [String val]: NUM_INT_CONST {$val = $NUM_INT_CONST.text;} | NUM_REAL_CONST {$val = $NUM_REAL_CONST.text;} | STRING_CONST {$val = Utils.fixString($STRING_CONST.text);} | NUM_INT_CONST_B {$val = Utils.fixBasedIntLiteral($NUM_INT_CONST_B.text);} | NUM_INT_CONST_O {$val = Utils.fixBasedIntLiteral($NUM_INT_CONST_O.text);} | NUM_INT_CONST_H {$val = Utils.fixBasedIntLiteral($NUM_INT_CONST_H.text);};
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



//Syntax for assignations
//Cada línea añade lo que tiene, y el formato de cada tipo de sentencia se pone bien en cada uno (espacios, saltos de línea, etc)
sent returns [translation.statements.Statement statement]: IDENT '=' exp ';' {$statement = new translation.statements.AssignStatement($IDENT.text, $exp.statement);}| proc_call ';' {$statement = $proc_call.statement;} |
    'IF' '(' expcond ')' sent_if[$expcond.statement] {$statement = $sent_if.statement_s;}; // | 'DO' sent_do {$statement = $sent_do.val;} |
//    'SELECT' 'CASE' '(' exp ')' casos 'END' 'SELECT' {$statement = "switch (" + $exp.statement + ") {\n" + $casos.val + "}\n";};
exp returns [translation.statements.ExprStatement statement] : factor {$statement = new translation.statements.ExprStatement(); $statement.left = $factor.statement;} exp_p[$statement];
exp_p[translation.statements.ExprStatement statement_h] returns [translation.statements.ExprStatement statement_s]: {$statement_s = $statement_h;} op {$statement_s.operator = $op.val;} exp {$statement_s.right = $exp.statement;} exp_p[$statement_s] | {$statement_s = $statement_h;};
op returns [String val]: '+' {$val = "+";} | '-' {$val = "-";} | '*' {$val = "*";} | '/' {$val = "/";};
factor returns [translation.statements.InlineStatement statement]: simpvalue {$statement = new translation.statements.SimpleStringStatement($simpvalue.val);} | '(' exp ')' {$exp.statement.hasParenthesis = true; $statement = $exp.statement;} | IDENT {$statement = new translation.statements.ProcedureCallStatement($IDENT.text);} subpparamlist[(translation.statements.GenericCallOrIdentifierStatement)$statement];
explist[List<translation.statements.InlineStatement> val_h] returns [List<translation.statements.InlineStatement> val_s] : {$val_s = $val_h;} ',' exp {$val_s.add($exp.statement);} expl1=explist[$val_s] {$val_s = $expl1.val_s;} | {$val_s = $val_h;};
proc_call returns [translation.statements.ProcedureCallStatement statement]: 'CALL' IDENT {$statement = new translation.statements.ProcedureCallStatement($IDENT.text);} subpparamlist[$statement] {$statement = (translation.statements.ProcedureCallStatement)$subpparamlist.val_s;};
subpparamlist[translation.statements.GenericCallOrIdentifierStatement val_h] returns [translation.statements.GenericCallOrIdentifierStatement val_s]: {$val_s = $val_h;} '(' exp {$val_s.paramList.add($exp.statement);} explist[$val_s.paramList] ')' {$val_s.paramList = $explist.val_s;} | {$val_s = $val_h; $val_s.hasParams = false;};


//Syntax for flux control TODO falta meterlo en los objetos, pero la logica ya esta hecha
sent_if [translation.statements.ExprStatement cond] returns [translation.statements.IfStatement statement_s] : sent {$statement_s = new translation.statements.IfStatement($cond); $statement_s.code.depth = blockDepth; $statement_s.code.statements.add($sent.statement);} | {$statement_s = new translation.statements.IfStatement($cond);} 'THEN' sentlist[$statement_s.code] sent_if_p[$statement_s];
sent_if_p [translation.statements.IfStatement statement_h] returns [translation.statements.IfStatement statement_s] : 'ENDIF' {$statement_s = $statement_h; blockDepth--;} | {$statement_s = $statement_h; blockDepth--;} 'ELSE' sentlist[$statement_s.elseCode] 'ENDIF' {blockDepth--;};
//sent_do returns [String val]: 'WHILE' '(' expcond ')' sentlist[null] 'ENDDO' {$val = "while (" + $expcond.val + ") {\n" + $sentlist.lista + "}\n";} | IDENT '=' d1=doval ',' d2=doval ',' d3=doval sentlist[null] 'ENDDO' {$val = "for (" + $IDENT.text + "=" + $d1.val + "; " + $IDENT.text + "!=" + $d2.val + "; " + $IDENT.text + "=" + $IDENT.text + "+" + $d3.val + ") {\n" + $sentlist.lista + "}\n";};
//doval returns [String val]: NUM_INT_CONST {$val = $NUM_INT_CONST} | IDENT {$val = $IDENT};
//casos returns [String val]: {$val = ""} | 'CASE' caso_p {$val = $caso_p.val;};
//caso_p returns [String val]: '(' etiquetas ')' sentlist[null] casos {$val = $etiquetas.val + "\n" + $sentlist.lista + "break;\n" + $casos.val;} | 'DEFAULT' sentlist[null] {$val = "default:\n" + $sentlist.lista + "break;\n";};
//etiquetas returns [String val]: simpvalue etiqueta_p[$simpvalue.val] {$val = $etiqueta_p.val;} | ':' simpvalue {$val = "case < " + $simpvalue.val + " :";};
//etiqueta_p [String baseVal] returns [String val]: listaetiquetas {if ($listaetiquetas.val.isEmpty()) $val = "case " + $baseVal + " :"; else $val = "case " + $baseVal + " :\n" + $listaetiquetas.val;} |
//    ':' etiqueta_secundaria {if ($etiqueta_secundaria.val.isEmpty()) $val = "case > " + $baseVal + " :\n"; else $val = "case " + $baseVal + " to " + $etiqueta_secundaria.val + ":\n";};
//etiqueta_secundaria returns [String val]: {$val = "";} | simpvalue {$val = $simpvalue.val;};
//listaetiquetas returns [String val]: {$val = "";} | ',' simpvalue l1=listaetiquetas {$val = "case " + $simpvalue.val + ":\n" + $l1.val;};
expcond returns [translation.statements.ExprStatement statement] : factorcond {$statement = new translation.statements.ExprStatement(); $statement.left = $factorcond.statement;} expcond_p[$statement];
expcond_p[translation.statements.ExprStatement statement_h] returns [translation.statements.ExprStatement statement_s]: {$statement_s = $statement_h;} | {$statement_s = $statement_h;} oplog {$statement_s.operator = $oplog.val;} factorcond {$statement_s.right = $factorcond.statement;} e1=expcond_p[$statement_s];
oplog returns [String val]: '.OR.' {$val = "||";} | '.AND.' {$val = "&&";} | '.EQV.' {$val = "!^";} | '.NEQV.' {$val = "^";};
factorcond returns [translation.statements.InlineStatement statement]: e1=exp opcomp e2=exp {$statement = new translation.statements.ExprStatement($e1.statement, $opcomp.val, $e2.statement);} | '(' expcond ')' {$expcond.statement.hasParenthesis = true; $statement = $expcond.statement;} | '.NOT.' f1=factorcond {$statement = new translation.statements.ExprStatement(); ((translation.statements.ExprStatement)$statement).operator = "!"; ((translation.statements.ExprStatement)$statement).right = $f1.statement;} | '.TRUE.' {$statement = new translation.statements.SimpleStringStatement("1");} | '.FALSE.' {$statement = new translation.statements.SimpleStringStatement("0");};
opcomp returns [String val]: '<' {$val = "<";} | '>' {$val = ">";} | '<=' {$val = "<=";} | '>=' {$val = ">=";} | '==' {$val = "==";} | '/=' {$val = "!=";};



//Syntax for functions implementation
subproglist : codproc subproglist | codfun subproglist | ;
codproc : 'SUBROUTINE' subroutineName=IDENT formal_paramlist y1 sentlist[p.functions.get($subroutineName.text).code] {blockDepth--;} 'END' 'SUBROUTINE' subroutineNameEnd=IDENT;
codfun : 'FUNCTION' functionName=IDENT '(' nomparamlist ')' tipo '::' IDENT ';' z1 sentlist[p.functions.get($functionName.text).code] {blockDepth--;} functionNameReturn=IDENT '=' exp ';' {p.functions.get($functionName.text).code.statements.add(new translation.statements.ReturnStatement($exp.statement));}
    'END' 'FUNCTION' functionNameEnd=IDENT;


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
