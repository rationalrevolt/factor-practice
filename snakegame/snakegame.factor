! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors.constants combinators kernel
math opengl random sequences timers ui ui.gadgets ui.gestures ui.render ;

IN: snakegame

SYMBOLS: :left :right :up :down ;

SYMBOLS: :head :tail :body ;

CONSTANT: snake-game-dim { 12 10 }

TUPLE: snake-part
    dir type ;

: <snake-part-head> ( dir -- snake-part )
    :head snake-part boa ;

TUPLE: snake-game
    { snake initial: { T{ snake-part f :left :head }
                       T{ snake-part f :left :body }
                       T{ snake-part f :left :tail } } }
    { snake-loc initial: { 5 4 } }
    { snake-dir initial: :right }
    { food-loc  initial: { 1 1 } } bonus-loc
    { score initial: 0 }
    game-over? ;

TUPLE: snake-gadget < gadget
    snake-game timer ;

: <snake-gadget> ( -- snake-gadget )
    snake-gadget new
    snake-game new
    >>snake-game ;

: draw-box ( loc color -- )
    gl-color
    [ 20 * 2 + ] map
    { 16 16 } gl-fill-rect ;

: draw-food ( loc -- )
    COLOR: green draw-box ;

: snake-part-color ( snake-part -- color )
    type>> {
        { :head [ COLOR: red ] }
        [ drop COLOR: blue ]
    } case ;

: draw-snake-part ( loc snake-part -- )
    snake-part-color draw-box ;

: ?roll-over ( x max -- x )
    {
        { [ 2dup >= ] [ 2drop 0 ] }
        { [ over neg? ] [ nip 1 - ] }
        [ drop ]
    } cond ;

: ?roll-over-x ( x -- x )
    snake-game-dim first ?roll-over ;

: ?roll-over-y ( y -- y )
    snake-game-dim second ?roll-over ;

: left ( loc -- loc )
    first2 [ 1 - ?roll-over-x ] dip 2array ;

: right ( loc -- loc )
    first2 [ 1 + ?roll-over-x ] dip 2array ;

: up ( loc -- loc )
    first2 1 - ?roll-over-y 2array ;

: down ( loc -- loc )
    first2 1 + ?roll-over-y 2array ;

: relative-loc ( loc dir -- loc )
    {
        { :left  [ left ] }
        { :right [ right ] }
        { :up    [ up ] }
        { :down  [ down ] }
    } case ;

: draw-snake ( snake loc -- )
    [
        [ draw-snake-part ] [ dir>> relative-loc ] 2bi
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
    dup second :body >>type drop ;

: snake-shape ( snake -- dirs )
    [ dir>> ] map ;

: move-snake ( snake dir -- snake )
    dupd [ snake-shape but-last ] dip
    opposite-dir prefix [ >>dir ] 2map ;

: update-snake-shape ( snake-game dir growing? -- )
    [ [ grow-snake ] curry change-snake ]
    [ [ move-snake ] curry change-snake ]
    if drop ;

: update-snake-loc ( snake-game dir -- )
    [ relative-loc ] curry change-snake-loc drop ;

: update-snake-dir ( snake-game dir -- )
    >>snake-dir drop ;

: snake-will-eat-itself? ( snake-game dir -- ? )
    [ [ snake>> ] [ snake-loc>> ] bi ] dip relative-loc
    [ [ dir>> relative-loc ] accumulate nip 1 tail ] keep
    swap member? ;

: snake-will-eat-food? ( snake-game dir -- ? )
    [ [ food-loc>> ] [ snake-loc>> ] bi ] dip
    relative-loc = ;

: random-point ( -- loc )
    snake-game-dim first2
    [ random ] bi@ 2array ;

: generate-food ( snake-game -- )
    random-point >>food-loc drop ;

: eat-food ( snake-game -- )
    [ 1 + ] change-score
    [ drop f ] change-food-loc
    drop ;

: update-snake ( snake-game dir -- )
    [
        2dup snake-will-eat-food?
        3dup [ drop eat-food ] [ 2drop ] if
        3dup update-snake-shape
        nip [ generate-food ] [ drop ] if
    ]
    [ update-snake-loc ]
    [ update-snake-dir ]
    2tri ;

: game-over ( snake-game -- )
    t >>game-over? drop ;

: game-in-progress? ( snake-game -- ? )
    game-over?>> not ;

: do-updates ( gadget -- )
    [
        snake-game>>
        dup game-in-progress? [
            dup snake-dir>>
            2dup snake-will-eat-itself?
            [ drop game-over ] [ update-snake ] if
        ] [ drop ] if
    ] keep relayout-1 ;

M: snake-gadget pref-dim*
    drop snake-game-dim [ 20 * ] map ;

M: snake-gadget draw-gadget*
    snake-game>>
    [ [ snake>> ] [ snake-loc>> ] bi draw-snake ] keep
    [ food-loc>> [ draw-food ] when* ] keep
    drop ;

M: snake-gadget graft*
    [ [ do-updates ] curry 200 milliseconds every ] keep timer<< ;

M: snake-gadget ungraft*
    [ stop-timer f ] change-timer drop ;

: key-action ( key -- action )
    H{
        { "RIGHT"  :right }
        { "LEFT"   :left }
        { "UP"     :up }
        { "DOWN"   :down }
    } at ;

: escape-key? ( gesture -- ? )
    sym>> "ESC" = ;

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
        dup escape-key? not [
            [ snake-game>> ] [ sym>> ] bi* handle-key
        ] [ drop close-window f ] if
    ] [ 2drop t ] if ;

: play-snake-game ( -- )
    [ <snake-gadget> "Snake Game" open-window ] with-ui ;
