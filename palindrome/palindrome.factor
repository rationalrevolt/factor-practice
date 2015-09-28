! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences ascii ;
IN: palindrome

: normalize ( str -- str' ) [ Letter? ] filter >lower ;

: palindrome? ( str -- ? ) normalize dup reverse = ;
