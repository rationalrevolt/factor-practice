! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors.constants combinators kernel
math opengl prettyprint sequences timers ui ui.gadgets ui.gestures ui.render ;

IN: snakegame

SYMBOLS: :left :right :up :down ;

CONSTANT: snake-game-dim { 12 10 }

TUPLE: snake-part
    dir head? tail? ;

: <snake-part-head> ( dir -- snake-part )
    t f snake-part boa ;

TUPLE: snake-game
    { snake initial: { T{ snake-part f :left t f }
                       T{ snake-part f :left f f }
                       T{ snake-part f :left f t } } }
    { snake-loc initial: { 5 4 } }
    { snake-dir initial: :right }
    food-loc bonus-loc
    { score initial: 0 }
    paused? ;

TUPLE: snake-gadget < gadget
    snake-game timer ;

: <snake-gadget> ( -- snake-gadget )
    snake-gadget new
    snake-game new
    >>snake-game ;

: snake-part-color ( snake-part -- color )
    {
        { [ dup head?>> ] [ drop COLOR: red ] }
        [ drop COLOR: blue ]
    } cond ;

: draw-snake-part ( loc snake-part -- )
    snake-part-color gl-color
    [ 20 * ] map
    { 20 20 } gl-fill-rect ;

: ?roll-over-x ( x -- x )
    {
        { [ dup 0 < ] [ drop snake-game-dim first 1 - ] }
        { [ dup snake-game-dim first = ] [ drop 0 ] }
        [ ]
    } cond ;

: ?roll-over-y ( y -- y )
    {
        { [ dup 0 < ] [ drop snake-game-dim second 1 - ] }
        { [ dup snake-game-dim second = ] [ drop 0 ] }
        [ ]
    } cond ;

: left ( loc -- loc )
    first2 [ 1 - ?roll-over-x ] dip 2array ;

: right ( loc -- loc )
    first2 [ 1 + ?roll-over-x ] dip 2array ;

: up ( loc -- loc )
    first2 1 - ?roll-over-y 2array ;

: down ( loc -- loc )
    first2 1 + ?roll-over-y 2array ;

: next-loc ( loc dir -- loc )
    {
        { :left  [ left ] }
        { :right [ right ] }
        { :up    [ up ] }
        { :down  [ down ] }
    } case ;

: draw-snake ( snake loc -- )
    [
        [ draw-snake-part ]
        [ dir>> next-loc ] 2bi
    ] reduce drop ;

: opposite-dir ( dir -- dir )
    H{
        { :left  :right }
        { :right :left }
        { :up    :down }
        { :down  :up }
    } at ;

: grow-snake ( snake dir -- snake )
    opposite-dir <snake-part-head> prefix
    dup second f >>head? drop ;

: update-snake-structure ( snake-game dir growing? -- )
    [
        [ dup snake>> ] dip
        grow-snake >>snake
        drop
    ] [
        opposite-dir 1array
        [ snake>> ] dip over
        [ dir>> ] map but-last
        append [ >>dir drop ] 2each
    ] if ;

: update-snake-loc ( snake-game dir -- )
    [ dup snake-loc>> ] dip
    next-loc >>snake-loc drop ;

: move-snake ( snake-game dir -- )
    [ f update-snake-structure ]
    [ update-snake-loc ]
    [ >>snake-dir drop ]
    2tri ;

: do-updates ( gadget -- )
    [ snake-game>> dup snake-dir>> move-snake ] keep
    relayout-1 ;

M: snake-gadget pref-dim*
    drop snake-game-dim [ 20 * ] map ;

M: snake-gadget draw-gadget*
    snake-game>>
    [ snake>> ] [ snake-loc>> ] bi draw-snake ;

M: snake-gadget graft*
    [ [ do-updates ] curry 200 milliseconds every ] keep timer<< ;

M: snake-gadget ungraft*
    [ stop-timer f ] change-timer drop ;

: key-action ( key -- action )
    H{
        { "RIGHT" :right }
        { "LEFT"  :left }
        { "UP"    :up }
        { "DOWN"  :down }
    } at ;

: handle-key ( snake-game key -- ? )
    key-action
    [
        2dup [ snake-dir>> opposite-dir ] dip =
        [ 2drop ] [ >>snake-dir drop ] if
        f
    ] [ drop t ] if* ;

M: snake-gadget handle-gesture
    swap dup key-down?
    [
        [ snake-game>> ] [ sym>> ] bi* handle-key
    ] [ 2drop t ] if ;

: snake-game-window ( -- )
    [ <snake-gadget> "Snake Game" open-window ] with-ui ;
