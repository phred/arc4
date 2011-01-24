! Copyright (C) 2011 Fred Alger
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences math fry accessors combinators
       arc4.key-schedule ;

IN: arc4

TUPLE: arc4 key key-schedule ndx0 ndx1 ;
: <arc4> ( key -- arc4 ) dup schedule-key 0 0 \ arc4 boa ;


GENERIC: current-byte ( arc4 -- byte )
GENERIC: next-key-byte ( arc4 -- byte )

: advance-ndx0 ( arc4 -- )
    [ 1 + key-schedule-length mod ] change-ndx0 drop ;

: advance-ndx1 ( arc4 -- )
    [ [ ndx0>> ] [ key-schedule>> ] bi nth ] keep
    [ + key-schedule-length mod ] change-ndx1 drop ;
    
: advance-stream-counters ( arc4 -- )
    [ advance-ndx0 ]
    [ advance-ndx1 ] bi ;

: rotate-schedule ( arc4 -- )
    [ ndx0>> ]
    [ ndx1>> ]
    [ key-schedule>> ] tri
    exchange ;

M: arc4 current-byte
    {
      [ ndx0>> ]
      [ key-schedule>> ]
      [ ndx1>> ]
      [ key-schedule>> ]
      [ key-schedule>> ]
      [ ndx0>> ]
    } cleave
    0 >
    [ [ nth [ nth ] dip + key-schedule-length mod ] dip nth ]
    [ "undefined result, call next-key-byte at least once" throw ] if ;

M: arc4 next-key-byte
  [ advance-stream-counters ]
  [ rotate-schedule ]
  [ current-byte ] tri ;
