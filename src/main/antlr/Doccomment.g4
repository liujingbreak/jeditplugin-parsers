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
	COMMENT_START ( Linebreak STARS* | content )* COMMENT_END
	;
	
content: 
	anotations | desc
;

desc:
	(~(Linebreak | COMMENT_END ))+
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

COMMENT_START:
	'/' ('*')+
	;
COMMENT_END:
	('*')+ '/'
	;
STARS:
	'*'
	;
ANYCHAR: .;
