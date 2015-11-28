! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar colors.constants combinators 
formatting hash-sets kernel make math opengl random sequences sets sorting
timers ui ui.gadgets ui.gadgets.status-bar ui.gadgets.worlds ui.gestures ui.render ;

IN: snake-game

SYMBOLS: :left :right :up :down ;

SYMBOLS: :head :body :tail :dead ;

CONSTANT: snake-game-dim { 12 10 }

TUPLE: snake-game
    snake snake-loc snake-dir food-loc
    { next-turn-dir initial: f }
    { score integer initial: 0 }
    { paused? boolean initial: t }
    { game-over? boolean initial: f } ;

TUPLE: snake-part
    dir type ;

: <snake-part> ( dir type -- snake-part )
    snake-part boa ;

: <snake> ( -- snake )
    [
        :left :head <snake-part> ,
        :left :body <snake-part> ,
        :left :tail <snake-part> ,
    ] V{ } make ;

: <snake-game> ( -- snake-game )
    snake-game new
    <snake> >>snake
    { 5 4 } clone >>snake-loc
    :right >>snake-dir
    { 1 1 } clone >>food-loc ;

TUPLE: snake-gadget < gadget
    snake-game timer ;

: start-new-game ( snake-gadget -- )
    <snake-game> >>snake-game drop ;

: <snake-gadget> ( -- snake-gadget )
    snake-gadget new
    [ start-new-game ] keep ;

: draw-box ( loc color -- )
    gl-color
    [ 20 * 2 + ] map
    { 16 16 } gl-fill-rect ;

: draw-food ( loc -- )
    COLOR: green draw-box ;

: snake-part-color ( snake-part -- color )
    type>> {
        { :head [ COLOR: red ] }
        { :dead [ COLOR: black ] }
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

: move-left ( loc -- loc )
    first2 [ 1 - ?roll-over-x ] dip 2array ;

: move-right ( loc -- loc )
    first2 [ 1 + ?roll-over-x ] dip 2array ;

: move-up ( loc -- loc )
    first2 1 - ?roll-over-y 2array ;

: move-down ( loc -- loc )
    first2 1 + ?roll-over-y 2array ;

: relative-loc ( loc dir -- loc )
    {
        { :left  [ move-left ] }
        { :right [ move-right ] }
        { :up    [ move-up ] }
        { :down  [ move-down ] }
    } case ;

: draw-snake ( snake loc -- )
    2dup
    [
        [ draw-snake-part ] [ dir>> relative-loc ] 2bi
    ] reduce drop
    ! make sure to draw the head again
    swap first draw-snake-part ;

: opposite-dir ( dir -- dir )
    H{
        { :left  :right }
        { :right :left }
        { :up    :down }
        { :down  :up }
    } at ;

: grow-snake ( snake dir -- snake )
    opposite-dir :head <snake-part> prefix
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

: point>index ( loc -- n )
    first2 [ ] [ snake-game-dim first * ] bi* + ;

: index>point ( n -- loc )
    snake-game-dim first /mod swap 2array ;

: snake-occupied-locs ( snake head-loc -- points )
    [ dir>> relative-loc ] accumulate nip ;

: snake-occupied-indices ( snake head-loc -- points )
    snake-occupied-locs [ point>index ] map natural-sort ;

: all-indices ( -- points )
    snake-game-dim first2 * iota ;

: snake-unoccupied-indices ( snake head-loc -- points )
    [ all-indices ] 2dip snake-occupied-indices >hash-set without ;

: snake-will-eat-itself? ( snake-game dir -- ? )
    [ [ snake>> ] [ snake-loc>> ] bi ] dip relative-loc
    [ snake-occupied-locs rest ] keep
    swap member? ;

: snake-will-eat-food? ( snake-game dir -- ? )
    [ [ food-loc>> ] [ snake-loc>> ] bi ] dip
    relative-loc = ;

: random-sample ( seq -- e )
    1 sample first ;

: generate-food ( snake-game -- )
    [
        [ snake>> ] [ snake-loc>> ] bi
        snake-unoccupied-indices random-sample index>point
    ] keep food-loc<< ;

: update-score ( snake-game -- )
    [ 1 + ] change-score
    drop ;

: update-snake ( snake-game dir -- )
    2dup snake-will-eat-food?
    {
        [ [ drop update-score ] [ 2drop ] if ]
        [ update-snake-shape ]
        [ drop update-snake-loc ]
        [ drop update-snake-dir ]
        [ nip [ generate-food ] [ drop ] if ]
    } 3cleave ;

: game-over ( snake-game -- )
    t >>game-over?
    snake>> first :dead >>type drop ;

: game-in-progress? ( snake-game -- ? )
    [ game-over?>> ] [ paused?>> ] bi or not ;

: ?handle-pending-turn ( snake-game -- )
    dup next-turn-dir>> [
        >>snake-dir
        f >>next-turn-dir
    ] when* drop ;

: do-game-step ( gadget -- )
    dup game-in-progress? [
        dup ?handle-pending-turn
        dup snake-dir>>
        2dup snake-will-eat-itself?
        [ drop game-over ] [ update-snake ] if
    ] [ drop ] if ;

: generate-status-message ( snake-game -- str )
    [ score>> "Score: %d" sprintf ]
    [
        {
            { [ dup game-over?>> ] [ drop "Game Over" ] }
            { [ dup paused?>> ] [ drop "Game Paused" ] }
            [ drop "Game In Progress" ]
        } cond
    ]
    bi 2array " -- " join ;
        
: update-status ( gadget -- )
    [ snake-game>> generate-status-message ] keep show-status ;

: do-updates ( gadget -- )
    [ snake-game>> do-game-step ]
    [ update-status ]
    [ relayout-1 ]
    tri ;
        
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

: quit-key? ( key -- ? )
    HS{ "ESC" "q" "Q" } in? ;

: pause-key? ( key -- ? )
    HS{ " " "SPACE" "p" "P" } in? ;

: new-game-key? ( key -- ? )
    HS{ "ENTER" "RET" "n" "N" } in? ;

: ?handle-movement-key ( snake-game key -- )
    key-action
    [
        2dup [ snake-dir>> opposite-dir ] dip =
        [ 2drop ] [ >>next-turn-dir drop ] if
    ] [ drop ] if* ;

: toggle-game-pause ( snake-gadget -- )
    snake-game>> [ not ] change-paused? drop ;

: handle-key ( snake-gadget key -- )
    {
        { [ dup quit-key? ] [ drop close-window ] }
        { [ dup pause-key? ] [ drop toggle-game-pause ] }
        { [ dup new-game-key? ] [ drop start-new-game ] }
        [
            [ snake-game>> ] dip over
            game-in-progress? [ ?handle-movement-key ] [ 2drop ] if
        ]
    } cond ;

M: snake-gadget handle-gesture
    swap dup key-down?
    [ sym>> handle-key ] [ 2drop ] if f ;

: <snake-world-attributes> ( -- world-attributes )
    <world-attributes> "Snake Game" >>title    
    [
        { maximize-button resize-handles } without
    ] change-window-controls ;

: play-snake-game ( -- )
    [ <snake-gadget> <snake-world-attributes> open-status-window ] with-ui ;
