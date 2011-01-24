! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math accessors combinators
    tools.continuations ;

IN: arc4.key-schedule

CONSTANT: key-schedule-length 256

#! for i from 0 to 255
#!     S[i] := i
#! endfor
#! j := 0
#! for i from 0 to 255
#!     j := (j + S[i] + key[i mod keylength]) mod 256
#!     swap values of S[i] and S[j]
#! endfor

: nth-modulo ( n bound seq -- elt ) 2over mod swap nth 2nip ;
: nth-modulo-length ( n seq -- elt ) [ length ] keep nth-modulo ;

#! Produce the initialization vector for the key-scheduling algorithm
: (init-vector) ( -- array ) key-schedule-length iota >array ;

#! Push the ith elements of key and init-vector onto the top of the stack.
: mixing-elements ( key init-vector i -- key-bits iv-bits )
    [ swap nth-modulo-length ] curry bi@ ;

#! Given the current byte of the initialization vector, the current byte of the
#! key, and the current index, produce the next index of the key schedule
#! 
#!     j := (j + S[i] + key[i mod keylength]) mod 256
#!
: next-schedule-index ( current-iv-bits current-key-bits j -- j' )
    + + key-schedule-length mod ;

: increment-schedule-counter ( key init-vector j i -- j' )
   swap [ mixing-elements ] dip next-schedule-index ;


: increment-and-swap ( key init-vector j i -- key init-vector' j' i )
    [ 2dup ] 2dip
    [ increment-schedule-counter ] keep
    [ pick exchange ] 2keep ;

: (schedule-key) ( key init-vector -- init-vector' ) 
    dup length 0 swap
    [
        increment-and-swap
        drop
    ] each-integer
    drop nip ;

: schedule-key ( key -- schedule )
    (init-vector) (schedule-key) ;
