! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators formatting kernel io locals
math math.parser sequences splitting ;

IN: jenny-fruit-basket

: fruit-selection>string ( fruit n -- str )
    dup 0 = [ 2drop f ] [
        swap over 1 > [ "s" append ] when
        "%d %s" sprintf 
    ] if ;

: print-basket ( basket -- )
    >alist [ first2 fruit-selection>string ] map
    harvest ", " join print ;

:: find-fruit-sets ( market basket money -- )
    {
        { [ money 0 = ] [ basket print-basket ] }
        { [ money 0 < ] [ ] }
        { [ market empty? ] [ ] }
        [
            ! Pick 1st fruit in market
            market first first2 :> ( fruit count )
            basket H{ } assoc-clone-like :> new-basket
            fruit new-basket [ 1 + ] change-at
            money fruit market at - :> new-money
            market new-basket new-money find-fruit-sets
            
            ! Leave 1st fruit in market
            market rest basket money find-fruit-sets
        ]
    } cond ;

: make-market ( -- market )
    lines [
        " " split first2
        string>number 2array
    ] map ;

: make-empty-basket ( market -- basket )
    [ drop 0 ] assoc-map ;

: jenny-pick-fruits ( -- )
    make-market
    dup make-empty-basket
    500 find-fruit-sets ;

