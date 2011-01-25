
USING: kernel math grouping math.parser 
        syntax lexer strings.parser namespaces sequences ;

IN: arc4.tests.utils

: byte-array-from-string ( str -- array )
    2 group [ hex> ] B{ } map-as ;

SYNTAX: HEXBYTE" lexer get skip-blank parse-string
                 byte-array-from-string suffix! ;

