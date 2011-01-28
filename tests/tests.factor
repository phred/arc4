! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math tools.test sorting sequences fry
        arrays grouping math.parser tools.continuations
        accessors io io.streams.string namespaces byte-arrays
        arc4.tests.utils
        arc4 arc4.key-schedule arc4.reader ;

IN: arc4.tests

#! make sure scheduling the key doesn't duplicate any elements of the sequence
(init-vector) 1array [ "abcdefghijklmnop" schedule-key natural-sort ] unit-test


TUPLE: test-vector key keystream plaintext ciphertext ;

#! Test vectors from http://en.wikipedia.org/wiki/RC4#Test_vectors
: test-vectors ( -- triples )
    {   #! { key keystream plaintext ciphertext }
        T{ test-vector 
           { key "Key" }
           { keystream HEXBYTE" eb9f7781b734ca72a719" }
           { plaintext "Plaintext" }
           { ciphertext HEXBYTE" BBF316E8D940AF0AD3" } }

        T{ test-vector
           { key "Wiki" }
           { keystream HEXBYTE" 6044db6d41b7" }
           { plaintext "pedia" }
           { ciphertext HEXBYTE" 1021BF0420" } }
        T{ test-vector
           { key "Secret" }
           { keystream HEXBYTE" 04d46b053ca87b59" }
           { plaintext "Attack at dawn" }
           { ciphertext HEXBYTE" 45A01F645FC35B383552544B9BF5" } }
    } ;


[ 54 ] [ HEX: eb CHAR: K 0 next-schedule-index ] unit-test
[ 58 ] [ HEX: 9f CHAR: e 54 next-schedule-index ] unit-test
[ 42 ] [ HEX: 77 CHAR: y 58 next-schedule-index ] unit-test

[ 54 ] [ { HEX: eb HEX: 9f HEX: 77 } "Key" 0 0 increment-schedule-counter ] unit-test
[ 58 ] [ { HEX: 9f HEX: 9f HEX: 77 } "Key" 54 1 increment-schedule-counter ] unit-test
[ 42 ] [ { HEX: 77 HEX: 9f HEX: 77 } "Key" 58 2 increment-schedule-counter ] unit-test


[ 1 ] [ 0 0 35 advance-counter ] unit-test
[ 2 ] [ 1 0 35 advance-counter ] unit-test
[ 35 ] [ 0 1 35  advance-counter ] unit-test
[ 35 ] [ 256 1 35 advance-counter ] unit-test

[ { 0 0 } ] [ "Key" <arc4> counters>> ] unit-test
[ t ] [ "Key" <arc4> [ current-schedule first ] [ key-schedule>> first ] bi = ] unit-test


[ "test" <arc4> current-byte ] must-fail

: keystream-test-procedure ( key keystream -- quot )
    '[ _ <arc4> _ length [ [ next ] keep ] times drop ] ;

: make-keystream-test ( test-vector -- quot )
      [ key>> ]
      [ keystream>> ] bi
      keystream-test-procedure ;

: keystream-tests ( -- tests )
    test-vectors 
    [
        [ keystream>> ]
        [ make-keystream-test ] bi
        [ unit-test ] 2curry
    ] map ;


keystream-tests [ call ] each

: cipher-test-procedure ( key keystream -- quot )
    '[ _ _ <arc4> cipher >byte-array ] ;

: make-cipher-test ( test-vector -- quot )
      [ plaintext>> ]
      [ key>> ] bi
      cipher-test-procedure ;

: cipher-tests ( -- tests )
    test-vectors 
    [
        [ ciphertext>> 1array ]
        [ make-cipher-test ] bi
        [ unit-test ] 2curry
    ] map ;

cipher-tests [ call ] each

: reader-test-procedure ( key keystream -- quot )
    '[ { } _ <arc4> _ <string-reader> <arc4-reader> stream-read-until ] ;

: make-reader-test ( test-vector -- quot )
      [ key>> ]
      [ plaintext>> ] bi
      reader-test-procedure ;

: reader-tests ( -- tests )
    test-vectors 
    [
        [ ciphertext>> f 2array ]
        [ make-reader-test ] bi
        [ unit-test ] 2curry
    ] map ;

reader-tests [ call ] each
