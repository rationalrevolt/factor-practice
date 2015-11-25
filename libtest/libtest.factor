! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax ;
IN: libtest

<< "hello" "libhello.dylib" cdecl add-library >>

LIBRARY: hello

FUNCTION: void printHelloWorld ( )
