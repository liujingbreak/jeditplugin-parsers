grammar MyCSS;


@header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}
@members {
    static Logger log = Logger.getLogger(MyCSSParser.class.getName());
    public static final int DOC_CHANN = 3;
}
cssfile:
    (cssUnit | cssRule)*
    ;
    
cssRule
    : RULE_NAME ~(';')*? ( '{' style* '}' | ':' lessValue )? ';'
    ;
lessValue:
	(~(';'))+
	;
    
cssUnit :
    selector '{' ( cssUnit | style )* '}'
    ;
selector
    : ~('{' | '}' | ';')+
    ;
    
style:
	(~( '{' | '}' | ';' ))+  ';'
	;
	
ID:
	(~[@{}:; \r\n\t])+
	;
RULE_NAME:
	'@' ID
	;
STRING_LITERAL: (
    '"' DOUBLE_STRING_CHARACTERS '"'
    | '\'' SINGLE_STRING_CHARACTERS '\'');
fragment DOUBLE_STRING_CHARACTERS: (~('"'|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;
fragment SINGLE_STRING_CHARACTERS:(~('\''|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;
WHITE_SPACE // Tab, vertical tab, form feed, space, non-breaking space and any other unicode "space separator".
	: ('\r'|'\n'|'\t' | '\u000b' | ' ' | '\u00a0'|USP)+	-> skip
	;
fragment USP: '\u2000'..'\u200b' | '\u3000';

DocComment:
     '/**' .*? '*/' ('\n'|'\r')*  -> channel(DOC_CHANN)
    ;
MultiLineComment
    : '/*' .*? '*/' ('\n'|'\r')* -> skip
    ;
ANYCHAR: .;
