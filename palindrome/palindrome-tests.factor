! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test palindrome ;
IN: palindrome.tests

{ f } [ "sankar" palindrome? ] unit-test
{ t } [ "malayalam" palindrome? ] unit-test
{ t } [ "A man, a plan, a canal: Panama." palindrome? ] unit-test
