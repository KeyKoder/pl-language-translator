grammar Scientific;


r : .*;

DOUBLE_QUOTE_STRING : '"' (~('"')|'""')* '"';
// DOUBLE_QUOTE_STRING : '"' PLAINTEXT* (('\'' | '""')* PLAINTEXT)* '"';

SIMPLE_QUOTE_STRING : '\'' (~('\'')|'\'\'')* '\'';
// SIMPLE_QUOTE_STRING : '\'' PLAINTEXT* (('"' | '\'\'')* PLAINTEXT)* '\'';

ID : [a-zA-Z] [a-zA-Z0-9_]*;

NUM_INT_CONST : '-'? DIGIT+;

NUM_FIXED_CONST : '-'? DIGIT+ '.' DIGIT+;

NUM_EXP_CONST : '-'? DIGIT+ [eE] '-'? DIGIT+; 

NUM_MIXED_CONST : '-'? DIGIT+ '.' DIGIT+ [eE] '-'? DIGIT+;

COMMENTS : '!' PLAINTEXT NL;

WS : (' ' | '\t') -> skip;

fragment
NL : '\r'? '\n';

fragment
PLAINTEXT : .;

fragment
DIGIT : [0-9];
