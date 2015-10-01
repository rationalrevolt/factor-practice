! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math quotations ;
IN: generator

TUPLE: generator
    state
    { quot quotation read-only } ;

GENERIC: next ( generator -- value )

: <generator> ( state quotation -- generator ) \ generator boa ;

: generate-value ( state quotation -- value newstate ) call( state -- value newstate ) ;

M: generator next dup
    [ state>> ] [ quot>> ] bi generate-value
    rot state<< ;

: natural-numbers ( -- generator ) -1 [ 1 + dup ] <generator> ;

: squares ( -- generator ) 0 [ dup 0 = [ drop 1 1 ] [ 1 + dup dup * swap ] if ] <generator> ;
