! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel io math.parser sequences combinators ascii math ;
IN: 99bottles

: bottle-string ( n -- str )
    {
        { [ dup 1 > ] [ number>string " bottles" append ] }
        { [ dup 1 = ] [ number>string " bottle" append ] }
        { [ dup 0 = ] [ drop "no more bottles" ] }
    } cond ;

: sing-verse ( n -- str )
    {
        [ bottle-string " of beer on the wall, " append capitalize ]
        [ bottle-string " of beer.\n" append ]
        [ 0 >
          [ "Take one down and pass it around, " ]
          [ "Go to the store and buy some more, " ] if ]
        [ dup 0 >
          [ 1 - bottle-string " of beer on the wall." append ]
          [ drop "99 bottles of beer on the wall." ] if ]
    } cleave append append append ;

: 99bottles ( -- ) 99
    [ dup 0 >= ]
    [ dup sing-verse print nl 1 - ]
    while drop ;

