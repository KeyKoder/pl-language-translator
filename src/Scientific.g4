grammar Scientific;

@members {
    Program p;
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


COMMENTS : '!' PLAINTEXT NL;

WS : (' ' | '\t' | NL) -> skip;

// Syntax

/*
    Atributos de p:
    p.dcls: guarda los #define
    p.vars: guarda la declaración de las varibles globales

*/

prg : 'PROGRAM' IDENT ';' {p = new Program();} dcllist header sentlist 'END' 'PROGRAM' IDENT subproglist {System.out.println(p);};
dcllist : | tipo dcl[$tipo.s]; //Le pasa el tipo a dcl para las declaraciones de variables, que es necesario escribirlo
header :  | 'INTERFACE' headlist 'END' 'INTERFACE';
headlist : decproc decsubprog | decfun decsubprog;
decsubprog :  | decproc decsubprog | decfun decsubprog;
sentlist : sent sentlist_p;
sentlist_p : | sent sentlist_p;

// Syntax declarations (TODO: Creo que está terminado, revisar)
dcl [String type]: ',' 'PARAMETER' '::' IDENT '=' simpvalue {p.dcls.add("#define "+$IDENT.text+" "+$simpvalue.val + "; \n");} ctelist ';' dcllist | '::'{p.vars.add($type + " ");} varlist ';' {p.vars.add(";\n");} dcllist;
//TODO: he creado un nuevo atributo p.vars porque todos los #define tienen que ir seguidos al final, pero la gramática permite que estén intercalados con las declaraciones de variables, así que hay que guardarlos en sitios distintos para conservar ese orden
//1: Hace el primer #define id xxx; y llama a laos demás del mismo tipo y al terminar al resto de constantes
//2: Hace las declaraciones de variables, escribe el tipo y llama al resto de vars de ese mismo tipo
ctelist :  | ',' IDENT '=' simpvalue {p.dcls.add("#define " + $IDENT.text + " "+ $simpvalue.val);} ctelist;
//Añade todos los #define del tipo anterior (en dcl)
simpvalue returns [String val]: NUM_INT_CONST {$val = $NUM_INT_CONST.text;}| NUM_REAL_CONST {$val = $NUM_REAL_CONST.text;}| STRING_CONST {$val = $STRING_CONST.text;};
tipo returns [String s] : 'INTEGER' {$s = "int";} | 'REAL' {$s = "float";} | 'CHARACTER' {$s = "char";} charlength {$s += "["+$charlength.len+"]";} ;
charlength returns [int len] :  | '(' NUM_INT_CONST {$len = Integer.parseInt($NUM_INT_CONST.text);} ')';
varlist : IDENT {p.vars.add($IDENT.text);} init varlist_p; //Añade a las vars la primera del tipo anterior y llama a las siguientes
varlist_p : | ',' IDENT {p.vars.add(", " + $IDENT.txt);} init varlist_p; //Añade la siguiente variable y continúa llamando a las siguientes
init :  | '=' simpvalue {p.vars.add(" = " + $simpvalue.val);}; //Da valor inicial a las variables que lo tengan


// Syntax for subroutines
decproc : 'SUBROUTINE' procName=IDENT formal_paramlist dec_s_paramlist[new ArrayList<Pair<String, String>>()] 'END' 'SUBROUTINE' procNameEnd=IDENT {p.functions.put($procName.text, new Function("void", $procName.text, $dec_s_paramlist.params_s));};
formal_paramlist :  | '(' nomparamlist ')';
nomparamlist : IDENT nomparamlist_p;
nomparamlist_p : | ',' nomparamlist;
dec_s_paramlist[List<Pair<String, String>> params_h] returns [List<Pair<String, String>> params_s] : {$params_s = $params_h;} | tipo ',' 'INTENT' '(' tipoparam ')' IDENT ';' dec_s_paramlist[$params_h] {$params_s = $dec_s_paramlist.params_s; $params_s.add(0, new Pair<String, String>($tipo.s, $IDENT.text));};
tipoparam : 'IN' | 'OUT' | 'INOUT';
decfun : 'FUNCTION' funcName=IDENT '(' nomparamlist ')' tipo '::' funcNameType=IDENT ';' dec_f_paramlist[new ArrayList<Pair<String, String>>()] 'END' 'FUNCTION' funcNameEnd=IDENT {p.functions.put($funcName.text, new Function($tipo.s, $funcName.text, $dec_f_paramlist.params_s));};
dec_f_paramlist[List<Pair<String, String>> params_h] returns [List<Pair<String, String>> params_s] : {$params_s = $params_h;} | tipo ',' 'INTENT' '(' 'IN' ')' IDENT ';' dec_f_paramlist[$params_h] {$params_s = $dec_f_paramlist.params_s; $params_s.add(0, new Pair<String, String>($tipo.s, $IDENT.text));};



//Syntax for assignations
sent : IDENT '=' exp ';' | proc_call ';';
exp : factor exp_p;
exp_p : | op exp exp_p;
op : '+' | '-' | '*' | '/';
factor : simpvalue | '(' exp ')' | IDENT subpparamlist;
explist : ',' exp explist | ;
proc_call : 'CALL' IDENT subpparamlist;
subpparamlist : '(' exp explist ')' | ;



//Syntax for functions implementation
subproglist : codproc subproglist | codfun subproglist | ;
codproc : 'SUBROUTINE' IDENT formal_paramlist y1 sentlist 'END' 'SUBROUTINE' IDENT;
codfun : 'FUNCTION' IDENT '(' nomparamlist ')' tipo '::' IDENT ';' z1 sentlist IDENT '=' exp ';'
    'END' 'FUNCTION' IDENT;


y1 : | tipo y2;
y2 : ',' y3 | '::' varlist ';' dcllist;
y3 : 'INTENT' '(' tipoparam ')' IDENT ';' y1 | 'PARAMETER' '::' IDENT '=' simpvalue ctelist ';' dcllist;

z1 : | tipo z2;
z2 : ',' z3 | '::' varlist ';' dcllist;
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
