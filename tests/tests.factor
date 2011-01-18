! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math tools.test sorting sequences fry
        arrays grouping math.parser rc4 rc4.key-schedule
        tools.continuations accessors
        syntax lexer strings.parser namespaces rc4.tests.utils ;
IN: rc4.tests

#! make sure scheduling the key doesn't duplicate any elements of the sequence
(init-vector) 1array [ "abcdefghijklmnop" schedule-key natural-sort ] unit-test


TUPLE: test-vector key keystream plaintext ciphertext ;

#! Test vectors from http://en.wikipedia.org/wiki/RC4#Test_vectors
: test-vectors ( -- triples )
    {   #! { key keystream plaintext ciphertext }
        T{ test-vector f "Key"      HEX" eb9f7781b734ca72a719" 
           "Plaintext" HEX" BBF316E8D940AF0AD3" }
        T{ test-vector f "Wiki"     HEX" 6044db6d41b7" 
           "pedia"  HEX" 1021BF0420" }
        T{ test-vector f "Secret"   HEX" 04d46b053ca87b59" 
           "Attack at dawn"  HEX" 45A01F645FC35B383552544B9BF5" }
    } ;


[ 54 ] [ HEX: eb CHAR: K 0 next-schedule-index ] unit-test
[ 58 ] [ HEX: 9f CHAR: e 54 next-schedule-index ] unit-test
[ 42 ] [ HEX: 77 CHAR: y 58 next-schedule-index ] unit-test

[ 54 ] [ { HEX: eb HEX: 9f HEX: 77 } "Key" 0 0 increment-schedule-counter ] unit-test
[ 58 ] [ { HEX: 9f HEX: 9f HEX: 77 } "Key" 54 1 increment-schedule-counter ] unit-test
[ 42 ] [ { HEX: 77 HEX: 9f HEX: 77 } "Key" 58 2 increment-schedule-counter ] unit-test

: keystream-test-procedure ( key keystream -- quot )
    '[ _ <arc4> _ length [ [ next-key-byte ] keep ] times drop ] ;

: make-keystream-test ( test-vector -- quot )
      [ key>> ]
      [ keystream>> ] bi
      keystream-test-procedure ;

: keystream-tests ( -- tests )
    test-vectors 
    [
        [ keystream>> ]
        [ make-keystream-test ] bi
        2array
    ] map ;

keystream-tests [ unit-test ] each
