! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io kernel math.parser prettyprint sequences sorting ;
IN: wordcount

DEFER: read-word

: process-word ( str -- str/f ) dup empty? [ drop read-word ] when ;

: process-word/f ( str/f -- str/f ) dup [ process-word ] when ;

: read-word ( -- str/f ) " \t\r\n" read-until drop process-word/f ;

: read-words ( -- seq ) [ read-word dup ] [ ] produce nip ;

: update-word-count ( assoc str -- assoc ) over inc-at ;

: words-freqs ( seq -- assoc ) H{ } clone swap [ update-word-count ] each ;

: sort-alist ( alist -- alist ) [ second ] sort-with reverse ;

: sorted-wc ( assoc -- alist ) >alist sort-alist ;

: print-pair ( pair -- )
    [ first write ]
    [ second number>string " --> " swap append print ]
    bi ;

: print-wc ( assoc -- ) sorted-wc [ print-pair ] each ;

: word-count ( -- ) read-words words-freqs print-wc ;

ALIAS: wc word-count
