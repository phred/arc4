! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.

USING: kernel arrays io accessors math sequences
       arc4 arc4.stream-helpers ;

IN: arc4.reader

TUPLE: arc4-reader arc4 reader ;
INSTANCE: arc4-reader input-stream

: <arc4-reader> ( arc4 reader -- obj ) \ arc4-reader boa ;

M: arc4-reader stream-read1 ( stream -- elt )
    [ reader>> stream-read1 ] keep over [ arc4>> next bitxor ] [ drop ] if ;
