lexer grammar Antlr4Lexer;

@header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}


ParamList:
    '[' (~']')* ']'
    ;
IMPORT: 'import';
LEXER: 'lexer';
PARSER: 'parser';
OPTIONS_: 'options';
TOKENS_: 'tokens';
SCOPE: 'scope';
AT: '@';
INIT_PREFIX: '@init';
AFTER_PREFIX: '@after';
COLON: ':';
COMMAR: ';';
CC: '::';
LBRACE: '{';
RBRACE: '}';
LPAREN: '(';
RPAREN: ')';
BANG: '!';
//SYNTACTIC_PREDICATES: '=>';
START: '*';
HOOK: '?';
OR: '|';
NOT: '~';
EQ: '=';
ADD: '+=';
LBRACKET: '[';
RBRACKET: ']';
FRAGMENT:'fragment';
EOF_KEY: 'EOF';
GRAMMAR :'grammar';
DOUBLE_DOT: '..';
DOT: '.';
ARRA: '^';
RETURNS: 'returns';
ARROW:'->';

ID: ID_START (ID_PART)*;
fragment ID_START: '$'|'_'|UNICODE_LETTER;
fragment ID_PART:
    (ID_START|'0'..'9');
fragment UNICODE_LETTER:
        'A'..'Z'
        | 'a'..'z'
        ;
STRING_LITERAL: (
    '"' DOUBLE_STRING_CHARACTERS '"'
    | '\'' SINGLE_STRING_CHARACTERS '\'');
fragment DOUBLE_STRING_CHARACTERS: (~('"'|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;
fragment SINGLE_STRING_CHARACTERS:(~('\''|'\\'|'\n'|'\r'|'\u2028'|'\u2029')
        | '\\' ~('\n'|'\r'|'\u2028'|'\u2029'))*;
WHITE_SPACE // Tab, vertical tab, form feed, space, non-breaking space and any other unicode "space separator".
	: ('\r'|'\n'|'\t' | '\u000b' | '' |'f'| ' ' | '\u00a0'|USP)	-> skip
	;
fragment USP: '\u2000'..'\u200b' | '\u3000';
MultiLineComment: '/*' .*? '*/' ('\n'|'\r')*	-> skip
   ;
SingleLineComment: '//' (~('\n'|'\r'))* ('\n'|'\r')* -> skip
	;
ANYCHAR: .;
