! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel quotations ;
IN: generator

TUPLE: generator
    state
    { quot quotation read-only } ;

GENERIC: next ( generator -- value )

: <generator> ( state quot -- generator ) \ generator boa ;

: generate-value ( state quot -- value state ) call( state -- value newstate ) ;

: update-state ( newstate generator -- ) state<< ;

M: generator next dup
    [ state>> ] [ quot>> ] bi generate-value
    rot state<< ;

: natural-numbers ( -- generator ) 0 [ 1 + dup ] <generator> ;
