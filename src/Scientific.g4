grammar Scientific;


// prg
r : .*;

// Lexer tokens

DOUBLE_QUOTE_STRING : '"' (~('"')|'""')* '"';
// DOUBLE_QUOTE_STRING : '"' PLAINTEXT* (('\'' | '""')* PLAINTEXT)* '"';

SIMPLE_QUOTE_STRING : '\'' (~('\'')|'\'\'')* '\'';
// SIMPLE_QUOTE_STRING : '\'' PLAINTEXT* (('"' | '\'\'')* PLAINTEXT)* '\'';

STRING_CONST : DOUBLE_QUOTE_STRING | SIMPLE_QUOTE_STRING;

IDENT : [a-zA-Z] [a-zA-Z0-9_]*;

NUM_INT_CONST : '-'? DIGIT+;

NUM_FIXED_CONST : '-'? DIGIT+ '.' DIGIT+;

NUM_EXP_CONST : '-'? DIGIT+ [eE] '-'? DIGIT+; 

NUM_MIXED_CONST : '-'? DIGIT+ '.' DIGIT+ [eE] '-'? DIGIT+;

NUM_REAL_CONST : NUM_FIXED_CONST | NUM_EXP_CONST | NUM_MIXED_CONST;

COMMENTS : '!' PLAINTEXT NL;

WS : (' ' | '\t') -> skip;

// Syntax

prg : 'PROGRAM' IDENT ';' dcllist header sentlist 'END' 'PROGRAM' IDENT subproglist;
dcllist : | dcl dcllist;
header :  | 'INTERFACE' headlist 'END' 'INTERFACE';
headlist : decproc decsubprog | decfun decsubprog;
decsubprog :  | decproc decsubprog | decfun decsubprog;
sentlist : sent sentlist_p;
sentlist_p : | sent sentlist_p;

// Syntax declarations
dcl : defcte | defvar;
defcte : tipo ',' 'PARAMETER' '::' IDENT '=' simpvalue ctelist ';'; 
ctelist :  | ',' IDENT '=' simpvalue ctelist;
simpvalue : NUM_INT_CONST | NUM_REAL_CONST | STRING_CONST;
defvar : tipo '::' varlist ';';
tipo : 'INTEGER' | 'REAL' | 'CHARACTER' charlength;
charlength :  | '(' NUM_INT_CONST ')';
varlist : IDENT init varlist_p;
varlist_p : | ',' IDENT init varlist_p;
init :  | '=' simpvalue;

// Syntax for subroutines
decproc : 'SUBROUTINE' IDENT formal_paramlist dec_s_paramlist 'END' 'SUBROUTINE' IDENT;
formal_paramlist :  | '(' nomparamlist ')';
nomparamlist : IDENT nomparamlist_p;
nomparamlist_p : | ',' nomparamlist;
dec_s_paramlist :  | tipo ',' 'INTENT' '(' tipoparam ')' IDENT ';' dec_s_paramlist;
dec_d_paramlist : tipo ',' 'INTENT' '(' tipoparam ')' IDENT ';';
tipoparam : 'IN' | 'OUT' | 'INOUT';
decfun : 'FUNCTION' IDENT '(' nomparamlist ')' tipo '::' IDENT ';' dec_f_paramlist dec_d_paramlist 'END' 'FUNCTION' IDENT;
dec_f_paramlist : | tipo ',' 'INTENT' '(' 'IN' ')' IDENT ';' dec_f_paramlist;



//Syntax for assignations
sent : IDENT '=' exp ';' | proc_call ';';
exp : factor exp_p;
exp_p : | op exp exp_p;
op : '+' | '-' | '*' | '/';
factor : simpvalue | '(' exp ')' | IDENT '(' exp explist ')' | IDENT;
explist : ',' exp explist | ;
proc_call : 'CALL' IDENT subpparamlist;
subpparamlist : '(' exp explist ')' | ;


//Syntax for functions implementation
subproglist : codproc subproglist | codfun subproglist | ;
codproc : 'SUBROUTINE' IDENT formal_paramlist dec_s_paramlist dcllist sentlist 'END' 'SUBROUTINE' IDENT;
codfun : 'FUNCTION' IDENT '(' nomparamlist ')' tipo '::' IDENT ';' dec_f_paramlist dcllist sentlist IDENT '=' exp ';'
    'END' 'FUNCTION' IDENT;


fragment 
KEYWORD : 'PROGRAM'|'INTERFACE'|'END'|'PARAMETER'|'INTEGER'|'REAL'|'CHARACTER'|'SUBROUTINE'|'INTENT'|'IN'|'OUT'|'INOUT'|'FUNCTION'|'CALL';



// Generic fragments

fragment
NL : '\r'? '\n';

fragment
PLAINTEXT : .;

fragment
DIGIT : [0-9];
