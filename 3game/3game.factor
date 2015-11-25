! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs formatting kernel math prettyprint ;
IN: 3game

CONSTANT: 3REMAP
  H{
      { 2 1 }
      { 1 -1 }
      { 0 0 }
   }

: 3step ( n -- n ) 3 rem 3REMAP at ;

: 3game ( n -- )
    dup 1 =
    [ . ]
    [ dup 3step [ "%d %d\n" printf ] [ + 3 / 3game ] 2bi ]
    if ; recursive

