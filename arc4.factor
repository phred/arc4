! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math accessors combinators
       arc4.key-schedule ;

IN: arc4

TUPLE: arc4 key key-schedule counters ;

GENERIC: current-byte ( arc4 -- byte )
GENERIC: next ( arc4 -- byte )

: <arc4> ( key -- arc4 ) dup schedule-key { 0 0 } \ arc4 boa ;

: key-schedule-at ( arc4 -- quot )
    key-schedule>> [ nth ] curry ; inline

: current-schedule ( arc4 -- schedule )
   [ counters>> ]
   [ key-schedule-at ] bi map ;

: next-schedule ( arc4 -- schedule )
    [ counters>> first 1 + ] [ key-schedule>> ] bi nth ;


: advance-counter ( value counter-ndx schedule -- value' )
   over 0 =
   [ 2drop 1 + ]
   [ nip + ] if key-schedule-length mod ;
    
: next-stream-counters ( counters schedule -- counters' )
   [ advance-counter ] curry map-index ;

: advance-stream-counters ( arc4 -- arc4 )
   [ next-schedule [ next-stream-counters ] curry ] keep swap change-counters ;

: rotate-schedule ( arc4 -- arc4 )
   [ [ counters>> first2 ] [ key-schedule>> ] bi exchange ] keep ;


: on-first-round ( arc4 -- ? )
   counters>> first 0 = ;

: first-round-error ( -- * ) 
   "undefined result, call next-key-byte at least once" throw ;

: check-first-round ( arc4 -- )
    on-first-round [ first-round-error ] when ;

: current-stream-index ( arc4 -- ndx )
    current-schedule sum key-schedule-length mod ;


M: arc4 current-byte
  [ current-stream-index ] 
  [ key-schedule>> ]
  [ check-first-round ] tri nth ;

M: arc4 next
  advance-stream-counters rotate-schedule current-byte ;

: cipher ( str arc4 -- ciphertext )
    [ next bitxor ] curry map ; inline
