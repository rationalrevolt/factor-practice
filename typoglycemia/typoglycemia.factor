! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel math random sequences strings ;
IN: typoglycemia

: typoglycemize ( str -- str )
    dup length 2 > [
        1 cut-slice
        dup length 1 - cut-slice
        swap randomize
        swap 3array concat
    ] when ;

: handle-c/f ( c/f -- ? )
    dup [ 1string write ] when* ;

: typoglycemia-print ( -- )
    [ ", .'" read-until [ >string typoglycemize write ] dip handle-c/f ] loop ;
