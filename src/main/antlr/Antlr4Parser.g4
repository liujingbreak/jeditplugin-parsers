parser grammar Antlr4Parser;

options { tokenVocab=Antlr4Lexer; }
@parser::header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}
@parser::members {
    static Logger log = Logger.getLogger( Antlr4Parser.class.getName() );
    public static final int DOC_CHANN = 3;
}

parseGrammar:
	( 'lexer' | 'parser' )? 'grammar' ID ';'
	parseOptions? 
	parseImport?
	parseTokens?
	(globalAction)*
	grammarRule* EOF
;

parseOptions
    :
    'options'
    braceBody
    ;
    
parseImport:
	'import'  (~(';'))+ ';'
	;
parseTokens
    :
    'tokens'  braceBody
    ;

globalAction:
	'@' (actionScopeName '::' )? ID braceBody
	;
	
actionScopeName
	:	ID
	|	'lexer'
   	|   	'parser'
	;
	
braceBody:
    '{' (  ~('{'|'}')
        | braceBody
        )*
    '}'
;


grammarRule:
    ('fragment' )? ID  ( braceBody | ~':')*
    ':'
    ( braceBody | ~';' )* ';'
    ;
