grammar Doccomment;

@header {
package org.liujing.antlr.parser;

import java.util.logging.*;
import java.io.*;
}
@members {
    static Logger log = Logger.getLogger(DoccommentParser.class.getName());
}

doc:
	'/**'  STARS* content?  STARS*  '*/'
	;
	
content: 
	(  (anotations | desc)? Linebreak STARS* )+
;

desc:
	(~(Linebreak | '*/' ))+?
	;

anotations:
	AnoName OTHER*
	;


Linebreak:  ('\n' | '\r') +
	;
AnoName:
	'@' ('a'..'z' | 'A'..'Z' | '0'..'9'| '_' | '.' )+
	;
WS:
	('\t' | ' ')+ -> skip
	;

OTHER: (~(' ' | '\t' | '\n' | '\r' | '*' | '<' | '>' | '/' | '@'))+;

STARS: '*'+;
ANYCHAR: '.';
