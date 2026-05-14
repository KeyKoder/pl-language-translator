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

prg : 'PROGRAM' IDENT ';' {p = new Program();} dcllist header sentlist 'END' 'PROGRAM' IDENT subproglist {System.out.println(p);};
dcllist : | tipo dcl;
header :  | 'INTERFACE' headlist 'END' 'INTERFACE';
headlist : decproc decsubprog | decfun decsubprog;
decsubprog :  | decproc decsubprog | decfun decsubprog;
sentlist : sent sentlist_p;
sentlist_p : | sent sentlist_p;

// Syntax declarations
dcl : ',' 'PARAMETER' '::' IDENT '=' simpvalue {p.dcls.add("#define "+$IDENT.text+" "+$simpvalue.text);} ctelist ';' dcllist | '::' varlist ';' dcllist;
ctelist :  | ',' IDENT '=' simpvalue {p.dcls.add("#define "+$IDENT.text+" "+$simpvalue.text);} ctelist;
simpvalue : NUM_INT_CONST | NUM_REAL_CONST | STRING_CONST;
tipo returns [String s] : 'INTEGER' {$s = "int";} | 'REAL' {$s = "float";} | 'CHARACTER' {$s = "char";} charlength {$s += "["+$charlength.len+"]";} ;
charlength returns [int len] :  | '(' NUM_INT_CONST {$len = Integer.parseInt($NUM_INT_CONST.text);} ')';
varlist : IDENT init varlist_p;
varlist_p : | ',' IDENT init varlist_p;
init :  | '=' simpvalue;

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
