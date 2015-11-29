! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays destructors formatting images.loader images.sprites
kernel make math opengl opengl.textures sequences sequences.deep
tools.continuations ui ui.gadgets ui.gadgets.worlds ui.render vocabs.loader ;

IN: sprite-test

TUPLE: i-gadget < gadget
    image textures ;

: <i-gadget> ( path -- gadget )
    [ i-gadget new ] dip load-image >>image ;    

M: i-gadget pref-dim*
    image>> dim>> [ 2 * 20 + ] map ;

M: i-gadget graft*
    drop ;

M: i-gadget ungraft*
    dup find-gl-context
    dup textures>> [ dispose ] each
    f >>textures drop ;

: make-sprites ( image -- seq )
    2 3 sprite-sheet
    [ { 0 0 } <texture> ] map ;

: load-textures ( gadget -- seq )
    dup textures>> [ ] [
        dup image>> make-sprites
        >>textures textures>>
    ] ?if ;

: draw-sprite ( texture loc -- )
    swap [ draw-texture ] curry with-translation ;

: draw-sprites ( seq -- )
    2 iota 3 iota [ 2array ] cartesian-map f join
    [ [ 40 * 20 + ] map ] map
    [ draw-sprite ] 2each ;

M: i-gadget draw-gadget*
    load-textures draw-sprites ;

: <sprites-gadget> ( -- gadget )
    i-gadget vocabulary>> vocab-dir "sprites.png"
    "vocab:%s/%s" sprintf <i-gadget> ;
    
: sprite-test ( -- )
    <sprites-gadget> "i-gadget" open-window ;
