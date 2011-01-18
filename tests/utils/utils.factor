
USING: kernel math grouping math.parser 
        syntax lexer strings.parser namespaces sequences ;

IN: rc4.tests.utils

: keystream-from-hexstring ( str -- array )
    2 group [ 16 base> ] { } map-as ;

SYNTAX: HEX" lexer get skip-blank parse-string 2 group [ hex> ] { } map-as suffix! ;

