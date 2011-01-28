! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.

USING: kernel arrays io locals byte-arrays arc4 accessors math sequences ;

IN: arc4.reader

MIXIN: input-stream

M:: input-stream stream-read ( n stream -- seq )
    BV{ } clone :> bytes n iota [ drop stream
    stream-read1 dup [ bytes push ] when* not ] find 2drop bytes >byte-array ;

: separator-or-eof? ( val seps -- ? )
    [ member? ] curry [ f = ] bi or ;

M:: input-stream stream-read-until ( seps stream -- seq sep/f )
    BV{ } clone :> bytes f :> sep!
    [ stream stream-read1
    [ dup ] [ sep! seps separator-or-eof? ] bi ]
    [ bytes push ] until drop bytes >byte-array sep ;

M: input-stream stream-read-partial ( n stream -- seq )
    stream-read ;


TUPLE: arc4-reader arc4 reader ;
INSTANCE: arc4-reader input-stream

: <arc4-reader> ( arc4 reader -- obj ) \ arc4-reader boa ;

M: arc4-reader stream-read1 ( stream -- elt )
    [ reader>> stream-read1 ] keep over [ arc4>> next bitxor ] [ drop ] if ;
