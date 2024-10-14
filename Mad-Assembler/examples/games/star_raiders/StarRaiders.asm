 ;*******************************************************************************
 ;*                                                                             *
 ;*                           S T A R   R A I D E R S                           *
 ;*                                                                             *
 ;*                  for the Atari 8-bit Home Computer System                   *
 ;*                                                                             *
 ;*       Reverse engineered and documented assembly language source code       *
 ;*                                                                             *
 ;*                                     by                                      *
 ;*                                                                             *
 ;*                                Lorenz Wiest                                 *
 ;*                                                                             *
 ;*                            (lo.wiest(at)web.de)                             *
 ;*                                                                             *
 ;*                                First Release                                *
 ;*                                 22-SEP-2015                                 *
 ;*                                                                             *
 ;*                                 Last Update                                 *
 ;*                                 10-DEC-2016                                 *
 ;*                                                                             *
 ;*                STAR RAIDERS was created by Douglas Neubauer                 *
 ;*                  STAR RAIDERS was published by Atari Inc.                   *
 ;*                                                                             *
 ;*******************************************************************************

                opt h-
                
 ; I wrote this document out of my own curiosity. When STAR RAIDERS was released
 ; in 1979 it became the killer app for the Atari 8-bit Home Computer System.
 ; Since then I have always been wondering what made it tick and how its (at that
 ; time) spectacular 3D graphics worked, especially the rotating star field.
 ; Impressed by "The Atari BASIC Source Book" I decided to reverse engineer the
 ; STAR RAIDERS 8KB ROM cartridge to recreate a fully documented assembly
 ; language source code file. I had no access to the original source code, so the
 ; only way to succeed was a combination of educated guesses, trial-and-error,
 ; and patience. Eventually, I made it.
 ;
 ; Essential in preparing this document were three programs I wrote:
 ;
 ; (1) A 6502-cross-assembler based on the syntax of the MAC/65 assembler for the
 ;     Atari 8-bit Home Computer System to create the binary file that I verified
 ;     against the binary of the original ROM cartridge.
 ;
 ; (2) A text formatter to layout the source code file with its copious comment
 ;     sections. This was a big time saver, because as the documentation grew the
 ;     source code had to be reformatted over and over again.
 ;
 ; (3) A symbol checker to verify that the ubiquitous symbol-value pairs in the
 ;     documentation match the corresponding symbol values produced by the
 ;     assembler.
 ;
 ; This assembly language source code file is compatible with the MAC/65
 ; assembler for the Atari 8-bit Home Computer System. I was able to assemble it
 ; on an emulated Atari running MAC/65, producing the identical binary of the ROM
 ; cartridge. 
 ;
 ; Your feedback is welcome! Send feedback to lo.wiest(at)web.de.
 ;
 ; Enjoy! -- Lorenz

 ;*******************************************************************************
 ;*                                                                             *
 ;*                               N O T A T I O N                               *
 ;*                                                                             *
 ;*******************************************************************************

 ; BITS AND BYTES
 ;
 ; o   A "byte" consists of 8 bits. They are numbered B7..0. Bit B0 is the least
 ;     significant bit.
 ;
 ; o   A "word" consists of 16 bits. They are numbered B15..B0. Bit B0 is the
 ;     least significant bit. A word is stored in low-order then high-order byte
 ;     order.
 ;
 ; o   The high-order byte ("high byte") of a word consists of bits B15..8 of the
 ;     word.
 ;
 ; o   The low-order byte ("low byte") of a word consists of bits B7..0 of the
 ;     word.
 ;
 ; NUMBERS
 ;
 ; o   The dollar sign ($) prefixes hexadecimal numbers.
 ;     Example: $101 is the decimal number 257.
 ;
 ; o   The percent sign (%) prefixes binary numbers.
 ;     Example: %101 is the decimal number 5.
 ;
 ; o   The asterisk (*) is a wildcard character for a single hexadecimal or
 ;     binary digit.
 ;     Example: $0*00 is a placeholder for the numbers $0000, $0100, ..., $0F00.
 ;
 ; o   The lowercase R (r) is a wildcard character for a single random
 ;     hexadecimal or binary digit. The random digit r is chosen by a random
 ;     number generator.
 ;     Example: %00r0 is a placeholder for the numbers %0000 or %0010.
 ;
 ; OPERATORS
 ;
 ; o   The exclamation mark (!) is the binary OR operator.
 ;     Example: $01|$02 is $03.
 ;
 ; o   The less-than sign (<) indicates bits B7..0 of a word.
 ;     Example: <$1234 is $34.
 ;
 ; o   The greater-than sign (>) indicates bits B15..8 of a word.
 ;     Example: >$1234 is $12.
 ;
 ; o   A pair of brackets ([]) groups mathematical expressions.
 ;     Example: [3-1]*4 is 8.
 ;
 ; ASSEMBLY LANGUAGE
 ;
 ; o   The uppercase A (A) indicates the accumulator register of the 6502 CPU.
 ;
 ; o   The uppercase X (X) indicates the X register of the 6502 CPU.
 ;
 ; o   The uppercase Y (Y) indicates the Y register of the 6502 CPU.
 ;
 ; o   The prefix uppercase L and dot (L.) indicates a local variable, a memory
 ;     location used temporarily in a subroutine.
 ;
 ; PSEUDO-FUNCTIONS
 ;
 ; o   The function ABS(<num>) returns the absolute value of <num>.
 ;     Example: ABS(3) returns 3.
 ;     Example: ABS(-3) returns 3.
 ;
 ; o   The function RND(<num1>..<num2>) returns a random integer in
 ;     <num1>..<num2>.
 ;     Example: RND(3..5) returns a random number out of 3, 4, or 5.
 ;
 ; o   The function MAX(<num1>,<num2>) returns the larger number of <num1> and
 ;     <num2>.
 ;     Example: MAX(2,4) returns 4.
 ;
 ; VECTORS
 ;
 ; o   The lowercase X (x) indicates the x-axis of the 3D coordinate system.
 ;
 ; o   The lowercase Y (y) indicates the y-axis of the 3D coordinate system.
 ;
 ; o   The lowercase Z (z) indicates the z-axis of the 3D coordinate system.
 ;
 ; o   Components of a position vector (called "coordinates") have the arbitrary
 ;     unit <KM> ("kilometers").
 ;
 ; o   Components of a velocity vector have the arbitrary unit <KM/H>
 ;     ("kilometers per hour").
 ;
 ; o   A positive component of a position vector (coordinate) in hexadecimal
 ;     notation is written in the form +$<hexNum> <KM>. <hexNum> is an unsigned
 ;     integer value.
 ;     Example: The starbase is +$1000 (or 4096) <KM> ahead of our starship.
 ;
 ; o   A negative component of a position vector (coordinate) in hexadecimal
 ;     notation is written in the form -($<hexNum>) <KM>. <hexNum> is an unsigned
 ;     integer value. To calculate the actual bit pattern of this coordinate
 ;     value compute the two's-complement of <hexNum>. See also "ON POSITION
 ;     VECTORS".
 ;     Example: The starbase is -($1000) (or -4096) <KM> behind our starship.
 ;
 ; o   An absolute component of a position vector (coordinate) in hexadecimal
 ;     notation is written in the form $<hexNum> <KM>. <hexNum> is an unsigned
 ;     integer value.
 ;     Example: The Zylon fighter fires when it is closer than $1000 (or 4096)
 ;              <KM>. 
 ;
 ; DISPLAY LIST
 ;
 ; o   The following notation is used for Display List instructions:
 ;
 ;     BLK<n>           = Display <n> blank video lines (<n> in 1..8)
 ;     GR1              = Display one GRAPHICS 1 row of 20 text characters
 ;     GR2              = Display one GRAPHICS 2 row of 20 text characters
 ;     GR7              = Display one GRAPHICS 7 row of 160 pixels
 ;     DLI              = Trigger a Display List Interrupt
 ;     ... @ <addr>     = Point to screen memory at address <addr>
 ;     JMP @ <addr>     = Jump to next Display List instruction at address <addr>
 ;     WAITJMP @ <addr> = Wait for vertical blank phase, then jump to next
 ;                        Display List instruction at address <addr>
 ;
 ; MISCELLANEOUS
 ;
 ; o   Probabilities are written in the form <percentage>% (<number of values out
 ;     of the possible values>:<number of possible values>).
 ;     Example: The probability to throw the number 3 with a die is 16% (1:6).
 ;
 ; o   A "game loop iteration" (or "game loop") is a single execution of the game
 ;     loop, the main program of the game.
 ;
 ; o   A "TICK" is the time span it takes to update the TV screen (1/60 s on an
 ;     NTSC TV system, 1/50 s on a PAL TV system).
 ;
 ; o   A pair of braces ({}) encloses color names.
 ;     Example: {BLACK}
 ;
 ; o   A pair of parentheses enclosing a question mark ((?)) indicates code that
 ;     is not well understood.
 ;
 ; o   A pair of parentheses enclosing an exclamation mark ((!)) indicates a
 ;     potential bug.

 ;*******************************************************************************
 ;*                                                                             *
 ;*                               O V E R V I E W                               *
 ;*                                                                             *
 ;*******************************************************************************

 ; ON POSITION VECTORS
 ;
 ; The game uses a 3D coordinate system with the position of our starship at the
 ; center of the coordinate system and the following coordinate axes:
 ;
 ; o   The x-axis points to the right.
 ; o   The y-axis points up.
 ; o   The z-axis points in flight direction.
 ;
 ; By the way, this is called a "left-handed" coordinate system.
 ;
 ; The locations of all space objects (Zylon ships, meteors, photon torpedoes,
 ; starbase, transfer vessel, Hyperwarp Target Marker, stars, and explosion
 ; fragments) are described by a "position vector".
 ;
 ; A "position vector" is composed of an x, y, and z component. The values of the
 ; position vector components are called the x, y, and z "coordinates". They have
 ; the arbitrary unit <KM>.
 ;
 ; Each coordinate is a signed 17-bit integer number, which fits into 3 bytes:
 ;
 ;     Sign     Mantissa
 ;          B16 B15...B8 B7....B0
 ;            | |      | |      |
 ;     0000000* ******** ********
 ;
 ; o   B16 contains the sign bit. Used values are:
 ;       1 -> Positive sign
 ;       0 -> Negative sign
 ; o   B15..0 contain the coordinate value (or "mantissa") as a two's-complement
 ;     integer number.
 ;
 ; The range of a position vector component is -65536..+65535 <KM>.
 ;
 ; Examples:
 ;
 ;     00000001 11111111 11111111 = +65535 <KM>
 ;     00000001 00010000 00000000 =  +4096 <KM>
 ;     00000001 00001111 11111111 =  +4095 <KM>
 ;     00000001 00000001 00000000 =   +256 <KM>
 ;     00000001 00000000 11111111 =   +255 <KM>
 ;     00000001 00000000 00010000 =    +16 <KM>
 ;     00000001 00000000 00001111 =    +15 <KM>
 ;     00000001 00000000 00000001 =     +1 <KM>
 ;     00000001 00000000 00000000 =     +0 <KM>
 ;
 ;     00000000 11111111 11111111 =     -1 <KM>
 ;     00000000 11111111 11111110 =     -2 <KM>
 ;     00000000 11111111 11110001 =    -15 <KM>
 ;     00000000 11111111 11110000 =    -16 <KM>
 ;     00000000 11111111 00000001 =   -255 <KM>
 ;     00000000 11111111 00000000 =   -256 <KM>
 ;     00000000 11110000 00000001 =  -4095 <KM>
 ;     00000000 11110000 00000000 =  -4096 <KM>
 ;     00000000 00000000 00000000 = -65536 <KM>
 ;
 ; The position vector for each space object is stored in 9 tables:
 ;
 ; o   XPOSSIGN ($09DE..$0A0E), XPOSHI ($0A71..$0AA1), and XPOSLO ($0B04..$0B34)
 ; o   YPOSSIGN ($0A0F..$0A3F), YPOSHI ($0AA2..$0AD2), and YPOSLO ($0B35..$0B65)
 ; o   ZPOSSIGN ($09AD..$09DD), ZPOSHI ($0A40..$0A70), and ZPOSLO ($0AD3..$0B03)
 ;
 ; There are up to 49 space objects used in the game simultaneously, thus each
 ; table is 49 bytes long.
 ;
 ; o   Position vectors 0..4 belong to space objects represented by PLAYERs
 ;     (Zylon ships, meteors, photon torpedoes, starbase, transfer vessel, and
 ;     Hyperwarp Target Marker).
 ; o   Position vectors 5..48 belong to space objects represented by PLAYFIELD
 ;     pixels. Position vectors 5..16 (stars, explosion fragments) are used for
 ;     stars, position vectors 17..48 are used for explosion fragments and star
 ;     trails.
 ;
 ; INFO: The x and y coordinates of space objects are converted and displayed by
 ; the THETA and PHI readouts of the Control Panel Display in "gradons". The
 ; z-coordinate is converted and displayed by the RANGE readout in "centrons".
 ; The conversion takes place in subroutine SHOWDIGITS ($B8CD) where the high
 ; byte of a coordinate (with values $00..$FF) is transformed with lookup table
 ; MAPTOBCD99 ($0EE9) into a BCD value of 00..99 in "gradons" or "centrons".
 ;
 ;
 ; ON VELOCITY VECTORS
 ;
 ; The velocities of all space objects are described by a "velocity vector". The
 ; velocity vector is relative to our starship.
 ;
 ; A "velocity vector" is composed of an x, y, and z component. The values of the
 ; velocity vector components are called the x, y, and z "velocities". They have
 ; the arbitrary unit <KM/H>.
 ;
 ; Each velocity vector component is an 8-bit integer number, which fits into 1
 ; byte:
 ;
 ;     B7 Sign
 ;     |
 ;     |B6...B0 Mantissa
 ;     ||     |
 ;     ********
 ;
 ; o   B7 contains the sign bit. Used values are:
 ;     0 -> Positive sign, movement along the positive coordinate axis
 ;          (x-velocity: right, y-velocity: up, z-velocity: in flight direction)
 ;     1 -> Negative sign, movement along the negative coordinate axis
 ;          (x-velocity: left, y-velocity: down, z-velocity: in reverse flight
 ;          direction)
 ; o   B6..B0 contain the velocity value (or "mantissa"). It is an unsigned
 ;     number.
 ;
 ; The range of a velocity vector component is -127..+127 <KM/H>.
 ;
 ; Examples:
 ;
 ;     01111111 = +127 <KM/H>
 ;     00010000 =  +16 <KM/H>
 ;     00001111 =  +15 <KM/H>
 ;     00000001 =   +1 <KM/H>
 ;     00000000 =   +0 <KM/H>
 ;
 ;     10000000 =   -0 <KM/H>
 ;     10000001 =   -1 <KM/H>
 ;     10001111 =  +15 <KM/H>
 ;     10010000 =  +16 <KM/H>
 ;     11111111 = -127 <KM/H>
 ;
 ; The velocity vector for each space object stored in 3 tables:
 ;
 ; o   XVEL ($0B97..$0BC7)
 ; o   YVEL ($0BC8..$0BF8)
 ; o   ZVEL ($0B66..$0B96)
 ;
 ; There are up to 49 space objects used in the game simultaneously, thus each
 ; table is 49 bytes long.
 ;
 ; o   Velocity vectors 0..4 belong to space objects represented by PLAYERs
 ;     (Zylon ships, meteors, photon torpedoes, starbase, transfer vessel, and
 ;     Hyperwarp Target Marker).
 ; o   Velocity vectors 5..48 belong to space objects represented by PLAYFIELD
 ;     pixels. Velocity vectors 5..16 are used for stars, velocity vectors 17..48
 ;     are used for explosion fragments and star trails.
 ;
 ; INFO: The velocity of our starship is converted and displayed by the VELOCITY
 ; readout of the Control Panel Display in "metrons per second" units. The
 ; conversion takes place in subroutine SHOWDIGITS ($B8CD) where our starship's
 ; velocity VELOCITYL ($70) (with values $00..$FF) is transformed with lookup
 ; table MAPTOBCD99 ($0EE9) into a BCD value of 00..99 in "metrons per second".  

 ;*******************************************************************************
 ;*                                                                             *
 ;*                             M E M O R Y   M A P                             *
 ;*                                                                             *
 ;*******************************************************************************
 ;
 ; The following variables are not changed by a SYSTEM RESET:
 ;
 ; $62      MISSIONLEVEL
 ;
 ;          Mission level. Used values are:
 ;            $00 -> NOVICE mission
 ;            $01 -> PILOT mission
 ;            $02 -> WARRIOR mission
 ;            $03 -> COMMANDER mission
 ;
 ; $63      FKEYCODE
 ;
 ;          Function key code. Used values are:
 ;            $00 -> No function key pressed
 ;            $01 -> START function key pressed
 ;            $02 -> SELECT function key pressed
 ;
 ; $64      ISDEMOMODE
 ;
 ;          Indicates whether the game is in game or in demo mode. Used values
 ;          are:
 ;            $00 -> Game mode
 ;            $FF -> Demo mode
 ;
 ; $65      NEWTITLEPHR
 ;
 ;          New title phrase offset for the text in the title line. The new title
 ;          phrase is not immediately displayed in the title line but only after
 ;          the display time of the currently displayed title phrase has expired.
 ;          Thus, setting a value to NEWTITLEPHR ($65) "enqueues" the display of
 ;          new title phrase. Used values are:
 ;            $00..$7B -> Title phrase offset into PHRASETAB ($BBAA)
 ;            $FF      -> Hide title line
 ;
 ;          See also TITLEPHR ($D1).
 ;
 ; $66      IDLECNTHI
 ;
 ;          Idle counter (high byte). Forms a 16-bit counter together with
 ;          IDLECNTLO ($77), which is incremented during the execution of the
 ;          Vertical Blank Interrupt handler VBIHNDLR ($A6D1). IDLECNTHI ($66) is
 ;          reset to 0 when the joystick trigger or a keyboard key has been
 ;          pressed, or to 1..3 when a function key has been pressed. When
 ;          IDLECNTHI ($66) reaches a value of 128 (after about 10 min idle time)
 ;          the game enters demo mode.
 ;
 ; The following variables are set to 0 after a SYSTEM RESET:
 ;
 ; $67      ISVBISYNC
 ;
 ;          Indicates whether the Vertical Blank Interrupt handler VBIHNDLR
 ;          ($A6D1) is executed. Used to synchronize the execution of a new game
 ;          loop iteration in GAMELOOP ($A1F3) with the vertical blank phase.
 ;          Used values are:
 ;            $00 -> Halt execution at start of game loop and wait for VBI
 ;            $FF -> Continue execution of game loop
 ;
 ; $68..$69 MEMPTR
 ;
 ;          A 16-bit memory pointer.
 ;
 ;          Also used as a local variable.
 ;
 ; $6A..$6B DIVIDEND
 ;
 ;          A 16-bit dividend value passed in GAMELOOP ($A1F3) to subroutine
 ;          PROJECTION ($AA21) to calculate a division.
 ;
 ;          Also used as a local variable.
 ;
 ; $6C      Used as a local variable.
 ;
 ; $6D      JOYSTICKDELTA
 ;
 ;          Used to pass joystick directions from GAMELOOP ($A1F3) to subroutine
 ;          ROTATE ($B69B). Used values are:
 ;            $01 -> Joystick pressed right or up
 ;            $00 -> Joystick centered
 ;            $FF -> Joystick pressed left or down
 ;
 ;          Also used as a local variable.
 ;
 ; $6E      Used as a local variable.
 ;
 ; $70      VELOCITYLO
 ;
 ;          Our starship's current velocity (low byte) in <KM/H>. Forms a 16-bit
 ;          value together with VELOCITYHI ($C1). In subroutine UPDPANEL ($B804),
 ;          VELOCITYLO ($70) is mapped to a BCD-value in 00..99 and displayed by
 ;          the VELOCITY readout of the Control Panel Display. See also
 ;          NEWVELOCITY ($71).
 ;
 ; $71      NEWVELOCITY
 ;
 ;          Our starship's new velocity (low byte) in <KM/H>. It is set by
 ;          pressing one of the speed keys '0'..'9'. A pressed speed key is
 ;          mapped to the new velocity value with VELOCITYTAB ($BAB4).
 ;
 ; $72      COUNT8
 ;
 ;          Wrap-around counter. Counts from 0..7, then starts over at 0. It is
 ;          incremented every game loop iteration. It is used to change the
 ;          brightness of stars and explosion fragments more randomly in GAMELOOP
 ;          ($A1F3) and to slow down the movement of the hyperwarp markers of the
 ;          Galactic Chart in subroutine SELECTWARP ($B162).
 ;
 ; $73      EXPLLIFE
 ;
 ;          Explosion lifetime. It is decremented every game loop iteration. Used
 ;          values are:
 ;              $00 -> Explosion is over
 ;            < $18 -> Number of explosion fragment space objects is decremented
 ;            < $70 -> HITBADNESS ($8A) is reset
 ;              $80 -> Initial value at start of explosion
 ;
 ; $74      CLOCKTIM
 ;
 ;          Star date clock delay timer. Counts down from 40 to 0. It is
 ;          decremented every game loop iteration. When the timer falls below 0
 ;          the last digit of the star date of the Galactic Chart Panel Display
 ;          is increased and the timer is reset to a value of 40. 
 ;
 ; $75      DOCKSTATE
 ;
 ;          State of docking operation. Used values are:
 ;            $00 -> NOT DOCKED
 ;            $01 -> TRANSFER COMPLETE
 ;            $81 -> RETURN TRANSFER VESSEL
 ;            $FF -> ORBIT ESTABLISHED
 ;
 ; $76      COUNT256
 ;
 ;          Wrap-around counter. Counts from 0..255, then starts over at 0. It is
 ;          incremented every game loop iteration. It is used to make the
 ;          starbase pulsate in brightness in GAMELOOP ($A1F3) and to decide on
 ;          the creation of a meteor in subroutine MANEUVER ($AA79).
 ;
 ; $77      IDLECNTLO
 ;
 ;          Idle counter (low byte). Forms a 16-bit counter together with
 ;          IDLECNTHI ($66), which is incremented during the execution of the
 ;          Vertical Blank Interrupt handler VBIHNDLR ($A6D1).
 ;
 ;          NOTE: This variable is never properly initialized except at initial
 ;          cartridge startup (cold start).
 ;
 ; $78      ZYLONUNITTIM
 ;
 ;          Zylon unit movement timer. This delay timer triggers movement of
 ;          Zylon units on the Galactic Chart. At the start of the game, the
 ;          timer is initialized to a value of 100. It is decremented every 40
 ;          game loop iterations. When the timer falls below 0 the Zylon units
 ;          move on the Galactic Chart and the timer value is reset to 49. If a
 ;          starbase is surrounded the timer is reset to 99 to buy you some extra
 ;          time to destroy one of the surrounding Zylon units.
 ;
 ; $79      MAXSPCOBJIND
 ;
 ;          Maximum index of used space objects in the current game loop
 ;          iteration. Frequently used values are:
 ;            $10 -> During regular cruise (5 PLAYER space objects + 12 PLAYFIELD
 ;                   space objects (stars), counted $00..$10)
 ;            $30 -> During explosion or hyperwarp (5 PLAYER space objects + 12
 ;                   PLAYFIELD space objects (stars) + 32 PLAYFIELD space objects
 ;                   (explosion fragments or stars of star trails), counted
 ;                   $00..$30)
 ;
 ; $7A      OLDMAXSPCOBJIND
 ;
 ;          Maximum index of used space objects in the previous game loop
 ;          iteration. Frequently used values are:
 ;            $10 -> During regular cruise (5 PLAYER space objects + 12 PLAYFIELD
 ;                   space objects (stars), counted $00..$10)
 ;            $30 -> During explosion or hyperwarp (5 PLAYER space objects + 12
 ;                   PLAYFIELD space objects (stars) + 32 PLAYFIELD space objects
 ;                   (explosion fragments or stars of star trails), counted
 ;                   $00..$30)
 ;
 ; $7B      ISSTARBASESECT
 ;
 ;          Indicates whether a starbase is in this sector. Used values are:
 ;            $00 -> Sector contains no starbase
 ;            $FF -> Sector contains starbase
 ;
 ; $7C      ISTRACKCOMPON
 ;
 ;          Indicates whether the Tracking Computer is on or off. Used values
 ;          are:
 ;            $00 -> Tracking Computer is off
 ;            $FF -> Tracking Computer is on
 ;
 ; $7D      DRAINSHIELDS
 ;
 ;          Energy drain rate of the Shields per game loop iteration in energy
 ;          subunits. See also subroutine UPDPANEL ($B804). Used values are:
 ;            $00 -> Shields are off
 ;            $08 -> Shields are on
 ;
 ; $7E      DRAINATTCOMP
 ;
 ;          Energy drain rate of the Attack Computer per game loop iteration in
 ;          energy subunits. See also subroutine UPDPANEL ($B804). Used values
 ;          are:
 ;            $00 -> Attack Computer off
 ;            $02 -> Attack Computer on
 ;
 ; $7F      ENERGYCNT
 ;
 ;          Running counter of consumed energy subunits (256 energy subunits = 1
 ;          energy unit displayed by the 4-digit ENERGY readout of the Control
 ;          Panel Display). Forms an invisible fractional or "decimals" part of
 ;          the 4-digit ENERGY readout of the Control Panel Display. See also
 ;          subroutine UPDPANEL ($B804).
 ;
 ; $80      DRAINENGINES
 ;
 ;          Energy drain rate of our starship's Engines per game loop iteration
 ;          in energy subunits (256 energy subunits = 1 energy unit displayed by
 ;          the 4-digit ENERGY readout of the Control Panel Display). Values are
 ;          picked from table DRAINRATETAB ($BAD3). See also subroutine UPDPANEL
 ;          ($B804).
 ;
 ; $81      SHIELDSCOLOR
 ;
 ;          Shields color. Used values are: 
 ;            $00 -> {BLACK} (Shields are off)
 ;            $A0 -> {DARK GREEN} (Shields are on)
 ;
 ; $82      PL3HIT
 ;
 ;          Collision register of PLAYER3 (usually our starship's photon torpedo
 ;          0) with other PLAYERs. Used values are:
 ;              $00 -> No collision
 ;            > $00 -> PLAYER3 has collided with another PLAYER space object. See
 ;                     subroutine COLLISION ($AF3D) for details which PLAYER has
 ;                     been hit by PLAYER3.
 ;
 ; $83      PL4HIT
 ;
 ;          Collision register of PLAYER4 (usually our starship's photon torpedo
 ;          1) with other PLAYERs. Used values are:
 ;              $00 -> No collision
 ;            > $00 -> PLAYER4 has collided with another PLAYER space object. See
 ;                     subroutine COLLISION ($AF3D) for details which PLAYER has
 ;                     been hit by PLAYER4.
 ;
 ; $84      OLDTRIG0
 ;
 ;          Joystick trigger state. Used values are:
 ;            $00 -> Joystick trigger was pressed
 ;            $01 -> Joystick trigger was not pressed
 ;            $AA -> Joystick trigger was "virtually" pressed (will launch
 ;                   another of our starship's photon torpedoes, see subroutine
 ;                   TRIGGER ($AE29).
 ;
 ; $86      ISTRACKING
 ;
 ;          Indicates whether one of our starship's photon torpedoes is currently
 ;          tracking (homing in on) the target space object. Used values are:
 ;              $00 -> No target space object tracked. Our starship's photon
 ;                     torpedoes will fly just straight ahead.
 ;            > $00 -> Tracking a target space object. Our starship's photon
 ;                     torpedoes will home in on the tracked space object.
 ;
 ; $87      BARRELNR
 ;
 ;          Barrel from which our starship's next photon torpedo will be
 ;          launched. Used values are:
 ;            $00 -> Left barrel
 ;            $01 -> Right barrel
 ;
 ; $88      LOCKONLIFE
 ;
 ;          Lifetime of target lock-on. A target remains in lock-on while
 ;          LOCKONLIFE ($88) counts down from 12 to 0. It is decremented every
 ;          game loop iteration.
 ;
 ; $89      PLTRACKED
 ;
 ;          Index of currently tracked PLAYER. It is copied in subroutine TRIGGER
 ;          ($AE29) from TRACKDIGIT ($095C). Used values are:
 ;            $00 -> Track Zylon ship 0
 ;            $01 -> Track Zylon ship 1
 ;            $02 -> Track starbase during docking operations
 ;            $03 -> Track Hyperwarp Target Marker during hyperwarp
 ;
 ; $8A      HITBADNESS
 ;
 ;          Severity of a Zylon photon torpedo hit. Used values are:
 ;            $00 -> NO HIT
 ;            $7F -> SHIELDS HIT
 ;            $FF -> STARSHIP DESTROYED
 ;
 ; $8B      REDALERTLIFE
 ;
 ;          Lifetime of red alert. It decreases from 255 to 0. It is decremented
 ;          every game loop iteration.
 ;
 ; $8C      WARPDEPRROW
 ;
 ;          Departure hyperwarp marker row number on the Galactic Chart. It is
 ;          given in Player/Missile pixels relative to the top Galactic Chart
 ;          border. It is initialized to a value of $47 (vertical center of
 ;          Galactic Chart). Divide this value by 16 to get the departure sector
 ;          row number. Used values are: $00..$7F.
 ;
 ; $8D      WARPDEPRCOLUMN
 ;
 ;          Departure hyperwarp marker column number on the Galactic Chart. It is
 ;          given in Player/Missile pixels relative to the left Galactic Chart
 ;          border and initialized to a value of $43 (horizontal center of
 ;          Galactic Chart). Divide this value by 8 to get the departure sector
 ;          column number. Used values are: $00..$7F.
 ;
 ; $8E      WARPARRVROW
 ;
 ;          Arrival hyperwarp marker row number on the Galactic Chart in
 ;          Player/Missile pixels relative to top Galactic Chart border. It is
 ;          initialized to a value of $47 (vertical center of Galactic Chart).
 ;          Divide this value by 16 to get the arrival sector row number. Used
 ;          values are: $00..$7F. 
 ;
 ; $8F      WARPARRVCOLUMN
 ;
 ;          Arrival hyperwarp marker column number on the Galactic Chart in
 ;          Player/Missile pixels relative to left Galactic Chart border. It is
 ;          initialized to a value of $43 (horizontal center of Galactic Chart).
 ;          Divide this value by 8 to get the arrival sector column number. Used
 ;          values are: $00..$7F. 
 ;
 ; $90      CURRSECTOR
 ;
 ;          Galactic Chart sector of the current location of our starship. At the
 ;          start of the game it is initialized to a value of $48. Used values
 ;          are: $00..$7F with, for example,
 ;            $00 -> NORTHWEST corner sector
 ;            $0F -> NORTHEAST corner sector
 ;            $70 -> SOUTHWEST corner sector
 ;            $7F -> SOUTHWEST corner sector
 ;
 ;          See also ARRVSECTOR ($92). 
 ;
 ; $91      WARPENERGY
 ;
 ;          Energy required to hyperwarp between the departure and arrival
 ;          hyperwarp marker locations on the Galactic Chart divided by 10.
 ;          Values are picked from table WARPENERGYTAB ($BADD). Multiply this
 ;          value by 10 to get the actual value in energy units displayed by the
 ;          Galactic Chart Panel Display.
 ;
 ; $92      ARRVSECTOR
 ;
 ;          Galactic Chart arrival sector of our starship after hyperwarp. Used
 ;          values are: $00..$7F with, for example,
 ;            $00 -> NORTHWEST corner sector
 ;            $0F -> NORTHEAST corner sector
 ;            $70 -> SOUTHWEST corner sector
 ;            $7F -> SOUTHWEST corner sector
 ;
 ;          See also CURRSECTOR ($90). 
 ;
 ; $93      HUNTSECTOR
 ;
 ;          Galactic Chart sector of the starbase toward which the Zylon units
 ;          are currently moving. Used values are: $00..$7F with, for example,
 ;            $00 -> NORTHWEST corner sector
 ;            $0F -> NORTHEAST corner sector
 ;            $70 -> SOUTHWEST corner sector
 ;            $7F -> SOUTHWEST corner sector
 ;
 ; $94      HUNTSECTCOLUMN
 ;
 ;          Galactic Chart sector column number of the starbase toward which the
 ;          Zylon units are currently moving. Used values are: 0..15.
 ;
 ; $95      HUNTSECTROW
 ;
 ;          Galactic Chart sector row number of the starbase toward which the
 ;          Zylon units are currently moving. Used values are: 0..7.
 ;
 ; $96..$9E NEWZYLONDIST
 ;
 ;          Table of distances between a Zylon unit and the hunted starbase when
 ;          the Zylon unit is tentatively moved in one of the 9 possible
 ;          directions NORTH, NORTHWEST, WEST, SOUTHWEST, SOUTH, SOUTHEAST, EAST,
 ;          NORTHEAST, CENTER. Used to decide into which sector the Zylon unit
 ;          should move.
 ;
 ; $9E      OLDZYLONDIST
 ;
 ;          Current distance between the Zylon unit and the hunted starbase.
 ;
 ; $9F      HUNTTIM
 ;
 ;          Delay timer for Zylon units to decide on which starbase to hunt. It
 ;          counts down from 7. It is decremented every game loop iteration. When
 ;          the timer falls below 0 the Zylon units re-decide toward which
 ;          starbase to move.
 ;
 ; $A0      BLIPCOLUMN
 ;
 ;          Top-left screen pixel column number of blip shape displayed in the
 ;          Attack Computer Display. Used in subroutine UPDATTCOMP ($A7BF). Used
 ;          values are: 120..142.
 ;
 ; $A1      BLIPROW
 ;
 ;          Top-left screen pixel row number of blip shape displayed in the
 ;          Attack Computer Display. Used in subroutine UPDATTCOMP ($A7BF). Used
 ;          values are: 71..81.
 ;
 ; $A2      BLIPCYCLECNT
 ;
 ;          Blip cycle counter. It controls drawing the blip shape in the Attack
 ;          Computer Display. Its value is incremented every game loop iteration.
 ;          Used in subroutine UPDATTCOMP ($A7BF). Used values are:
 ;            $00..$04 -> Draw 0..4th row of blip shape
 ;            $05..$09 -> Do not draw blip shape (delay)
 ;            $0A      -> Recalculate blip shape position, erase Attack Computer
 ;                        Display
 ;
 ; $A3      ISINLOCKON
 ;
 ;          Indicates whether the tracked space object is currently in full
 ;          lock-on (horizontally and vertically centered as well as in range) in
 ;          the Attack Computer Display. If so, all lock-on markers show up on
 ;          the Attack Computer Display and our starship's launched photon
 ;          torpedoes will home in on the tracked space object. Used values are:
 ;            $00 -> Not in lock-on
 ;            $A0 -> In lock-on
 ;
 ; $A4      DIRLEN
 ;
 ;          Used to pass the direction and length of a single line to be drawn in
 ;          the PLAYFIELD. Used in subroutines DRAWLINES ($A76F), DRAWLINE
 ;          ($A782), and UPDATTCOMP ($A7BF). Used values are:
 ;            Bit B7 = 0 -> Draw right
 ;            Bit B7 = 1 -> Draw down
 ;            Bits B6..0 -> Length of line in pixels.
 ;
 ;          See also PENROW ($A5) and PENCOLUMN ($A6).
 ;
 ; $A5      PENROW
 ;
 ;          Used to pass the start screen pixel row number of the line to be
 ;          drawn in the PLAYFIELD. Used in subroutines DRAWLINES ($A76F),
 ;          DRAWLINE ($A782), and UPDATTCOMP ($A7BF).
 ;
 ; $A6      PENCOLUMN
 ;
 ;          Used to pass the start screen pixel column number of the line to be
 ;          drawn in the PLAYFIELD. Used in subroutines DRAWLINES ($A76F),
 ;          DRAWLINE ($A782), and UPDATTCOMP ($A7BF).
 ;
 ; $A7      CTRLDZYLON
 ;
 ;          Index of Zylon ship currently controlled by the game. Used in
 ;          subroutine MANEUVER ($AA79). The value is toggled every other game
 ;          loop iteration. Used values are:
 ;            $00 -> Control Zylon ship 0.
 ;            $01 -> Control Zylon ship 1.
 ;
 ; $A8      ZYLONFLPAT0
 ;
 ;          Flight pattern of Zylon ship 0. Used in subroutine MANEUVER ($AA79).
 ;          Used values are:
 ;            $00 -> Attack flight pattern "0"
 ;            $01 -> Flight pattern "1"
 ;            $04 -> Flight pattern "4"
 ;
 ; $A9      ZYLONFLPAT1
 ;
 ;          Flight pattern of Zylon ship 1. Compare ZYLONFLPAT0 ($A8).
 ;
 ; $AA      MILESTTIM0
 ;
 ;          Delay timer of the milestone velocity indices of Zylon ship 0. Used
 ;          in subroutine MANEUVER ($AA79).
 ;
 ;          When Zylon ship 0 is active, this value is decremented every game
 ;          loop iteration. If it falls below 0 then the milestone velocity
 ;          indices of Zylon ship 0 are recalculated. When Zylon ship 0 is
 ;          controlled by the computer for the first time, the timer is set to an
 ;          initial value of 1, later to an initial value of 120.
 ;
 ; $AB      MILESTTIM1
 ;
 ;          Delay timer of the milestone velocity index vector of Zylon ship 1.
 ;          Compare MILESTTIM0 ($AA).
 ;
 ; $AC      MILESTVELINDZ0
 ;
 ;          Milestone z-velocity index of Zylon ship 0. Used in subroutine
 ;          MANEUVER ($AA79). The current z-velocity index of Zylon ship 0
 ;          ZYLONVELINDZ0 ($B2) is compared with this index and gradually
 ;          adjusted to it. Used values are: 0..15.
 ;
 ; $AD      MILESTVELINDZ1
 ;
 ;          Milestone z-velocity index of Zylon ship 1. Compare MILESTVELINDZ0
 ;          ($AC).
 ;
 ; $AE      MILESTVELINDX0
 ;
 ;          Milestone x-velocity index of Zylon ship 0. Used in subroutine
 ;          MANEUVER ($AA79). The current x-velocity index of Zylon ship 0
 ;          ZYLONVELINDX0 ($B4) is compared with this index and gradually
 ;          adjusted to it. Used values are: 0..15.
 ;
 ; $AF      MILESTVELINDX1
 ;
 ;          Milestone x-velocity index of Zylon ship 1. Compare MILESTVELINDX0
 ;          ($AE).
 ;
 ; $B0      MILESTVELINDY0
 ;
 ;          Milestone y-velocity index of Zylon ship 0. Used in subroutine
 ;          MANEUVER ($AA79). The current y-velocity index of Zylon ship 0
 ;          ZYLONVELINDY0 ($B6) is compared with this index and gradually
 ;          adjusted to it. Used values are: 0..15.
 ;
 ; $B1      MILESTVELINDY1
 ;
 ;          Milestone y-velocity index of Zylon ship 1. Compare MILESTVELINDY0
 ;          ($B0).
 ;
 ; $B2      ZYLONVELINDZ0
 ;
 ;          Current z-velocity index of Zylon ship 0. Used in subroutine MANEUVER
 ;          ($AA79). It indexes velocity values in ZYLONVELTAB ($BF99). Used
 ;          values are: 0..15.
 ;
 ; $B3      ZYLONVELINDZ1
 ;
 ;          Current z-velocity index of Zylon ship 1. Compare ZYLONVELINDZ0
 ;          ($B2).
 ;
 ; $B4      ZYLONVELINDX0
 ;
 ;          Current x-velocity index of Zylon ship 0. Compare ZYLONVELINDZ0
 ;          ($B2).
 ;
 ; $B5      ZYLONVELINDX1
 ;
 ;          Current x-velocity index of Zylon ship 1. Compare ZYLONVELINDZ0
 ;          ($B2).
 ;
 ; $B6      ZYLONVELINDY0
 ;
 ;          Current y-velocity index of Zylon ship 0. Compare ZYLONVELINDZ0
 ;          ($B2).
 ;
 ; $B7      ZYLONVELINDY1
 ;
 ;          Current y-velocity index of Zylon ship 1. Compare ZYLONVELINDZ0
 ;          ($B2).
 ;
 ; $B8      ISBACKATTACK0
 ;
 ;          Indicates whether Zylon ship 0 will attack our starship from the
 ;          back. Used in subroutine MANEUVER ($AA79). Used values are:
 ;            $00 -> Zylon ship 0 attacks from the front of our starship
 ;            $01 -> Zylon ship 0 attacks from the front and back of our starship
 ;
 ; $B9      ISBACKATTACK1
 ;
 ;          Indicates whether Zylon ship 1 will attack our starship from the
 ;          back. Compare ISBACKATTACK0 ($B8).
 ;
 ; $BA      ZYLONTIMX0
 ;
 ;          Delay timer of the x-velocity index of Zylon ship 0. Used in
 ;          subroutine MANEUVER ($AA79). It is decremented every game loop
 ;          iteration. When the timer value falls below 0 the current velocity
 ;          index ZYLONVELINDX0 ($B4) is adjusted depending on the current
 ;          joystick position. The new timer value is set depending on the
 ;          resulting new x-velocity index. Used values are: 0, 2, 4, ..., 14.
 ;
 ; $BB      ZYLONTIMX1
 ;
 ;          Delay timer of x-velocity index of Zylon ship 1. Compare ZYLONTIMX0
 ;          ($BA).
 ;
 ; $BC      ZYLONTIMY0
 ;
 ;          Delay timer of y-velocity index of Zylon ship 0. Compare ZYLONTIMX0
 ;          ($BA).
 ;
 ; $BD      ZYLONTIMY1
 ;
 ;          Delay timer of y-velocity index of Zylon ship 1. Compare ZYLONTIMX0
 ;          ($BA).
 ;
 ; $BE      TORPEDODELAY
 ;
 ;          After a Zylon photon torpedo has hit our starship this delay timer is
 ;          initialized to a value of 2. It is decremented every game loop
 ;          iteration and so delays the launch of the next Zylon photon torpedo
 ;          for 2 game loop iterations.
 ;
 ; $BF      ZYLONATTACKER
 ;
 ;          Index of the Zylon ship that launched the Zylon photon torpedo. It is
 ;          used in GAMELOOP ($A1F3) to override the current tracking computer
 ;          settings in order to track this Zylon ship first. Used values are:
 ;            $00 -> Zylon photon torpedo was launched by Zylon ship 0
 ;            $01 -> Zylon photon torpedo was launched by Zylon ship 1
 ;
 ; $C0      WARPSTATE
 ;
 ;          Hyperwarp state. Used values are:
 ;            $00 -> Hyperwarp not engaged
 ;            $7F -> Hyperwarp engaged
 ;            $FF -> In hyperspace
 ;
 ; $C1      VELOCITYHI
 ;
 ;          Our starship's velocity (high byte) in <KM/H>. Used values are:
 ;            $00 -> Not in hyperspace (regular cruise or accelerating to
 ;                   hyperspace velocity)
 ;            $01 -> Hyperspace velocity
 ;
 ;          See also VELOCITYLO ($70). 
 ;
 ; $C2      TRAILDELAY
 ;
 ;          Delay timer to create the next star trail. Its value is decremented
 ;          from 3 to 0 every game loop iteration during the hyperwarp STAR TRAIL
 ;          PHASE in subroutine INITTRAIL ($A9B4).
 ;
 ; $C3      TRAILIND
 ;
 ;          Position vector index of the star trail's first star. Used in
 ;          subroutine INITTRAIL ($A9B4) to initialize a star trail, which is
 ;          then displayed during the hyperwarp STAR TRAIL PHASE. Used values
 ;          are: 17..48 in wrap-around fashion.
 ;
 ; $C4      WARPTEMPCOLUMN
 ;
 ;          Temporary arrival column number of our starship on the Galactic Chart
 ;          at the beginning of hyperspace. It is given in Player/Missile pixels
 ;          relative to the left Galactic Chart border. Divide this value by 8 to
 ;          get the sector column number. Used values are: $00..$7F. See also
 ;          WARPARRVCOLUMN ($8F).
 ;
 ; $C5      WARPTEMPROW
 ;
 ;          Temporary arrival row number of our starship on the Galactic Chart at
 ;          the beginning of hyperspace. It is given in Player/Missile pixels
 ;          relative to top Galactic Chart border. Divide this value by 16 to get
 ;          the sector row number.  Used values are: $00..$7F. See also
 ;          WARPARRVROW ($8E).
 ;
 ; $C6      VEERMASK
 ;
 ;          Limits the veer-off velocity of the Hyperwarp Target Marker during
 ;          the hyperwarp ACCELERATION PHASE in subroutine HYPERWARP ($A89B).
 ;          Values are picked from table VEERMASKTAB ($BED7).
 ;
 ;          Also used as a local variable.
 ;
 ; $C7      VICINITYMASK
 ;
 ;          Mask to confine space objects' position vector components
 ;          (coordinates) in a sector into a certain interval around our starship
 ;          after its arrival from hyperspace. Values are picked from table
 ;          VICINITYMASKTAB ($BFB3).
 ;
 ; $C8      JOYSTICKX
 ;
 ;          Horizontal joystick direction. Values are picked from table
 ;          STICKINCTAB ($BAF5). Used values are:
 ;            $01 -> Right
 ;            $00 -> Centered
 ;            $FF -> Left
 ;
 ; $C9      JOYSTICKY
 ;
 ;          Vertical joystick direction. Values are picked from table STICKINCTAB
 ;          ($BAF5). Used values are:
 ;            $01 -> Up
 ;            $00 -> Centered 
 ;            $FF -> Down
 ;
 ; $CA      KEYCODE
 ;
 ;          Hardware keyboard code of the pressed key on the keyboard. Shift and
 ;          Control key bits B7..6 are always set.
 ;
 ; $CB..$CC SCORE
 ;
 ;          Internal 16-bit score of the game in low byte-high byte order
 ;
 ; $CD      SCOREDRANKIND
 ;
 ;          Scored Rank Index. It is translated with table RANKTAB ($BEE9) to a
 ;          title phrase offset pointing to the rank string. Used values are: 
 ;            $00 -> GALACTIC COOK
 ;            $01 -> GARBAGE SCOW CAPTAIN
 ;            $02 -> GARBAGE SCOW CAPTAIN
 ;            $03 -> ROOKIE
 ;            $04 -> ROOKIE
 ;            $05 -> NOVICE
 ;            $06 -> NOVICE
 ;            $07 -> ENSIGN
 ;            $08 -> ENSIGN
 ;            $09 -> PILOT
 ;            $0A -> PILOT
 ;            $0B -> ACE
 ;            $0C -> LIEUTENANT
 ;            $0D -> WARRIOR
 ;            $0E -> CAPTAIN
 ;            $0F -> COMMANDER
 ;            $10 -> COMMANDER
 ;            $11 -> STAR COMMANDER
 ;            $12 -> STAR COMMANDER
 ;
 ; $CE      SCOREDCLASSIND
 ;
 ;          Scored Class Index. It is translated into a class number with table
 ;          CLASSTAB ($BEFC). Used values are:
 ;            $00 -> Class 5
 ;            $01 -> Class 5
 ;            $02 -> Class 5
 ;            $03 -> Class 4
 ;            $04 -> Class 4
 ;            $05 -> Class 4
 ;            $06 -> Class 4
 ;            $07 -> Class 3
 ;            $08 -> Class 3
 ;            $09 -> Class 3
 ;            $0A -> Class 2
 ;            $0B -> Class 2
 ;            $0C -> Class 2
 ;            $0D -> Class 1
 ;            $0E -> Class 1
 ;            $0F -> Class 1
 ;
 ; $CF      TITLELIFE
 ;
 ;          Lifetime of title line. It is decremented every game loop iteration.
 ;          Used initial values are:
 ;            $3C -> When displaying regular title phrases
 ;            $FE -> When displaying "STARBASE SURROUNDED", "STARBASE DESTOYED",
 ;                   and "RED ALERT" messages
 ;            $FF -> Hide title line
 ;
 ; $D0      SHIPVIEW
 ;
 ;          Current view of our starship. Values are picked from table
 ;          VIEWMODETAB ($BE22). Used values are:
 ;            $00 -> Front view
 ;            $01 -> Aft view
 ;            $40 -> Long-Range Scan view
 ;            $80 -> Galactic Chart view
 ;
 ; $D1      TITLEPHR
 ;
 ;          Title phrase offset for text phrase in title line. Used values are:
 ;            $00..$7B -> Title phrase offset into PHRASETAB ($BBAA)
 ;            $FF      -> Hide title line
 ;
 ;          See also NEWTITLEPHR ($65). 
 ;
 ; $D2      BEEPFRQIND
 ;
 ;          Beeper sound pattern: Running index into frequency table BEEPFRQTAB
 ;          ($BF5C). See also BEEPFRQSTART ($D7). See also subroutines BEEP
 ;          ($B3A6) and SOUND ($B2AB).
 ;
 ; $D3      BEEPREPEAT
 ;
 ;          Beeper sound pattern: Number of times the beeper sound pattern is
 ;          repeated - 1. See also subroutines BEEP ($B3A6) and SOUND ($B2AB).
 ;
 ; $D4      BEEPTONELIFE
 ;
 ;          Beeper sound pattern: Lifetime of tone in TICKs - 1. See also
 ;          subroutines BEEP ($B3A6) and SOUND ($B2AB).
 ;
 ; $D5      BEEPPAUSELIFE
 ;
 ;          Beeper sound pattern: Lifetime of pause in TICKs - 1. Used values
 ;          are: 
 ;            < $FF -> Number of TICKs - 1 to play
 ;              $FF -> Skip playing pause
 ;
 ;          See also subroutines BEEP ($B3A6) and SOUND ($B2AB).
 ;
 ; $D6      BEEPPRIORITY
 ;
 ;          Beeper sound pattern: Pattern priority. Each beeper sound pattern has
 ;          a priority. When a pattern of higher priority is about to be played
 ;          the pattern that is currently playing is stopped. Used values are:
 ;              $00 -> No pattern playing at the moment
 ;            > $00 -> Pattern priority
 ;
 ;          See also subroutines BEEP ($B3A6) and SOUND ($B2AB).
 ;
 ; $D7      BEEPFRQSTART
 ;
 ;          Beeper sound pattern: Index to first byte of the pattern frequency in
 ;          table BEEPFRQTAB ($BF5C). See also BEEPFRQIND ($D2). See also
 ;          subroutines BEEP ($B3A6) and SOUND ($B2AB).
 ;
 ; $D8      BEEPLIFE
 ;
 ;          Beeper sound pattern: Lifetime of the current tone or pause in TICKs.
 ;          It is decremented every TICK. See also subroutines BEEP ($B3A6) and
 ;          SOUND ($B2AB). 
 ;
 ; $D9      BEEPTOGGLE
 ;
 ;          Beeper sound pattern: Indicates that either a tone or a pause is
 ;          currently played. Used values are:
 ;            $00 -> Tone
 ;            $01 -> Pause
 ;
 ;          See also subroutines BEEP ($B3A6) and SOUND ($B2AB).    
 ;
 ; $DA      NOISETORPTIM
 ;
 ;          Noise sound pattern: Delay timer for PHOTON TORPEDO LAUNCHED noise
 ;          sound pattern. It is decremented every TICK. See also subroutines
 ;          NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $DB      NOISEEXPLTIM
 ;
 ;          Noise sound pattern: Delay timer for SHIELD EXPLOSION and ZYLON
 ;          EXPLOSION noise sound pattern. It is decremented every TICK. See also
 ;          subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $DC      NOISEAUDC2
 ;
 ;          Noise sound pattern: Audio channel 1/2 control shadow register. See
 ;          also subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $DD      NOISEAUDC3
 ;
 ;          Noise sound pattern: Audio channel 3 control shadow register. See
 ;          also subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $DE      NOISEAUDF1
 ;
 ;          Noise sound pattern: Audio channel 1 frequency shadow register. See
 ;          also subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $DF      NOISEAUDF2
 ;
 ;          Noise sound pattern: Audio channel 2 frequency shadow register. See
 ;          also subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $E0      NOISEFRQINC
 ;
 ;          Noise sound pattern: Audio channel 1/2 frequency increment. See also
 ;          subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $E1      NOISELIFE
 ;
 ;          Noise sound pattern: Noise sound pattern lifetime. It is decremented
 ;          every TICK. See also subroutines NOISE ($AEA8) and SOUND ($B2AB).
 ;
 ; $E2      NOISEZYLONTIM
 ;
 ;          Delay timer to trigger the ZYLON EXPLOSION noise sound pattern. It is
 ;          set in subroutine COLLISION ($AF3D) when an impact of one of our
 ;          starship's photon torpedoes into a target is imminent. The timer is
 ;          decremented every TICK during the execution of the Vertical Blank
 ;          Interrupt handler VBIHNDLR ($A6D1). When the timer value reaches 0
 ;          the ZYLON EXPLOSION noise sound pattern is played in subroutine SOUND
 ;          ($B2AB). 
 ;
 ; $E3      NOISEHITLIFE
 ;
 ;          Lifetime of STARSHIP EXPLOSION noise when our starship was destroyed
 ;          by a Zylon photon torpedo. It is set in routine GAMELOOP ($A1F3) to a
 ;          value of 64 TICKs. It is decremented every TICK during the execution
 ;          of the Vertical Blank Interrupt handler VBIHNDLR ($A6D1).
 ;
 ; $E4      PL0SHAPOFF
 ;
 ;          PLAYER0 offset into shape table PLSHAP2TAB ($B9B1)
 ;
 ; $E5      PL1SHAPOFF
 ;
 ;          PLAYER1 offset into shape table PLSHAP2TAB ($B9B1)
 ;
 ; $E6      PL2SHAPOFF
 ;
 ;          PLAYER2 offset into shape table PLSHAP1TAB ($B8E4)
 ;
 ; $E7      PL3SHAPOFF
 ;
 ;          PLAYER3 offset into shape table PLSHAP1TAB ($B8E4)
 ;
 ; $E8      PL4SHAPOFF
 ;
 ;          PLAYER4 offset into shape table PLSHAP1TAB ($B8E4)
 ;
 ; $E9      PL0LIFE
 ;
 ;          Lifetime of the space object represented by PLAYER0 (usually Zylon
 ;          ship 0). Any value other than $FF is decremented with every game loop
 ;          iteration. Used values are:
 ;            $00      -> Space object not alive (= not in use)
 ;            $01..$FE -> Values during lifetime countdown
 ;            $FF      -> Infinite lifetime (not counted down)
 ;
 ; $EA      PL1LIFE
 ;
 ;          Lifetime of a space object represented by PLAYER1 (usually Zylon ship
 ;          1). Compare PL0LIFE ($E9).
 ;
 ; $EB      PL2LIFE
 ;
 ;          Lifetime of a space object represented by PLAYER2 (usually the Zylon
 ;          photon torpedo). Compare PL0LIFE ($E9).
 ;
 ;          If this PLAYER represents a photon torpedo, its lifetime is
 ;          decremented from an initial value of $FF.
 ;
 ; $EC      PL3LIFE
 ;
 ;          Lifetime of a space object represented by PLAYER3 (usually our
 ;          starship's photon torpedo 0). Compare PL2LIFE ($EB).
 ;
 ;          If this PLAYER represents a photon torpedo, its lifetime is
 ;          decremented from an initial value of $FF.
 ;
 ; $ED      PL4LIFE
 ;
 ;          Lifetime of a space object represented by PLAYER4 (usually our
 ;          starship's photon torpedo 1). Compare PL2LIFE ($EB).
 ;
 ;          If this PLAYER represents a photon torpedo, its lifetime is
 ;          decremented from an initial value of $FF.
 ;
 ; $EE      PL0COLOR
 ;
 ;          Color of PLAYER0
 ;
 ; $EF      PL1COLOR
 ;
 ;          Color of PLAYER1
 ;
 ; $F0      PL2COLOR
 ;
 ;          Color of PLAYER2
 ;
 ; $F1      PL3COLOR
 ;
 ;          Color of PLAYER3
 ;
 ; $F2      PF0COLOR
 ;
 ;          Color of PLAYFIELD0
 ;
 ; $F3      PF1COLOR
 ;
 ;          Color of PLAYFIELD1
 ;
 ; $F4      PF2COLOR
 ;
 ;          Color of PLAYFIELD2
 ;
 ; $F5      PF3COLOR
 ;
 ;          Color of PLAYFIELD3
 ;
 ; $F6      BGRCOLOR
 ;
 ;          Color of BACKGROUND
 ;
 ; $F7      PF0COLORDLI
 ;
 ;          Color of PLAYFIELD0 after DLI
 ;
 ; $F8      PF1COLORDLI
 ;
 ;          Color of PLAYFIELD1 after DLI
 ;
 ; $F9      PF2COLORDLI
 ;
 ;          Color of PLAYFIELD2 after DLI
 ;
 ; $FA      PF3COLORDLI
 ;
 ;          Color of PLAYFIELD3 after DLI
 ;
 ; $FB      BGRCOLORDLI
 ;
 ;          Color of BACKGROUND after DLI
 ;
 ; $0280..$02E9 DSPLST
 ;
 ;              Display List
 ;
 ; $0300..$03FF PL4DATA
 ;
 ;              PLAYER4 data area
 ;
 ; $0400..$04FF PL0DATA
 ;
 ;              PLAYER0 data area
 ;
 ; $0500..$05FF PL1DATA
 ;
 ;              PLAYER1 data area
 ;
 ; $0600..$06FF PL2DATA
 ;
 ;              PLAYER2 data area
 ;
 ; $0700..$07FF PL3DATA
 ;
 ;              PLAYER3 data area
 ;
 ; $0800..$0863 PFMEMROWLO
 ;
 ;              Lookup table of start addresses (low byte) for each row of
 ;              PLAYFIELD memory, which is located at PFMEM ($1000). The table
 ;              contains 100 bytes for 100 rows (of which only 99 are shown by
 ;              the Display List, the PLAYFIELD is 160 x 99 pixels). The
 ;              addresses grow in increments of 40 (40 bytes = 160 pixels in
 ;              GRAPHICS7 mode = 1 PLAYFIELD row of pixels). See also PFMEMROWHI
 ;              ($0864).
 ;
 ; $0864..$08C7 PFMEMROWHI
 ;
 ;              Lookup table of start addresses (high byte) of each row of
 ;              PLAYFIELD memory. See also PFMEMROWLO ($0800).
 ;
 ; $08C9..$0948 GCMEMMAP
 ;
 ;              Galactic Chart memory map (16 columns x 8 rows = 128 bytes)
 ;
 ; $0949..$0970 PANELTXT
 ;
 ;              Memory of Control Panel Display (bottom text window) in Front
 ;              view, Aft view, and Long-Range Scan view (20 characters x 2 rows
 ;              = 40 bytes).
 ;
 ; $094A        VELOCD1
 ;
 ;              First digit (of 2) of the VELOCITY readout in Control Panel
 ;              Display memory.
 ;
 ; $0950        KILLCNTD1
 ;
 ;              First digit (of 2) of the KILL COUNTER readout in Control Panel
 ;              Display memory.
 ;
 ; $0955        ENERGYD1
 ;
 ;              First digit (of 4) of the ENERGY readout in Control Panel Display
 ;              memory.
 ;
 ; $095A        TRACKC1
 ;
 ;              Character of the TRACKING readout 'T' or 'C' in Control Panel
 ;              Display memory.
 ;
 ; $095C        TRACKDIGIT
 ;
 ;              Digit of the TRACKING readout in Control Panel Display memory. It
 ;              is used to store the index of the currently tracked space object.
 ;              Used values are:
 ;                $00 -> Track Zylon ship 0
 ;                $01 -> Track Zylon ship 1
 ;                $02 -> Track starbase
 ;                $03 -> Track Hyperwarp Target Marker
 ;
 ; $0960        THETAC1
 ;
 ;              First character of the THETA readout in Control Panel Display
 ;              memory.
 ;
 ; $0966        PHIC1
 ;
 ;              First character of the PHI readout in Control Panel Display
 ;              memory.
 ;
 ; $096C        RANGEC1
 ;
 ;              First character of the RANGE readout in Control Panel Display
 ;              memory.
 ;
 ; $0971..$09AC GCTXT
 ;
 ;              Memory of Galactic Chart Panel Display (bottom text window) of
 ;              Galactic Chart view (20 characters x 3 rows = 60 bytes).
 ;
 ; $097D        GCWARPD1
 ;
 ;              First digit (of 4) of the HYPERWARP ENERGY readout in Galactic
 ;              Chart Panel Display memory.
 ;
 ; $098D        GCTRGCNT
 ;
 ;              First target counter digit (of 2) in Galactic Chart Panel Display
 ;              memory.
 ;
 ; $0992        GCSTATPHO
 ;
 ;              Photon Torpedo status letter in Galactic Chart Panel Display
 ;              memory. Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $0993        GCSTATENG
 ;
 ;              Engines status letter in Galactic Chart Panel Display memory.
 ;              Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $0994        GCSTATSHL
 ;
 ;              Shields status letter in Galactic Chart Panel Display memory.
 ;              Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $0995        GCSTATCOM
 ;
 ;              Attack Computer status letter in Galactic Chart Panel Display
 ;              memory. Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $0996        GCSTATLRS
 ;
 ;              Long-Range Scan status letter in Galactic Chart Panel Display
 ;              memory. Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $0997        GCSTATRAD
 ;
 ;              Subspace Radio status letter in Galactic Chart Panel Display
 ;              memory. Used values are:
 ;                %00****** -> OK
 ;                %10****** -> Destroyed
 ;                %11****** -> Damaged
 ;
 ; $09A3        GCSTARDAT
 ;
 ;              First (of 5) digits of the star date clock in the Galactic Chart
 ;              Panel Display memory.
 ;
 ; $09AD..$09DD ZPOSSIGN
 ;
 ;              Table containing the sign bit (B16) of position vector
 ;              z-components (z-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). Used values
 ;              are:
 ;                $00 -> Negative sign (behind our starship)
 ;                $01 -> Positive sign (in front of our starship)
 ;
 ;              See also "ON POSITION VECTORS".
 ;
 ; $09AD        PL0ZPOSSIGN
 ;
 ;              Sign bit (B16) of position vector z-component (z-coordinate) of
 ;              PLAYER0. Compare ZPOSSIGN ($09AD). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09AE        PL1ZPOSSIGN
 ;
 ;              Sign bit (B16) of position vector z-component (z-coordinate) of
 ;              PLAYER1. Compare ZPOSSIGN ($09AD). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09AF        PL2ZPOSSIGN
 ;
 ;              Sign bit (B16) of position vector z-component (z-coordinate) of
 ;              PLAYER2. Compare ZPOSSIGN ($09AD). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09B0        PL3ZPOSSIGN
 ;
 ;              Sign bit (B16) of position vector z-component (z-coordinate) of
 ;              PLAYER3. Compare ZPOSSIGN ($09AD). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09B1        PL4ZPOSSIGN
 ;
 ;              Sign bit (B16) of position vector z-component (z-coordinate) of
 ;              PLAYER4. Compare ZPOSSIGN ($09AD). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09DE..$0A0E XPOSSIGN
 ;
 ;              Table containing the sign bit (B16) of position vector
 ;              x-components (x-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). Used values
 ;              are:
 ;                $00 -> Negative sign (left)
 ;                $01 -> Positive sign (right)
 ;
 ;              See also "ON POSITION VECTORS".
 ;
 ; $09DE        PL0XPOSSIGN
 ;
 ;              Sign bit (B16) of position vector x-component (x-coordinate) of
 ;              PLAYER0. Compare XPOSSIGN ($09DE). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09DF        PL1XPOSSIGN
 ;
 ;              Sign bit (B16) of position vector x-component (x-coordinate) of
 ;              PLAYER1. Compare XPOSSIGN ($09DE). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09E0        PL2XPOSSIGN
 ;
 ;              Sign bit (B16) of position vector x-component (x-coordinate) of
 ;              PLAYER2. Compare XPOSSIGN ($09DE). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09E1        PL3XPOSSIGN
 ;
 ;              Sign bit (B16) of position vector x-component (x-coordinate) of
 ;              PLAYER3. Compare XPOSSIGN ($09DE). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $09E2        PL4XPOSSIGN
 ;
 ;              Sign bit (B16) of position vector x-component (x-coordinate) of
 ;              PLAYER4. Compare XPOSSIGN ($09DE). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A0F..$0A3F YPOSSIGN
 ;
 ;              Table containing the sign bit (B16) of position vector
 ;              y-components (y-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). Used values
 ;              are:
 ;                $00 -> Negative sign (down)
 ;                $01 -> Positive sign (up)
 ;
 ;              See also "ON POSITION VECTORS".
 ;
 ; $0A0F        PL0YPOSSIGN
 ;
 ;              Sign bit (B16) of position vector y-component (y-coordinate) of
 ;              PLAYER0. Compare YPOSSIGN ($0A0F). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A10        PL1YPOSSIGN
 ;
 ;              Sign bit (B16) of position vector y-component (y-coordinate) of
 ;              PLAYER1. Compare YPOSSIGN ($0A0F). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A11        PL2YPOSSIGN
 ;
 ;              Sign bit (B16) of position vector y-component (y-coordinate) of
 ;              PLAYER2. Compare YPOSSIGN ($0A0F). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A12        PL3YPOSSIGN
 ;
 ;              Sign bit (B16) of position vector y-component (y-coordinate) of
 ;              PLAYER3. Compare YPOSSIGN ($0A0F). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A13        PL4YPOSSIGN
 ;
 ;              Sign bit (B16) of position vector y-component (y-coordinate) of
 ;              PLAYER4. Compare YPOSSIGN ($0A0F). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A40..$0A70 ZPOSHI
 ;
 ;              Table containing the high byte (B15..8) of position vector
 ;              y-components (y-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0A40        PL0ZPOSHI
 ;
 ;              High byte (B15..8) of position vector z-component (z-coordinate)
 ;              of PLAYER0. Compare ZPOSHI ($0A40). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A41        PL1ZPOSHI
 ;
 ;              High byte (B15..8) of position vector z-component (z-coordinate)
 ;              of PLAYER1. Compare ZPOSHI ($0A40). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A42        PL2ZPOSHI
 ;
 ;              High byte (B15..8) of position vector z-component (z-coordinate)
 ;              of PLAYER2. Compare ZPOSHI ($0A40). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A43        PL3ZPOSHI
 ;
 ;              High byte (B15..8) of position vector z-component (z-coordinate)
 ;              of PLAYER3. Compare ZPOSHI ($0A40). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A44        PL4ZPOSHI
 ;
 ;              High byte (B15..8) of position vector z-component (z-coordinate)
 ;              of PLAYER4. Compare ZPOSHI ($0A40). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A71..$0AA1 XPOSHI
 ;
 ;              Table containing the high byte (B15..8) of position vector
 ;              x-components (x-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0A71        PL0XPOSHI
 ;
 ;              High byte (B15..8) of position vector x-component (x-coordinate)
 ;              of PLAYER0. Compare XPOSHI ($0A71). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A72        PL1XPOSHI
 ;
 ;              High byte (B15..8) of position vector x-component (x-coordinate)
 ;              of PLAYER1. Compare XPOSHI ($0A71). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A73        PL2XPOSHI
 ;
 ;              High byte (B15..8) of position vector x-component (x-coordinate)
 ;              of PLAYER2. Compare XPOSHI ($0A71). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A74        PL3XPOSHI
 ;
 ;              High byte (B15..8) of position vector x-component (x-coordinate)
 ;              of PLAYER3. Compare XPOSHI ($0A71). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0A75        PL4XPOSHI
 ;
 ;              High byte (B15..8) of position vector x-component (x-coordinate)
 ;              of PLAYER4. Compare XPOSHI ($0A71). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AA2..$0AD2 YPOSHI
 ;
 ;              Table containing the high byte (B15..8) of position vector
 ;              y-components (y-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0AA2        PL0YPOSHI
 ;
 ;              High byte (B15..8) of position vector y-component (y-coordinate)
 ;              of PLAYER0. Compare YPOSHI ($0AA2). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AA3        PL1YPOSHI
 ;
 ;              High byte (B15..8) of position vector y-component (y-coordinate)
 ;              of PLAYER1. Compare YPOSHI ($0AA2). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AA4        PL2YPOSHI
 ;
 ;              High byte (B15..8) of position vector y-component (y-coordinate)
 ;              of PLAYER2. Compare YPOSHI ($0AA2). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AA5        PL3YPOSHI
 ;
 ;              High byte (B15..8) of position vector y-component (y-coordinate)
 ;              of PLAYER3. Compare YPOSHI ($0AA2). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AA6        PL4YPOSHI
 ;
 ;              High byte (B15..8) of position vector y-component (y-coordinate)
 ;              of PLAYER4. Compare YPOSHI ($0AA2). See also "ON POSITION
 ;              VECTORS".
 ;
 ; $0AD3..$0B03 ZPOSLO
 ;
 ;              Table containing the low byte (B7..0) of position vector
 ;              z-components (z-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0AD3        PL0ZPOSLO
 ;
 ;              Low byte (B7..0) of position vector z-component (z-coordinate) of
 ;              PLAYER0. Compare ZPOSLO ($0AD3). See also "ON POSITION VECTORS".
 ;
 ; $0AD4        PL1ZPOSLO
 ;
 ;              Low byte (B7..0) of position vector z-component (z-coordinate) of
 ;              PLAYER1. Compare ZPOSLO ($0AD3). See also "ON POSITION VECTORS".
 ;
 ; $0AD5        PL2ZPOSLO
 ;
 ;              Low byte (B7..0) of position vector z-component (z-coordinate) of
 ;              PLAYER2. Compare ZPOSLO ($0AD3). See also "ON POSITION VECTORS".
 ;
 ; $0AD6        PL3ZPOSLO
 ;
 ;              Low byte (B7..0) of position vector z-component (z-coordinate) of
 ;              PLAYER3. Compare ZPOSLO ($0AD3). See also "ON POSITION VECTORS".
 ;
 ; $0AD7        PL4ZPOSLO
 ;
 ;              Low byte (B7..0) of position vector z-component (z-coordinate) of
 ;              PLAYER4. Compare ZPOSLO ($0AD3). See also "ON POSITION VECTORS".
 ;
 ; $0B04..$0B34 XPOSLO
 ;
 ;              Table containing the low byte (B7..0) of position vector
 ;              x-components (x-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0B04        PL0XPOSLO
 ;
 ;              Low byte (B7..0) of position vector x-component (x-coordinate) of
 ;              PLAYER0. Compare XPOSLO ($0B04). See also "ON POSITION VECTORS".
 ;
 ; $0B05        PL1XPOSLO
 ;
 ;              Low byte (B7..0) of position vector x-component (x-coordinate) of
 ;              PLAYER1. Compare XPOSLO ($0B04). See also "ON POSITION VECTORS".
 ;
 ; $0B06        PL2XPOSLO
 ;
 ;              Low byte (B7..0) of position vector x-component (x-coordinate) of
 ;              PLAYER2. Compare XPOSLO ($0B04). See also "ON POSITION VECTORS".
 ;
 ; $0B07        PL3XPOSLO
 ;
 ;              Low byte (B7..0) of position vector x-component (x-coordinate) of
 ;              PLAYER3. Compare XPOSLO ($0B04). See also "ON POSITION VECTORS".
 ;
 ; $0B08        PL4XPOSLO
 ;
 ;              Low byte (B7..0) of position vector x-component (x-coordinate) of
 ;              PLAYER4. Compare XPOSLO ($0B04). See also "ON POSITION VECTORS".
 ;
 ; $0B35..$0B65 YPOSLO
 ;
 ;              Table containing the low byte (B7..0) of position vector
 ;              y-components (y-coordinate) (49 bytes). Bytes 0..4 belong to
 ;              position vectors of PLAYER space objects (Zylon ships, photon
 ;              torpedoes, etc.). Bytes 5..48 belong to position vectors of
 ;              PLAYFIELD space objects (stars, explosion fragments). See also
 ;              "ON POSITION VECTORS".
 ;
 ; $0B35        PL0YPOSLO
 ;
 ;              Low byte (B7..0) of position vector y-component (y-coordinate) of
 ;              PLAYER0. Compare YPOSLO ($0B35). See also "ON POSITION VECTORS". 
 ;
 ; $0B36        PL1YPOSLO
 ;
 ;              Low byte (B7..0) of position vector y-component (y-coordinate) of
 ;              PLAYER1. Compare YPOSLO ($0B35). See also "ON POSITION VECTORS".
 ;
 ; $0B37        PL2YPOSLO
 ;
 ;              Low byte (B7..0) of position vector y-component (y-coordinate) of
 ;              PLAYER2. Compare YPOSLO ($0B35). See also "ON POSITION VECTORS".
 ;
 ; $0B38        PL3YPOSLO
 ;
 ;              Low byte (B7..0) of position vector y-component (y-coordinate) of
 ;              PLAYER3. Compare YPOSLO ($0B35). See also "ON POSITION VECTORS".
 ;
 ; $0B39        PL4YPOSLO
 ;
 ;              Low byte (B7..0) of position vector y-component (y-coordinate) of
 ;              PLAYER4. Compare YPOSLO ($0B35). See also "ON POSITION VECTORS".
 ;
 ; $0B66..$0B96 ZVEL
 ;
 ;              Table containing velocity vector z-components (z-velocities) (49
 ;              bytes). Bytes 0..4 belong to velocity vectors of PLAYER space
 ;              objects (Zylon ships, photon torpedoes, etc.). Bytes 5..48 belong
 ;              to velocity vectors of PLAYFIELD space objects (stars, explosion
 ;              fragments). Each z-velocity is stored in the binary format
 ;              %sxxxxxxx where
 ;                %s = 0   -> Positive sign (moving in flight direction)
 ;                %s = 1   -> Negative sign (moving in reverse flight direction)
 ;                %xxxxxxx -> Unsigned 7-bit velocity value in <KM/H>
 ;
 ;              See also "ON VELOCITY VECTORS".
 ;
 ; $0B66        PL0ZVEL
 ;
 ;              Velocity vector z-component (z-velocity) of PLAYER0. Compare ZVEL
 ;              ($0B66). See also "ON VELOCITY VECTORS".
 ;
 ; $0B67        PL1ZVEL
 ;
 ;              Velocity vector z-component (z-velocity) of PLAYER1. Compare ZVEL
 ;              ($0B66). See also "ON VELOCITY VECTORS".
 ;
 ; $0B68        PL2ZVEL
 ;
 ;              Velocity vector z-component (z-velocity) of PLAYER2. Compare ZVEL
 ;              ($0B66). See also "ON VELOCITY VECTORS".
 ;
 ; $0B69        PL3ZVEL
 ;
 ;              Velocity vector z-component (z-velocity) of PLAYER3. Compare ZVEL
 ;              ($0B66). See also "ON VELOCITY VECTORS".
 ;
 ; $0B6A        PL4ZVEL
 ;
 ;              Velocity vector z-component (z-velocity) of PLAYER4. Compare ZVEL
 ;              ($0B66). See also "ON VELOCITY VECTORS".
 ;
 ; $0B97..$0BC7 XVEL
 ;
 ;              Table containing velocity vector x-components (x-velocities) (49
 ;              bytes). Bytes 0..4 belong to velocity vectors of PLAYER space
 ;              objects (Zylon ships, photon torpedoes, etc.). Bytes 5..48 belong
 ;              to velocity vectors of PLAYFIELD space objects (stars, explosion
 ;              fragments). Each x-velocity is stored in the binary format
 ;              %sxxxxxxx where
 ;                %s = 0   -> Positive sign (moving to the right)
 ;                %s = 1   -> Negative sign (moving to the left)
 ;                %xxxxxxx -> Unsigned 7-bit velocity value in <KM/H>
 ;
 ;              See also "ON VELOCITY VECTORS".
 ;
 ; $0B97        PL0XVEL
 ;
 ;              Velocity vector x-component (x-velocity) of PLAYER0. Compare XVEL
 ;              ($0B97). See also "ON VELOCITY VECTORS". 
 ;
 ; $0B98        PL1XVEL
 ;
 ;              Velocity vector x-component (x-velocity) of PLAYER1. Compare XVEL
 ;              ($0B97). See also "ON VELOCITY VECTORS".
 ;
 ; $0B99        PL2XVEL
 ;
 ;              Velocity vector x-component (x-velocity) of PLAYER2. Compare XVEL
 ;              ($0B97). See also "ON VELOCITY VECTORS".
 ;
 ; $0B9A        PL3XVEL
 ;
 ;              Velocity vector x-component (x-velocity) of PLAYER3. Compare XVEL
 ;              ($0B97). See also "ON VELOCITY VECTORS".
 ;
 ; $0B9B        PL4XVEL
 ;
 ;              Velocity vector x-component (x-velocity) of PLAYER4. Compare XVEL
 ;              ($0B97). See also "ON VELOCITY VECTORS".
 ;
 ; $0BC8..$0BF8 YVEL
 ;
 ;              Table containing velocity vector y-components (y-velocities) (49
 ;              bytes). Bytes 0..4 belong to velocity vectors of PLAYER space
 ;              objects (Zylon ships, photon torpedoes, etc.). Bytes 5..48 belong
 ;              to velocity vectors of PLAYFIELD space objects (stars, explosion
 ;              fragments). Each y-velocity is stored in the binary format
 ;              %sxxxxxxx where
 ;                %s = 0   -> Positive sign (moving up)
 ;                %s = 1   -> Negative sign (moving down)
 ;                %xxxxxxx -> Unsigned 7-bit velocity value in <KM/H>
 ;
 ;              See also "ON VELOCITY VECTORS".
 ;
 ; $0BC8        PL0YVEL
 ;
 ;              Velocity vector y-component (y-velocity) of PLAYER0. Compare YVEL
 ;              ($0BC8). See also "ON VELOCITY VECTORS". 
 ;
 ; $0BC9        PL1YVEL
 ;
 ;              Velocity vector y-component (y-velocity) of PLAYER1. Compare YVEL
 ;              ($0BC8). See also "ON VELOCITY VECTORS".
 ;
 ; $0BCA        PL2YVEL
 ;
 ;              Velocity vector y-component (y-velocity) of PLAYER2. Compare YVEL
 ;              ($0BC8). See also "ON VELOCITY VECTORS".
 ;
 ; $0BCB        PL3YVEL
 ;
 ;              Velocity vector y-component (y-velocity) of PLAYER3. Compare YVEL
 ;              ($0BC8). See also "ON VELOCITY VECTORS".
 ;
 ; $0BCC        PL4YVEL
 ;
 ;              Velocity vector y-component (y-velocity) of PLAYER4. Compare YVEL
 ;              ($0BC8). See also "ON VELOCITY VECTORS".
 ;
 ; $0BF9..$0C29 PIXELROWNEW
 ;
 ;              Table containing the new pixel row number of space objects (49
 ;              bytes). Bytes 0..4 belong to PLAYER space objects and contain
 ;              Player/Missile (PM) pixel row numbers. They are counted from
 ;              vertical PM position 0, which is offscreen. Bytes 5..48 belong to
 ;              PLAYFIELD space objects (stars, explosion fragments) and contain
 ;              PLAYFIELD pixel row numbers. They are counted from the top border
 ;              of the PLAYFIELD and have values of 0..99. See also PIXELROW
 ;              ($0C5B).
 ;
 ; $0BF9        PL0ROWNEW
 ;
 ;              New pixel row number of PLAYER0 in Player/Missile pixels. See
 ;              also PIXELROWNEW ($0BF9).
 ;
 ; $0BFA        PL1ROWNEW
 ;
 ;              New pixel row number of PLAYER1 in Player/Missile pixels. See
 ;              also PIXELROWNEW ($0BF9).
 ;
 ; $0BFB        PL2ROWNEW
 ;
 ;              New pixel row number of PLAYER2 in Player/Missile pixels. See
 ;              also PIXELROWNEW ($0BF9).
 ;
 ; $0BFC        PL3ROWNEW
 ;
 ;              New pixel row number of PLAYER3 in Player/Missile pixels. See
 ;              also PIXELROWNEW ($0BF9).
 ;
 ; $0BFD        PL4ROWNEW
 ;
 ;              New pixel row number of PLAYER4 in Player/Missile pixels. See
 ;              also PIXELROWNEW ($0BF9).
 ;
 ; $0C2A..$0C5A PIXELCOLUMN
 ;
 ;              Table containing the pixel column number of space objects (49
 ;              bytes). Bytes 0..4 belong to PLAYER space objects and contain
 ;              Player/Missile (PM) pixel column numbers. They are counted from
 ;              horizontal PM position 0, which is offscreen. Bytes 5..48 belong
 ;              to PLAYFIELD space objects (stars, explosion fragments) and
 ;              contain PLAYFIELD pixel column numbers. They are counted from the
 ;              left border of the PLAYFIELD and have values of 0..159.
 ;
 ; $0C2A        PL0COLUMN
 ;
 ;              Pixel column number of PLAYER0 in Player/Missile pixels. See also
 ;              PIXELCOLUMN ($0C2A).
 ;
 ; $0C2B        PL1COLUMN
 ;
 ;              Pixel column number of PLAYER1 in Player/Missile pixels. See also
 ;              PIXELCOLUMN ($0C2A).
 ;
 ; $0C2C        PL2COLUMN
 ;
 ;              Pixel column number of PLAYER2 in Player/Missile pixels. See also
 ;              PIXELCOLUMN ($0C2A).
 ;
 ; $0C2D        PL3COLUMN
 ;
 ;              Pixel column number of PLAYER3 in Player/Missile pixels. See also
 ;              PIXELCOLUMN ($0C2A).
 ;
 ; $0C2E        PL4COLUMN
 ;
 ;              Pixel column number of PLAYER4 in Player/Missile pixels. See also
 ;              PIXELCOLUMN ($0C2A).
 ;
 ; $0C5B..$0C8B PIXELROW
 ;
 ;              Table containing the pixel row number of space objects (49
 ;              bytes). Bytes 0..4 belong to PLAYER space objects and contain
 ;              Player/Missile (PM) pixel row numbers. They are counted from
 ;              vertical PM position 0, which is offscreen. Bytes 5..48 belong to
 ;              PLAYFIELD space objects (stars, explosion fragments) and contain
 ;              PLAYFIELD pixel row numbers. They are counted from the top border
 ;              of the PLAYFIELD and have values of 0..99. See also PIXELROWNEW
 ;              ($0BF9).
 ;
 ; $0C5B        PL0ROW
 ;
 ;              Pixel row number of PLAYER0 in Player/Missile pixels. See also
 ;              PIXELROW ($0C5B).
 ;
 ; $0C5C        PL1ROW
 ;
 ;              Pixel row number of PLAYER1 in Player/Missile pixels. See also
 ;              PIXELROW ($0C5B).
 ;
 ; $0C5D        PL2ROW
 ;
 ;              Pixel row number of PLAYER2 in Player/Missile pixels. See also
 ;              PIXELROW ($0C5B).
 ;
 ; $0C5E        PL3ROW
 ;
 ;              Pixel row number of PLAYER3 in Player/Missile pixels. See also
 ;              PIXELROW ($0C5B).
 ;
 ; $0C5F        PL4ROW
 ;
 ;              Pixel row number of PLAYER4 in Player/Missile pixels. See also
 ;              PIXELROW ($0C5B).
 ;
 ; $0C8C..$0CBC PIXELBYTEOFF
 ;
 ;              Table containing a byte offset into PLAYFIELD memory for each
 ;              PLAYFIELD space object (stars, explosion fragments) (49 bytes):
 ;              the number of bytes from the start of the PLAYFIELD row to the
 ;              byte containing the space object pixel in the same PLAYFIELD row.
 ;              In other words, the pixel column modulo 4 (1 byte = 4 GRAPHICS7
 ;              pixels).
 ;
 ;              NOTE: Only bytes 5..48 are used for PLAYFIELD space objects in
 ;              this way. Bytes 0..4 are used differently. See PL0SHAPTYPE
 ;              ($0C8C)..PL4SHAPTYPE ($0C90).
 ;
 ; $0C8C        PL0SHAPTYPE
 ;
 ;              Shape type of PLAYER0. Used to index the PLAYER's set of shape
 ;              cells in tables PLSHAPOFFTAB ($BE2F) and PLSHAPHEIGHTTAB ($BE7F).
 ;              Used values are:
 ;                $00 -> PHOTON TORPEDO
 ;                $10 -> ZYLON FIGHTER
 ;                $20 -> STARBASE RIGHT
 ;                $30 -> STARBASE CENTER
 ;                $40 -> STARBASE LEFT
 ;                $50 -> TRANSFER VESSEL
 ;                $60 -> METEOR
 ;                $70 -> ZYLON CRUISER
 ;                $80 -> ZYLON BASESTAR
 ;                $90 -> HYPERWARP TARGET MARKER
 ;
 ; $0C8D        PL1SHAPTYPE
 ;
 ;              Shape type of PLAYER1. Compare PL0SHAPTYPE ($0C8C).
 ;
 ; $0C8E        PL2SHAPTYPE
 ;
 ;              Shape type of PLAYER2. Compare PL0SHAPTYPE ($0C8C).
 ;
 ; $0C8F        PL3SHAPTYPE
 ;
 ;              Shape type of PLAYER3. Compare PL0SHAPTYPE ($0C8C).
 ;
 ; $0C90        PL4SHAPTYPE
 ;
 ;              Shape type of PLAYER4. Compare PL0SHAPTYPE ($0C8C).
 ;
 ; $0CBD..$0CED PIXELSAVE
 ;
 ;              Table containing the byte of PLAYFIELD memory before drawing the
 ;              PLAYFIELD space object pixel into it (star, explosion fragments),
 ;              for each PLAYFIELD space object (49 bytes). 
 ;
 ;              NOTE: Only bytes 5..48 are used for PLAYFIELD space objects in
 ;              this way. Bytes 0..4 are used differently. See PL0HEIGHT
 ;              ($0CBD)..PL4HEIGHT ($0CC1).
 ;
 ; $0CBD        PL0HEIGHT
 ;
 ;              Shape height of PLAYER0
 ;
 ; $0CBE        PL1HEIGHT
 ;
 ;              Shape height of PLAYER1
 ;
 ; $0CBF        PL2HEIGHT
 ;
 ;              Shape height of PLAYER2
 ;
 ; $0CC0        PL3HEIGHT
 ;
 ;              Shape height of PLAYER3
 ;
 ; $0CC1        PL4HEIGHT
 ;
 ;              Shape height of PLAYER4
 ;
 ; $0CEE..$0D1E PIXELBYTE
 ;
 ;              Table containing a 1-byte bit pattern for 4 pixels in the color
 ;              of the space object's pixel, for each PLAYFIELD space object (49
 ;              bytes). 
 ;
 ;              NOTE: Only bytes 5..48 are used for PLAYFIELD space objects in
 ;              this way. Bytes 0..4 are used differently. See PL0HEIGHTNEW
 ;              ($0CEE)..PL4HEIGHTNEW ($0CF2).
 ;
 ; $0CEE        PL0HEIGHTNEW
 ;
 ;              New shape height of PLAYER0
 ;
 ; $0CEF        PL1HEIGHTNEW
 ;
 ;              New shape height of PLAYER1
 ;
 ; $0CF0        PL2HEIGHTNEW
 ;
 ;              New shape height of PLAYER2
 ;
 ; $0CF1        PL3HEIGHTNEW
 ;
 ;              New shape height of PLAYER3
 ;
 ; $0CF2        PL4HEIGHTNEW
 ;
 ;              New shape height of PLAYER4
 ;
 ; $0D1F..$0D32 TITLETXT
 ;
 ;              Title text line, contains ATASCII-coded characters (20 bytes)
 ;
 ; $0D35..$0DE8 GCPFMEM
 ;
 ;              Galactic Chart PLAYFIELD memory (20 characters x 9 rows = 180
 ;              bytes)
 ;
 ; $0DE9..$0EE8 MAPTO80
 ;
 ;              Lookup table to convert values in $00..$FF to values of 0..80
 ;              (255 bytes). Used to map position vector components (coordinates)
 ;              to pixel row or column numbers relative to the PLAYFIELD center. 
 ;
 ; $0EE9..$0FE8 MAPTOBCD99
 ;
 ;              Lookup table to convert values in $00..$FF to BCD-values of
 ;              00..99 (255 bytes). Used in subroutines UPDPANEL ($B804) and
 ;              SHOWDIGITS ($B8CD) to convert values to a 2-digit decimal readout
 ;              value of the Control Panel Display.
 ;
 ; $1000..$1F77 PFMEM
 ;
 ;              PLAYFIELD graphics memory (40 bytes x 100 rows = 4000 bytes, 1
 ;              byte stores 4 pixels, 40 bytes = 160 pixels in GRAPHICS7 mode = 1
 ;              PLAYFIELD row of pixels).
 ;
 ;              NOTE: The Display List displays only PLAYFIELD rows 0..98.

 ;*******************************************************************************
 ;*                                                                             *
 ;*                         S Y S T E M   S Y M B O L S                         *
 ;*                                                                             *
 ;*******************************************************************************

 VDSLST          = $0200                           ; Display List Interrupt (DLI) vector
 VIMIRQ          = $0216                           ; Interrupt request (IRQ) immediate vector
 VVBLKI          = $0222                           ; Vertical blank immediate vector
 HPOSP0          = $D000                           ; Horizontal position of PLAYER0
 HPOSP1          = $D001                           ; Horizontal position of PLAYER1
 HPOSP2          = $D002                           ; Horizontal position of PLAYER2
 HPOSP3          = $D003                           ; Horizontal position of PLAYER3
 HPOSM0          = $D004                           ; Horizontal position of MISSILE0
 HPOSM1          = $D005                           ; Horizontal position of MISSILE1
 HPOSM2          = $D006                           ; Horizontal position of MISSILE2
 HPOSM3          = $D007                           ; Horizontal position of MISSILE3
 M0PL            = $D008                           ; MISSILE0 to PLAYER collisions
 M1PL            = $D009                           ; MISSILE1 to PLAYER collisions
 M2PL            = $D00A                           ; MISSILE2 to PLAYER collisions
 M3PL            = $D00B                           ; MISSILE3 to PLAYER collisions
 P3PL            = $D00F                           ; PLAYER3 to PLAYER collisions
 TRIG0           = $D010                           ; Joystick 0 trigger
 COLPM0          = $D012                           ; Color and brightness of PLAYER0
 COLPF0          = $D016                           ; Color and brightness of PLAYFIELD0
 PRIOR           = $D01B                           ; Priority selection register
 GRACTL          = $D01D                           ; Graphics control register
 HITCLR          = $D01E                           ; Clear collision register
 CONSOL          = $D01F                           ; Function keys register
 AUDF1           = $D200                           ; Audio channel 1 frequency
 AUDF2           = $D202                           ; Audio channel 2 frequency
 AUDC2           = $D203                           ; Audio channel 2 control
 AUDF3           = $D204                           ; Audio channel 3 frequency
 AUDC3           = $D205                           ; Audio channel 3 control
 AUDF4           = $D206                           ; Audio channel 4 frequency
 AUDC4           = $D207                           ; Audio channel 4 control
 AUDCTL          = $D208                           ; Audio control
 KBCODE          = $D209                           ; Keyboard code
 STIMER          = $D209                           ; Start POKEY timers
 RANDOM          = $D20A                           ; Random number generator
 IRQEN           = $D20E                           ; Interrupt request (IRQ) enable
 SKCTL           = $D20F                           ; Serial port control
 PORTA           = $D300                           ; Port A
 PACTL           = $D302                           ; Port A control
 DMACTL          = $D400                           ; Direct Memory Access (DMA) control
 DLIST           = $D402                           ; Display List pointer
 PMBASE          = $D407                           ; Player/Missile base address (high byte)
 CHBASE          = $D409                           ; Character set base address (high byte)
 WSYNC           = $D40A                           ; Wait for horizontal synchronization
 VCOUNT          = $D40B                           ; Vertical line counter
 NMIEN           = $D40E                           ; Non-maskable interrupt (NMI) enable
 ROMCHARSET      = $E000                           ; ROM character set

 ;*******************************************************************************
 ;*                                                                             *
 ;*                           G A M E   S Y M B O L S                           *
 ;*                                                                             *
 ;*******************************************************************************

 MISSIONLEVEL    = $62
 FKEYCODE        = $63
 ISDEMOMODE      = $64
 NEWTITLEPHR     = $65
 IDLECNTHI       = $66
 ISVBISYNC       = $67
 MEMPTR          = $68

 DIVIDEND        = $6A
 JOYSTICKDELTA   = $6D


 VELOCITYLO      = $70
 NEWVELOCITY     = $71
 COUNT8          = $72
 EXPLLIFE        = $73
 CLOCKTIM        = $74
 DOCKSTATE       = $75
 COUNT256        = $76
 IDLECNTLO       = $77
 ZYLONUNITTIM    = $78
 MAXSPCOBJIND    = $79
 OLDMAXSPCOBJIND = $7A
 ISSTARBASESECT  = $7B
 ISTRACKCOMPON   = $7C
 DRAINSHIELDS    = $7D
 DRAINATTCOMP    = $7E
 ENERGYCNT       = $7F
 DRAINENGINES    = $80
 SHIELDSCOLOR    = $81
 PL3HIT          = $82
 PL4HIT          = $83
 OLDTRIG0        = $84

 ISTRACKING      = $86
 BARRELNR        = $87
 LOCKONLIFE      = $88
 PLTRACKED       = $89
 HITBADNESS      = $8A
 REDALERTLIFE    = $8B
 WARPDEPRROW     = $8C
 WARPDEPRCOLUMN  = $8D
 WARPARRVROW     = $8E
 WARPARRVCOLUMN  = $8F
 CURRSECTOR      = $90
 WARPENERGY      = $91
 ARRVSECTOR      = $92
 HUNTSECTOR      = $93
 HUNTSECTCOLUMN  = $94
 HUNTSECTROW     = $95
 NEWZYLONDIST    = $96
 OLDZYLONDIST    = $9E
 HUNTTIM         = $9F
 BLIPCOLUMN      = $A0
 BLIPROW         = $A1
 BLIPCYCLECNT    = $A2
 ISINLOCKON      = $A3
 DIRLEN          = $A4
 PENROW          = $A5
 PENCOLUMN       = $A6
 CTRLDZYLON      = $A7
 ZYLONFLPAT0     = $A8
 ZYLONFLPAT1     = $A9
 MILESTTIM0      = $AA
 MILESTTIM1      = $AB
 MILESTVELINDZ0  = $AC
 MILESTVELINDZ1  = $AD
 MILESTVELINDX0  = $AE
 MILESTVELINDX1  = $AF
 MILESTVELINDY0  = $B0
 MILESTVELINDY1  = $B1
 ZYLONVELINDZ0   = $B2
 ZYLONVELINDZ1   = $B3
 ZYLONVELINDX0   = $B4
 ZYLONVELINDX1   = $B5
 ZYLONVELINDY0   = $B6
 ZYLONVELINDY1   = $B7
 ISBACKATTACK0   = $B8
 ISBACKATTACK1   = $B9
 ZYLONTIMX0      = $BA
 ZYLONTIMX1      = $BB
 ZYLONTIMY0      = $BC
 ZYLONTIMY1      = $BD
 TORPEDODELAY    = $BE
 ZYLONATTACKER   = $BF
 WARPSTATE       = $C0
 VELOCITYHI      = $C1
 TRAILDELAY      = $C2
 TRAILIND        = $C3
 WARPTEMPCOLUMN  = $C4
 WARPTEMPROW     = $C5
 VEERMASK        = $C6
 VICINITYMASK    = $C7
 JOYSTICKX       = $C8
 JOYSTICKY       = $C9
 KEYCODE         = $CA
 SCORE           = $CB
 SCOREDRANKIND   = $CD
 SCOREDCLASSIND  = $CE
 TITLELIFE       = $CF
 SHIPVIEW        = $D0
 TITLEPHR        = $D1
 BEEPFRQIND      = $D2
 BEEPREPEAT      = $D3
 BEEPTONELIFE    = $D4
 BEEPPAUSELIFE   = $D5
 BEEPPRIORITY    = $D6
 BEEPFRQSTART    = $D7
 BEEPLIFE        = $D8
 BEEPTOGGLE      = $D9
 NOISETORPTIM    = $DA
 NOISEEXPLTIM    = $DB
 NOISEAUDC2      = $DC
 NOISEAUDC3      = $DD
 NOISEAUDF1      = $DE
 NOISEAUDF2      = $DF
 NOISEFRQINC     = $E0
 NOISELIFE       = $E1
 NOISEZYLONTIM   = $E2
 NOISEHITLIFE    = $E3
 PL0SHAPOFF      = $E4
 PL1SHAPOFF      = $E5
 PL2SHAPOFF      = $E6
 PL3SHAPOFF      = $E7
 PL4SHAPOFF      = $E8
 PL0LIFE         = $E9
 PL1LIFE         = $EA
 PL2LIFE         = $EB
 PL3LIFE         = $EC
 PL4LIFE         = $ED
 PL0COLOR        = $EE
 PL1COLOR        = $EF
 PL2COLOR        = $F0
 PL3COLOR        = $F1
 PF0COLOR        = $F2
 PF1COLOR        = $F3
 PF2COLOR        = $F4
 PF3COLOR        = $F5
 BGRCOLOR        = $F6
 PF0COLORDLI     = $F7
 PF1COLORDLI     = $F8
 PF2COLORDLI     = $F9
 PF3COLORDLI     = $FA
 BGRCOLORDLI     = $FB
 DSPLST          = $0280
 PL4DATA         = $0300
 PL0DATA         = $0400
 PL1DATA         = $0500
 PL2DATA         = $0600
 PL3DATA         = $0700
 PFMEMROWLO      = $0800
 PFMEMROWHI      = $0864
 GCMEMMAP        = $08C9
 PANELTXT        = $0949
 VELOCD1         = $094B
 KILLCNTD1       = $0950
 ENERGYD1        = $0955
 TRACKC1         = $095A
 TRACKDIGIT      = $095C
 THETAC1         = $0960
 PHIC1           = $0966
 RANGEC1         = $096C
 GCTXT           = $0971
 GCWARPD1        = $097D
 GCTRGCNT        = $098D
 GCSTATPHO       = $0992
 GCSTATENG       = $0993
 GCSTATSHL       = $0994
 GCSTATCOM       = $0995
 GCSTATLRS       = $0996
 GCSTATRAD       = $0997
 GCSTARDAT       = $09A3
 ZPOSSIGN        = $09AD
 PL2ZPOSSIGN     = $09AF
 PL3ZPOSSIGN     = $09B0
 PL4ZPOSSIGN     = $09B1
 XPOSSIGN        = $09DE
 PL2XPOSSIGN     = $09E0
 PL3XPOSSIGN     = $09E1
 PL4XPOSSIGN     = $09E2
 YPOSSIGN        = $0A0F
 PL2YPOSSIGN     = $0A11
 PL3YPOSSIGN     = $0A12
 PL4YPOSSIGN     = $0A13
 ZPOSHI          = $0A40
 PL0ZPOSHI       = $0A40
 PL2ZPOSHI       = $0A42
 PL3ZPOSHI       = $0A43
 PL4ZPOSHI       = $0A44
 XPOSHI          = $0A71
 PL2XPOSHI       = $0A73
 PL3XPOSHI       = $0A74
 PL4XPOSHI       = $0A75
 YPOSHI          = $0AA2
 PL2YPOSHI       = $0AA4
 PL3YPOSHI       = $0AA5
 PL4YPOSHI       = $0AA6
 ZPOSLO          = $0AD3
 PL2ZPOSLO       = $0AD5
 PL3ZPOSLO       = $0AD6
 PL4ZPOSLO       = $0AD7
 XPOSLO          = $0B04
 PL2XPOSLO       = $0B06
 PL3XPOSLO       = $0B07
 PL4XPOSLO       = $0B08
 YPOSLO          = $0B35
 PL2YPOSLO       = $0B37
 PL3YPOSLO       = $0B38
 PL4YPOSLO       = $0B39
 ZVEL            = $0B66
 PL0ZVEL         = $0B66
 PL1ZVEL         = $0B67
 PL2ZVEL         = $0B68
 PL3ZVEL         = $0B69
 PL4ZVEL         = $0B6A
 XVEL            = $0B97
 PL0XVEL         = $0B97
 PL1XVEL         = $0B98
 PL2XVEL         = $0B99
 PL3XVEL         = $0B9A
 PL4XVEL         = $0B9B
 YVEL            = $0BC8
 PL0YVEL         = $0BC8
 PL1YVEL         = $0BC9
 PL2YVEL         = $0BCA
 PL3YVEL         = $0BCB
 PL4YVEL         = $0BCC
 PIXELROWNEW     = $0BF9
 PL0ROWNEW       = $0BF9
 PL1ROWNEW       = $0BFA
 PL2ROWNEW       = $0BFB
 PL3ROWNEW       = $0BFC
 PL4ROWNEW       = $0BFD
 PIXELCOLUMN     = $0C2A
 PL0COLUMN       = $0C2A
 PL1COLUMN       = $0C2B
 PL2COLUMN       = $0C2C
 PL3COLUMN       = $0C2D
 PL4COLUMN       = $0C2E
 PIXELROW        = $0C5B
 PL0ROW          = $0C5B
 PL1ROW          = $0C5C
 PL2ROW          = $0C5D
 PL3ROW          = $0C5E
 PL4ROW          = $0C5F
 PIXELBYTEOFF    = $0C8C
 PL0SHAPTYPE     = $0C8C
 PL1SHAPTYPE     = $0C8D
 PL2SHAPTYPE     = $0C8E
 PL3SHAPTYPE     = $0C8F
 PL4SHAPTYPE     = $0C90
 PIXELSAVE       = $0CBD
 PL0HEIGHT       = $0CBD
 PL1HEIGHT       = $0CBE
 PL2HEIGHT       = $0CBF
 PL3HEIGHT       = $0CC0
 PL4HEIGHT       = $0CC1
 PIXELBYTE       = $0CEE
 PL0HEIGHTNEW    = $0CEE
 PL1HEIGHTNEW    = $0CEF
 PL2HEIGHTNEW    = $0CF0
 PL3HEIGHTNEW    = $0CF1
 PL4HEIGHTNEW    = $0CF2
 TITLETXT        = $0D1F
 GCPFMEM         = $0D35
 MAPTO80         = $0DE9
 MAPTOBCD99      = $0EE9
 PFMEM           = $1000

    ORG $A000

 ;*******************************************************************************
 ;*                                                                             *
 ;*                G A M E   D A T A   ( P A R T   1   O F   2 )                *
 ;*                                                                             *
 ;*******************************************************************************

 ;*** Number of space objects ***************************************************

 NUMSPCOBJ.PL    = 5                               ; Number of PLAYER space objects
 NUMSPCOBJ.STARS = 12                              ; Number of PLAYFIELD space objects (stars)
 NUMSPCOBJ.NORM  = NUMSPCOBJ.PL+NUMSPCOBJ.STARS    ; Normal number of space objects
 NUMSPCOBJ.ALL   = 49                              ; Maximum number of space objects

 ;*** PLAYER shape data offsets *************************************************

 SHAP.TORPEDO    = $00                             ; Photon torpedo
 SHAP.ZFIGHTER   = $10                             ; Zylon fighter
 SHAP.STARBASEL  = $20                             ; Starbase (left part)
 SHAP.STARBASEC  = $30                             ; Starbase (center part)
 SHAP.STARBASER  = $40                             ; Starbase (right part)
 SHAP.TRANSVSSL  = $50                             ; Transfer vessel
 SHAP.METEOR     = $60                             ; Meteor
 SHAP.ZCRUISER   = $70                             ; Zylon cruiser
 SHAP.ZBASESTAR  = $80                             ; Zylon basestar
 SHAP.HYPERWARP  = $90                             ; Hyperwarp Target Marker

 ;*** ROM character set constants ***********************************************
 ROM.SPC         = $00                             ; ROM character ' '
 ROM.DOT         = $0E                             ; ROM character '.'
 ROM.0           = $10                             ; ROM character '0'
 ROM.1           = $11                             ; ROM character '1'
 ROM.2           = $12                             ; ROM character '2'
 ROM.3           = $13                             ; ROM character '3'
 ROM.4           = $14                             ; ROM character '4'
 ROM.5           = $15                             ; ROM character '5'
 ROM.9           = $19                             ; ROM character '9'
 ROM.COLON       = $1A                             ; ROM character ':'
 ROM.A           = $21                             ; ROM character 'A'
 ROM.C           = $23                             ; ROM character 'C'
 ROM.D           = $24                             ; ROM character 'D'
 ROM.E           = $25                             ; ROM character 'E'
 ROM.G           = $27                             ; ROM character 'G'
 ROM.L           = $2C                             ; ROM character 'L'
 ROM.N           = $2E                             ; ROM character 'N'
 ROM.P           = $30                             ; ROM character 'P'
 ROM.R           = $32                             ; ROM character 'R'
 ROM.S           = $33                             ; ROM character 'S'
 ROM.T           = $34                             ; ROM character 'T'
 ROM.W           = $37                             ; ROM character 'W'
 ROM.Y           = $39                             ; ROM character 'Y'

 ;*** Custom character set constants ********************************************
 CCS.COL1        = $40                             ; COLOR1 bits for text in GR1/2 text mode
 CCS.COL2        = $80                             ; COLOR2 bits for text in GR1/2 text mode
 CCS.COL3        = $C0                             ; COLOR3 bits for text in GR1/2 text mode

 CCS.0           = 0                               ; Custom character '0'
 CCS.1           = 1                               ; Custom character '1'
 CCS.2           = 2                               ; Custom character '2'
 CCS.3           = 3                               ; Custom character '3'
 CCS.4           = 4                               ; Custom character '4'
 CCS.5           = 5                               ; Custom character '5'
 CCS.6           = 6                               ; Custom character '6'
 CCS.7           = 7                               ; Custom character '7'
 CCS.8           = 8                               ; Custom character '8'
 CCS.9           = 9                               ; Custom character '9'
 CCS.SPC         = 10                              ; Custom character ' '
 CCS.COLON       = 11                              ; Custom character ':'
 CCS.BORDERSW    = 12                              ; Custom character 'BORDER SOUTHWEST'
 CCS.E           = 13                              ; Custom character 'E'
 CCS.INF         = 14                              ; Custom character 'INFINITY'
 CCS.MINUS       = 15                              ; Custom character '-'
 CCS.PLUS        = 16                              ; Custom character '+'
 CCS.PHI         = 17                              ; Custom character 'PHI'
 CCS.V           = 18                              ; Custom character 'V'
 CCS.R           = 19                              ; Custom character 'R'
 CCS.THETA       = 20                              ; Custom character 'THETA'
 CCS.K           = 21                              ; Custom character 'K'
 CCS.T           = 22                              ; Custom character 'T'
 CCS.C           = 23                              ; Custom character 'C'
 CCS.BORDERS     = 24                              ; Custom character 'BORDER SOUTH'
 CCS.BORDERW     = 25                              ; Custom character 'BORDER WEST'
 CCS.CORNERSW    = 26                              ; Custom character 'CORNER SOUTHWEST'
 CCS.STARBASE    = 27                              ; Custom character 'STARBASE SECTOR'
 CCS.4ZYLONS     = 28                              ; Custom character '4-ZYLON SECTOR'
 CCS.3ZYLONS     = 29                              ; Custom character '3-ZYLON SECTOR'
 CCS.2ZYLONS     = 30                              ; Custom character '2-ZYLON SECTOR'

 ;*** Custom character set ******************************************************
 ;
 ; 0        1        2        3        4        5        6        7
 ; ........ ........ ........ ........ ........ ........ ........ ........
 ; .####### ..##.... .####... .####... .##..... .####... .####... .#####..
 ; .#...### ...#.... ....#... ....#... .##..... .#...... .#..#... .#...#..
 ; .#...### ...#.... ....#... ....#... .##..... .#...... .#...... .....#..
 ; .#...### ...#.... .####... .#####.. .##.##.. .####... .#...... ...###..
 ; .#...### ..###... .#...... ....##.. .#####.. ....#... .######. ...#....
 ; .#...### ..###... .#...... ....##.. ....##.. ....#... .#....#. ...#....
 ; .####### ..###... .####... .#####.. ....##.. .####... .######. ...#....
 ;
 ; 8        9        10       11       12       13       14       15
 ; ........ ........ ........ ..###... #....... ........ ........ ........
 ; ..###... .#####.. ........ ..###... #....... ..####.. .##..##. ........
 ; ..#.#... .#...#.. ........ ..###... #....... ..#..... #..##..# ........
 ; ..#.#... .#...#.. ........ ........ #....... ..#..... #..##..# .######.
 ; .#####.. .#####.. ........ ........ #....... .####... #..##..# ........
 ; .##.##.. ....##.. ........ ..###... #....... .##..... .##..##. ........
 ; .##.##.. ....##.. ........ ..###... #....... .##..... ........ ........
 ; .#####.. ....##.. ........ ..###... ######## .#####.. ........ ........
 ;
 ; 16       17       18       19       20       21       22       23
 ; ........ ........ .##..##. ........ ........ ........ #######. ######..
 ; ...##... ...##... .##..##. .#####.. ...###.. .#...##. #..#..#. #...##..
 ; ...##... .######. .##..##. .#...#.. ..#####. .#...##. ...#.... #...##..
 ; ...##... ##.##.## .##..##. .#...#.. .##...## .#...#.. ...##... #.......
 ; .######. #..##..# .##..##. .#####.. .#.###.# .#####.. ...##... #.......
 ; ...##... ##.##.## ..#.##.. .##.#... .##...## .##..#.. ...##... #.......
 ; ...##... .######. ..###... .##.##.. ..#####. .##..##. ...##... #....#..
 ; ...##... ...##... ..##.... .##.##.. ...###.. .##..##. ...##... ######..
 ;
 ; 24       25       26       27       28       29       30
 ; ........ #....... ........ #....... #....... #....... #.......
 ; ........ #....... ........ #.#.#.#. #..##... #...###. #.##....
 ; ........ #....... ........ #..###.. #....... #....... #..##...
 ; ........ #....... ........ #.#####. #.##.##. #.###... #.#####.
 ; ........ #....... ........ #..###.. #....... #....... #..##...
 ; ........ #....... ........ #.#.#.#. #...##.. #..###.. #.##....
 ; ........ #....... ........ #....... #....... #....... #.......
 ; ######## #....... #....... ######## ######## ######## ########

CHARSET
                .BYTE $00,$7F,$47,$47,$47,$47,$47,$7F ; Custom character '0'
                .BYTE $00,$30,$10,$10,$10,$38,$38,$38 ; Custom character '1'
                .BYTE $00,$78,$08,$08,$78,$40,$40,$78 ; Custom character '2'
                .BYTE $00,$78,$08,$08,$7C,$0C,$0C,$7C ; Custom character '3'
                .BYTE $00,$60,$60,$60,$6C,$7C,$0C,$0C ; Custom character '4'
                .BYTE $00,$78,$40,$40,$78,$08,$08,$78 ; Custom character '5'
                .BYTE $00,$78,$48,$40,$40,$7E,$42,$7E ; Custom character '6'
                .BYTE $00,$7C,$44,$04,$1C,$10,$10,$10 ; Custom character '7'
                .BYTE $00,$38,$28,$28,$7C,$6C,$6C,$7C ; Custom character '8'
                .BYTE $00,$7C,$44,$44,$7C,$0C,$0C,$0C ; Custom character '9'
                .BYTE $00,$00,$00,$00,$00,$00,$00,$00 ; Custom character ' '
                .BYTE $38,$38,$38,$00,$00,$38,$38,$38 ; Custom character ':'
                .BYTE $80,$80,$80,$80,$80,$80,$80,$FF ; Custom character 'BORDER SOUTHWEST'
                .BYTE $00,$3C,$20,$20,$78,$60,$60,$7C ; Custom character 'E'
                .BYTE $00,$66,$99,$99,$99,$66,$00,$00 ; Custom character 'INFINITY'
                .BYTE $00,$00,$00,$7E,$00,$00,$00,$00 ; Custom character '-'
                .BYTE $00,$18,$18,$18,$7E,$18,$18,$18 ; Custom character '+'
                .BYTE $00,$18,$7E,$DB,$99,$DB,$7E,$18 ; Custom character 'PHI'
                .BYTE $66,$66,$66,$66,$66,$2C,$38,$30 ; Custom character 'V'
                .BYTE $00,$7C,$44,$44,$7C,$68,$6C,$6C ; Custom character 'R'
                .BYTE $00,$1C,$3E,$63,$5D,$63,$3E,$1C ; Custom character 'THETA'
                .BYTE $00,$46,$46,$44,$7C,$64,$66,$66 ; Custom character 'K'
                .BYTE $FE,$92,$10,$18,$18,$18,$18,$18 ; Custom character 'T'
                .BYTE $FC,$8C,$8C,$80,$80,$80,$84,$FC ; Custom character 'C'
                .BYTE $00,$00,$00,$00,$00,$00,$00,$FF ; Custom character 'BORDER SOUTH'
                .BYTE $80,$80,$80,$80,$80,$80,$80,$80 ; Custom character 'BORDER WEST'
                .BYTE $00,$00,$00,$00,$00,$00,$00,$80 ; Custom character 'CORNER SOUTHWEST'
                .BYTE $80,$AA,$9C,$BE,$9C,$AA,$80,$FF ; Custom character 'STARBASE SECTOR'
                .BYTE $80,$98,$80,$B6,$80,$8C,$80,$FF ; Custom character '4-ZYLON SECTOR'
                .BYTE $80,$8E,$80,$B8,$80,$9C,$80,$FF ; Custom character '3-CYCLON SECTOR'
                .BYTE $80,$B0,$98,$BE,$98,$B0,$80,$FF ; Custom character '2-ZYLON SECTOR'

 ;*** Header text of Long-Range Scan view (shares spaces with following header) *
LRSHEADER
                .BYTE $00,$00,$6C,$6F,$6E,$67,$00,$72 ; "  LONG RANGE SCAN"
                .BYTE $61,$6E,$67,$65,$00,$73,$63,$61
                .BYTE $6E

;*** Header text of Aft view (shares spaces with following header) *************
AFTHEADER
                .BYTE $00,$00,$00,$00,$00,$00,$61,$66 ; "      AFT VIEW   "
                .BYTE $74,$00,$76,$69,$65,$77,$00,$00
                .BYTE $00

;*** Header text of Galactic Chart view ****************************************
GCHEADER
                .BYTE $00,$00,$00,$67,$61,$6C,$61,$63 ; "   GALACTIC CHART   "
                .BYTE $74,$69,$63,$00,$63,$68,$61,$72
                .BYTE $74,$00,$00,$00

;*** Display List of Galactic Chart view ***************************************
DLSTGC
                .BYTE $60                             ; BLK7
                .BYTE $46,<GCHEADER,>GCHEADER         ; GR1 @ GCHEADER
                .BYTE $F0                             ; BLK8 + DLI
                .BYTE $47,<GCPFMEM,>GCPFMEM           ; GR2 @ GCPFMEM
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $07                             ; GR2
                .BYTE $80                             ; BLK1 + DLI
                .BYTE $46,<TITLETXT,>TITLETXT         ; GR1 @ TITLETXT
                .BYTE $46,<GCTXT,>GCTXT               ; GR1 @ GCTXT
                .BYTE $06                             ; GR1
                .BYTE $06                             ; GR1
                .BYTE $41,<DSPLST,>DSPLST             ; JMP @ DSPLST

;*******************************************************************************
;*                                                                             *
;*                              G A M E   C O D E                              *
;*                                                                             *
;*******************************************************************************

;*******************************************************************************
;*                                                                             *
;*                                  INITCOLD                                   *
;*                                                                             *
;*                        Initialize game (Cold start)                         *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Initializes the game, then continues into the game loop at GAMELOOP ($A1F3).
;
; There are four entry points to initialization:
;
; (1)  INITCOLD ($A14A) is entered at initial cartridge startup (cold start).
;      This initializes POKEY, resets the idle counter, sets the mission level
;      to NOVICE mission, and clears the function key code. POKEY is enabled to
;      receive keyboard input. Code execution continues into INITSELECT ($A15A)
;      below.
;
; (2)  INITSELECT ($A15A) is entered from GAMELOOP ($A1F3) after the SELECT
;      function key has been pressed. This loads the title phrase offset for the
;      copyright notice. Code execution continues into INITDEMO ($A15C) below. 
;
; (3)  INITDEMO ($A15C) is entered when the game switches into demo mode. This
;      loads the demo mode flag. Code execution continues into INITSTART ($A15E)
;      below.
;
; (4)  INITSTART ($A15E) is entered from GAMELOOP ($A1F3) after the START
;      function key has been pressed. This enqueues the new title phrase and
;      enables or disables demo mode, depending on the preloaded value.
;
; Initialization continues with the following steps: 
;
; (1)  Clear the custom chip registers and zero page game variables from
;      ISVBISYNC ($0067) on.
;
;      NOTE: Because of loop jamming there is a loop index overshoot. This
;      clears memory at $0067..$0166 instead of the game's zero page memory at
;      $0067..$00FB. However, this does no harm because memory at $0100..$0166
;      is - at this point in time - a yet unused part of the 6502 CPU stack
;      (memory addresses $0100..$01FF).
;
;      NOTE: At address $A175 a hack is necessary in the source code to force an
;      STA ISVBISYNC,X instruction with a 16-bit address operand, as opposed to
;      an 8-bit (zero page) address operand. The latter would be chosen by
;      virtually all 6502 assemblers, as ISVBISYNC ($0067) is located in the
;      zero page (memory addresses $0000..$00FF). The reason to force a 16-bit
;      address operand is the following: The instruction STA ISVBISYNC,X is used
;      in a loop which iterates the CPU's X register from 0 to 255 to clear
;      memory. By using this instruction with a 16-bit address operand
;      ("indexed, absolute" mode), memory at $0067..$0166 is cleared. Had the
;      code been using the same operation with an 8-bit address operand
;      ("indexed, zero page" mode), memory at $0067..$00FF would have been
;      cleared first, then the indexed address would have wrapped back to $0000
;      and cleared memory at $0000..$0066, thus effectively overwriting already
;      initialized memory locations.
;
; (2)  Initialize the 6502 CPU (reset the stack pointer, disable decimal mode).
;
; (3)  Clear game memory from $0200..$1FFF in subroutine CLRMEM ($AE0F).
;
; (4)  Set the address vectors of the IRQ, VBI, and DLI handlers.
;
; (5)  Enable input from Joystick 0.
;
; (6)  Enable Player/Missile graphics, providing a fifth PLAYER, and set
;      PLAYER-PLAYFIELD priority.
;
;      BUG (at $A1A6): The set PLAYER-PLAYFIELD priority arranges PLAYERs
;      (PL0..4) in front of the PLAYFIELD (PF0..4) in this specific order, from
;      front to back:
;
;          PL0 > PL1 > PL2 > PL3 > PL4 > PF0, PF1, PF2 > PF4 (BGR)
;
;      This makes sense as space objects represented by PLAYERs (for example,
;      Zylon ships, photon torpedoes, and meteors) move in front of the stars,
;      which are part of the PLAYFIELD. However, PLAYERs also move in front of
;      the cross hairs, which are also part of the PLAYFIELD. Suggested fix:
;      None, technically not possible.  
;
; (7)  Do more initialization in subroutine INITIALIZE ($B3BA).
;
; (8)  Set display to Front view.
;
; (9)  Show or hide the Control Panel Display (bottom text window) in subroutine
;      MODDLST ($ADF1), depending on the demo mode flag.
;
; (10) Initialize our starship's velocity equivalent to speed key '6'.
;
; (11) Enable the Display List.
;
; (12) Initialize the number of space objects to 16 (5 PLAYER space objects + 12
;      PLAYFIELD space objects (stars), counted 0..16).
;
; (13) Set the title phrase to the selected mission level in subroutine SETTITLE
;      ($B223).
;
; (14) Enable the IRQ, DLI, and VBI interrupts.
;
; Code execution continues into the game loop at GAMELOOP ($A1F3).

INITCOLD        LDA #0                  ;
                STA SKCTL               ; POKEY: Initialization
                STA IDLECNTHI           ; Reset idle counter
                STA MISSIONLEVEL        ; Mission level := NOVICE mission
                STA FKEYCODE            ; Clear function key code
                LDA #$03                ; POKEY: Enable keyboard scan and debounce
                STA SKCTL               ;

;*** Entry point when SELECT function key was pressed **************************
INITSELECT      LDY #$2F                ; Prep title phrase "COPYRIGHT ATARI 1979"

;*** Entry point when game switches into demo mode *****************************
INITDEMO        LDA #$FF                ; Prep demo mode flag

;*** Entry point when START function key was pressed ***************************
INITSTART       STY NEWTITLEPHR         ; Enqueue new title phrase
                STA ISDEMOMODE          ; Store demo mode flag

;*** More initialization *******************************************************
                LDA #0                  ; Clear custom chip registers, zero page variables
                TAX                     ;
LOOP001         STA HPOSP0,X            ; Clear $D000..$D0FF (GTIA registers)
                STA DMACTL,X            ; Clear $D400..$D4FF (ANTIC registers)
                CPX #$0F                ;
                BCS SKIP001             ;
                STA AUDF1,X             ; Clear $D200..$D20E (POKEY registers)

SKIP001         STA PORTA,X             ; Clear $D300..$D3FF (PIA registers)
                                        ; Clear $0067..$0166 (zero page game variables)
                .BYTE $9D               ; HACK: Force ISVBISYNC,X with 16-bit address
                .WORD ISVBISYNC         ; (loop jamming)
                INX                     ;
                BNE LOOP001             ;

                DEX                     ; Reset 6502 CPU stack pointer
                TXS                     ;

                CLD                     ; Clear 6502 CPU decimal mode

                LDA #$02                ; Clear $0200..$1FFF (game memory)
                JSR CLRMEM              ;

                LDA #<IRQHNDLR          ; Set IRQ handler (VIMIRQ)
                STA VIMIRQ              ;
                LDA #>IRQHNDLR          ;
                STA VIMIRQ+1            ;

                LDA #<VBIHNDLR          ; Set VBI and DLI handler (VVBLKI and VDSLST)
                STA VVBLKI              ;
                LDA #<DLSTHNDLR         ;
                STA VDSLST              ;
                LDA #>VBIHNDLR          ;
                STA VVBLKI+1            ;
                LDA #>DLSTHNDLR         ;
                STA VDSLST+1            ;

                LDA #$04                ; PIA: Enable PORTA (Joystick 0)
                STA PACTL               ;
                LDA #$11                ; GTIA: Enable PLAYER4, prio: PLs > PFs > BGR (!)
                STA PRIOR               ; (PLAYERs in front of stars - and cross hairs)
                LDA #$03                ; GTIA: Enable DMA for PLAYERs and MISSILEs
                STA GRACTL              ;

                JSR INITIALIZE          ; Init Display List, tables, Galactic Chart, etc.

                LDX #$0A                ; Set Front view
                JSR SETVIEW             ;

                LDA ISDEMOMODE          ; If in/not in demo mode hide/show...
                AND #$80                ; ...Control Panel Display (bottom text window)
                TAY                     ;
                LDX #$5F                ;
                LDA #$08                ;
                JSR MODDLST             ;

                LDA #32                 ; Init our starship's velocity (= speed key '6')
                STA NEWVELOCITY         ;

                LDA #<DSPLST            ; ANTIC: Set Display List
                STA DLIST               ;
                LDA #>DSPLST            ;
                STA DLIST+1             ;

                LDA #$3E                ; ANTIC: Enable Display List DMA, single-line PM
                STA DMACTL              ; resolution, PM DMA, normal-width PLAYFIELD

                LDA #0                  ; ANTIC: Set PM memory base address
                STA PMBASE              ;

                LDA #NUMSPCOBJ.NORM-1   ; Set normal number of space objects
                STA MAXSPCOBJIND        ; (5 PLAYER spc objs + 12 PLAYFIELD spc objs (stars))

                LDX MISSIONLEVEL        ; Set title phrase
                LDY MISSIONPHRTAB,X     ; NOVICE, PILOT, WARRIOR, or COMMANDER MISSION
                JSR SETTITLE            ;

                LDA #$40                ; POKEY: Enable keyboard interrupt (IRQ)
                STA IRQEN               ;

                CLI                     ; Enable all IRQs

                LDA #$C0                ; ANTIC: Enable DLI and VBI
                STA NMIEN               ;

;*******************************************************************************
;*                                                                             *
;*                                  GAMELOOP                                   *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; The game loop is the main part of the game. It is basically an infinite loop
; that collects input, computes the game state, and updates the display. It
; executes the following steps:
;
; (1)  Synchronize the start of the game loop with the vertical blank phase of
;      the TV beam, which flagged by the Vertical Blank Interrupt handler
;      VBIHNDLR ($A6D1). This prevents screen flicker while the PLAYFIELD is
;      redrawn at the beginning of the game loop, because during the vertical
;      blank phase the TV beam is turned off and nothing is rendered on the TV
;      display. 
;
; (2)  Erase all PLAYFIELD space objects (stars, explosion fragments) from the
;      PLAYFIELD that were drawn in the previous game loop iteration.
;
; (3)  Draw the updated PLAYFIELD space objects (stars, explosion fragments)
;      into the PLAYFIELD (skip this if in hyperspace).
;
; (4)  If the idle counter has reached its trigger value then clear the center
;      of the PLAYFIELD, an 8 x 2 pixel rectangle with a top-left position at
;      pixel column number 76 and pixel row number 49 (?).
;
; (5)  Clear all PLAYER shapes.
;
; (6)  Update the vertical position of all PLAYERs and update all PLAYER shapes.
;
; (7)  Update the horizontal position of all PLAYERs.
;
; (8)  Rotate the position vector of all space objects horizontally and
;      vertically, according to the saved joystick position (skip this if in
;      Galactic Chart view) using subroutine ROTATE ($B69B).
;
; (9)  Move our starship forward in space. Our starship is always located at the
;      center of the game's 3D coordinate system, so all space objects are moved
;      along the z-axis toward our starship by subtracting a displacement from
;      their z-coordinate. The amount of the displacement depends on our
;      starship's velocity.
;
;      BUG (at $A3C1): This operation is not applied to Photon torpedoes (?).
;      Suggested fix: Remove LDA PL0SHAPTYPE,X and BEQ SKIP011. 
;
; (10) Add the proper velocity vector of all space objects to their position
;      vector (except for stars, which do not have any proper motion).
;
;      BUG (at $A419): The correct maximum loop index is NUMSPCOBJ.ALL*3 = 147
;      instead of 144. Suggested fix: Replace CMP #144 with CMP #147.
;
; (11) Correct the position vector components (coordinates) of all PLAYER space
;      objects if they have over- or underflowed during the calculations of the
;      previous steps.
;
; (12) Calculate the perspective projection of the position vectors of all space
;      objects and from that their pixel row and column number (applies to Front
;      and Aft view) using subroutines PROJECTION ($AA21), SCREENCOLUMN ($B6FB),
;      and SCREENROW ($B71E). If a space object (star, explosion fragment) moved
;      offscreen then a new space object is automatically created in subroutine
;      SCREENCOLUMN ($B6FB).
;
; (13) Handle hyperwarp marker selection in the Galactic Chart view in
;      subroutine SELECTWARP ($B162).
;
; (14) If in Long-Range Scan view, compute the pixel column number and the pixel
;      row number of all PLAYFIELD space objects (stars, explosion fragments) on
;      the plane established by the z and x axis of the 3D coordinate system
;      using subroutines SCREENCOLUMN ($B6FB) and SCREENROW ($B71E). Our
;      starship's shape is drawn using subroutine DRAWLINES ($A76F). If the
;      Long-Range Scan is OK then PLAYFIELD space object pixel numbers are
;      computed and drawn. This is skipped if the Long-Range Scan is destroyed. 
;
; (15) Update all PLAYER shapes, heights, and colors (see detailed description
;      below).
;
; (16) Flash a red alert when leaving hyperspace into a sector containing Zylon
;      ships by setting appropriate colors to PLAYFIELD2 and BACKGROUND.
;
; (17) Update the color of all PLAYFIELD space objects (stars, explosion
;      fragments). The color calculation is similar to that of the PLAYER color
;      calculation in (15). It also computes a range index and uses the same
;      color lookup table FOURCOLORPIXEL ($BA90). If a star in the Aft view
;      became too distant (z-coordinate < -$F000 (-4096) <KM>) its position is
;      re-initialized in subroutine INITPOSVEC ($B764).
;
; (18) If in demo mode skip input handling and jump directly to function key
;      handling (28).
;
; (19) Handle keyboard input in subroutine KEYBOARD ($AFFE).
;
; (20) Handle joystick input. Store the current joystick directions in JOYSTICKX
;      ($C8) and JOYSTICKY ($C9).
;
; (21) Check if our starship's photon torpedoes have hit a target in subroutine
;      COLLISION ($AF3D). This subroutine triggers a game over if all Zylon
;      ships have been destroyed.
;
; (22) Handle the joystick trigger in subroutine TRIGGER ($AE29).
;
; (23) Handle the Attack Computer and Tracking Computer. If the Attack Computer
;      is neither destroyed nor switched off then execute the following steps:
;
;      o   Update the Attack Computer Display's blip and lock-on markers in
;          subroutine UPDATTCOMP ($A7BF) (if in Front view).
;
;      o   Update the tracking index of the currently tracked PLAYER space
;          object. If a Zylon ship is tracked, then make sure to always track
;          the Zylon ship that launched the last Zylon photon torpedo. If this
;          Zylon ship is not alive then track the other Zylon ship - if alive.
;
;      o   If the Tracking Computer is on then switch to the view that shows the
;          tracked PLAYER space object by emulating pressing the 'F' (Front
;          view) or 'A' (Aft view) key (only if in Front or Aft view).
;
; (24) Handle docking at a starbase in subroutine DOCKING ($ACE6).
;
; (25) Handle maneuvering both of our starship's photon torpedoes, the single
;      Zylon photon torpedo, and the attacking Zylon ships in subroutine
;      MANEUVER ($AA79). This subroutine also automatically creates meteors and
;      new Zylon ships.
;
; (26) Check if our starship was hit by a Zylon photon torpedo (skip this if in
;      a starbase sector): Its x, y, and z coordinates must be within a range of
;      -($0100)..+$00FF (-256..+255) <KM> of our starship.
;
; (27) If our starship was hit then execute the following steps:
;
;      o   Damage or destroy one of our starship's subsystems in subroutine
;          DAMAGE ($AEE1).
;
;      o   Trigger an explosion in subroutine INITEXPL ($AC6B), 
;
;      o   Store the severity of the hit.
;
;      o   End the lifetime of the Zylon photon torpedo.
;
;      o   Subtract 100 energy units for being hit by the Zylon photon torpedo
;          in subroutine DECENERGY ($B86F). 
;
;      o   Trigger the noise sound pattern SHIELD EXPLOSION in subroutine NOISE
;          ($AEA8). 
;
;      If the Shields were down during the hit, our starship is destroyed.
;      Execute the following steps:
;
;      o   Switch to Front view.
;
;      o   Flash the title phrase "SHIP DESTROYED BY ZYLON FIRE".
;
;      o   Add the mission bonus to the internal game score in subroutine
;          GAMEOVER ($B10A).
;
;      o   Hide the Control Panel Display (bottom text window) in subroutine
;          MODDLST ($ADF1).
;
;      o   Clear the PLAYFIELD in subroutine CLRPLAYFIELD ($AE0D).
;
;      o   Enable the STARSHIP EXPLOSION noise. 
;
; (28) Handle the function keys START and SELECT. If SELECT has been pressed
;      cycle through the next of the 4 mission levels. If either START or SELECT
;      have been pressed, reset the idle counter, then jump to the corresponding
;      game initialization subroutines INITSTART ($A15E) or INITSELECT ($A15A),
;      respectively. 
;
; (29) Update the Control Panel Display in subroutine UPDPANEL ($B804).
;
; (30) Handle hyperwarp in subroutine HYPERWARP ($A89B).
;
; (31) Update the text in the title line in subroutine UPDTITLE ($B216).
;
; (32) Move Zylon units, decrease lifetime of photon torpedoes, elapse game
;      time, etc. in subroutine FLUSHGAMELOOP ($B4E4). This subroutine also
;      triggers a game over if our starship's energy is zero.
;
; (33) Jump back to the start of the game loop for the next game loop iteration.

L.HEIGHTCNT     = $6A                   ; Height counter during copying a PLAYER shape
L.ZPOSOFF       = $6E                   ; Offset to z-coordinate
L.VELOCITYHI    = $6B                   ; Velocity vector component (high byte)
L.VECCOMPIND    = $6A                   ; Position vector component index. Used values are:
                                        ;   0 -> z-component
                                        ;   1 -> x-component
                                        ;   2 -> y-component
L.RANGEINDEX    = $6A                   ; Range index for space object, computed from the
                                        ; distance to our starship. Used to pick the shape
                                        ; cell index of the PLAYERs shape data and shape
                                        ; height. Used values are: 0..15.
L.FOURCOLORPIX  = $6A                   ; 1-byte bit pattern for 4 pixels of same color
L.COLORMASK     = $6B                   ; Color/brightness to modify PLAYER color

;*** (1) Synchronize game loop with execution of VBI ***************************
GAMELOOP        LDA ISVBISYNC           ; Wait for execution of VBI
                BEQ GAMELOOP            ;

                LDA #0                  ; VBI is executed, clear VBI sync flag
                STA ISVBISYNC           ;

;*** (2) Erase PLAYFIELD space objects (stars, explosion fragments) ************
                LDA OLDMAXSPCOBJIND     ; Skip if no space objects in use
                BEQ SKIP002             ;

                LDX #NUMSPCOBJ.PL-1     ; Loop over all PLAYFIELD space objs (X index > 4)
LOOP002         INX                     ;
                LDY PIXELROW,X          ; Load pixel row number of PLAYFIELD space object

                LDA PFMEMROWLO,Y        ; Point MEMPTR to start of pixel's row...
                STA MEMPTR              ; ...in PLAYFIELD memory
                LDA PFMEMROWHI,Y        ;
                STA MEMPTR+1            ;

                LDY PIXELBYTEOFF,X      ; Get within-row-offset to byte with space obj pixel
                LDA PIXELSAVE,X         ; Load saved byte
                STA (MEMPTR),Y          ; Restore byte of PLAYFIELD memory

                CPX OLDMAXSPCOBJIND     ;
                BCC LOOP002             ; Next PLAYFIELD space object

                LDA #0                  ; Clear number of space objects
                STA OLDMAXSPCOBJIND     ;

;*** (3) Draw PLAYFIELD space objects (stars, explosion fragments) *************
SKIP002         LDA WARPSTATE           ; Skip during hyperspace
                BMI SKIP003             ;

                LDX MAXSPCOBJIND        ; Update number of space objects
                STX OLDMAXSPCOBJIND     ;

LOOP003         LDA PIXELROWNEW,X       ; Loop over all PLAYFIELD space objs (X index > 4)
                STA PIXELROW,X          ; Update pixel row number of PLAYFIELD space object

                TAY                     ;
                LDA PFMEMROWLO,Y        ; Point MEMPTR to start of pixel's row...
                STA MEMPTR              ; ...in PLAYFIELD memory
                LDA PFMEMROWHI,Y        ;
                STA MEMPTR+1            ;

                LDA PIXELCOLUMN,X       ; Convert pixel column number to within-row-offset
                LSR @                  ; ...of byte with space obj pixel (4 pixels = 1 byte)
                LSR @                  ;
                STA PIXELBYTEOFF,X      ; Store within-row-offset

                TAY                     ;
                LDA (MEMPTR),Y          ; Load pixel's byte from PLAYFIELD memory
                STA PIXELSAVE,X         ; Save it (for restoring it in next game loop)
                ORA PIXELBYTE,X         ; Blend with pixel's color bit-pattern
                STA (MEMPTR),Y          ; Store byte in PLAYFIELD memory

                DEX                     ;
                CPX #NUMSPCOBJ.PL-1     ;
                BNE LOOP003             ; Next PLAYFIELD space object

;*** (4) Clear PLAYFIELD center if idle counter is up (?) **********************
                                        ; PLAYFIELD addresses of...
PFMEM.C76R49    = PFMEM+49*40+76/4      ; ...pixel column number 76, row number 49
PFMEM.C80R49    = PFMEM+49*40+80/4      ; ...pixel column number 80, row number 49
PFMEM.C76R50    = PFMEM+50*40+76/4      ; ...pixel column number 76, row number 50
PFMEM.C80R50    = PFMEM+50*40+80/4      ; ...pixel column number 80, row number 50

SKIP003         LDA IDLECNTHI           ; Skip if idle counter not negative
                BPL SKIP004             ;

                LDA #0                  ; Clear pixels of 8 x 2 pixel rectangle...
                STA PFMEM.C76R50        ; ...@ column number 76, row number 49 (?)
                STA PFMEM.C80R50        ;
                STA PFMEM.C80R49        ;
                STA PFMEM.C76R49        ;

;*** (5) Clear all PLAYER shapes ***********************************************
SKIP004         LDA #0                  ; Clear shape of PLAYER4
                LDY PL4ROW              ;
                LDX PL4HEIGHT           ;
LOOP004         STA PL4DATA,Y           ;
                INY                     ;
                DEX                     ;
                BPL LOOP004             ;

                LDY PL3ROW              ; Clear shape of PLAYER3
                LDX PL3HEIGHT           ;
LOOP005         STA PL3DATA,Y           ;
                INY                     ;
                DEX                     ;
                BPL LOOP005             ;

                LDY PL2ROW              ; Clear shape of PLAYER2
                LDX PL2HEIGHT           ;
LOOP006         STA PL2DATA,Y           ;
                INY                     ;
                DEX                     ;
                BPL LOOP006             ;

                LDY PL1ROW              ; Clear shape of PLAYER1
                LDX PL1HEIGHT           ;
LOOP007         STA PL1DATA,Y           ;
                INY                     ;
                DEX                     ;
                BPL LOOP007             ;

                LDY PL0ROW              ; Clear shape of PLAYER0
                LDX PL0HEIGHT           ;
LOOP008         STA PL0DATA,Y           ;
                INY                     ;
                DEX                     ;
                BPL LOOP008             ;

;*** (6) Update PLAYER vertical positions and update PLAYER shapes *************
                LDA PL4SHAPTYPE         ; CARRY := PLAYER4 a PHOTON TORPEDO (shape type 0)?
                CMP #1                  ;
                LDY PL4SHAPOFF          ; Load PLAYER4 shape data offset

                LDX PL4ROWNEW           ; Update vertical position of PLAYER4
                STX PL4ROW              ;

                LDA PL4HEIGHTNEW        ; Update PLAYER4 shape height
                STA L.HEIGHTCNT         ;
                STA PL4HEIGHT           ;

LOOP009         LDA PLSHAP1TAB,Y        ; Load PLAYER4 shape byte from shape data table
                BCS SKIP005             ; Skip if PLAYER4 not PHOTON TORPEDO (shape type 0)
                AND RANDOM              ; AND random bits to shape byte
SKIP005         STA PL4DATA,X           ; Store shape byte in PLAYER4 data area
                INY                     ;
                INX                     ;
                DEC L.HEIGHTCNT         ;
                BPL LOOP009             ; Next row of PLAYER4 shape

                LDA PL3SHAPTYPE         ; Repeat above with PLAYER3
                CMP #1                  ;
                LDY PL3SHAPOFF          ;
                LDX PL3ROWNEW           ;
                STX PL3ROW              ;
                LDA PL3HEIGHTNEW        ;
                STA L.HEIGHTCNT         ;
                STA PL3HEIGHT           ;
LOOP010         LDA PLSHAP1TAB,Y        ;
                BCS SKIP006             ;
                AND RANDOM              ;
SKIP006         STA PL3DATA,X           ;
                INX                     ;
                INY                     ;
                DEC L.HEIGHTCNT         ;
                BPL LOOP010             ;

                LDA PL2SHAPTYPE         ; Repeat above with PLAYER2
                CMP #1                  ;
                LDY PL2SHAPOFF          ;
                LDX PL2ROWNEW           ;
                STX PL2ROW              ;
                LDA PL2HEIGHTNEW        ;
                STA L.HEIGHTCNT         ;
                STA PL2HEIGHT           ;
LOOP011         LDA PLSHAP1TAB,Y        ;
                BCS SKIP007             ;
                AND RANDOM              ;
SKIP007         STA PL2DATA,X           ;
                INX                     ;
                INY                     ;
                DEC L.HEIGHTCNT         ;
                BPL LOOP011             ;

                LDY PL1SHAPOFF          ; Repeat above with PLAYER1 (without torpedo part)
                LDX PL1ROWNEW           ;
                STX PL1ROW              ;
                LDA PL1HEIGHTNEW        ;
                STA L.HEIGHTCNT         ;
                STA PL1HEIGHT           ;
LOOP012         LDA PLSHAP2TAB,Y        ;
                STA PL1DATA,X           ;
                INX                     ;
                INY                     ;
                DEC L.HEIGHTCNT         ;
                BPL LOOP012             ;

                LDY PL0SHAPOFF          ; Repeat above with PLAYER0 (without torpedo part)
                LDX PL0ROWNEW           ;
                STX PL0ROW              ;
                LDA PL0HEIGHTNEW        ;
                STA L.HEIGHTCNT         ;
                STA PL0HEIGHT           ;
LOOP013         LDA PLSHAP2TAB,Y        ;
                STA PL0DATA,X           ;
                INX                     ;
                INY                     ;
                DEC L.HEIGHTCNT         ;
                BPL LOOP013             ;

;*** (7) Update PLAYER horizontal positions ************************************
                LDA PL0COLUMN           ; Update horizontal position of PLAYER0
                STA HPOSP0              ;
                LDA PL1COLUMN           ; Update horizontal position of PLAYER1
                STA HPOSP1              ;
                LDA PL2COLUMN           ; Update horizontal position of PLAYER2
                STA HPOSP2              ;
                LDA PL3COLUMN           ; Update horizontal position of PLAYER3
                STA HPOSP3              ;
                LDA PL4COLUMN           ; Update horizontal position of PLAYER4
                STA HPOSM3              ;
                CLC                     ;
                ADC #2                  ;
                STA HPOSM2              ;
                ADC #2                  ;
                STA HPOSM1              ;
                ADC #2                  ;
                STA HPOSM0              ;

;*** (8) Rotate space objects horizontally and vertically **********************
                BIT SHIPVIEW            ; Skip if in Galactic Chart view
                BMI SKIP009             ;

;*** Rotate horizontally *******************************************************
                LDA JOYSTICKX           ; Skip if joystick centered horizontally
                BEQ SKIP008             ;

                STA JOYSTICKDELTA       ; Save JOYSTICKX (used in subroutine ROTATE)
                LDY MAXSPCOBJIND        ; Loop over all space objects in use
LOOP014         STY L.ZPOSOFF           ; Save offset to z-coordinate
                CLC                     ;

                TYA                     ;
                TAX                     ; X := offset to z-coordinate
                ADC #NUMSPCOBJ.ALL      ;
                TAY                     ; Y := offset to x-coordinate
                JSR ROTATE              ; Calc new x-coordinate (horizontal rot @ y-axis)

                TYA                     ;
                TAX                     ; X := offset to x-coordinate
                LDY L.ZPOSOFF           ; Y := offset to z-coordinate
                JSR ROTATE              ; Calc new z-coordinate (horizontal rot @ y-axis)
                DEY                     ;
                BPL LOOP014             ; Next space object

;*** Rotate vertically *********************************************************
SKIP008         LDA JOYSTICKY           ; Skip if joystick centered vertically
                BEQ SKIP009             ;

                STA JOYSTICKDELTA       ; Save JOYSTICKY (used in subroutine ROTATE)
                LDY MAXSPCOBJIND        ; Loop over all space objects in use
LOOP015         STY L.ZPOSOFF           ; Save offset to z-coordinate
                CLC                     ;

                TYA                     ;
                TAX                     ; X := offset to z-coordinate
                ADC #NUMSPCOBJ.ALL*2    ;
                TAY                     ; Y := offset to y-coordinate
                JSR ROTATE              ; Calc new y-coordinate (vertical rot @ x-axis)

                TYA                     ;
                TAX                     ; X := offset to y-coordinate
                LDY L.ZPOSOFF           ; Y := offset to z-coordinate
                JSR ROTATE              ; Calc new z-coordinate (vertical rot @ x-axis)
                DEY                     ;
                BPL LOOP015             ; Next space object

;*** (9) Move all space objects along z-axis (toward our starship) *************
SKIP009         LDX MAXSPCOBJIND        ; Loop over all space objects in use
LOOP016         CPX #NUMSPCOBJ.PL       ; Skip if PLAYFIELD space object (X index > 4)
                BCS SKIP010             ;

                LDA PL0SHAPTYPE,X       ; Skip if next PLAYER space obj is PHOTON TORPEDO (!)
                BEQ SKIP011             ;

SKIP010         SEC                     ; New z-coordinate := old z-coordinate -
                LDA ZPOSLO,X            ; ...our starship's velocity
                SBC VELOCITYLO          ; (signed 24-bit subtraction)
                STA ZPOSLO,X            ;
                LDA ZPOSHI,X            ;
                SBC VELOCITYHI          ;
                STA ZPOSHI,X            ;
                LDA ZPOSSIGN,X          ;
                SBC #0                  ;
                STA ZPOSSIGN,X          ;

SKIP011         DEX                     ;
                BPL LOOP016             ; Next space object

;*** (10) Add space object's velocity vector to space object's position vector *
                LDX MAXSPCOBJIND        ; Loop over all space objects in use
LOOP017         CPX #NUMSPCOBJ.NORM-1   ; Skip if space object is star (X index 5..16)...
                BNE SKIP012             ; ...because stars don't move by themselves
                LDX #4                  ;

SKIP012         TXA                     ;
LOOP018         TAY                     ; Loop over all 3 coordinates

                LDA #0                  ; Expand 8-bit velocity vector component to 16-bit:
                STA L.VELOCITYHI        ; ...16-bit velocity (high byte) = L.VELOCITYHI := 0
                LDA ZVEL,Y              ; ...16-bit velocity (low byte)  = A := ZVEL,Y
                BPL SKIP013             ; Skip if 16-bit velocity >= 0 (positive)

                EOR #$7F                ; 16-bit velocity < 0 (negative)...
                CLC                     ; ...calculate two's-complement of 16-bit velocity
                ADC #1                  ;
                BCS SKIP013             ;
                DEC L.VELOCITYHI        ;

SKIP013         CLC                     ; New coordinate := old coordinate + 16-bit velocity
                ADC ZPOSLO,Y            ; (signed 24-bit addition)
                STA ZPOSLO,Y            ;
                LDA ZPOSHI,Y            ;
                ADC L.VELOCITYHI        ;
                STA ZPOSHI,Y            ;
                LDA ZPOSSIGN,Y          ;
                ADC L.VELOCITYHI        ;
                STA ZPOSSIGN,Y          ;

                TYA                     ;
                CLC                     ;
                ADC #NUMSPCOBJ.ALL      ;
                CMP #144                ; (!)
                BCC LOOP018             ; Next coordinate

                DEX                     ;
                BPL LOOP017             ; Next space object

;*** (11) Correct over/underflow of PLAYER space objects' position vector ******
                LDY #NUMSPCOBJ.PL-1     ;
LOOP019         TYA                     ; Loop over all PLAYER space objects (X index < 5)
                TAX                     ;

                LDA #2                  ; Loop over all 3 coordinates
                STA L.VECCOMPIND        ;

LOOP020         LDA ZPOSSIGN,X          ; Load sign of coordinate
                CMP #2                  ;
                BCC SKIP015             ; Skip if sign = 0 (negative) or 1 (positive)

                ASL @                  ; SUMMARY: Space object out-of-bounds correction
                LDA #0                  ; If new coordinate > +65535 <KM> subtract 256 <KM>
                STA ZPOSSIGN,X          ; ...until new coordinate <= +65535 <KM>
                BCS SKIP014             ; If new coordinate < -65536 <KM> add 256 <KM>
                INC ZPOSSIGN,X          ; ...until new coordinate >= -65536 <KM>
                EOR #$FF                ;
SKIP014         STA ZPOSHI,X            ;

SKIP015         TXA                     ;
                CLC                     ;
                ADC #NUMSPCOBJ.ALL      ;
                TAX                     ;
                DEC L.VECCOMPIND        ;
                BPL LOOP020             ; Next coordinate

                DEY                     ;
                BPL LOOP019             ; Next space object

;*** (12) Calc perspective projection of space objects *************************
                LDA SHIPVIEW            ; Skip if in Long-Range Scan or Galactic Chart view
                CMP #$02                ;
                BCS SKIP019             ;

                LDX MAXSPCOBJIND        ; Loop over all space objects in use
LOOP021         LDA #255                ; Prep magic offscreen pixel number value
                LDY ZPOSSIGN,X          ; Compare sign of z-coordinate with view mode
                CPY SHIPVIEW            ;
                BEQ SKIP018             ; Equal? Space object is offscreen -> New space obj!

                LDA YPOSSIGN,X          ; Prepare projection division...
                BNE SKIP016             ; DIVIDEND (16-bit value) := ABS(y-coordinate)
                SEC                     ; (used in subroutine PROJECTION)
                LDA #0                  ;
                SBC YPOSLO,X            ;
                STA DIVIDEND            ;
                LDA #0                  ;
                SBC YPOSHI,X            ;
                STA DIVIDEND+1          ;
                JMP JUMP001             ;
SKIP016         LDA YPOSLO,X            ;
                STA DIVIDEND            ;
                LDA YPOSHI,X            ;
                STA DIVIDEND+1          ;

JUMP001         JSR PROJECTION          ; Calc pixel row number rel. to screen center
                JSR SCREENROW           ; Calc pixel row number rel. to top-left of screen

                LDA XPOSSIGN,X          ; Prepare projection division...
                BNE SKIP017             ; DIVIDEND (16-bit value) := ABS(x-coordinate)
                SEC                     ; (used in subroutine PROJECTION)
                LDA #0                  ;
                SBC XPOSLO,X            ;
                STA DIVIDEND            ;
                LDA #0                  ;
                SBC XPOSHI,X            ;
                STA DIVIDEND+1          ;
                JMP JUMP002             ;
SKIP017         LDA XPOSLO,X            ;
                STA DIVIDEND            ;
                LDA XPOSHI,X            ;
                STA DIVIDEND+1          ;

JUMP002         JSR PROJECTION          ; Calc pixel column number rel. to screen center
SKIP018         JSR SCREENCOLUMN        ; Calc pixel column number rel. to top-left of screen
                DEX                     ;
                BPL LOOP021             ; Next space object

;*** (13) Handle hyperwarp marker selection in Galactic Chart view *************
SKIP019         JSR SELECTWARP          ; Handle hyperwarp marker in Galactic Chart view

;*** (14) Compute and draw Long-Range Scan view star field on z-x plane ********
                BIT SHIPVIEW            ; Skip if not in Long-Range Scan view
                BVC SKIP022             ;

                LDX #$31                ; Draw our starship's shape
                JSR DRAWLINES           ;

                BIT GCSTATLRS           ; Skip if Long-Range Scan destroyed
                BVS SKIP022             ;

                LDX MAXSPCOBJIND        ; Loop over all space objects in use
LOOP022         LDA ZPOSHI,X            ; Load z-coordinate (high byte)
                LDY ZPOSSIGN,X          ; Load sign of z-coordinate
                BNE SKIP020             ;
                EOR #$FF                ; A := ABS(z-coordinate (high byte))
SKIP020         TAY                     ;
                LDA MAPTO80,Y           ; Calc pixel row number rel. to screen center
                JSR SCREENROW           ; Calc pixel row number rel. to top-left of screen

                LDA XPOSHI,X            ; Load x-coordinate (high byte)
                LDY XPOSSIGN,X          ; Load sign of x-coordinate
                BNE SKIP021             ;
                EOR #$FF                ; A := ABS(x-coordinate (high byte))
SKIP021         TAY                     ;
                LDA MAPTO80,Y           ; Calc pixel column number rel. to screen center
                JSR SCREENCOLUMN        ; Calc pixel column number rel. to top-left of screen

                DEX                     ;
                BPL LOOP022             ; Next space object

;*** (15) Update PLAYER shapes, heights, and colors ****************************

; DESCRIPTION
;
; In a loop over all PLAYERs, the following steps are executed:
;
; o   Clear the PLAYER shape offset and height.
;
; o   If in Galactic Chart view or in Long-Range Scan view, preload a random
;     color and a magic z-coordinate (distance value) for PLAYER3..4
;     (representing hyperwarp markers in Galactic Chart view and blips in the
;     Long-Range Scan view, like, for example, Zylon ships, meteors - or even
;     the Hyperwarp Target Marker during hyperwarp!).
;
; o   If in Front or Aft view, execute the following steps:
;
;      o   Skip dead PLAYERs.
;
;      o   Preload the distance value for the remaining live PLAYERs.
;
;      o   If we are in a starbase sector, combine PLAYER0..2 into a three-part
;          starbase shape. Compute the pixel column numbers and pixel row
;          numbers of PLAYER0..1 such that they are arranged left (PLAYER0) and
;          right (PLAYER1) of PLAYER2. In addition, preload a color mask, a
;          counter actually, that will make the starbase pulsate in brightness.
;
;     BUG (at $A512): The code at $A512 that skips the combination operation for
;     PLAYER2..4 jumps for PLAYER3..4 to SKIP025 at $A52A instead of SKIP026 at
;     $A52E. Thus it stores a color mask which does not only make the starbase
;     PLAYER0..2 pulsate in brightness but also PLAYER3..4 in a starbase sector,
;     for example the transfer vessel, photon torpedoes, etc. - or even the
;     Hyperwarp Target Marker when hyperwarping out of such a sector! Suggested
;     fix: None, code hard to untwist.
;
; o   After storing the color mask, check if the PLAYER shape is still above the
;     bottom edge of the PLAYFIELD.
;
;     BUG (at $A534): The test checks the vertical position of the top edge of
;     the PLAYER against the bottom edge of the PLAYFIELD above the Console
;     Panel Display (= Player/Missile pixel row number 204). This is not
;     completely accurate as the Console Panel Display starts at PM pixel row
;     number 208. For example, if you carefully navigate a starbase to the
;     bottom edge of the PLAYFIELD, at a certain point the center of the
;     starbase shape bleeds over the bottom edge of the PLAYFIELD (while
;     sometimes even losing its left and right wings!). Suggested fix: None, as
;     a more elaborate test may consume too many bytes of the cartridge ROM
;     memory in order to fix a rarely noticed visual glitch.
;
; o   Convert the preloaded distance value of a PLAYER space object closer than
;     $2000 (8192) <KM> into a range index of 0..15. PLAYER space objects more
;     distant than $2000 (8192) <KM> are skipped and not displayed.
;
;     Later, this range index will pick not only the correct brightness for the
;     PLAYER (the closer the space object the brighter its PLAYER) but also the
;     correct PLAYER shape cell and height (the closer the space object the
;     larger the PLAYER shape and height). 
;
; o   Update the PLAYER's shape offset and height. On the way to the shape
;     offset and height add the PLAYER's shape type to the range index and
;     divide it by 2 to arrive at the shape offset index and height index (the
;     same value). Use this index to pick the correct shape data and shape
;     heights from a set of shape cells and their corresponding heights, stored
;     in tables PLSHAPOFFTAB ($BE2F) and PLSHAPHEIGHTTAB ($BE7F), respectively.
;
;     Remember that magic distance value used in the Galactic Chart and
;     Long-Range Scan view? Its value of $F2 is actually part of a negative
;     z-coordinate which is inverted to $0D00, leading to a range index of 13,
;     which, after the division by 2, picks shape cell 6. Shape cell 6 (the
;     seventh shape cell) of all space objects (except the starbase) is the
;     Long-Range Scan blip's dot (see PLSHAPOFFTAB ($BE2F) and PLSHAPHEIGHTTAB
;     ($BE7F)).
;
; o   Update the PLAYER's color/brightness by picking the appropriate values
;     with the range index from lookup tables PLSHAPCOLORTAB ($BFD1) and
;     PLSHAPBRITTAB ($BFDB). Apply some special effects to the color/brightness
;     of certain PLAYERs, such as using random colors for Zylon basestars, or
;     using the precomputed pulsating brightness value for a starbase.

SKIP022         LDX #NUMSPCOBJ.PL       ; Loop over all PLAYER space objects (X index < 5)
LOOP023         DEX                     ;
                BPL SKIP023             ; Jump into loop body below
                JMP JUMP003             ; Loop is finished, skip loop body

;*** Clear PLAYER shape offsets and heights ************************************
SKIP023         LDA #0                  ;
                STA PL0SHAPOFF,X        ; Clear PLAYER shape offset
                STA PL0HEIGHTNEW,X      ; Clear new PLAYER shape height

;*** Preload stuff for hyperwarp markers and Long-Range Scan blips *************
                BIT SHIPVIEW            ; Skip if not in Galactic Chart view
                BPL SKIP024             ;

                CPX #3                  ; Next PLAYER space object if PLAYER0..2
                BCC LOOP023             ;

LOOP024         LDA RANDOM              ; Prep random color mask for warp markers/LRS blips
                LDY #$F2                ; Prep magic z-coordinate for warp markers/LRS blips
                BMI SKIP026             ; Unconditional jump

SKIP024         CMP PL0LIFE,X           ; Next PLAYER space object if this PLAYER not alive
                BEQ LOOP023             ;

                BVS LOOP024             ; Skip back if in Long-Range Scan view

;*** Preload stuff for other views *********************************************

                LDY PL0ZPOSHI,X         ; Prep z-coordinate (high byte)

;*** Combine PLAYER0..2 to starbase shape **************************************
                BIT ISSTARBASESECT      ; Skip if no starbase in this sector
                BVC SKIP026             ;

                CPX #2                  ; Skip if PLAYER2..4
                BCS SKIP025             ; (!)

                LDA PL2COLUMN           ; Calc new PM pixel column number for PLAYER0..1:
                CLC                     ; Load PLAYER2 (starbase center) pixel column number
                ADC PLSTARBAOFFTAB,X    ; ...add PLAYER left/right offset (starbase wings)
                STA PL0COLUMN,X         ; Store new PM pixel column number of starbase wing

                LDA PL2ROWNEW           ; Calc new PM pixel row number for PLAYER0..1:
                CLC                     ; Add vertical offset (= 4 PM pixels) to PLAYER2's
                ADC #4                  ;
                STA PL0ROWNEW,X         ; Store new PM pixel row number of starbase wing

                LDY PL2ZPOSHI           ; Prep Y with z-coordinate (high byte) of starbase

SKIP025         LDA COUNT256            ; Prep color mask with B3..0 of counter
                AND #$0F                ; ...(= brightness bits cause pulsating brightness)

SKIP026         STA L.COLORMASK         ; Store color mask

;*** Check if PLAYER is below PLAYFIELD bottom edge ****************************
                TYA                     ; A := z-coordinate (high byte)

                LDY PL0ROWNEW,X         ; Next PLAYER space object if top of PM shape...
                CPY #204                ; ...is below PLAYFIELD bottom... (!)
                BCS LOOP023             ; ...(PM pixel row number >= 204)

;*** Convert PLAYER z-coordinate to range index in 0..15 ***********************
                LDY SHIPVIEW            ; Skip if in Front view...
                BEQ SKIP027             ;
                EOR #$FF                ; ...else invert z-coordinate (high byte)

SKIP027         CMP #$20                ; Next PLAYER space object if this one too far away
                BCS LOOP023             ; ...(z-coordinate >= $20** (8192) <KM>)

                CMP #16                 ; Load z-coordinate (high byte) and...
                BCC SKIP028             ;
                LDA #15                 ;
SKIP028         STA L.RANGEINDEX        ; ...trim to range index in 0..15

;*** Update PLAYER shape offset and height *************************************
                ORA PL0SHAPTYPE,X       ; Calc offset to shape table (shape type+range index)
                LSR @                  ;
                TAY                     ; Divide by 2 to get offset in 0..7 into shape data
                LDA PLSHAPOFFTAB,Y      ; Update new PLAYER shape offset
                STA PL0SHAPOFF,X        ;
                LDA PLSHAPHEIGHTTAB,Y   ; Update new PLAYER shape height
                STA PL0HEIGHTNEW,X      ;

;*** Calculate PLAYER color/brightness value ***********************************
                TYA                     ; Pick color (B7..4) using PLAYER shape type
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                TAY                     ;
                LDA PLSHAPCOLORTAB,Y    ;
                CPY #8                  ; Pick random color if ZYLON BASESTAR (shape type 8)
                BNE SKIP029             ;
                EOR RANDOM              ;
SKIP029         LDY L.RANGEINDEX        ;
                EOR PLSHAPBRITTAB,Y     ; Pick brightness (B3..0) using range index and merge

                EOR L.COLORMASK         ; Modify color/brightness of PLAYER

                LDY PLCOLOROFFTAB,X     ; Get PLAYER color offset
                STA PL0COLOR,Y          ; Store color in PLAYER color register
                JMP LOOP023             ; Next PLAYER space object

;*** (16) Flash red alert ******************************************************
JUMP003         LDY #$AF                ; Prep PLAYFIELD2 color {BRIGHT BLUE-GREEN}
                LDX SHIELDSCOLOR        ; Prep Shields color {DARK GREEN} or {BLACK}

                LDA REDALERTLIFE        ; Skip if red alert is over
                BEQ SKIP030             ;

                DEC REDALERTLIFE        ; Decrement lifetime of red alert
                LDY #$4F                ; Prep PLAYFIELD2 color {BRIGHT ORANGE}

                AND #$20                ; Switch colors every 64 game loops
                BEQ SKIP030             ;

                LDX #$42                ; Load BACKGROUND color {DARK ORANGE}
                LDY #$60                ; Load PLAYFIELD2 color {DARK PURPLE BLUE}

SKIP030         STY PF2COLOR            ; Store PLAYFIELD2 color
                STX BGRCOLOR            ; Store BACKGROUND color

;*** (17) Update color of PLAYFIELD space objects (stars, explosion fragments) *
                LDX MAXSPCOBJIND        ; Loop over all PLAYFIELD space objs (X index > 4)
LOOP025         LDA ZPOSHI,X            ; Prep z-coordinate (high byte)
                LDY SHIPVIEW            ;
                CPY #1                  ; Skip if not in Aft view
                BNE SKIP032             ;

                CMP #$F0                ; Skip if star not too far (z < $F0** (-4096) <KM>)
                BCS SKIP031             ;
                JSR INITPOSVEC          ; Re-init position vector
SKIP031         EOR #$FF                ; Invert z-coordinate (high byte)

SKIP032         CMP #16                 ; Convert z-coordinate (high byte)
                BCC SKIP033             ; ...into range index 0..15
                LDA #15                 ;

SKIP033         ASL @                  ; Compute index to pixel color table:
                AND #$1C                ; Use bits B3..1 from range index as B4..2.
                ORA COUNT8              ; Combine with random bits B3..0 from counter

                TAY                     ;
                LDA FOURCOLORPIXEL,Y    ; Load 1-byte bit pattern for 4 pixels of same color
                STA L.FOURCOLORPIX      ; ...and temporarily save it

                LDA PIXELCOLUMN,X       ; Load pixel mask to mask 1 pixel out of 4 pixels:
                AND #$03                ; Use B1..0 from pixel column number...
                TAY                     ;
                LDA PIXELMASKTAB,Y      ; ...to pick mask to filter pixel in byte
                AND L.FOURCOLORPIX      ; ...AND with 1-byte bit pattern for 4 pixels
                STA PIXELBYTE,X         ; ...store byte (used in repaint step of game loop)

                DEX                     ;
                CPX #NUMSPCOBJ.PL       ;
                BCS LOOP025             ; Next PLAYFIELD space object

;*** (18) Skip input handling if in demo mode **********************************
                BIT ISDEMOMODE          ; If in demo mode skip to function keys
                BVC SKIP034             ;
                JMP SKIP040             ;

;*** (19) Handle keyboard input ************************************************
SKIP034         JSR KEYBOARD            ; Handle keyboard input

;*** (20) Handle joystick input ************************************************
                LDA PORTA               ; Load Joystick 0 directions
                TAY                     ; ...Bits B0..3 -> Right, left, down, up.
                AND #$03                ; ...Bit = 0/1 -> Stick pressed/not pressed
                TAX                     ; JOYSTICKY := +1 -> Up
                LDA STICKINCTAB,X       ; JOYSTICKY :=  0 -> Centered
                STA JOYSTICKY           ; JOYSTICKY := -1 -> Down
                TYA                     ;
                LSR @                  ;
                LSR @                  ;
                AND #$03                ;
                TAX                     ; JOYSTICKX := -1 -> Left
                LDA STICKINCTAB,X       ; JOYSTICKX :=  0 -> Centered
                STA JOYSTICKX           ; JOYSTICKX := +1 -> Right

;*** (21) Check if our starship's photon torpedoes have hit a target ***********
                JSR COLLISION           ; Check if our starship's photon torpedoes have hit

;*** (22) Handle joystick trigger **********************************************
                JSR TRIGGER             ; Handle joystick trigger

;*** (23) Handle Attack Computer and Tracking Computer *************************
                BIT GCSTATCOM           ; Skip if Attack Computer destroyed
                BVS SKIP038             ;

                LDA DRAINATTCOMP        ; Skip if Attack Computer off
                BEQ SKIP038             ;

                LDA SHIPVIEW            ; Skip if not in Front view
                BNE SKIP035             ;

                JSR UPDATTCOMP          ; Update Attack Computer Display

SKIP035         LDX TRACKDIGIT          ; Load index of tracked space object

                LDA ZYLONATTACKER       ; Skip if ship of current Zylon torpedo is tracked
                BMI SKIP036             ;
                TAX                     ; ...else override Tracking Computer...
                ORA #$80                ;
                STA ZYLONATTACKER       ; ...and mark Zylon torpedo's ship as being tracked

SKIP036         LDA PL0LIFE,X           ; Skip if tracked space object still alive
                BNE SKIP037             ;

                TXA                     ;
                EOR #$01                ;
                TAX                     ;
                LDA PL0LIFE,X           ; Check if other Zylon ship still alive
                BNE SKIP037             ; ...yes -> Keep new index
                LDX TRACKDIGIT          ; ...no  -> Revert to old index of tracked space obj

SKIP037         STX TRACKDIGIT          ; Store index of tracked space object

                LDA ISTRACKCOMPON       ; Skip if tracking computer is turned off
                BEQ SKIP038             ;

                LDA SHIPVIEW            ; Skip if in Long-Range Scan or Galactic Chart view
                CMP #2                  ;
                BCS SKIP038             ;

                EOR #$01                ;
                CMP ZPOSSIGN,X          ; Skip if tracked space object in our starship's...
                BEQ SKIP038             ; ...view direction

                TAX                     ;
                LDA TRACKKEYSTAB,X      ; Pick 'F' or 'A' (Front or Aft view) keyboard code
                STA KEYCODE             ; ...and store it (= emulate pressing 'F' or 'A' key)

;*** (24) Handle docking to starbase *******************************************
SKIP038         JSR DOCKING             ; Handle docking to starbase

;*** (25) Handle maneuvering ***************************************************
                JSR MANEUVER            ; Handle maneuvering photon torpedoes and Zylon ships

;*** (26) Was our starship hit by Zylon photon torpedo? ************************
                LDA ISSTARBASESECT      ; Skip hit check if in starbase sector
                BNE SKIP040             ;

                LDA PL2LIFE             ; Skip hit check if PLAYER2 (Zylon photon torpedo)...
                BEQ SKIP040             ; ...not alive

                LDY PL2ZPOSHI           ; Our starship was not hit if Zylon photon torpedo's
                INY                     ; ...z-coordinate is not in -256..255 <KM> or...
                CPY #$02                ;
                BCS SKIP040             ;

                LDY PL2XPOSHI           ; ...x-coordinate is not in -256..255 <KM> or...
                INY                     ;
                CPY #$02                ;
                BCS SKIP040             ;

                LDY PL2YPOSHI           ; ...y-coordinate is not in -256..255 <KM>.
                INY                     ;
                CPY #$02                ;
                BCS SKIP040             ;

;*** (27) Our starship was hit! ************************************************
                JSR DAMAGE              ; Damage or destroy some subsystem

                LDY #2                  ; Trigger explosion at PLAYER2 (Zylon photon torpedo)
                JSR INITEXPL            ;

                LDX #$7F                ; Prep HITBADNESS := SHIELDS HIT
                LDA SHIELDSCOLOR        ; Skip if Shields are up (SHIELDSCOLOR not {BLACK}).
                BNE SKIP039             ;

                LDX #$0A                ; Set Front view
                JSR SETVIEW             ;

                LDY #$23                ; Set title phrase "SHIP DESTROYED BY ZYLON FIRE"
                LDX #8                  ; Set mission bonus offset
                JSR GAMEOVER            ; Game over

                LDX #$5F                ; Hide Control Panel Display (bottom text window)
                LDY #$80                ;
                LDA #$08                ;
                JSR MODDLST             ;

                JSR CLRPLAYFIELD        ; Clear PLAYFIELD

                LDX #64                 ; Enable STARSHIP EXPLOSION noise (see SOUND)
                STX NOISEHITLIFE        ;

                LDX #$FF                ; Prep HITBADNESS := STARSHIP DESTROYED

SKIP039         STX HITBADNESS          ; Store HITBADNESS
                LDA #0                  ; Zylon photon torpedo lifetime := 0 game loops
                STA PL2LIFE             ;
                LDA #2                  ; Init Zylon photon torpedo trigger
                STA TORPEDODELAY        ;

                LDX #1                  ; ENERGY := ENERGY - 100 after photon torpedo hit
                JSR DECENERGY           ;

                LDX #$0A                ; Play noise sound pattern SHIELD EXPLOSION
                JSR NOISE               ;

;*** (28) Handle function keys *************************************************
SKIP040         LDY FKEYCODE            ; Prep old function key code
                LDA CONSOL              ; POKEY: Load function key code

                EOR #$FF                ; Store inverted and masked function key code
                AND #$03                ;
                STA FKEYCODE            ;
                BEQ SKIP042             ; Skip if no function key pressed

                DEY                     ;
                BPL SKIP042             ; Skip if SELECT or START still pressed
                STA IDLECNTHI           ; Reset idle counter to a value in 1..3 (?)
                CMP #2                  ; Skip if SELECT function key pressed
                BCS SKIP041             ;

                LDA #0                  ; START function key pressed:
                TAY                     ; Prep empty title phrase offset
                JMP INITSTART           ; Reenter game loop via INITSTART

SKIP041         INC MISSIONLEVEL        ; SELECT function key pressed:
                LDA MISSIONLEVEL        ; Cycle through next of 4 mission levels
                AND #$03                ;
                STA MISSIONLEVEL        ;
                JMP INITSELECT          ; Reenter game loop via INITSELECT

;*** (29) Update Control Panel Display *****************************************
SKIP042         JSR UPDPANEL            ; Update Control Panel Display

;*** (30) Handle hyperwarp *****************************************************
                JSR HYPERWARP           ; Handle hyperwarp

;*** (31) Update title line ****************************************************
                JSR UPDTITLE            ; Update title line

;*** (32) Flush game loop iteration ********************************************
                JSR FLUSHGAMELOOP       ; Move Zylon units, age torpedoes, elapse time

;*** (33) Jump back to begin of game loop **************************************
                JMP GAMELOOP            ; Next game loop iteration

;*******************************************************************************
;*                                                                             *
;*                                  VBIHNDLR                                   *
;*                                                                             *
;*                      Vertical Blank Interrupt Handler                       *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine is executed during the Vertical Blank Interrupt (VBI) when the
; TV beam has reached the bottom-right corner of the TV screen and is switched
; off to return to the top-left position. This situation is called the "vertical
; blank phase".
;
; This subroutine signals its execution with flag ISVBISYNC ($67) (which is
; examined by GAMELOOP ($A1F3) to synchronize the execution of the game loop
; with the start of this subroutine). Then it switches the character set to the
; ROM character set, sets the BACKGROUND color depending on the severity of a
; Zylon photon torpedo hit and view mode, copies PLAYER and PLAYFIELD color
; registers to their corresponding hardware registers, clears the Player/Missile
; collision registers, calls the sound effects code in subroutine SOUND ($B2AB),
; and increments the idle counter. If the idle counter reaches the value $8000
; the title phrase is cleared and the game is switched to demo mode.
;
; BUG (at $A6EC): Because the values of SHIPVIEW ($D0) are $00, $01, $40, and
; $80, a value of 3 overspecifies the comparison. Suggested fix: Replace CMP #3
; with CMP #2, which may make the code clearer.
;
; BUG (at $A712): Demo mode is entered via a JMP instruction, which proceeds
; directly into GAMELOOP ($A1F3). Thus code execution never returns to pop the
; registers pushed on the stack during entry of this subroutine. Suggested fix:
; None.

VBIHNDLR        LDA #$FF                ; Signals entering Vertical Blank Interrupt
                STA ISVBISYNC           ;

                LDA #>ROMCHARSET        ; Switch character set to ROM character set
                STA CHBASE              ;

                LDX BGRCOLOR            ; Preload BACKGROUND color
                LDA RANDOM              ; Preload random number
                BIT HITBADNESS          ; Check if our starship was hit
                BVC SKIP044             ; If HITBADNESS has a value of...
                BMI SKIP043             ; $00 -> NO HIT             (BGR color := unchanged)
                AND #$72                ; $7F -> SHIELDS HIT        (BGR color := %01rr00r0)
                ORA #$40                ; $FF -> STARSHIP DESTROYED (BGR color := %01rr00r0)
SKIP043         TAX                     ;
SKIP044         LDA SHIPVIEW            ; Skip if in Front or Aft view
                CMP #3                  ; (!)
                BCC SKIP045             ;
                LDX #$A0                ; Preload BACKGROUND color {DARK BLUE GREEN}...
SKIP045         STX BGRCOLOR            ; Store BACKGROUND color

                LDX #8                  ; Copy all color registers to hardware registers
LOOP026         LDA PL0COLOR,X          ;
                STA COLPM0,X            ;
                DEX                     ;
                BPL LOOP026             ;

                STA HITCLR              ; Clear Player/Missile collision registers

                JSR SOUND               ; Call sound effects

                INC IDLECNTLO           ; Increment 16-bit idle counter
                BNE SKIP046             ;
                LDA IDLECNTHI           ;
                BMI SKIP046             ;
                INC IDLECNTHI           ;
                BPL SKIP046             ; Skip if idle counter value of $8000 not reached yet

                LDY #$00                ; Prep empty title phrase offset
                JMP INITDEMO            ; Enter demo mode (!)

SKIP046         JMP JUMP004             ; Return via DLI return code

;*******************************************************************************
;*                                                                             *
;*                                  DLSTHNDLR                                  *
;*                                                                             *
;*                       Display List Interrupt Handler                        *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine is executed during the Display List Interrupt (DLI). It
; switches the character set to the ROM character set if the DLI occurs at ANTIC
; line 96 (video line 192), otherwise to the custom character set. The former
; happens in the Galactic Chart view where the ROM character set is used in the
; Galactic Chart Panel Display.
;
; Then, the DLI PLAYFIELD colors are copied to the corresponding hardware
; registers and the values of the collision hardware registers for PLAYER3..4
; (our starship's photon torpedoes) are copied to the corresponding zero page
; variables PL3HIT ($82) and PL4HIT ($83).

DLSTHNDLR       PHA                     ; Push A
                TXA                     ;
                PHA                     ; Push X
                TYA                     ;
                PHA                     ; Push Y

                LDA #>ROMCHARSET        ; Switch to ROM charset if ANTIC line counter = 96
                LDY VCOUNT              ; ...else switch to custom character set
                CPY #96                 ;
                BEQ SKIP047             ;
                LDA #>CHARSET           ;
SKIP047         STA CHBASE              ;

                LDX #4                  ; Loop over all PLAYFIELD colors
                STA WSYNC               ; Stop and wait for horizontal TV beam sync
LOOP027         LDA PF0COLORDLI,X       ; Copy DLI PLAYFIELD colors to hardware registers
                STA COLPF0,X            ;
                DEX                     ;
                BPL LOOP027             ; Next PLAYFIELD color

                LDA M0PL                ; Merge MISSILE-to-PLAYER collision registers...
                ORA M1PL                ;
                ORA M2PL                ;
                ORA M3PL                ;
                STA PL4HIT              ; ...and store them in PL4HIT
                LDA P3PL                ; Copy PLAYER3-to-PLAYER coll. register to PL3HIT
                STA PL3HIT              ;

JUMP004         PLA                     ; Pop Y
                TAY                     ;
                PLA                     ; Pop X
                TAX                     ;
                PLA                     ; Pop A
                RTI                     ; Return from interrupt

;*******************************************************************************
;*                                                                             *
;*                                  IRQHNDLR                                   *
;*                                                                             *
;*                       Interrupt Request (IRQ) Handler                       *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine is executed during immediate interrupt requests (IRQs), such
; as after pressing a key on the keyboard. It clears and disables all IRQs
; except the interrupt raised by a pressed key. If a key has been pressed, its
; hardware code is collected and the bits of the SHIFT and CONTROL keys are
; added. The resulting keyboard code is stored in KEYCODE ($CA).

IRQHNDLR        PHA                     ; Push A
                LDA #0                  ; POKEY: Disable all IRQs
                STA IRQEN               ;
                LDA #$40                ; POKEY: Enable keyboard interrupt (IRQ)
                STA IRQEN               ;
                LDA KBCODE              ; POKEY: Load keyboard key code
                ORA #$C0                ; Combine with SHIFT and CONTROL key bits
                STA KEYCODE             ; Store keyboard code
                PLA                     ; Pop A
                RTI                     ; Return from interrupt

;*******************************************************************************
;*                                                                             *
;*                                  DRAWLINES                                  *
;*                                                                             *
;*                     Draw horizontal and vertical lines                      *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Draws the Attack Computer Display (in Front view), cross hairs (in Front and
; Aft view), and our starship's shape (in Long-Range Scan view) on the PLAYFIELD
; (if the Attack Computer is not destroyed) by being passed an offset to table
; DRAWLINESTAB ($BAF9). This table consists of a list of 3-byte elements,
; terminated by an end marker byte ($FE). Each such element defines a single
; horizontal or vertical line, and is passed via memory addresses DIRLEN ($A4),
; PENROW ($A5), and PENCOLUMN ($A6) to subroutine DRAWLINE ($A782), which
; executes the actual drawing. See subroutine DRAWLINE ($A782) and table
; DRAWLINESTAB ($BAF9) for a description of the 3-byte elements. 
;
; With every call of this subroutine the blip cycle counter is initialized to
; the start of the DELAY phase (see subroutine UPDATTCOMP ($A7BF)).
;
; NOTE: The entry to this subroutine is in mid-code, not at the beginning.
;
; INPUT
;
;   X = Offset into DRAWLINESTAB ($BAF9). Used values are:
;     $00 -> Draw Attack Computer Display and cross hairs (Front view)
;     $2A -> Draw Aft view cross hairs (Aft view)
;     $31 -> Draw our starship's shape (Long-Range Scan view)

LOOP028         STA DIRLEN,Y            ; Store byte of 3-byte element
                INX                     ;
                DEY                     ;
                BPL SKIP048             ; Next byte of 3-byte element until 3 bytes copied
                JSR DRAWLINE            ; Draw line on PLAYFIELD

DRAWLINES       LDA #5                  ; Init blip cycle to DELAY phase...
                STA BLIPCYCLECNT        ; ...delays drawing each row

                BIT GCSTATCOM           ; Return if Attack Computer destroyed
                BVS SKIP049             ;

                LDY #2                  ;
SKIP048         LDA DRAWLINESTAB,X      ; Load byte of 3-byte element
                CMP #$FE                ; Loop until end marker byte ($FE) encountered
                BNE LOOP028             ;
SKIP049         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  DRAWLINE                                   *
;*                                                                             *
;*                  Draw a single horizontal or vertical line                  *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Draws a single horizontal or vertical transparent line.
;
; There are two entries to this subroutine:
;
; (1)  DRAWLINE ($A782) is entered from subroutine DRAWLINES ($A76F) to draw a
;      line in COLOR1.
;
; (2)  DRAWLINE2 ($A784) is entered from subroutine UPDATTCOMP ($A7BF) to draw
;      the blip in COLOR2 in the Attack Computer Display.
;
; The position, direction, and length of the line is defined by three bytes
; passed in memory addresses DIRLEN ($A4), PENROW ($A5), and PENCOLUMN ($A6). 
;
; A drawing operation draws one transparent line. It uses both the color
; register number of the overwritten (old) and the overwriting (new) pixel to
; decide on the new pixel color register number. This results in a transparent
; drawing effect. See the table below for all resulting combinations of color
; registers.
;
; +-----------+---------------+
; |           |   Old Color   |
; |           |   Register    |
; | New Color +---------------+
; | Register  | 0 | 1 | 2 | 3 |
; +-----------+---+---+---+---+
; |         0 | 0 | 1 | 2 | 3 |
; +-----------+---+---+---+---+
; |         1 | 1 | 1 | 3 | 3 |
; +-----------+---+---+---+---+
; |         2 | 2 | 3 | 2 | 3 |
; +-----------+---+---+---+---+
; |         3 | 3 | 3 | 3 | 3 |
; +-----------+---+---+---+---+
;
; For example, COLOR1 overwritten by COLOR2 yields COLOR3. If you look closely
; at the blip (in COLOR2) on the Attack Computer Display (in COLOR1) the lines
; of the Attack Computer Display shine through (in COLOR3) where they overlap.
;
; INPUT
;
;   DIRLEN    ($A4) = B7 = 0 -> Draw line to the right
;                     B7 = 1 -> Draw line downward
;                     B6..0  -> Length of line in pixels
;   PENROW    ($A5) = Start pixel row number of line
;   PENCOLUMN ($A6) = Start pixel column number of line

L.PIXELBYTEOFF  = $6A                   ; Within-row-offset to byte with pixel in PLAYFIELD
L.BITPAT        = $6B                   ; 1-byte bit pattern for 4 pixels of same color
L.DIRSAV        = $6E                   ; Saves DIRLEN

DRAWLINE        LDA #$55                ; Copy 1-byte bit pattern for 4 pixels of COLOR1
DRAWLINE2       STA L.BITPAT            ;
                LDA DIRLEN              ; Copy direction (and length) of line
                STA L.DIRSAV            ;
                AND #$7F                ; Strip direction bit
                STA DIRLEN              ; Store length of line

LOOP029         LDY PENROW              ; Loop over length of line to be drawn
                LDA PFMEMROWLO,Y        ; Point MEMPTR to start of pen's pixel row...
                STA MEMPTR              ; ...in PLAYFIELD memory
                LDA PFMEMROWHI,Y        ;
                STA MEMPTR+1            ;

                LDA PENCOLUMN           ; Calc and store pen's byte-within-row offset
                LSR @                  ;
                LSR @                  ;
                STA L.PIXELBYTEOFF      ;

                LDA PENCOLUMN           ; Calc pixel-within-byte index
                AND #$03                ;
                TAY                     ;

                LDA PIXELMASKTAB,Y      ; Pick mask to filter pixel in byte
                AND L.BITPAT            ; ...AND with bit pattern for 4 pixels of same color
                LDY L.PIXELBYTEOFF      ;
                ORA (MEMPTR),Y          ; Blend byte with new pixel and PLAYFIELD byte
                STA (MEMPTR),Y          ; ...and store it back in PLAYFIELD memory

                BIT L.DIRSAV            ; Check direction bit B7
                BPL SKIP050             ;
                INC PENROW              ; If B7 = 1 -> Increment pen's pixel row number
                BNE SKIP051             ;
SKIP050         INC PENCOLUMN           ; If B7 = 0 -> Increment pen's pixel column number

SKIP051         DEC DIRLEN              ;
                BNE LOOP029             ; Next pixel of line
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 UPDATTCOMP                                  *
;*                                                                             *
;*                       Update Attack Computer Display                        *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Draws the blip of the tracked space object and the lock-on markers into the
; Attack Computer Display. The actual drawing follows a cycle of 11 game loop
; iterations (numbered by this subroutine as "blip cycles" 0..10), which can be
; divided into three phases:
;
; (1)  Blip cycle 0..4: Draw blip shape row-by-row
;
;      Draw the blip's shape into the Attack Computer Display, one row each blip
;      cycle. After 5 blip cycles the blip shape is complete and completely
;      visible because between blip cycles, that is, game loop iterations, the
;      PLAYFIELD is not erased (only the PLAYFIELD space objects are). Drawing
;      is executed by branching to entry DRAWLINE2 ($A784) of subroutine
;      DRAWLINE ($A782). The blip shape is retrieved from table BLIPSHAPTAB
;      ($BF6E).
;
; (2)  Blip cycle 5..9: Delay
;
;      Delay the execution of blip cycle 10.
;
; (3)  Blip cycle 10: Update Attack Computer Display
;
;      After verifying that the tracked space object is alive, calculate the
;      blip's relative top-left pixel column and row number. The resulting
;      values are in -11..11 and -6..4, relative to the blip's top-left
;      reference position at pixel column number 131 and pixel row number 77,
;      respectively. 
;
;      Filter the Attack Computer Display area: Only pixels of COLOR1 within the
;      inner frame area (a 28 pixel wide x 15 pixel high rectangle with its
;      top-left corner at pixel column number 120 and pixel row number 71) pass
;      the filter operation. This effectively erases the blip.
;
;      If the blip is within -2..+2 pixels off its horizontal reference position
;      (pixel column numbers 129..132) then the tracked space object is in x
;      lock-on. Draw the x lock-on marker. 
;
;      If the tracked space object is in x lock-on and the blip is within -2..+1
;      pixels off its vertical reference position (pixel column numbers 75..78)
;      then the tracked space object is in x and y lock-on. Draw also the y
;      lock-on marker. 
;
;      If the tracked space object is in x and y lock-on and the tracked space
;      object's z-coordinate < +3072 (+$0C**) <KM> then the tracked space object
;      is in x, y and z lock-on. Draw also the z lock-on marker. 
;
;      If the tracked space object is in x, y, and z lock-on (and thus in
;      optimal firing range) set the ISINLOCKON ($A3) flag.
;
;      The following sketches show the Attack Computer Display area overlaid
;      with the Attack Computer Display frame:
;
;          119                                 119
;      70 ##############################    70 ##############################
;         #         ....#....          #       #             #              #
;         #         ....#....          #       #             #              #
;         #         ....#....          #       #             #              #
;         #         ....#....          #       #             #              #
;         #      ###############       #       #......###############.......#
;         #XXXX  #  .........  #   XXXX#       #......#.............#.......#
;         #      #  ..$......  #       #       #......#....$........#.......#
;         ########  .........  #########       ########.............#########
;         #      #  .........  #       #       #......#.............#.......#
;         #      #  .........  #       #       #YYYY..#.............#...YYYY#
;         #      ###############       #       #......###############.......#
;         #         ....#....          #       #.............#..............#
;         #         ....#....          #       #             #              #
;         #         ....#....          #       #             #              #
;         #         ....#....          #       #             #              #
;         ##############################       ##############################
;
;         X = x lock-on marker                 Y = y lock-on marker
;         . = x lock-on blip zone              . = y lock-on blip zone
;         $ = Blip's top-left reference        $ = Blip's top-left reference
;             position                             position
;
;         119
;      70 ##############################
;         #             #              #
;         #             #              #
;         #             #              #
;         #             #              #
;         #      ###############       #
;         #      #             #       #
;         #      #    $        #       #
;         ########             #########
;         #      #             #       #
;         #      #             #       #
;         #      ###############       #
;         #             #              #
;         #             #              #
;         #        ZZ   #  ZZ          #
;         #        ZZ   #  ZZ          #
;         ##############################
;
;         Z = z lock-on marker
;         $ = Blip's top-left reference
;             position

L.SHIFTSHAP     = $6C                   ; Saves shifted byte of blip shape bit pattern

UPDATTCOMP      LDX TRACKDIGIT          ; Load index of tracked space object
                LDY BLIPCYCLECNT        ; Load blip cycle counter
                CPY #5                  ;
                BCS SKIP054             ; Skip drawing blip if blip cycle > 5

;*** Blip cycle 0..4: Draw blip shape one row each cycle ***********************
                LDA BLIPCOLUMN          ; Init pen's pixel column number...
                STA PENCOLUMN           ; ...with top position of blip shape
                LDA BLIPSHAPTAB,Y       ; Load bit pattern of one row of blip shape
LOOP030         ASL @                  ; Shift bit pattern one position to the left
                STA L.SHIFTSHAP         ; Temporarily save shifted shape byte
                BCC SKIP052             ; Skip if shifted-out bit = 0

                LDA #$81                ; Store "draw a line of 1 pixel length downward"
                STA DIRLEN              ; ...for call to DRAWLINE2

                LDA BLIPROW             ; Init pen's pixel row number...
                STA PENROW              ; ...with leftmost position of blip shape
                LDA #$AA                ; Load 1-byte bit pattern for 4 pixels of COLOR2
                JSR DRAWLINE2           ; Draw pixel on PLAYFIELD

SKIP052         INC PENCOLUMN           ; Move pen one pixel to the right
                LDA L.SHIFTSHAP         ; Reload shifted shape byte
                BNE LOOP030             ; Next horizontal pixel of blip shape

                INC BLIPROW             ; Move pen one pixel downward
SKIP053         INC BLIPCYCLECNT        ; Increment blip cycle counter
                RTS                     ; Return

;*** Blip cycle 5..9: Delay ****************************************************
SKIP054         CPY #10                 ; Return if blip cycle < 10
                BCC SKIP053             ;

;*** Blip cycle 10: Calculate new blip pixel row and column numbers ************
                LDA PL0LIFE,X           ; Skip if tracked object not alive
                BEQ SKIP059             ;

                LDA XPOSHI,X            ; Map x-coordinate of tracked space obj to -11..11:
                LDY XPOSSIGN,X          ; Skip if tracked object on left screen half (x >= 0)
                BEQ SKIP055             ;

                CMP #12                 ; Skip if x of tracked obj < +$0C** (< 3327) <KM>
                BCC SKIP056             ;
                LDA #11                 ; Prep relative pixel column number of 11, skip
                BPL SKIP056             ;

SKIP055         CMP #-11                ; Skip if x of tracked obj >= -($0B**) (>=-2816) <KM>
                BCS SKIP056             ;
                LDA #-11                ; Prep relative pixel column number of -11

SKIP056         CLC                     ; Add 131 (= blip's top-left reference pixel column)
                ADC #131                ;
                STA BLIPCOLUMN          ; BLIPCOLUMN := 131 + -11..11

                LDA YPOSHI,X            ; Map y-coordinate of tracked space obj to -6..4:
                EOR #$FF                ; Mirror y-coordinate on y-axis (displacement of +1)
                LDY YPOSSIGN,X          ; Skip if tracked obj on lower screen half (y < 0)
                BNE SKIP057             ;

                CMP #5                  ; Skip if mirrored y of tracked obj < +$05** <KM>
                BCC SKIP058             ;
                LDA #4                  ; Prep relative pixel row number of 4, skip
                BPL SKIP058             ;

SKIP057         CMP #-6                 ; Skip if mirrored y of tracked obj >= -($06**) <KM>
                BCS SKIP058             ;
                LDA #-6                 ; Prep relative pixel row number of -6

SKIP058         CLC                     ; Add 77 (= blip's top-left ref. pixel row number)
                ADC #77                 ;
                STA BLIPROW             ; BLIPROW := 77 + -6..4

                LDA #0                  ; Reset blip cycle
                STA BLIPCYCLECNT        ;

;*** Filter Attack Computer Display frame area *********************************
                                        ; PLAYFIELD address of top-left of Attack Computer
PFMEM.C120R71   = PFMEM+71*40+120/4     ; Display's inner frame @ pixel column 120, row 71

SKIP059         LDA #<PFMEM.C120R71     ; Point MEMPTR to start of frame's...
                STA MEMPTR              ; ...inner top-left corner at column 120, row 71...
                LDA #>PFMEM.C120R71     ; ...in PLAYFIELD memory
                STA MEMPTR+1            ;

                LDX #14                 ; Traverse a 28 x 15 pixel rect of PLAYFIELD memory
LOOP031         LDY #6                  ;
LOOP032         LDA (MEMPTR),Y          ; Load byte (4 pixels) from PLAYFIELD memory
                AND #$55                ; Filter COLOR1 pixels
                STA (MEMPTR),Y          ; Store byte (4 pixels) back to PLAYFIELD memory
                DEY                     ;
                BPL LOOP032             ; Next 4 pixels in x-direction

                CLC                     ; Add 40 to MEMPTR
                LDA MEMPTR              ; (40 bytes = 160 pixels = 1 PLAYFIELD row of pixels)
                ADC #40                 ;
                STA MEMPTR              ;
                BCC SKIP060             ;
                INC MEMPTR+1            ;

SKIP060         DEX                     ;
                BPL LOOP031             ; Next row of pixels in y-direction

;*** Prepare lock-on marker checks *********************************************
                LDX TRACKDIGIT          ; Preload index of tracked space obj to check z-range
                INY                     ; Y := 0, preloaded value of ISINLOCKON

;*** Draw lock-on markers ******************************************************
                                        ; PLAYFIELD addresses of
PFMEM.C120R76   = PFMEM+76*40+120/4     ; ...x lock-on marker @ pixel column 120, row 76
PFMEM.C144R76   = PFMEM+76*40+144/4     ; ...x lock-on marker @ pixel column 144, row 76
PFMEM.C120R80   = PFMEM+80*40+120/4     ; ...y lock-on marker @ pixel column 120, row 80
PFMEM.C144R80   = PFMEM+80*40+144/4     ; ...y lock-on marker @ pixel column 144, row 80
PFMEM.C128R84   = PFMEM+84*40+128/4     ; ...z lock-on marker @ pixel column 128, row 84
PFMEM.C128R85   = PFMEM+85*40+128/4     ; ...z lock-on marker @ pixel column 128, row 85
PFMEM.C136R84   = PFMEM+84*40+136/4     ; ...z lock-on marker @ pixel column 136, row 84
PFMEM.C136R85   = PFMEM+85*40+136/4     ; ...z lock-on marker @ pixel column 136, row 85

                LDA LOCKONLIFE          ; If lock-on lifetime expired redraw lock-on markers
                BEQ SKIP061             ;

                DEC LOCKONLIFE          ; else decrem. lock-on lifetime, skip drawing markers
                BNE SKIP062             ;

SKIP061         LDA BLIPCOLUMN          ; Skip x, y, and z lock-on marker if blip's...
                CMP #129                ; ...top-left pixel column number not in 129..132
                BCC SKIP062             ;
                CMP #133                ;
                BCS SKIP062             ;

                LDA #$AA                ; Draw x lock-on marker (4 horiz. pixels of COLOR2)
                STA PFMEM.C120R76       ; ...at pixel column 120, row 76
                STA PFMEM.C144R76       ; ...at pixel column 144, row 76

                LDA BLIPROW             ; Skip y and z lock-on marker if blip's...
                CMP #75                 ; ...top-left pixel row number not in 75...78
                BCC SKIP062             ;
                CMP #79                 ;
                BCS SKIP062             ;

                LDA #$AA                ; Draw y lock-on marker (4 horiz. pixels of COLOR2)
                STA PFMEM.C120R80       ; ...at pixel column 120, row 80
                STA PFMEM.C144R80       ; ...at pixel column 144, row 80

                LDA ZPOSHI,X            ; Skip z lock-on marker if z >= +$0C** (>= 3072) <KM>
                CMP #12                 ;
                BCS SKIP062             ;

                LDY #$A0                ; Draw z lock-on marker (2 horiz. pixels of COLOR2)
                STY PFMEM.C128R84       ; ...at pixel column 128, row 84 (prep lock-on flag)
                STY PFMEM.C128R85       ; ...at pixel column 128, row 85
                STY PFMEM.C136R84       ; ...at pixel column 136, row 84
                STY PFMEM.C136R85       ; ...at pixel column 136, row 85

SKIP062         STY ISINLOCKON          ; Store lock-on flag (> 0 -> Tracked obj locked on)
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  HYPERWARP                                  *
;*                                                                             *
;*                              Handle hyperwarp                               *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Handles the hyperwarp sequence, which transports our starship from one sector
; to another. It can be divided into four phases:
;
; (1)  ACCELERATION PHASE
;
;      The ACCELERATION PHASE is entered after the hyperwarp sequence has been
;      engaged in subroutine KEYBOARD ($AFFE) by pressing the 'H' key.
;
;      The Hyperwarp Target Marker appears and our starship begins to
;      accelerate. When our starship's velocity reaches 128 <KM/H> (the VELOCITY
;      readout of the Control Panel Display displays "50"), the STAR TRAIL phase
;      is entered. 
;
;      The Hyperwarp Target Marker is represented by a space object some fixed
;      distance away in front of our starship as PLAYER3. It has a lifetime of
;      144 game loop iterations and is tracked. Thus, tracking handling in
;      subroutine UPDATTCOMP ($A7BF) provides drawing the x and y lock-on
;      markers in the Attack Computer Display when the Hyperwarp Target Marker
;      is centered. 
;
;      A temporary arrival location on the Galactic Chart was saved when the
;      hyperwarp was engaged in subroutine KEYBOARD ($AFFE). During the
;      ACCELERATION PHASE (and the subsequent STAR TRAIL PHASE) this location is
;      constantly updated depending on how much the Hyperwarp Target Marker
;      veers off its center position.
;
;      The actual arrival hyperwarp marker row and column numbers on the
;      Galactic Chart are the sum of the temporary arrival hyperwarp marker row
;      and column numbers stored when engaging the hyperwarp in subroutine
;      KEYBOARD ($AFFE) and the number of Player/Missile (PM) pixels which the
;      Hyperwarp Target Marker is off-center vertically and horizontally,
;      respectively, at the end of the STAR TRAIL PHASE.
;
;      NOTE: The used vertical center value of 119 PM pixels is the PM pixel row
;      number of the top edge of the centered Hyperwarp Target Marker (from top
;      to bottom: 8 PM pixels to the start of Display List + 16 PM pixels blank
;      lines + 100 PM pixels to the vertical PLAYFIELD center - 5 PM pixels
;      relative offset of the Hyperwarp Target Marker's shape center to the
;      shape's top edge = 119 PM pixels). Recall also that PLAYERs at
;      single-line resolution have PM pixels that are half as high as they are
;      wide.
;
;      NOTE: The used horizontal center value of 125 PM pixels is the PM pixel
;      row number of the left edge of the centered Hyperwarp Target Marker (from
;      left to right: 127 PM pixels to the PLAYFIELD center - 3 PM pixels
;      relative offset of the Hyperwarp Target Marker's shape center to the
;      shape's left edge = 125 PM pixels).
;
;      If during the ACCELERATION PHASE (and the subsequent STAR TRAIL PHASE)
;      you switch the Front view to another view, the Hyperwarp Target Marker
;      changes to a random position which results in arriving at a random
;      destination sector.
;
;      During the ACCELERATION PHASE (and the subsequent STAR TRAIL PHASE) in
;      all but NOVICE missions, the Hyperwarp Target Marker veers off with
;      random velocity in x and y direction, which is changed during 6% of game
;      loop iterations. Table VEERMASKTAB ($BED7) limits the maximum veer-off
;      velocity depending on the mission level:
;
;      +-----------+-----------------------------+
;      |  Mission  |      Veer-Off Velocity      |
;      +-----------+-----------------------------+
;      | NOVICE    |                   0  <KM/H> |
;      | PILOT     |  -63..-16, +16..+63  <KM/H> |
;      | WARRIOR   |  -95..-16, +16..+95  <KM/H> |
;      | COMMANDER | -127..-16, +16..+127 <KM/H> |
;      +-----------+-----------------------------+
;
; (2)  STAR TRAIL PHASE
;
;      When our starship's velocity reaches a velocity of 128 <KM/H> (the
;      VELOCITY readout of the Control Panel Display displays "50"), in addition
;      to all effects of the ACCELERATION PHASE, multiple star trails begin to
;      appear while our starship continues to accelerate. Each star trail is
;      initialized in subroutine INITTRAIL ($A9B4).
;
; (3)  HYPERSPACE PHASE
;
;      When our starship's velocity reaches a velocity of 254 <KM/H> (the
;      VELOCITY readout of the Control Panel Display displays "99") our starship
;      enters the HYPERSPACE PHASE (the VELOCITY readout of the Control Panel
;      Display displays the infinity symbol).
;
;      During the first pass of the HYPERSPACE PHASE the hyperwarp state is set
;      to HYPERSPACE. This makes the stars and the Hyperwarp Target Marker
;      disappear in GAMELOOP ($A1F3). Then, the beeper sound pattern HYPERWARP
;      TRANSIT is played in subroutine BEEP ($B3A6), the hyperwarp distance and
;      required hyperwarp energy is calculated in subroutine CALCWARP ($B1A7),
;      and the title line is preloaded with "HYPERSPACE". Code execution returns
;      via calling subroutine CLEANUPWARP ($A98D) where game variables are
;      already initialized to their post-hyperwarp values.
;
;      During subsequent passes of the HYPERSPACE PHASE, the calculated
;      hyperwarp energy is decremented in chunks of 10 energy units. Code
;      execution returns via calling subroutine DECENERGY ($B86F), which
;      decrements our starship's energy. After the calculated hyperwarp energy
;      is spent the DECELERATION PHASE is entered.
;
; (4)  DECELERATION PHASE
;
;      The title line flashes "HYPERWARP COMPLETE", the star field reappears and
;      our starship decelerates to a stop. The Engines and the hyperwarp are
;      disengaged and stopped in subroutine ENDWARP ($A987), the arrival
;      coordinates on the Galactic Chart are initialized, as well as the
;      vicinity mask.
;
;      The vicinity mask limits the position vector components (coordinates) of
;      space objects in the arrival sector relative to our starship. The
;      vicinity mask is picked from table VICINITYMASKTAB ($BFB3) by an index
;      calculated by the arrival y-coordinate modulo 8: The more you have placed
;      the arrival hyperwarp marker in the vertical center of a sector on the
;      Galactic Chart, the closer space objects in this sector will be to our
;      starship. For example, if you placed the arrival hyperwarp marker exactly
;      in the vertical middle of the sector the index will be 3, thus the space
;      objects inside the arrival sector will be in the vicinity of <= 4095 <KM>
;      of our starship. The following table lists the possible coordinates
;      depending on the calculated index:
;
;      +-------+-----------------------+
;      | Index |    ABS(Coordinate)    |
;      +-------+-----------------------+
;      |   0   | <= 65535 ($FF**) <KM> |
;      |   1   | <= 65535 ($FF**) <KM> |
;      |   2   | <= 16383 ($3F**) <KM> |
;      |   3   | <=  4095 ($0F**) <KM> |
;      |   4   | <= 16383 ($3F**) <KM> |
;      |   5   | <= 32767 ($7F**) <KM> |
;      |   6   | <= 65535 ($FF**) <KM> |
;      |   7   | <= 65535 ($FF**) <KM> |
;      +-------+-----------------------+
;
;      If there is a starbase in the arrival sector, its x and y coordinates are
;      initialized to random values within the interval defined by the vicinity
;      mask by using subroutine RNDINVXY ($B7BE). Its z-coordinate is forced to
;      a value >= +$71** (+28928) <KM>. Its velocity vector components are set
;      to 0 <KM/H>. 
;
;      If there are Zylon ships in the arrival sector then a red alert is
;      initialized by setting the red alert lifetime to 255 game loop
;      iterations, playing the beeper sound pattern RED ALERT in subroutine BEEP
;      ($B3A6) and setting the title phrase to "RED ALERT".

HYPERWARP       LDY WARPSTATE           ; Return if hyperwarp not engaged
                BEQ SKIP066             ;

                LDA VELOCITYLO          ; If velocity >= 254 <KM/H> skip to HYPERSPACE PHASE
                CMP #254                ;
                BCS SKIP067             ;

                CMP #128                ; If velocity < 128 <KM/H> skip to ACCELERATION PHASE
                BCC SKIP063             ;

;*** STAR TRAIL PHASE **********************************************************
                JSR INITTRAIL           ; Init star trail

;*** ACCELERATION PHASE ********************************************************
SKIP063         LDA #3                  ; Track Hyperwarp Target Marker (PLAYER3)
                STA TRACKDIGIT          ;

                LDA #SHAP.HYPERWARP     ; PLAYER3 is HYPERWARP TARGET MARKER (shape type 9)
                STA PL3SHAPTYPE         ;
                STA PL3LIFE             ; PLAYER3 lifetime := 144 game loops

                LDA #$1F                ; PLAYER3 z-coordinate := $1F** (7936..8191) <KM>
                STA PL3ZPOSHI           ;

                SEC                     ; New arrival hyperwarp marker row number is...
                LDA PL3ROWNEW           ; WARPARRVROW := WARPTEMPROW + PL3ROWNEW...
                SBC #119                ; ... - 119 PM pixels (top edge of centered...
                CLC                     ; ...Hyperwarp Target Marker)
                ADC WARPTEMPROW         ;
                AND #$7F                ; Limit WARPARRVROW to 0..127
                STA WARPARRVROW         ;

                SEC                     ; New arrival hyperwarp marker column number is...
                LDA PL3COLUMN           ; WARPARRVCOLUMN := WARPTEMPCOLUMN + PL3COLUMN...
                SBC #125                ; ... - 125 PM pixels (left edge of centered...
                CLC                     ; ...Hyperwarp Target Marker)
                ADC WARPTEMPCOLUMN      ;
                AND #$7F                ; Limit WARPARRVCOLUMN to 0..127
                STA WARPARRVCOLUMN      ;

                LDA MISSIONLEVEL        ; Skip if NOVICE mission
                BEQ SKIP065             ;

                LDA RANDOM              ; Prep random number
                LDY SHIPVIEW            ; Skip if in Front view
                BEQ SKIP064             ;

                STA PL3COLUMN           ; Randomize PM pixel row and column number...
                STA PL3ROWNEW           ; ...of Hyperwarp Target Marker

SKIP064         CMP #16                 ; Return in 94% (240:256) of game loops
                BCS SKIP066             ;

;*** Veer off Hyperwarp Target Marker and return *******************************
SKIP065         LDA RANDOM              ; Prep random x-velocity of Hyperwarp Target Marker
                ORA #$10                ; Velocity value >= 16 <KM/H>
                AND VEERMASK            ; Limit velocity value by mission level
                STA PL3XVEL             ; PLAYER3 x-velocity := velocity value

                LDA RANDOM              ; Prep random y-velocity of Hyperwarp Target Marker
                ORA #$10                ; Velocity value >= 16 <KM/H>
                AND VEERMASK            ; Limit velocity value by mission level
                STA PL3YVEL             ; PLAYER3 y-velocity := velocity value
SKIP066         RTS                     ; Return

;*** HYPERSPACE PHASE **********************************************************
SKIP067         TYA                     ; Skip if already in HYPERSPACE PHASE
                BMI SKIP068             ;

;*** HYPERSPACE PHASE (First pass) *********************************************
                LDA #$FF                ; Set hyperwarp state to HYPERSPACE PHASE
                STA WARPSTATE           ;

                LDX #$00                ; Play beeper sound pattern HYPERWARP TRANSIT
                JSR BEEP                ;

                JSR CALCWARP            ; Calc hyperwarp energy

                LDY #$1B                ; Prep title phrase "HYPERSPACE"
                JMP CLEANUPWARP         ; Return via CLEANUPWARP

;*** HYPERSPACE PHASE (Second and later passes) ********************************
SKIP068         DEC WARPENERGY          ; Decrement energy in chunks of 10 energy units
                BEQ SKIP069             ; Skip to DECELERATION PHASE if hyperwarp energy zero

                LDX #2                  ; ENERGY := ENERGY - 10 and return
                JMP DECENERGY           ;

;*** DECELERATION PHASE ********************************************************
SKIP069         LDY #$19                ; Prep title phrase "HYPERWARP COMPLETE"
                JSR ENDWARP             ; Stop our starship

                LDA WARPARRVCOLUMN      ; Make the arrival hyperwarp marker column number...
                STA WARPDEPRCOLUMN      ; ...the departure hyperwarp marker column number
                LDA WARPARRVROW         ; Make the arrival hyperwarp marker row number...
                STA WARPDEPRROW         ; ...the departure hyperwarp marker row number

                LSR @                  ; B3..1 of arrival hyperwarp marker row number...
                AND #$07                ; ...pick vicinity mask
                TAX                     ;
                LDA VICINITYMASKTAB,X   ;
                STA VICINITYMASK        ; Store vicinity mask (limits space obj coordinates)

                LDY ARRVSECTOR          ; Make the arrival sector the current sector
                STY CURRSECTOR          ;

;*** Init starbase in arrival sector *******************************************
                LDA #0                  ; Clear starbase-in-sector flag
                STA ISSTARBASESECT      ;

                LDX GCMEMMAP,Y          ; Skip if no starbase in arrival sector
                BPL SKIP070             ;

                LDA #$FF                ; Set starbase-in-sector flag
                STA ISSTARBASESECT      ;

;*** Set position vector and velocity vector of starbase ***********************
                LDY #0                  ;
LOOP033         LDA #0                  ; Loop over all coordinates of starbase
                STA PL2ZVEL,Y           ; Starbase velocity vector component := 0 <KM/H>
                LDA #1                  ;
                STA PL2ZPOSSIGN,Y       ; Starbase coordinate sign := + (positive)
                LDA RANDOM              ; Prep random number...
                AND VICINITYMASK        ; ...limit number range by vicinity mask, then...
                STA PL2ZPOSHI,Y         ; ...store in starbase coordinate (high byte)

                TYA                     ;
                CLC                     ;
                ADC #NUMSPCOBJ.ALL      ;
                TAY                     ;
                CMP #NUMSPCOBJ.ALL*3    ;
                BCC LOOP033             ; Next starbase coordinate

                LDA PL2ZPOSHI           ; Force starbase z-coordinate >= +$71** <KM>
                ORA #$71                ;
                STA PL2ZPOSHI           ;
                LDX #2                  ; Randomly invert starbase x and y coordinates...
                JMP RNDINVXY            ; ...and return

;*** Flash red alert if Zylon sector entered ***********************************
SKIP070         BEQ SKIP071             ; Skip if no Zylon ships in sector

                LDA #255                ; Red alert lifetime := 255 game loops
                STA REDALERTLIFE        ;

                LDX #$06                ; Play beeper sound pattern RED ALERT
                JSR BEEP                ;

                LDY #$75                ; Set title phrase "RED ALERT"
                JSR SETTITLE            ;

SKIP071         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  ABORTWARP                                  *
;*                                                                             *
;*                               Abort hyperwarp                               *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Aborts hyperwarp.
;
; This subroutine is entered from subroutine KEYBOARD ($AFFE). It subtracts 100
; energy units for aborting the hyperwarp and preloads the title phrase with
; "HYPERWARP ABORTED". Code execution continues into subroutine ENDWARP
; ($A987). 

ABORTWARP       LDX #1                  ; ENERGY := ENERGY - 100 after hyperwarp abort
                JSR DECENERGY           ;

                LDY #$17                ; Prep title phrase "HYPERWARP ABORTED"

;*******************************************************************************
;*                                                                             *
;*                                   ENDWARP                                   *
;*                                                                             *
;*                                End hyperwarp                                *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Ends hyperwarp.
;
; This subroutine stops our starship's Engines and resets the hyperwarp state.
; Code execution continues into subroutine CLEANUPWARP ($A98D).

ENDWARP         LDA #0                  ; Stop Engines
                STA NEWVELOCITY         ;
                STA WARPSTATE           ; Disengage hyperwarp

;*******************************************************************************
;*                                                                             *
;*                                 CLEANUPWARP                                 *
;*                                                                             *
;*                        Clean up hyperwarp variables                         *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Cleans up after a hyperwarp.
;
; This subroutine restores many hyperwarp related variables to their
; post-hyperwarp values: The number of used space objects is set to the regular
; value of 16 (5 PLAYER space objects + 12 PLAYFIELD space objects (stars),
; counted 0..16), our starship's velocity (high byte) is cleared as well as the
; explosion lifetime, the hit badness, the PLAYER3 shape type (Hyperwarp Target
; Marker), the Engines energy drain rate, and the lifetimes of the PLAYERs. The
; docking state is reset as well as the tracking digit. The title phrase is
; updated with either "HYPERSPACE" or "HYPERWARP ABORTED".
;
; INPUT
;
;   Y = Title phrase offset. Used values are: 
;     $17 -> "HYPERWARP ABORTED"
;     $1B -> "HYPERSPACE"

CLEANUPWARP     LDA #NUMSPCOBJ.NORM-1   ; Set normal number of space objects
                STA MAXSPCOBJIND        ; (5 PLAYER spc objs + 12 PLAYFIELD spc objs (stars))

                LDA #0                  ;
                STA VELOCITYHI          ; Turn off hyperwarp velocity
                STA EXPLLIFE            ; Explosion lifetime := 0 game loops
                STA HITBADNESS          ; HITBADNESS := NO HIT
                STA PL3SHAPTYPE         ; Clear PLAYER3 shape type
                STA DRAINENGINES        ; Clear Engines energy drain rate
                CPY #$17                ; Skip if hyperwarp was aborted
                BEQ SKIP072             ;

                STA PL0LIFE             ; Zylon ship 0 lifetime := 0 game loops
                STA PL1LIFE             ; Zylon ship 1 lifetime := 0 game loops

SKIP072         STA PL2LIFE             ; Zylon photon torpedo lifetime := 0 game loops
                STA PL3LIFE             ; Hyperwarp Target Marker lifetime := 0 game loops
                STA PL4LIFE             ; Photon torpedo 1 lifetime := 0  game loops
                STA DOCKSTATE           ; DOCKSTATE := NO DOCKING
                STA TRACKDIGIT          ; Clear index of tracked space object
                JMP SETTITLE            ; Set title phrase and return

;*******************************************************************************
;*                                                                             *
;*                                  INITTRAIL                                  *
;*                                                                             *
;*         Initialize star trail during STAR TRAIL PHASE of hyperwarp          *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; BACKGROUND
;
; Star trails are displayed during the STAR TRAIL PHASE, that is, after the
; ACCELERATION PHASE and before the HYPERSPACE PHASE of the hyperwarp. 
;
; A star trail is formed by 6 stars represented by 6 PLAYFIELD space objects
; with continuous position vector indices in 17..48 (indices are wrapped around
; when greater than 48). Between the creations of two star trails there is delay
; of 4 game loop iterations.
;
; DETAILS
;
; This subroutine first decrements this star trail creation delay, returning if
; the delay is still counting down. If the delay falls below 0 then it continues
; accelerating our starship's velocity toward hyperwarp speed and then creates a
; new star trail:
;
; First, it raises the maximum index of used space objects to 48 (increasing the
; number of displayed space objects to 49), resets the star trail creation delay
; to 4 game loop iterations, and then forms a new star trail of 6 stars
; represented by 6 PLAYFIELD space objects. The x and y coordinates for all 6
; stars are the same, picked randomly from tables WARPSTARXTAB ($BB3A) and
; WARPSTARYTAB ($BB3E), respectively, with their signs changed randomly. Their
; z-coordinates are computed in increasing depth from at least +4608 (+$12**)
; <KM> in intervals of +80 (+$0050) <KM>. Their velocity vector components are
; set to 0 <KM/H>.

L.RANGE         = $68                   ; z-coordinate of star in star trail (16-bit value)
L.TRAILCNT      = $6E                   ; Star's index in star trail. Used values are: 0..5.

INITTRAIL       DEC TRAILDELAY          ; Decrement star trail delay
                BPL SKIP074             ; Return if delay still counting

                LDA #1                  ; Turn on hyperwarp velocity
                STA VELOCITYHI          ;

                LDA #NUMSPCOBJ.ALL-1    ; Max index of space objects (for star trail stars)
                STA MAXSPCOBJIND        ;

                LDA #3                  ; Star trail delay := 3(+1) game loops
                STA TRAILDELAY          ;

                LDX TRAILIND            ; Next avail. space obj index for star of star trail

                LDA #$12                ; Star z-coordinate := >= +$12** (+4608) <KM>
                STA L.RANGE+1           ;

                LDA RANDOM              ; Calc random index to pick initial star coordinates
                AND #$03                ;
                TAY                     ;
                LDA WARPSTARXTAB,Y      ; Pick x-coordinate (high byte) of star from table
                STA XPOSHI,X            ;
                LDA WARPSTARYTAB,Y      ;
                STA YPOSHI,X            ; Pick y-coordinate (high byte) of star from table
                JSR RNDINVXY            ; Randomize signs of x and y coordinates of star

                TXA                     ; Save space object index
                TAY                     ;
                LDA #5                  ; Loop over 5(+1) stars that form the star trail
                STA L.TRAILCNT          ; Store star counter of star trail

LOOP034         CLC                     ; Place stars in z-coordinate intervals of +80 <KM>
                LDA L.RANGE             ;
                ADC #80                 ;
                STA L.RANGE             ;
                STA ZPOSLO,X            ;
                LDA L.RANGE+1           ;
                ADC #0                  ;
                STA L.RANGE+1           ;
                STA ZPOSHI,X            ;

                LDA #0                  ; Star's velocity vector components := 0 <KM/H>
                STA ZVEL,X              ;
                STA XVEL,X              ;
                STA YVEL,X              ;
                LDA #1                  ; Star's z-coordinate sign := + (= ahead of starship)
                STA ZPOSSIGN,X          ;

                LDA #99                 ; Init pixel row and column numbers to magic...
                STA PIXELROWNEW,X       ; ...offscreen value (triggers automatic recalc in...
                STA PIXELCOLUMN,X       ; ...GAMELOOP's calls to SCREENCOLUMN and SCREENROW)

                JSR COPYPOSXY           ; Copy x and y coordinate from previous star in trail

                DEX                     ; Decrement space object index to next star
                CPX #NUMSPCOBJ.NORM     ; If index reaches minimum value...
                BCS SKIP073             ;
                LDX #NUMSPCOBJ.ALL-1    ; ...wrap-around to maximum space object index
SKIP073         DEC L.TRAILCNT          ;
                BPL LOOP034             ; Next star of star trail

                STX TRAILIND            ; Save space object index of star trail's last star
SKIP074         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 PROJECTION                                  *
;*                                                                             *
;*         Calculate pixel column (or row) number from position vector         *
;*                                                                             *
;*******************************************************************************

; Calculates the pixel column (or row) number of a position vector x (or y)
; component relative to the PLAYFIELD center by computing the perspective
; projection quotient
;
;     QUOTIENT := DIVIDEND / DIVISOR * 128
;
; with
;
;     DIVIDEND := ABS(x-coordinate (or y-coordinate)) / 2
;     DIVISOR  := ABS(z-coordinate) / 2  
;
; If the QUOTIENT is in 0..255, it is used as an index to pick the pixel column
; (or row) number from table MAPTO80 ($0DE9), returning values in 0..80.
;
; If the QUOTIENT is larger than 255 ("dividend overflow") or if the
; z-coordinate = 0 ("division by zero") then the error value 255 is returned.
;
; INPUT
;
;   X                   = Position vector index. Used values are: 0..48.
;   DIVIDEND ($6A..$6B) = Dividend (positive 16-bit value), contains the
;                         absolute value of the x (or y) coordinate.
;
; OUTPUT
;
;   A = Pixel column (or row) number relative to PLAYFIELD center. Used values
;       are: 
;     0..80 -> Pixel number
;     255   -> Error value indicating "dividend overflow" or "division by zero"

L.DIVISOR       = $68                   ; Divisor (16-bit value)
L.QUOTIENT      = $6D                   ; Division result (unsigned 8-bit value)
L.LOOPCNT       = $6E                   ; Division loop counter. Used values are: 7..0.

PROJECTION      LDA #0                  ; Init quotient result
                STA L.QUOTIENT          ;

                LDA #7                  ; Init division loop counter
                STA L.LOOPCNT           ;

                LSR DIVIDEND+1          ; DIVIDEND := x-coordinate (or y-coordinate) / 2
                ROR DIVIDEND            ; (division by 2 to make B15 = 0?) (?)

                LDA SHIPVIEW            ; Skip if in Aft view
                BNE SKIP075             ;

                LDA ZPOSHI,X            ; If in Front view -> DIVISOR := z-coordinate / 2
                LSR @                  ; (division by 2 to make B15 = 0?) (?)
                STA L.DIVISOR+1         ;
                LDA ZPOSLO,X            ;
                ROR @                  ;
                STA L.DIVISOR           ;
                JMP LOOP035             ;

SKIP075         SEC                     ; If in Aft view -> DIVISOR := - z-coordinate / 2
                LDA #0                  ; (division by 2 to make B15 = 0?) (?)
                SBC ZPOSLO,X            ;
                STA L.DIVISOR           ;
                LDA #0                  ;
                SBC ZPOSHI,X            ;
                LSR @                  ;
                STA L.DIVISOR+1         ;
                ROR L.DIVISOR           ;

LOOP035         ASL L.QUOTIENT          ; QUOTIENT := DIVIDEND / DIVISOR * 128
                SEC                     ;
                LDA DIVIDEND            ;
                SBC L.DIVISOR           ;
                TAY                     ;
                LDA DIVIDEND+1          ;
                SBC L.DIVISOR+1         ;
                BCC SKIP076             ;

                STA DIVIDEND+1          ;
                STY DIVIDEND            ;
                INC L.QUOTIENT          ;

SKIP076         ASL DIVIDEND            ;
                ROL DIVIDEND+1          ;
                BCC SKIP077             ;

                LDA #255                ; Return 255 if division by zero or dividend overflow
                RTS                     ;

SKIP077         DEC L.LOOPCNT           ;
                BPL LOOP035             ; Next division loop iteration

                LDY L.QUOTIENT          ; Prep with quotient
                LDA MAPTO80,Y           ; Pick and return pixel column (or row) number...
SKIP078         RTS                     ; ...relative to PLAYFIELD center

;*******************************************************************************
;*                                                                             *
;*                                  MANEUVER                                   *
;*                                                                             *
;*     Maneuver our starship's and Zylon photon torpedoes and Zylon ships      *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine maneuvers both of our starship's photon torpedoes, the single
; Zylon photon torpedo, and the one or two Zylon ships that are simultaneously
; displayed on the screen. It also creates meteors and new Zylon ships. This
; subroutine is executed only if our starship is not in a starbase sector and
; hyperwarp is not engaged.
;
; BACKGROUND
;
; When a Zylon ship is initialized, a "flight pattern" is assigned to it. There
; are 3 flight patterns (0, 1, and 4) which are picked from table ZYLONFLPATTAB
; ($BF91).
;
; The flight pattern determines the maximum velocity with which a Zylon ship can
; move along each axis of the 3D coordinate system, that is, the maximum value
; of a velocity vector component. Velocity vector components for Zylon ships are
; picked from the Zylon velocity table ZYLONVELTAB ($BF99):
;
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
; | Velocity Index  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
; | Velocity <KM/H> | +62 | +30 | +16 |  +8 |  +4 |  +2 |  +1 |  0  |
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
; | Velocity Index  |  8  |  9  |  10 |  11 |  12 |  13 |  14 |  15 |
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
; | Velocity <KM/H> |  0  |  -1 |  -2 |  -4 |  -8 | -16 | -30 | -62 |
; +-----------------+-----+-----+-----+-----+-----+-----+-----+-----+
;
; The index into the Zylon velocity table ZYLONVELTAB ($BF99) corresponding to
; the maximum velocity is called the "maximum velocity index". The following
; table shows the flight patterns, their maximum velocity indices, and their
; corresponding velocities:
;
; +----------------+------------------+------------------+
; | Flight Pattern | Maximum Velocity | Maximum Velocity |
; |                |      Index       |                  |
; +----------------+------------------+------------------+
; |       0        |         0        |    +62 <KM/H>    |
; |       0        |        15        |    -62 <KM/H>    |
; |       1        |         1        |    +30 <KM/H>    |
; |       1        |        14        |    -30 <KM/H>    |
; |       4        |         4        |     +4 <KM/H>    |
; |       4        |        11        |     -4 <KM/H>    |
; +----------------+------------------+------------------+
;
; Because flight pattern 0 produces the fastest-moving Zylon ships, which
; maneuver aggressively, it is called the "attack flight pattern".
;
; Each Zylon ship has a set of 3 maximum velocity indices, one for each of its
; velocity vector components.
;
; Each Zylon ship has also one more set of 3 velocity indices, called "Zylon
; velocity indices", one for each of its velocity vector components. They are
; used to pick the current values of the velocity vector components from the
; Zylon velocity table ZYLONVELTAB ($BF99).
;
; In order to maneuver Zylon ships this subroutine uses the concept of
; "milestone velocity indices". By using delay timers, called "Zylon timers",
; this subroutine gradually increases or decreases the Zylon velocity indices
; with every game loop iteration to eventually match the corresponding milestone
; velocity indices. By incrementing a Zylon velocity index a Zylon ship
; accelerates toward the negative direction of a coordinate axis. By
; decrementing a Zylon velocity index a Zylon ship accelerates toward the
; positive direction of a coordinate axis. If one milestone velocity index is
; matched or a "milestone timer" has counted down to 0, a new milestone velocity
; index is calculated and the matching of the current Zylon velocity indices
; with the new milestone velocity indices repeats.
;
; DETAILS
;
; For quick lookup, the following table lists the PLAYERs and what space objects
; they represent in this subroutine:
;
; +--------+---------------------------------+
; | PLAYER |           Represents            |
; +--------+---------------------------------+
; |    0   | Zylon Ship 0                    |
; |    1   | Zylon Ship 1                    |
; |    2   | Zylon Photon Torpedo, Meteor    |
; |    3   | Our starship's Photon Torpedo 0 |
; |    4   | Our starship's Photon Torpedo 1 |
; +--------+---------------------------------+
;
; This subroutine executes the following steps:
;
; (1)  Update the x and y velocity vector components of both of our starship's
;      photon torpedoes 0 and 1.
;
;      The x and y velocity vector components of both of our starship's photon
;      torpedoes 0 and 1 are only updated if they are tracking (homing in on) a
;      target.
;
;      To update the y-velocity vector components of both of our starship's
;      photon torpedoes 0 and 1 the PLAYER row number difference between the
;      PLAYER of tracked target space object and the current location of the
;      PLAYER of our starship's photon torpedo 0 is passed to subroutine
;      HOMINGVEL ($AECA). It returns the new y-velocity vector component value
;      for both of our starship's photon torpedoes in <KM/H>. If the target is
;      located below our starship's photon torpedo 0 a value of 0 <KM/H> is
;      used.
;
;      NOTE: The new y-velocity vector components depend only on the PLAYER row
;      number of our starship's photon torpedo 0.
;
;      To update the x-velocity vector components of both of our starship's
;      photon torpedoes, the above calculation is repeated for the PLAYER column
;      numbers of each of our starship's photon torpedoes 0 and 1.
;
; (2)  Make the Zylon ships follow the rotation of our starship.
;
;      If you rotate our starship away from Zylon ships they adjust their course
;      such that they reappear in our starship's view.
;
;      This is achieved by 4 Zylon timers, one for each of both Zylon ships'
;      current x and y Zylon velocity indices. The Zylon timers are decremented
;      every game loop iteration. If any of them reach a value of 0, the
;      corresponding Zylon velocity index is incremented or decremented
;      depending on the current joystick position.
;
;      For example, if the Zylon timer for the x-velocity of Zylon ship 0
;      reaches 0 and at the same time the joystick is pushed left then the
;      x-Zylon velocity index of this Zylon ship is incremented. This
;      accelerates the Zylon ship toward negative x-direction ("left"): The
;      Zylon ship follows our starship's rotation. This works in Aft view, too,
;      where the direction of change of the Zylon velocity index is reversed.
;      After setting the new Zylon velocity index, it is used to pick a new
;      Zylon timer value for this Zylon velocity index: 
;
;      +--------------------------------+----+----+----+----+----+----+----+----+
;      | Velocity Index                 |  0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |
;      +--------------------------------+----+----+----+----+----+----+----+----+
;      | Zylon Timer Value (Game Loops) |  0 |  2 |  4 |  6 |  8 | 10 | 12 | 14 |
;      +--------------------------------+----+----+----+----+----+----+----+----+
;      +--------------------------------+----+----+----+----+----+----+----+----+
;      | Velocity Index                 |  8 |  9 | 10 | 11 | 12 | 13 | 14 | 15 |
;      +--------------------------------+----+----+----+----+----+----+----+----+
;      | Zylon Timer Value (Game Loops) | 14 | 12 | 10 |  8 |  6 |  4 |  2 |  0 |
;      +--------------------------------+----+----+----+----+----+----+----+----+
;
; (3)  Update the x and y velocity vector components of the single Zylon photon
;      torpedo.
;
;      If a Zylon photon torpedo is moving toward our starship then update its x
;      and y velocity vector components. They are picked from table
;      ZYLONHOMVELTAB ($BF85) and depend on the mission level. The signs of the
;      velocity vector components are always set such that the Zylon photon
;      torpedo is guided toward our starship. 
;
; (4)  Create a meteor?
;
;      If PLAYER2, the PLAYER to represent a meteor, is either initial or not
;      alive, then attempt in 7 out of 8 game loop iterations to create a new
;      meteor. 
;
;      With a probability of 2% (4:256) a new meteor is created: Its shape type
;      is set to METEOR, its position vector components to random coordinates in
;      subroutine INITPOSVEC ($B764), its lifetime to 60 game loop iterations,
;      and its velocity vector components (velocities) to x-velocity: 0 <KM/H>,
;      y-velocity: 0 <KM/H>, z-velocity: -8 <KM/H>. Then code execution returns.
;
; (5)  Toggle Zylon ship control.
;
;      Every other game loop iteration, the game takes control of and maneuvers
;      the other Zylon ship.
;
; (6)  Create new Zylon ship?
;
;      If the game-controlled Zylon ship is not alive, check if both Zylon ships
;      are not alive and this is an empty sector. If so, then attempt to create
;      a meteor. Otherwise create a new Zylon ship with infinite lifetime.
;      Randomly pick its shape type from table ZYLONSHAPTAB ($BF89) (ZYLON
;      BASESTAR, ZYLON CRUISER, or ZYLON FIGHTER) and its flight pattern from
;      table ZYLONFLPATTAB ($BF91) (attack flight pattern 0 is always picked in
;      a NOVICE mission). Then set the milestone timer to 1 game loop iteration
;      and the position vector of the Zylon ship to a position of at least
;      +28928 (+$71**) <KM> in front of our starship. The y-coordinate depends
;      on the value of VICINITYMASK ($C7). The x-coordinate is the sum of the
;      y-coordinate plus at least 4864..5119 ($13**) <KM>. Randomly choose the
;      signs of the x and y coordinates.
;
; (7)  Set the current flight pattern to attack flight pattern?
;
;      The current flight pattern of the Zylon ship will change to attack flight
;      pattern if it is close enough (z-coordinate < +8192 (+$20**) <KM>) and
;      one of the following conditions is met:
;
;      o   The Zylon ship is located behind our starship.
;
;      o   The shape of the Zylon ship is not initial and does not currently
;          appear as a blip in the Long-Range Scan view.
;
; (8)  Update the back-attack flag and the milestone velocity indices.
;
;      The milestone timer is decremented for the game-controlled Zylon ship. If
;      this timer reaches a value of 0 the following steps are executed:
;
;      o   The milestone timer is reset to a value of 120 game loop iterations.
;
;      o   The back-attack flag is updated. It determines if the game-controlled
;          Zylon ship not only attacks from the front of our starship but also
;          from the back. A back-attack takes place with a probability of 19%
;          (48:256) in WARRIOR or COMMANDER missions.
;
;      o   Course corrections are prepared for the game-controlled Zylon ship by
;          computing the new milestone vector indices, resulting in new velocity
;          vector components for this Zylon ship. The new milestone velocity
;          indices for each velocity vector component are randomly chosen
;          depending of the flight pattern. Recall that the Zylon velocity index
;          is changed gradually to match the milestone velocity index. It
;          corresponds to a maximum velocity vector component when using this
;          index to pick a velocity vector component from Zylon velocity table
;          ZYLONVELTAB ($BF99):
;
;          +----------------+----------------+------------------+
;          | Flight Pattern | New Milestone  | Maximum Velocity |
;          |                | Velocity Index | Vector Component |
;          +----------------+----------------+------------------+
;          |       0        |        0       |    +62 <KM/H>    |
;          |       0        |       15       |    -62 <KM/H>    |
;          |       1        |        1       |    +30 <KM/H>    |
;          |       1        |       14       |    -30 <KM/H>    |
;          |       4        |        4       |     +4 <KM/H>    |
;          |       4        |       11       |     -4 <KM/H>    |
;          +----------------+----------------+------------------+
;
; (9)  Update milestone velocity indices in attack flight pattern.
;
;      If a Zylon ship executes the attack flight pattern, its milestone
;      velocity indices are changed depending on the current location of the
;      Zylon ship as follows:
;
;      +--------------+-------------+----------------+------------+----------------+
;      | x-Coordinate |  Where on   |   Milestone    |  Velocity  | Zylon Ship     |
;      |              |   Screen    | Velocity Index |            | Accelerates... |
;      +--------------+-------------+----------------+------------+----------------+
;      | x <  0 <KM>  | left half   |       0        | +62 <KM/H> | to the right   |
;      | x >= 0 <KM>  | right half  |      15        | -62 <KM/H> | to the left    |
;      +--------------+-------------+----------------+------------+----------------+
;      +--------------+-------------+----------------+------------+----------------+
;      | y-Coordinate |  Where on   |   Milestone    |  Velocity  | Zylon Ship     |
;      |              |   Screen    | Velocity Index |            | Accelerates... |
;      +--------------+-------------+----------------+------------+----------------+
;      | y <  0 <KM>  | bottom half |       0        | +62 <KM/H> | up             |
;      | y >= 0 <KM>  | top half    |      15        | -62 <KM/H> | down           |
;      +--------------+-------------+----------------+------------+----------------+
;
;      Thus, with respect to its x and y coordinates, the Zylon ship oscillates
;      around the center of the Front or Aft view.
;
;      This is the behavior of the Zylon ship along the z-axis:
;
;      If the Zylon ship attacks from the front:
;
;      +--------------------------+----------------+------------+----------------+
;      |       z-Coordinate       |   Milestone    |  Velocity  | Zylon Ship     |
;      |                          | Velocity Index |            | Accelerates... |
;      +--------------------------+----------------+------------+----------------+
;      | z <  +2560 (+$0A00) <KM> |       0        | +62 <KM/H> | outbound       |
;      | z >= +2560 (+$0A00) <KM> |      15        | -62 <KM/H> | inbound        |
;      +--------------------------+----------------+------------+----------------+
;
;      In other words, the Zylon ship accelerates into positive z-direction
;      (outbound) up to a distance of +2560 (+$0A00) <KM>, then reverses its
;      course and returns back to our starship (inbound).
;
;      If the Zylon ship attacks from the back:
;
;      +--------------------------+----------------+------------+----------------+
;      |       z-Coordinate       |   Milestone    |  Velocity  | Zylon Ship     |
;      |                          | Velocity Index |            | Accelerates... |
;      +--------------------------+----------------+------------+----------------+
;      | z <  -2816 (-$F500) <KM> |       0        | +62 <KM/H> | inbound        |
;      | z >= -2816 (-$F500) <KM> |      15        | -62 <KM/H> | outbound       |
;      +--------------------------+----------------+------------+----------------+
;
;      In other words, the Zylon ship accelerates into negative z-direction
;      (outbound) up to a distance of -2816 (-$(0B00)) <KM>, then reverses its
;      course and returns back to our starship (inbound).
;
; (10) Change Zylon velocity index toward milestone velocity index.
;
;      Compare all 3 Zylon velocity indices of the game-controlled Zylon ship
;      with their corresponding milestone velocity indices. Increment or
;      decrement the former to better match the latter. Use the new Zylon
;      velocity indices to pick the current velocity values from Zylon velocity
;      table ZYLONVELTAB ($BF99). 
;
; (11) Launch a Zylon photon torpedo?
;
;      Prepare launching a Zylon photon torpedo if either of the following
;      conditions are met:
;
;      o   PLAYER2 is not used as a photon torpedo
;
;      o   The y-coordinate of the Zylon ship is in the range of -768..+767
;          (-$0300..+$2FF) <KM>. 
;
;      or if
;
;      o   The Zylon photon torpedo is not alive
;
;      o   The corresponding Zylon photon torpedo delay timer has reached a
;          value of 0
;
;      o   The y-coordinate of the Zylon ship is in the range of -768..+767
;          (-$0300..+$2FF) <KM>. 
;
;      At this point the z-velocity vector component of the Zylon photon torpedo
;      is preloaded with a value of -80 or +80 <KM/H> depending on the Zylon
;      ship being in front or behind of our starship, respectively. 
;
;      Launch a Zylon photon torpedo if both of the following conditions are
;      met:
;
;      o   The Zylon ship is in front or behind of our starship, with the
;          exception of a Zylon ship behind our starship in a NOVICE mission
;          (our starship will never be shot in the back in a NOVICE mission).
;
;      o   The z-coordinate of the Zylon ship (no matter if in front or behind
;          our starship) is closer than 8192 ($20**) <KM>.
;
;      Finally, the Zylon photon torpedo is launched with a lifetime of 62 game
;      loop iterations. Its position vector is copied from the launching Zylon
;      ship in subroutine COPYPOSVEC ($ACAF). In addition, the Zylon ship is
;      earmarked for the tracking computer.

L.CTRLDZYLON    = $6A                   ; Index of currently game-controlled Zylon ship.
                                        ; Used values are:
                                        ;   0 -> Control Zylon ship 0
                                        ;   1 -> Control Zylon ship 1
NEG             = $80                   ; Negative sign bit for velocity vector component

MANEUVER        LDA WARPSTATE           ; Return if in starbase sector or hyperwarp engaged
                ORA ISSTARBASESECT      ;
                BNE SKIP078             ;

;*** Update x and y velocity of both our starship's photon torpedoes 0 and 1 ***
                LDA ISTRACKING          ; Skip this if ship's torpedoes not tracking a target
                BEQ SKIP080             ;

                LDX PLTRACKED           ; Load PLAYER index of tracked target space object

                SEC                     ; Prep A := PLAYER row number of target...
                LDA PL0ROWNEW,X         ; ...- PLAYER row number photon torpedo 0
                SBC PL3ROWNEW           ;
                BCC SKIP079             ; Skip if target above our starship's photon torpedo
                LDA #0                  ; Prep A := 0
SKIP079         JSR HOMINGVEL           ; Get y-velocity for homing photon torpedo 0 and 1
                STA PL3YVEL             ; Store y-velocity photon torpedo 0
                STA PL4YVEL             ; Store y-velocity photon torpedo 1

                SEC                     ; Prep A := PLAYER column number of target...
                LDA PL3COLUMN           ; ...- PLAYER column number of photon torpedo 0
                SBC PL0COLUMN,X         ;
                JSR HOMINGVEL           ; Get x-velocity for homing photon torpedo 0
                STA PL3XVEL             ; Store x-velocity of photon torpedo 0

                SEC                     ; Prep A := PLAYER column number of target...
                LDA PL4COLUMN           ; ...- PLAYER column number of photon torpedo 1
                SBC PL0COLUMN,X         ;
                JSR HOMINGVEL           ; Get x-velocity for homing photon torpedo 1
                STA PL4XVEL             ; Store x-velocity of photon torpedo 1

;*** Make Zylon ships follow rotation of our starship **************************
SKIP080         LDX #3                  ; Loop over x and y velocity indices of both Zylons
LOOP036         DEC ZYLONTIMX0,X        ; Decrement Zylon timer
                BPL SKIP085             ; Next timer if this one still counting down

                TXA                     ; Prep joystick (x or y) value in -1, 0, +1
                LSR @                  ;
                TAY                     ;
                LDA JOYSTICKX,Y         ;

                LDY SHIPVIEW            ; Skip if in Front view
                BEQ SKIP081             ;

                EOR #$FF                ; Invert joystick value (when in Aft view)
                CLC                     ; (two's-complement)
                ADC #1                  ;

SKIP081         CLC                     ; Add joystick value to Zylon velocity index
                ADC ZYLONVELINDX0,X     ;
                BPL SKIP082             ;
                LDA #0                  ;
SKIP082         CMP #16                 ; Limit new Zylon velocity index to 0..15 ...
                BCC SKIP083             ;
                LDA #15                 ;
SKIP083         STA ZYLONVELINDX0,X     ; ...and store new Zylon velocity index

                CMP #8                  ; Calc new Zylon timer value in 0, 2, ..., 14
                BCC SKIP084             ;
                EOR #$0F                ;
SKIP084         ASL @                  ;
                STA ZYLONTIMX0,X        ; ...and store new Zylon timer value

SKIP085         DEX                     ;
                BPL LOOP036             ; Next Zylon timer

;*** Update x and y velocity of single Zylon photon torpedo ********************
                LDA PL2SHAPTYPE         ; Skip if PLAYER2 not PHOTON TORPEDO (shape type 0)
                BNE SKIP088             ;

                LDY MISSIONLEVEL        ; Depending on mission level...
                LDA ZYLONHOMVELTAB,Y    ; ...pick (initially negative) Zylon torpedo velocity

                LDX PL2YPOSHI           ; If photon torpedo in upper screen half (y >= 0)...
                BPL SKIP086             ; ...don't toggle velocity sign -> torpedo goes down
                AND #$7F                ; ...toggle velocity sign       -> torpedo goes up
SKIP086         STA PL2YVEL             ; Store new y-velocity of Zylon photon torpedo

                ORA #NEG                ; Restore negative sign bit of velocity

                LDX PL2XPOSHI           ; If photon torpedo in right screen half (x >= 0)...
                BPL SKIP087             ; ...don't toggle velocity sign -> torpedo goes left
                AND #$7F                ; ...toggle velocity sign       -> torpedo goes right
SKIP087         STA PL2XVEL             ; Store new x-velocity of Zylon photon torpedo

;*** Create new meteor? ********************************************************
SKIP088         LDA COUNT256            ; Attempt meteor creation in 7 out of 8 game loops
                AND #$03                ;
                BEQ SKIP092             ;

SKIP089         LDA PL2SHAPOFF          ; If PLAYER2 shape is initial try to create a meteor
                BEQ SKIP090             ;

                LDA PL2LIFE             ; Return if PLAYER2 alive
                BNE SKIP091             ;

SKIP090         LDA RANDOM              ; Return in 98% (252:256) (do not create meteor)
                CMP #4                  ;
                BCS SKIP091             ;

;*** Create new meteor! ********************************************************
                LDA #SHAP.METEOR        ; PLAYER2 is METEOR (shape type 6)
                STA PL2SHAPTYPE         ;
                LDX #2                  ; Randomize position vector of meteor
                JSR INITPOSVEC          ;
                LDA #60                 ; Meteor lifetime := 60 game loops
                STA PL2LIFE             ;
                LDA #NEG|8              ; SUMMARY:
                STA PL2ZVEL             ; x-velocity :=  0 <KM/H>
                LDA #0                  ; y-velocity :=  0 <KM/H>
                STA PL2COLUMN           ; z-velocity := -8 <KM/H>
                STA PL2XVEL             ;
                STA PL2YVEL             ; PLAYER2 column number := 0 (offscreen)
SKIP091         RTS                     ; Return

;*** Toggle Zylon ship control *************************************************
SKIP092         LDA CTRLDZYLON          ; Toggle control to the other Zylon ship
                EOR #$01                ;
                STA CTRLDZYLON          ;

;*** Create a new Zylon ship? **************************************************
                TAX                     ; Save index of controlled Zylon ship
                LDA PL0LIFE,X           ; Skip creating Zylon ship if its PLAYER still alive
                BNE SKIP094             ;

                LDA PL0LIFE             ; If both Zylon ships are not alive...
                ORA PL1LIFE             ;
                AND #$01                ;
                LDY CURRSECTOR          ; ...and this an empty sector...
                CMP GCMEMMAP,Y          ;
                BCS SKIP089             ; ...attempt to create meteor and return

;*** Create a new Zylon ship! **************************************************
                LDA #255                ; Zylon ship lifetime := 255 game loops (infinite)
                STA PL0LIFE,X           ;

                LDA RANDOM              ; Pick a Zylon ship shape type (1 out of 8)
                AND #$07                ;
                TAY                     ;
                LDA ZYLONSHAPTAB,Y      ;
                STA PL0SHAPTYPE,X       ;

                LDA MISSIONLEVEL        ; Init Zylon's flight pattern (0 if NOVICE mission)
                BEQ SKIP093             ;
                LDA ZYLONFLPATTAB,Y     ;
SKIP093         STA ZYLONFLPAT0,X       ;

                LDA #1                  ; Zylon ship's milestone timer := 1 game loop
                STA MILESTTIM0,X        ;

                STA ZPOSSIGN,X          ; Put Zylon ship in front of our starship
                LDA RANDOM              ;
                AND VICINITYMASK        ; y-coordinate (high byte) := RND(0..VICINITYMASK)
                STA YPOSHI,X            ;
                ADC #19                 ; x-coordinate (high byte) := y (high byte) + 19
                STA XPOSHI,X            ;
                ORA #$71                ; z-coordinate (high byte) := >= +28928 (+$71**) <KM>
                STA ZPOSHI,X            ;
                JSR RNDINVXY            ; Randomly invert x and y coordinate of pos vector

;*** Set current flight pattern to attack flight pattern? **********************
SKIP094         LDA ZPOSHI,X            ; Skip if Zylon too distant (z >= +$20** <KM>)
                CMP #$20                ;
                BCS SKIP096             ;

                LDA ZPOSSIGN,X          ; Set attack flight pattern if Zylon is behind
                BEQ SKIP095             ;

                LDA PL0SHAPOFF,X        ; Skip if Zylon shape initial
                BEQ SKIP096             ;

                CMP #$29                ; Skip if Zylon shape is Long-Range Scan blip
                BEQ SKIP096             ;

SKIP095         LDA #0                  ; Set attack flight pattern
                STA ZYLONFLPAT0,X       ;

;*** Update back-attack flag and milestone velocity indices ********************
SKIP096         DEC MILESTTIM0,X        ; Skip if milestone timer still counting down
                BPL SKIP099             ;

                LDA #120                ; Milestone timer := 120 game loops
                STA MILESTTIM0,X        ;

                LDA MISSIONLEVEL        ; Back-attack flag := 1 in 19% (48:256) of...
                LDY RANDOM              ; ...WARRIOR or COMMANDER missions
                CPY #48                 ; ...              := 0 otherwise
                BCC SKIP097             ;
                LSR @                  ;
SKIP097         LSR @                  ;
                STA ISBACKATTACK0,X     ;

                                        ; Loop over all 3 milestone velocity indices
                LDA ZYLONFLPAT0,X       ; Set new milestone velocity index:
LOOP037         BIT RANDOM              ; If Zylon flight pattern is...
                BPL SKIP098             ; ...0 -> milestone velocity index := either 0 or 15
                EOR #$0F                ; ...1 -> milestone velocity index := either 1 or 14
SKIP098         STA MILESTVELINDZ0,X    ; ...4 -> milestone velocity index := either 4 or 11
                INX                     ;
                INX                     ;
                CPX #6                  ;
                BCC LOOP037             ; Next Zylon milestone velocity index

;*** Update milestone velocity indices in attack flight pattern ****************
                LDX CTRLDZYLON          ; Reload index of controlled Zylon ship

SKIP099         LDA ZYLONFLPAT0,X       ; Skip if not in attack flight pattern
                BNE SKIP105             ;

                LDY CTRLDZYLON          ; Reload index of controlled Zylon ship

                                        ; Loop over all 3 milestone velocity indices
LOOP038         CPY #$31                ; Skip to handle x and y velocity index
                BCS SKIP101             ;
                                        ; SUMMARY:
                LDA ISBACKATTACK0,Y     ; Handle z-velocity index:
                LSR @                  ;
                LDA ZPOSHI,Y            ; If Zylon attacks from front...
                BCS SKIP100             ; z <  $0A00 <KM> -> mil vel index := 0  (+62 <KM/H>)
                CMP #$0A                ; z >= $0A00 <KM> -> mil vel index := 15 (-62 <KM/H>)
                BCC SKIP103             ;
                BCS SKIP101             ; If Zylon attacks from back...
SKIP100         CMP #$F5                ; z >= $F500 <KM> -> mil vel index := 15 (-62 <KM/H>)
                BCS SKIP102             ; z <  $F500 <KM> -> mil vel index := 0  (+62 <KM/H>)

SKIP101         LDA ZPOSSIGN,Y          ; Handle x and y velocity index:
                LSR @                  ;
SKIP102         LDA #15                 ; x >= 0 <KM> -> mil vel index := 15 (-62 <KM/H>)
                BCS SKIP104             ; x <  0 <KM> -> mil vel index := 0  (+62 <KM/H>)
SKIP103         LDA #0                  ; y >= 0 <KM> -> mil vel index := 15 (-62 <KM/H>)
SKIP104         STA MILESTVELINDZ0,X    ; y <  0 <KM> -> mil vel index := 0  (+62 <KM/H>)

                CLC                     ; Adjust position vector component index
                TYA                     ;
                ADC #NUMSPCOBJ.ALL      ;
                TAY                     ;

                INX                     ;
                INX                     ;
                CPX #6                  ;
                BCC LOOP038             ; Next milestone velocity index

;*** Acceleration: Change Zylon velocity index toward milestone velocity index *
                LDX CTRLDZYLON          ; Reload index of controlled Zylon ship
SKIP105         LDY CTRLDZYLON          ; Reload index of controlled Zylon ship

                                        ; Loop over all 3 milestone velocity indices
LOOP039         LDA ZYLONVELINDZ0,X     ; Compare Zylon velocity index with milestone index
                CMP MILESTVELINDZ0,X    ;
                BEQ SKIP107             ; Skip if equal
                BCS SKIP106             ;
                INC ZYLONVELINDZ0,X     ; Increm. Zylon velocity index if < milestone index
                BCC SKIP107             ;
SKIP106         DEC ZYLONVELINDZ0,X     ; Decrem. Zylon velocity index if >= milestone index

SKIP107         STX L.CTRLDZYLON        ; Save index of controlled Zylon ship
                TAX                     ;
                LDA ZYLONVELTAB,X       ; Pick new velocity value by Zylon velocity index
                LDX L.CTRLDZYLON        ; Reload index of controlled Zylon ship
                STA ZVEL,Y              ; Store new velocity vector component of Zylon ship

                TYA                     ; Next velocity vector component
                CLC                     ;
                ADC #NUMSPCOBJ.ALL      ;
                TAY                     ;

                INX                     ;
                INX                     ;
                CPX #6                  ;
                BCC LOOP039             ; Next milestone velocity index

;*** Launch Zylon photon torpedo? **********************************************

;*** Check PLAYER2 shape and lifetime ******************************************
                LDX CTRLDZYLON          ; Reload index of controlled Zylon ship

                LDA PL2SHAPTYPE         ; Skip if PLAYER2 not PHOTON TORPEDO (shape type 0)
                BNE SKIP109             ;

                LDA PL2LIFE             ; Return if Zylon photon torpedo still alive
                BNE SKIP108             ;

                LDA TORPEDODELAY        ; Count down Zylon photon torpedo delay timer...
                BEQ SKIP109             ; ...before launching next Zylon photon torpedo
                DEC TORPEDODELAY        ;
SKIP108         RTS                     ; Return

;*** Check y-coordinate of Zylon ship ******************************************
SKIP109         CLC                     ; Return if Zylon ship's y-coordinate not...
                LDA YPOSHI,X            ; ...in -768..+767 (-$(0300)..+$2FF) <KM>.
                ADC #2                  ;
                CMP #5                  ;
                BCS SKIP108             ;

;*** Set Zylon photon torpedo's z-velocity *************************************
                LDY #NEG|80             ; Prep Zylon torpedo's z-velocity := -80 <KM/H>

                LDA ZPOSSIGN,X          ; Prep Zylon ship's sign of z-coordinate
                LSR @                  ;
                LDA ZPOSHI,X            ; Prep Zylon ship's z-coordinate
                BCS SKIP110             ; Skip if Zylon ship in front...
                EOR #$FF                ; ...else invert loaded Zylon ship's z-coordinate

                LDY MISSIONLEVEL        ; Return (no torpedo from back) if NOVICE mission
                BEQ SKIP108             ;

                LDY #80                 ; Preload Zylon torpedo's z-velocity := +80 <KM/H>

;*** Is Zylon ship in range? ***************************************************
SKIP110         CMP #$20                ; Return if Zylon ship too far...
                BCS SKIP108             ; ... (ABS(z-coordinate) > 8192 ($20**) <KM>)

                STY PL2ZVEL             ; Store Zylon photon torpedo's z-velocity

;*** Launch Zylon photon torpedo! **********************************************

                LDA #0                  ; PLAYER2 is PHOTON TORPEDO (shape type 0)
                STA PL2SHAPTYPE         ;
                STA PL2COLUMN           ; Zylon torpedo PLAYER column number := 0 (offscreen)
                LDA #62                 ;
                STA PL2LIFE             ; Zylon torpedo lifetime := 62 game loops

                LDX #2                  ; Prep source index for position vector copy
                LDY CTRLDZYLON          ; Prep destination index for position vector copy
                STY ZYLONATTACKER       ; Save Zylon ship index for tracking computer
                JMP COPYPOSVEC          ; Copy position vector from Zylon ship to its torpedo

;*******************************************************************************
;*                                                                             *
;*                                  INITEXPL                                   *
;*                                                                             *
;*                            Initialize explosion                             *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Initializes the explosion's lifetime, the explosion fragments' position and
; velocity vectors as well as their pixel row and column numbers.
;
; An explosion has a lifetime of 128 game loop iterations. It consists of 32
; explosion fragment space objects with indices 17..48. The position vector of
; each explosion fragment is copied from the exploding PLAYER space object.
;
; The pixel column number of each explosion fragment is initialized to
;
;     PIXEL COLUMN NUMBER := PLAYER column number - 48 + RND(0..15)
;
; To convert PLAYER column numbers (in Player/Missile (PM) pixels) into pixel
; column numbers, the PLAYER column number of the left PLAYFIELD border (= 48)
; is subtracted and a random number is added.
;
; BUG (at $AC76): The added random number should not be in 0..15 but in 0..7
; because the exploding PLAYER is 8 pixels wide. The PLAYER column number
; represents the left edge of the PLAYER shape. When using a random number in
; 0..15, half of the pixels are located off to the right of the PLAYER, outside
; the PLAYER area. Suggested fix: Replace instruction AND #$0F with AND #$07. 
;
; The pixel row number of each explosion fragment is initialized to
;
;     PIXEL ROW NUMBER := (PLAYER row number - RND(0..15)) / 2 - 16
;
; BUG (at $AC88): To convert PLAYER row numbers (in PM pixels) into pixel row
; numbers, the PLAYER row number to the top PLAYFIELD border (= 16) should be
; subtracted first, then the division by 2 (instruction LRS A) should be applied
; to reduce the double-line PM resolution to the single-line PLAYFIELD
; resolution. Suggested fix: Swap instruction LRS A with SBC #16 which leads to
; the following formula for the pixel row number:
;
;     PIXEL ROW NUMBER := (PLAYER row number - 16 + RND(0..15)) / 2
;
; Incidentally, adding a random number in 0..15 is correct. PLAYER row number
; represents the top edge of the PLAYER shape, which is typically 16 PM pixels
; tall when representing a close space object.
;
; The velocity vector of explosion fragments is set to random x, y, and z
; velocity vector components in -7..+7 <KM/H>.
;
; INPUT
;
;   Y = PLAYER index from which the explosion originates. Used values are:
;     0 -> Explosion of PLAYER0 (Zylon ship 0)
;     1 -> Explosion of PLAYER1 (Zylon ship 1)
;     2 -> Explosion of PLAYER2 (Zylon photon torpedo, starbase, or meteor)

INITEXPL        LDA #128                ; Explosion lifetime := 128 game loops
                STA EXPLLIFE            ;

                LDX #NUMSPCOBJ.ALL-1    ; Max index of space objects (for explosion frags)
                STX MAXSPCOBJIND        ;

                                        ; Loop over all explosion fragment position vectors
                                        ; (index 48..17)
LOOP040         LDA RANDOM              ; PIXEL COLUMN NUM := PLAYER column - 48 + RND(0..15)
                AND #$0F                ; (!)
                ADC PL0COLUMN,Y         ;
                SBC #48                 ;
                STA PIXELCOLUMN,X       ;

                LDA RANDOM              ; PIXEL ROW NUM := (PLAYER row + RND(0..15)) / 2 - 16
                AND #$0F                ;
                ADC PL0ROWNEW,Y         ;
                LSR @                  ; (!)
                SBC #16                 ;
                STA PIXELROWNEW,X       ;

                JSR COPYPOSVEC          ; Copy position vector of PLAYER to explosion frag

                LDA RANDOM              ; z-velocity := RND(-7..+7) <KM/H>
                AND #NEG|7              ;
                STA ZVEL,X              ;
                LDA RANDOM              ; x-velocity := RND(-7..+7) <KM/H>
                AND #NEG|7              ;
                STA XVEL,X              ;
                LDA RANDOM              ; y-velocity := RND(-7..+7) <KM/H>
                AND #NEG|7              ;
                STA YVEL,X              ;

                DEX                     ; Next explosion fragment position vector
                CPX #16                 ;
                BNE LOOP040             ;
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 COPYPOSVEC                                  *
;*                                                                             *
;*                           Copy a position vector                            *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Copies a position vector.
;
; Actually, this subroutine copies the z-coordinate only, then code execution
; continues into subroutine COPYPOSXY ($ACC1) to copy the x and y coordinate.
;
; INPUT
;
;   X = Destination position vector index. Used values are: 0..48.
;   Y = Source position vector index. Used values are: 0..48.

COPYPOSVEC      LDA ZPOSSIGN,Y          ;
                STA ZPOSSIGN,X          ;
                LDA ZPOSHI,Y            ;
                STA ZPOSHI,X            ;
                LDA ZPOSLO,Y            ;
                STA ZPOSLO,X            ;

;*******************************************************************************
;*                                                                             *
;*                                  COPYPOSXY                                  *
;*                                                                             *
;*          Copy x and y components (coordinates) of position vector           *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Copies the x and y components (coordinates) of a position vector.
;
; INPUT
;
;   X = Destination position vector index. Used values are: 0..48.
;   Y = Source position vector index. Used values are: 0..48.

COPYPOSXY       LDA XPOSSIGN,Y          ;
                STA XPOSSIGN,X          ;
                LDA XPOSHI,Y            ;
                STA XPOSHI,X            ;
                LDA YPOSSIGN,Y          ;
                STA YPOSSIGN,X          ;
                LDA YPOSHI,Y            ;
                STA YPOSHI,X            ;
                LDA XPOSLO,Y            ;
                STA XPOSLO,X            ;
                LDA YPOSLO,Y            ;
                STA YPOSLO,X            ;
SKIP111         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                   DOCKING                                   *
;*                                                                             *
;*      Handle docking at starbase, launch and return of transfer vessel       *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Handles docking at a starbase, launching and returning the transfer vessel,
; and repairing our starship's subsystems. 
;
; This subroutine changes, if in Front view, the PLAYER-PLAYFIELD priority such
; that PLAYERs like the starbase appear behind the cross hairs, which are part
; of the PLAYFIELD.
;
; BUG (at $ACEE): In Front view, the specific order of PLAYERs (PL0..4) and
; PLAYFIELD colors (PF0..4) is, from front to back:
;
;     PL4 > PF0, PF1, PF2 > PL0 > PL1 > PL2 > PL3 > PF4 (BGR)
;
; This makes the starbase appear behind the cross hairs, but also behind the
; stars, as both cross hairs and stars are part of the PLAYFIELD - a rarely
; noticed glitch.
;
; Note also that, as an exception of the rule, PLAYER4 (transfer vessel) is
; displayed before the PLAYFIELD. Thus, the transfer vessel appears in front of
; the cross hairs!
;
; In Aft view, the arrangement is reversed: PLAYERs are arranged in front of the
; PLAYFIELD. The specific order of PLAYERs (PL0..4) and PLAYFIELD colors
; (PF0..4) is, from front to back:
;
;     PL0 > PL1 > PL2 > PL3 > PL4 > PF0, PF1, PF2 > PF4 (BGR)
;
; In this case, both the starbase and the transfer vessel appear in front of the
; cross hairs! Suggested fix: None, technically not possible.
;
;
; The starbase is tracked and the PLAYER0..2 shape types are set to STARBASE
; RIGHT, STARBASE LEFT, and STARBASE CENTER, respectively, combining them into a
; 3-part starbase shape. 
;
; If this sector is still marked as a starbase sector but no more so on the
; Galactic Chart (if in the meantime either Zylon units have surrounded this
; sector and destroyed the starbase or you have destroyed the starbase with a
; photon torpedo) then the noise sound pattern SHIELD EXPLOSION is played in
; subroutine NOISE ($AEA8) and code execution returns.
;
; Otherwise a minimum distance to the starbase of +32 (+$0020) <KM> is enforced
; and the conditions for a successful docking are checked:
;
; DOCKING CONDITIONS
;
; A docking is successful if all of the following conditions are met:
;
; (1)  The PLAYER2 (STARBASE CENTER) column number is in 120..135. 
;
;      BUG (at $AD39): At first glance, the PLAYER column interval of 120..135
;      corresponds to an almost symmetric interval of -8..+7 PM pixels relative
;      to the horizontal center of the PLAYFIELD, at PLAYER column number 128
;      (48 PM pixels offset to left PLAYFIELD border + 80 PM pixels to the
;      PLAYFIELD center). This is correct only if the PLAYER column number were
;      to designate the horizontal center of the PLAYER. However it designates
;      its left edge! Thus the used pixel column number range 120..135 creates
;      an asymmetric horizontal docking position: A docking is successful if the
;      horizontal position of the starbase shape's center is roughly -5..+10 PM
;      pixels relative to the horizontal center of the PLAYFIELD. Suggested fix:
;      Replace SBC #120 with SBC #117. This leads to an interval of -8..+7
;      pixels relative to the horizontal center of the PLAYFIELD and better
;      symmetry in the horizontal docking position.
;
; (2)  The PLAYER2 (STARBASE CENTER) row number is in 104..119.
;
;      BUG (at $AD43): The PLAYER row interval of 104..119 corresponds to an
;      asymmetric interval of -20..-5 PM pixels relative to the vertical center
;      of the PLAYFIELD, at pixel row number 80 or PLAYER row number 124. It
;      lets you dock at a starbase that "sits" on top of the horizontal cross
;      hairs but not at one that "hangs" from them. Suggested fix: Replace SBC
;      #104 with SBC #108. This leads to an interval of -8..+7 pixels relative
;      to the vertical center of the PLAYFIELD (assuming a PLAYER2 shape of 16
;      pixel height, which is typical during docking) and better symmetry in the
;      vertical docking position. 
;
; (3)  The starbase is in correct distance in front of our starship: The
;      starbase's z-coordinate must be < +512 (+$02**) <KM>.
;
; (4)  Our starship is horizontally level with the starbase: The starbase's
;      y-coordinate must be < +256 (+$01**) <KM>.
;
; (5)  Our starship is at a complete halt.
;
; DOCKING SUCCESSFUL
;
; If the conditions for a successful docking are met, the subsequent docking and
; transfer operation can be divided in the following states, starting with state
; NOT DOCKED:
;
; (1)  NOT DOCKED 
;
;      The docking state is set to ORBIT ESTABLISHED and the title line is
;      updated with "ORBIT ESTABLISHED".
;
; (2)  ORBIT ESTABLISHED 
;
;      After waiting until the title line "ORBIT ESTABLISHED" has disappeared,
;      the transfer vessel is initialized and launched: The PLAYER4 shape type
;      is set to TRANSFER VESSEL. Its position vector is set to a position above
;      and in front of our starship, but behind the starbase:
;
;          x-coordinate :=     +0..+255 (+$00**) <KM>
;          y-coordinate :=   +256..+511 (+$01**) <KM> 
;          z-coordinate := +4096..+4351 (+$10**) <KM>
;
;      Its velocity vector is set to
;
;          x-velocity   := +1 <KM/H> 
;          y-velocity   := -1 <KM/H> 
;          z-velocity   := -7 <KM/H>
;
;      This will move the transfer vessel from behind the starbase into a
;      direction toward and a little to the lower right of our starship. The
;      lifetime of the transfer vessel (and its return journey) is set to 129
;      game loop iterations. Finally, the docking state is set to RETURN
;      TRANSFER VESSEL.
;
; (3)  RETURN TRANSFER VESSEL 
;
;      After checking if the transfer vessel has passed behind our starship, the
;      beeper sound pattern ACKNOWLEDGE is played in subroutine BEEP ($B3A6),
;      the title line is updated with "TRANSFER COMPLETE", our starship's
;      subsystems are repaired, and our starship's ENERGY readout is restored to
;      9999 energy units. by inverting the z-velocity the velocity vector of the
;      transfer vessel is changed to
;
;          x-velocity   := +1 <KM/H> 
;          y-velocity   := -1 <KM/H> 
;          z-velocity   := +7 <KM/H>
;
;      thus launching the transfer vessel on its return journey to the starbase.
;      The docking state is set to TRANSFER COMPLETE. Finally, the screen is
;      updated in subroutine UPDSCREEN ($B07B).
;
; (4)  TRANSFER COMPLETE 
;
;      This docking state marks the end of a successful docking and transfer
;      operation.
;
; DOCKING ABORTED
;
; If the docking conditions above are not met and the docking state is already
; ORBIT ESTABLISHED or RETURN TRANSFER VESSEL then the message "DOCKING ABORTED"
; is displayed and the docking state is set to NOT DOCKED.

DOCKING         LDA ISSTARBASESECT      ; Return if not in starbase sector
                BEQ SKIP111             ;

                LDA SHIPVIEW            ; Skip if not in Front view
                BNE SKIP112             ;
                LDA #$14                ; GTIA: Enable PLAYER4, prio: PFs > PLs > BGR (!)
                STA PRIOR               ; (Cross hairs in front of PLAYERs)

SKIP112         LDA #2                  ; Track starbase (PLAYER2)
                STA TRACKDIGIT          ;

;** Initialize starbase shape **************************************************
                LDA #SHAP.STARBASEC     ; PLAYER2 is STARBASE CENTER (shape type 3)
                STA PL2SHAPTYPE         ;
                LDA #SHAP.STARBASEL     ; PLAYER1 is STARBASE LEFT (shape type 2)
                STA PL1SHAPTYPE         ;
                LDA #SHAP.STARBASER     ; PLAYER0 is STARBASE RIGHT (shape type 4)
                STA PL0SHAPTYPE         ;

                LDA #255                ; Prep starbase lifetime := 255 game loops (infinite)

                LDX CURRSECTOR          ; Skip if starbase in current sector
                LDY GCMEMMAP,X          ;
                BMI SKIP113             ;

                LDA #0                  ; Prep starbase lifetime := 0 game loops (fast death)

SKIP113         STA PL0LIFE             ; PLAYER0 lifetime := either 0 or 255 game loops
                STA PL1LIFE             ; PLAYER1 lifetime := either 0 or 255 game loops
                STA PL2LIFE             ; PLAYER2 lifetime := either 0 or 255 game loops
                STA ISSTARBASESECT      ; Store starbase-in-sector flag
                BMI SKIP114             ; Skip if starbase in current sector

                LDY #2                  ; Init explosion at PLAYER2 (STARBASE CENTER)
                JSR INITEXPL            ;

                LDX #$0A                ; Play noise sound pattern SHIELD EXPLOSION, return
                JMP NOISE               ;

;*** Keep minimum distance to starbase *****************************************
SKIP114         LDA PL2ZPOSHI           ; Skip if starbase z-coordinate > +255 (+$00**) <KM>
                BNE SKIP115             ;

                LDA PL2ZPOSLO           ; Approach starbase not closer than +32 (+$0020) <KM>
                CMP #32                 ;
                BCS SKIP115             ;
                INC PL2ZPOSLO           ; ...else push starbase back

;*** Check if in docking range *************************************************
SKIP115         LDA PL2COLUMN           ; Abort docking if PLAYER column number of...
                SEC                     ; ...PLAYER2 (STARBASE CENTER) not in 120..135.
                SBC #120                ; (!)
                CMP #16                 ;
                BCS SKIP116             ;

                LDA PL2ROWNEW           ; Abort docking if PLAYER row number of...
                SEC                     ; ...PLAYER2 (STARBASE CENTER) not in 104..119.
                SBC #104                ; (!)
                CMP #16                 ;
                BCS SKIP116             ;

                LDA PL2ZPOSHI           ; Abort docking if...
                CMP #2                  ; ... z-coordinate of starbase >= +512 (+$02**) <KM>
                BCS SKIP116             ;

                LDA PL2ZPOSSIGN         ; Abort docking...
                AND PL2YPOSSIGN         ; ...if starbase not in front and upper screen half
                EOR #$01                ;
                ORA VELOCITYLO          ; ...if our starship's velocity not zero
                ORA PL2YPOSHI           ; ...if starbase not roughly vertically centered
                ORA NEWVELOCITY         ; ...if our starship's new velocity not zero
                BEQ SKIP119             ; Else skip and handle docking

;*** Docking aborted ***********************************************************
SKIP116         LDA DOCKSTATE           ; Skip if DOCKSTATE is NOT DOCKED, TRANSFER COMPLETE
                CMP #2                  ;
                BCC SKIP117             ;

                LDY #$1F                ; Set title phrase "DOCKING ABORTED"
                JSR SETTITLE            ;

SKIP117         LDA #0                  ; DOCKSTATE := NOT DOCKED
                STA DOCKSTATE           ;
SKIP118         RTS                     ; Return

;*** Docking successful, check docking state ***********************************
SKIP119         BIT DOCKSTATE           ; Check DOCKSTATE
                BVS SKIP120             ; If DOCKSTATE = ORBIT ESTABLISHED hide title line
                BMI SKIP122             ; If DOCKSTATE = RETURN TRANSFER VESSEL return it
                LDA DOCKSTATE           ;
                BNE SKIP118             ; Return if DOCKSTATE not NOT DOCKED
                DEC DOCKSTATE           ; DOCKSTATE := ORBIT ESTABLISHED

                LDY #$1C                ; Set title phrase "ORBIT ESTABLISHED" and return
                JMP SETTITLE            ;

;*** Orbit established *********************************************************
SKIP120         LDX #0                  ; Enqueue new, empty title phrase
                STX NEWTITLEPHR         ;

                LDY TITLEPHR            ; Return if "ORBIT ESTABLISHED" still displayed
                BNE SKIP118             ;

;*** Launch transfer vessel ****************************************************
                LDA #SHAP.TRANSVSSL     ; PLAYER4 is TRANSFER VESSEL (shape 5)
                STA PL4SHAPTYPE         ;

                LDA #1                  ; Place transfer vessel behind starbase:
                STA PL4ZPOSSIGN         ; x-coordinate :=    +0..+255  (+$00**) <KM>
                STA PL4XPOSSIGN         ; y-coordinate :=  +256..+511  (+$01**) <KM>
                STA PL4YPOSSIGN         ; z-coordinate := +4096..+4351 (+$10**) <KM>
                STA PL4YPOSHI           ;
                STA PL4XVEL             ; Move transfer vessel toward our starship:
                LDA #$10                ; x-velocity := +1 <KM/H>
                STA PL4ZPOSHI           ; y-velocity := -1 <KM/H>
                LDA #$00                ; z-velocity := -7 <KM/H>
                STA PL4XPOSHI           ;
                LDA #NEG|7              ;
                STA PL4ZVEL             ;
                LDA #NEG|1              ; DOCKSTATE := RETURN TRANSFER VESSEL
                STA DOCKSTATE           ;
                STA PL4YVEL             ;
                STA PL4LIFE             ; Transfer vessel lifetime := 129 game loops
SKIP121         RTS                     ; Return

;*** Return transfer vessel ****************************************************
SKIP122         LDA PL4ZPOSSIGN         ; Return if transfer vessel in front of our starship
                BNE SKIP121             ;

                LDX #$0C                ; Play beeper sound pattern ACKNOWLEGDE
                JSR BEEP                ;

                LDY #$21                ; Set title phrase "TRANSFER COMPLETE"
                JSR SETTITLE            ;

                LDX #5                  ; Repair all 6 subsystems
LOOP041         LDA PANELTXTTAB+73,X    ;
                STA GCSTATPHO,X         ;
                DEX                     ;
                BPL LOOP041             ;

                LDA #CCS.COL2|CCS.9     ; Set starship's ENERGY readout to "9999" in COLOR2
                LDX #3                  ;
LOOP042         STA ENERGYD1,X          ;
                DEX                     ;
                BPL LOOP042             ;

                LDA #7                  ; Move transfer vessel back toward starbase:
                STA PL4ZVEL             ; x-velocity := -1 <KM/H>
                LDA #NEG|1              ; y-velocity := +1 <KM/H>
                STA PL4XVEL             ; z-velocity := +7 <KM/H>
                LDA #1                  ;
                STA PL4YVEL             ;

                STA DOCKSTATE           ; DOCKSTATE := TRANSFER COMPLETE
                JMP UPDSCREEN           ; Update screen and return

;*******************************************************************************
;*                                                                             *
;*                                   MODDLST                                   *
;*                                                                             *
;*                             Modify Display List                             *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Modifies the Display List to show and hide title, headers, and the Control
; Panel Display.
;
; INPUT
;
;   A = Number of bytes to copy into the Display List
;   X = Offset into Display List DSPLST ($0280)
;   Y = Offset into Display List fragment table DLSTFRAG ($BA62). If Y = $80
;       then no bytes are copied but the specified locations of the Display List
;       are overwritten with Display List instruction $0D (one row of
;       GRAPHICS7).
;
;   Used values are:
;
;    A    X    Y
;   $08  $5F  $00 -> Show Control Panel Display (bottom text window)
;   $08  $5F  $80 -> Hide Control Panel Display (bottom text window)
;   $07  $0F  $23 -> Show title line
;   $07  $0F  $80 -> Hide title line
;   $08  $02  $1B -> Show Display List header line of Front view
;   $08  $02  $13 -> Show Display List header line of Aft view
;   $08  $02  $0B -> Show Display List header line of Long-Range Scan view
;   $08  $02  $08 -> Show Display List header line of Galactic Chart view

L.NUMBYTES      = $6A                   ; Number of bytes to copy

MODDLST         SEI                     ; Disable IRQ
                STA L.NUMBYTES          ; Save number of bytes to copy

LOOP043         LDA VCOUNT              ; Wait for ANTIC line counter >= 124 (PLAYFIELD...
                CMP #124                ; ...bottom) before changing the Display List
                BCC LOOP043             ;

LOOP044         LDA DLSTFRAG,Y          ; Load byte from Display List fragment table
                INY                     ;
                BPL SKIP123             ; Skip if fragment table index < $80
                LDA #$0D                ; Prep Display List instruction $0D (GRAPHICS7)
SKIP123         STA DSPLST,X            ; Store byte in Display List
                INX                     ;
                DEC L.NUMBYTES          ;
                BNE LOOP044             ; Copy next byte

                CLI                     ; Enable IRQ
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                CLRPLAYFIELD                                 *
;*                                                                             *
;*                           Clear PLAYFIELD memory                            *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Clears PLAYFIELD memory from $1000 to $1FFF.
;
; This subroutine sets the start address of the memory to be cleared then code
; execution continues into subroutine CLRMEM ($AE0F) where the memory is
; actually cleared.

CLRPLAYFIELD    LDA #$10

;*******************************************************************************
;*                                                                             *
;*                                   CLRMEM                                    *
;*                                                                             *
;*                                Clear memory                                 *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Clears memory from a given start address to memory address $1FFF. This
; subroutine is called in the following situations:
;
; (1)  In routine INITCOLD ($A14A) at the beginning of the game to initialize
;      the game's variables 
;
; (2)  In subroutine CLRPLAYFIELD ($AE0D) to clear PLAYFIELD memory.
;
; As a side effect this subroutine also clears the saved number of space objects
; and the lock-on flag.
;
; INPUT
;
;   A = Start address (high byte) of memory to be cleared. Used values are:
;     $02 -> Clear memory $0200..$1FFF during game initialization
;     $10 -> Clear PLAYFIELD memory $1000..$1FFF

CLRMEM          STA MEMPTR+1            ; Store start address (high byte) to be cleared
                LDA #0                  ; Store start address (low byte) to be cleared
                TAY                     ;
                STA MEMPTR              ;

                STA ISINLOCKON          ; Clear lock-on flag
                STA OLDMAXSPCOBJIND     ; Clear saved number of space objects

LOOP045         STA (MEMPTR),Y          ; Clear memory location
                INY                     ;
                BNE LOOP045             ;

                INC MEMPTR+1            ; Next page (= 256-byte block)
                LDY MEMPTR+1            ;
                CPY #$20                ;
                TAY                     ;
                BCC LOOP045             ; Loop until memory address $2000 reached
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                   TRIGGER                                   *
;*                                                                             *
;*                           Handle joystick trigger                           *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine handles the joystick trigger and launches one of our
; starship's photon torpedo. If a target is in full lock-on then a second photon
; torpedo is prepared for automatic launch in the next game loop iteration.
;
; DETAILS
;
; If the trigger is pressed then reset the idle counter and, if not in
; hyperwarp, launch a photon torpedo with the following steps:
;
; (1)  If the trigger was pressed in this game loop iteration, a photon torpedo
;      will be launched if a previously launched photon torpedo is already under
;      way for at least 255 - 232 = 23 game loop iterations. This avoids firing
;      photon torpedoes too rapidly. 
;
; (2)  Start tracking a space object. If it is in full lock-on, set up the
;      lock-on timer, activate photon torpedo tracking, and tweak the last saved
;      trigger state such that our other photon torpedo (if available) is
;      launched automatically in the next game loop iteration.
;
; (3)  If the Photon Torpedoes are destroyed, do nothing.
;
; (4)  If the Photon Torpedoes are damaged, launch a photon torpedo from the
;      same barrel than the previous one. 
;
; (5)  If the Photon Torpedoes are not damaged, launch a photon torpedo from the
;      other barrel. 
;
; (6)  Set the lifetime of our starship's photon torpedo to infinite, set the
;      PLAYER shape to PHOTON TORPEDO. 
;
; (7)  Initialize the position vector of our starship's photon torpedo to:
;
;          x-coordinate := +256 (+$0100) <KM> (Right barrel)
;                          -256 (-$FF00) <KM> (Left barrel)
;          y-coordinate := -256 (-$FF00) <KM>
;          z-coordinate :=   +1 (+$0001) <KM>
;
; (8)  Initialize the velocity vector of our starship's photon torpedo to:
;
;          x-velocity   :=   +0 <KM/H>
;          y-velocity   :=   +0 <KM/H>
;          z-velocity   := +102 <KM/H> (All views but Aft view)
;                          -102 <KM/H> (Aft view)
;
; (9)  Subtract 10 energy units for launching our starship's photon torpedo.
;
; (10) Play the noise sound pattern PHOTON TORPEDO LAUNCHED by continuing code
;      execution into subroutine NOISE ($AEA8).

TRIGGER         LDA OLDTRIG0            ; Prep last trigger state

                LDY TRIG0               ; Copy current trigger state
                STY OLDTRIG0            ;
                BNE SKIP124             ; Return if trigger currently not pressed

                STY IDLECNTHI           ; Reset idle counter

                LDX WARPSTATE           ; Return if hyperwarp engaged
                BNE SKIP124             ;

                LDX BARRELNR            ; Prep barrel number (0 -> left, 1 -> right)

                CMP #1                  ; If trigger is newly pressed -> handle tracking...
                BEQ SKIP125             ; ...and launch our starship's photon torpedo...
                BCS SKIP127             ; ...else launch our starship's photon torpedo only
SKIP124         RTS                     ; Return

;*** Set up our starship's photon torpedo tracking *****************************
SKIP125         LDA PL3LIFE,X           ; Return if torpedo's lifetime >= 232 game loops
                CMP #232                ;
                BCS SKIP124             ;

                LDY TRACKDIGIT          ; Store index of tracked space object
                STY PLTRACKED           ;

                LDA #12                 ; Prep lock-on lifetime := 12 game loops
                LDY ISINLOCKON          ; If target is in full lock-on...
                STY ISTRACKING          ; ...activate photon torpedo tracking

                BEQ SKIP126             ; Skip if target not in full lock-on
                LDA #0                  ; Prep lock-on lifetime := 0 game loops
SKIP126         STA LOCKONLIFE          ; Store lock-on lifetime (either 0 or 12 game loops)

;*** Launch our starship's photon torpedo **************************************
SKIP127         STY OLDTRIG0            ; Update last trigger state
                BIT GCSTATPHO           ; Return if Photon Torpedoes are destroyed
                BVS SKIP124             ;

                BMI SKIP128             ; If Photon Torpedoes damaged launch from same barrel
                TXA                     ; ...else switch barrel from which to launch torpedo
                EOR #$01                ;
                STA BARRELNR            ;

SKIP128         TXA                     ; SUMMARY: Our starship's photon torpedo's...
                STA PL3XPOSSIGN,X       ; x-coordinate := +256 (+$0100) <KM> (right barrel)
                LDA BARRELXTAB,X        ; x-coordinate := -256 (-$FF00) <KM> (left barrel)
                STA PL3XPOSHI,X         ; y-coordinate := -256 (-$FF00) <KM>
                LDA #255                ; z-coordinate :=   +1 (+$0001) <KM>
                STA PL3LIFE,X           ; ...lifetime := 255 game loops
                STA PL3YPOSHI,X         ;
                LDA #0                  ;
                STA PL3SHAPTYPE,X       ; PLAYER3 or PLAYER4 is PHOTON TORPEDO (shape type 0)
                STA PL3ZPOSHI,X         ;
                STA PL3XPOSLO,X         ;
                STA PL3YPOSSIGN,X       ;
                STA PL3YPOSLO,X         ;
                LDA #1                  ;
                STA PL3ZPOSSIGN,X       ;
                STA PL3ZPOSLO,X         ;

                LDA SHIPVIEW            ; SUMMARY: Our starship's photon torpedo's...
                LSR @                  ; x-velocity :=   +0 <KM/H>
                ROR @                  ; y-velocity :=   +0 <KM/H>
                ORA #102                ; z-velocity := +102 <KM/H> (Other views)
                STA PL3ZVEL,X           ; z-velocity := -102 <KM/H> (Aft view)
                LDA #0                  ;
                STA PL3XVEL,X           ;
                STA PL3YVEL,X           ;

                LDX #2                  ; ENERGY := ENERGY - 10 for launching photon torpedo
                JSR DECENERGY           ;

                LDX #$00                ; Play noise sound pattern PHOTON TORPEDO LAUNCHED

;*******************************************************************************
;*                                                                             *
;*                                    NOISE                                    *
;*                                                                             *
;*                          Copy noise sound pattern                           *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Copies a 10-byte noise sound pattern from table NOISEPATTAB ($BF20). The first
; 8 bytes are copied to the noise sound pattern area NOISETORPTIM
; ($DA)..NOISELIFE ($E1), the remaining 2 bytes are copied to audio registers
; AUDCTL ($D208) and AUDF3 ($D204). The noise sound pattern is automatically
; played in subroutine SOUND ($B2AB).
;
; NOTE: The first 8 bytes of each pattern in table NOISEPATTAB ($BF20) are
; copied in reverse order from memory. See subroutine SOUND ($B2AB) for details
; on the noise sound patterns stored in NOISEPATTAB ($BF20).
;
; Playing a SHIELD EXPLOSION or ZYLON EXPLOSION noise sound pattern overrides a
; currently playing PHOTON TORPEDO LAUNCHED noise sound pattern.
;
; Playing a PHOTON TORPEDO LAUNCHED noise sound pattern overrides a currently
; playing PHOTON TORPEDO LAUNCHED noise sound pattern if the latter has < 24
; TICKs to play.
;
; INPUT
;
;   X = Offset into table NOISEPATTAB ($BF20) to index noise sound patterns.
;       Used values are:
;     $00 -> PHOTON TORPEDO LAUNCHED
;     $0A -> SHIELD EXPLOSION (either our starship or a starbase explodes)
;     $14 -> ZYLON EXPLOSION

NOISE           TXA                     ; Skip if SHIELD EXPLOSION or ZYLON EXPLOSION playing
                BNE SKIP129             ;

                LDA NOISELIFE           ; Return if PHOTON TORPEDO LAUNCHED noise sound pat.
                CMP #24                 ; ...playing for yet more than 24 TICKs
                BCS SKIP130             ;

SKIP129         LDY #7                  ; Copy noise sound pattern (in reverse order)
LOOP046         LDA NOISEPATTAB,X       ;
                STA NOISETORPTIM,Y      ;
                INX                     ;
                DEY                     ;
                BPL LOOP046             ;

                LDA NOISEPATTAB,X       ; Copy AUDCTL from noise sound pattern table
                STA AUDCTL              ;
                LDA NOISEPATTAB+1,X     ; Copy AUDF3 from noise sound pattern table
                STA AUDF3               ;

SKIP130         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  HOMINGVEL                                  *
;*                                                                             *
;*      Calculate homing velocity of our starship's photon torpedo 0 or 1      *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Calculates the x (or y) velocity vector component of our starship's photon
; torpedo 0 or 1 when it is tracking (homing in on) a target space object.
;
; Our starship's photon torpedo's x (or y) velocity vector component depends on
; the PLAYER column (or row) number difference between the target PLAYER and our
; starship's photon torpedo PLAYER in Player/Missile (PM) pixels. This
; difference is used as an index to pick the new x (or y) velocity vector
; component of our starship's photon torpedo from table HOMVELTAB ($BFC9):
;
; +---------------+--------------+
; | Difference in | New Velocity |
; |   PM Pixels   |  Component   |
; +---------------+--------------+
; |    >= +7      |   -64 <KM/H> |
; |       +6      |   -56 <KM/H> |
; |       +5      |   -48 <KM/H> |    
; |       +4      |   -40 <KM/H> |
; |       +3      |   -24 <KM/H> |
; |       +2      |   -16 <KM/H> |    
; |       +1      |    -8 <KM/H> |
; |        0      |     0 <KM/H> |
; |       -1      |    +8 <KM/H> |    
; |       -2      |   +16 <KM/H> |
; |       -3      |   +24 <KM/H> |
; |       -4      |   +40 <KM/H> |    
; |       -5      |   +48 <KM/H> |
; |       -6      |   +56 <KM/H> |    
; |    <= -7      |   +64 <KM/H> |
; +---------------+--------------+      
;
; INPUT
;
;   A     = PLAYER column (or row) number difference between the target PLAYER
;           and our starship's photon torpedo PLAYER in Player/Missile pixels
;
;   CARRY = Sign of the PLAYER column (or row) number difference. Used values
;           are:
;     0 -> Negative difference (target PLAYER column (or row) number < our
;          starship's photon torpedo PLAYER column (or row) number
;     1 -> Positive difference (target PLAYER column (or row) number >= our
;          starship's photon torpedo PLAYER column (or row) number
;
; OUTPUT
;
;   A = New velocity vector component of our starship's photon torpedo in <KM/H>

L.VELSIGN       = $6A                   ; Saves velocity sign

HOMINGVEL       LDY #NEG                ; Preload negative velocity sign
                BCS SKIP131             ; Skip if difference is positive

                EOR #$FF                ; Invert to get absolute value of difference
                LDY #0                  ; Preload positive velocity sign

SKIP131         STY L.VELSIGN           ; Save velocity sign
                CMP #8                  ;
                BCC SKIP132             ;
                LDA #7                  ; Limit difference to 0..7
SKIP132         TAY                     ;
                LDA L.VELSIGN           ; Reload velocity sign
                ORA HOMVELTAB,Y         ; Combine with homing velocity from table
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                   DAMAGE                                    *
;*                                                                             *
;*             Damage or destroy one of our starship's subsystems              *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Damages or destroys one of our starship's subsystems. There are 6 subsystems:
;
; (1)  Photon Torpedoes
; (2)  Engines
; (3)  Shields
; (4)  Attack Computer
; (5)  Long-Range Scan
; (6)  Subspace Radio
;
; Their status is stored and displayed in the Galactic Chart Panel Display by
; the colored letters PESCLR. The color of each letter represents the
; subsystem's status:
;
; +---------------+------------------+
; | Letter Color  | Subsystem Status |
; +---------------+------------------+
; | {LIGHT GREEN} | OK               |
; | {CORN YELLOW} | Damaged          |
; | {PINK}        | Destroyed        |
; +---------------+------------------+
;
; This subroutine first makes sure that we are not in demo mode. Then it picks a
; random value in 0..255 and the damage probability value. The latter value
; depends on the mission level and is picked from table DAMAGEPROBTAB ($BF10):
;
; +-----------+-------------------+---------------+
; |  Mission  |       Damage      |    Damage     |
; |   Level   | Probability Value |  Probability  |
; +-----------+-------------------+---------------+
; | NOVICE    |          0        |  0% (  0:256) | 
; | PILOT     |         80        | 31% ( 80:256) |
; | WARRIOR   |        180        | 70% (180:256) |
; | COMMANDER |        254        | 99% (254:256) |
; +-----------+-------------------+---------------+
;
; If the random number is lower than the damage probability value, a randomly
; picked subsystem is about to get damaged (or destroyed). There is a built-in
; upfront probability of 25% (2:8) that no subsystem gets harmed.
;
; If the picked subsystem is already destroyed then another subsystem is picked.
;
; Then the title phrase offset is picked from table DAMAGEPHRTAB ($BF14) to
; display the damaged subsystem in the title line. Next, color bits are picked
; that indicate a damaged system.
;
; If the Zylon photon torpedo's lifetime >= 30 game loop iterations the
; subsystem will not only be damaged but destroyed.
;
; NOTE: The Zylon photon torpedo lifetime decreases from 62 to 0 game loop
; iterations. With a remaining lifetime >= 30 game loop iterations it is
; considered strong enough to destroy one of our starship's subsystems. There
; are two exceptions to this rule: If the Attack Computer was picked to be
; destroyed it will be damaged only - not destroyed - if the Long-Range Scan has
; been already destroyed, and vice versa.
;
; Then the title phrase offset from table DESTROYPHRTAB ($BF1A) is picked to
; display the destroyed subsystem in the title line. Next, color bits are picked
; that indicate a destroyed system.
;
; The color of the subsystem's status letter is adjusted in the Galactic Chart
; Panel Display. Next, the title phrase describing the subsystem's status is
; enqueued for display in the title line. If the Attack Computer has been
; destroyed it is switched off and the PLAYFIELD is cleared. The title line is
; updated with the "DAMAGE CONTROL" message. Finally, the beeper sound pattern
; DAMAGE REPORT is played in subroutine BEEP ($B3A6).

DAMAGE          BIT ISDEMOMODE          ; Return if in demo mode
                BMI SKIP137             ;

;*** Damage some subsystem *****************************************************
                LDX MISSIONLEVEL        ; Prep mission level
LOOP047         LDA RANDOM              ; Return if random number >= damage probability
                CMP DAMAGEPROBTAB,X     ; ...(the latter depends on mission level)
                BCS SKIP137             ;

                AND #$07                ; Randomly pick 1 of 6 subsystems
                CMP #6                  ; Return if no subsystem picked
                BCS SKIP137             ;

                TAX                     ;
                LDA GCSTATPHO,X         ; Get picked subsystem status letter
                ASL @                  ; Check bit B6 (= destroyed) of letter code
                BMI LOOP047             ; Try again if subsystem already destroyed

                LDA PL2LIFE             ; Load Zylon photon torpedo lifetime...
                CMP #30                 ; ...and compare it to 30 game loops

                LDA #CCS.COL2           ; Preload COLOR2 text color bits (= damaged status)
                LDY DAMAGEPHRTAB,X      ; Preload title phrase offset of damaged subsystem

                BCC SKIP135             ; Skip if Zylon torpedo lifetime < 30 game loops

                CPX #3                  ; Skip if selected subsystem not Attack Computer
                BNE SKIP133             ;
                BIT GCSTATLRS           ; Skip if Long-Range Scan already destroyed
                BVS SKIP135             ;
SKIP133         CPX #4                  ; Skip if selected subsystem is not Long-Range Scan
                BNE SKIP134             ;
                BIT GCSTATCOM           ; Skip if Attack Computer already destroyed
                BVS SKIP135             ;

SKIP134         LDA #CCS.COL3           ; Preload COLOR3 text color bits (= destroyed status)
                LDY DESTROYPHRTAB,X     ; Preload title phrase offset of destroyed subsystem

SKIP135         ORA GCSTATPHO,X         ; Combine status letter with new color
                STA GCSTATPHO,X         ;
                STY NEWTITLEPHR         ; Enqueue damage status title phrase
                BIT GCSTATCOM           ; Skip if Attack Computer OK or damaged
                BVC SKIP136             ;

                LDA #0                  ; Switch Attack Computer off
                STA DRAINATTCOMP        ;
                JSR CLRPLAYFIELD        ; Clear PLAYFIELD

SKIP136         LDY #$52                ; Set title phrase "DAMAGE CONTROL..."
                JSR SETTITLE            ;

                LDX #$12                ; Play beeper sound pattern DAMAGE REPORT
                JSR BEEP                ;

SKIP137         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  COLLISION                                  *
;*                                                                             *
;*            Detect a collision of our starship's photon torpedoes            *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Both of our starship's photon torpedoes are checked if they have collided with
; a space object represented by PLAYER0..2, such as a Zylon ship, a Zylon photon
; torpedo, a starbase, or a meteor. 
;
; For quick lookup, the following table lists the PLAYERs and what space objects
; they represent:
;
; +--------+--------------------------------------------------+
; | PLAYER |                   Represents                     |
; +--------+--------------------------------------------------+
; |   0    | Zylon ship 0, Starbase Left                      |
; |   1    | Zylon ship 1, Starbase Right                     |
; |   2    | Zylon photon torpedo, Starbase Center, Meteor    | 
; |   3    | Our starship's photon torpedo 0                  |
; |   4    | Our starship's photon torpedo 1, Transfer Vessel |
; +--------+--------------------------------------------------+
;
; NOTE: Only space objects represented by PLAYER0..2 are checked for collisions.
; The transfer vessel of the starbase, represented by PLAYER4, is not checked
; and therefore cannot be destroyed by one of our starship's photon torpedoes.
;
; This subroutine first checks if our starship's photon torpedoes are
; represented by alive PLAYERs with PHOTON TORPEDO shape.
;
; In order to detect a collision with a space object, our starship's photon
; torpedo must compare its x, y, and z coordinates with the ones of the space
; object.
;
; Instead of comparing the x and y coordinates, however, this subroutines uses a
; much more efficient method by inspecting the Player/Missile collision
; registers, as the x and y axis of the 3D coordinate system establish the plane
; in which the TV screen lies. Each of our starship's photon torpedoes has its
; own Player/Missile collision register: PL3HIT ($82) for our starship's photon
; torpedo 0 and PL4HIT ($83) for our starship's photon torpedo 1. By inspecting
; these registers the hit space object is determined: 
;
; +---------------------------------------------------+-------------------------+
; |          Bits B2..0 of Collision Register         |        Hit PLAYER       |
; |              (0 -> Not Hit, 1 -> Hit)             |                         |
; +-----------------+----------------+----------------+                         |
; |     PLAYER2     |     PLAYER1    |    PLAYER0     |                         |
; | (Zylon torpedo) | (Zylon ship 1) | (Zylon ship 0) |                         |
; +-----------------+----------------+----------------+-------------------------+
; |        0        |        0       |        0       | None                    |
; |        0        |        0       |        1       | PLAYER0 (Zylon ship 0)  |
; |        0        |        1       |        0       | PLAYER1 (Zylon ship 1)  |
; |        0        |        1       |        1       | PLAYER1 (Zylon ship 1)  |
; |        1        |        0       |        0       | PLAYER2 (Zylon torpedo) |
; |        1        |        0       |        1       | PLAYER2 (Zylon torpedo) |
; |        1        |        1       |        0       | PLAYER1 (Zylon ship 1)  |
; |        1        |        1       |        1       | PLAYER1 (Zylon ship 1)  |
; +-----------------+----------------+----------------+-------------------------+
;
; If the lifetime of the hit space object has already expired, then the hit is
; ignored.
;
; A collision along the z-axis happens if the z-coordinate of our starship's
; photon torpedo is close enough to the z-coordinate of the space object. This
; is determined as follows:
;
; The absolute value of the z-coordinate of the space object is converted into a
; range index in 0..7. This index picks a minimum and a maximum z-coordinate
; from tables HITMINZTAB ($BF7D) and HITMAXZTAB ($BF75). If the absolute value
; of the z-coordinate of our starship's photon torpedo is inside this interval,
; then our starship's photon torpedo has hit the space object. The following
; table lists the relevant values: 
;
; +-----------------------+-------+--------------------------+--------------------------+
; | ABS(z-Coordinate)     | Range | Min ABS(z-Coordinate)    | Max ABS(z-Coordinate)    |
; | of Space Object       | Index | of Photon Torpedo to Hit | of Photon Torpedo to Hit |
; +-----------------------+-------+--------------------------+--------------------------+
; | <=   511 ($01**) <KM> |   0   |           0 ($00**) <KM> |      < 3328 ($0C**) <KM> |
; | <=  1023 ($03**) <KM> |   1   |           0 ($00**) <KM> |      < 3328 ($0C**) <KM> |
; | <=  1535 ($05**) <KM> |   2   |           0 ($00**) <KM> |      < 3328 ($0C**) <KM> |
; | <=  2047 ($07**) <KM> |   3   |         512 ($02**) <KM> |      < 3328 ($0C**) <KM> |
; | <=  2559 ($09**) <KM> |   4   |        1024 ($04**) <KM> |      < 3840 ($0E**) <KM> |
; | <=  3071 ($0B**) <KM> |   5   |        1536 ($06**) <KM> |      < 3840 ($0E**) <KM> |
; | <=  3583 ($0D**) <KM> |   6   |        2048 ($08**) <KM> |      < 3840 ($0E**) <KM> |
; | <= 65535 ($FF**) <KM> |   7   |        3072 ($0C**) <KM> |      < 8448 ($20**) <KM> |
; +-----------------------+-------+--------------------------+--------------------------+
;
; If a collision has been detected, the "age" (= initial lifetime - remaining
; lifetime) of our starship's photon torpedo is calculated. This age is used to
; delay playing the ZYLON EXPLOSION noise sound pattern. It is also used to
; determine the strength of our starship's photon torpedo. Only photon torpedoes
; of an age < 15 game loop iterations can destroy a Zylon basestar.
;
; Some clean-up work is done before the actual explosion: The lock-on timer, our
; starship's photon torpedo lifetime, and the hit space object's PLAYER lifetime
; is set to 0. 
;
; If a meteor or a Zylon photon torpedo have been hit, then the score is not
; changed, skipping right to the explosion part. Otherwise, our starship's
; photon torpedo tracking flag is cleared and the Galactic Chart Map is updated.
; If a starbase was destroyed, then 3 points are subtracted from the score. If a
; Zylon ship was destroyed, then 6 points are added to the score and the Zylon
; KILL COUNTER readout of the Control Panel Display is incremented. Next, the
; explosion is initialized in subroutine INITEXPL ($AC6B).
;
; NOTE: This subroutine lacks proper explosion initialization if the starbase
; was hit. The actual explosion initialization is done in subroutine DOCKING
; ($ACE6) when the code finds out that the starbase sector is no more marked as
; such in the Galactic Chart.
;
; Finally, the Galactic Chart Map is searched for a remaining Zylon unit. If
; none is found then the mission is complete and code execution continues into
; subroutine GAMEOVER2 ($B121), ending the game. 

L.PLHIT         = $6B                   ; Saves PLAYER (and space object) index of hit PLAYER
L.VIEWDIR       = $6C                   ; Saves view direction. Used values are:
                                        ;   $00 -> Front view
                                        ;   $FF -> Aft view

COLLISION       LDX #2                  ; Loop over our starship's two photon torpedoes
LOOP048         DEX                     ;
                BPL SKIP138             ; Branch into loop body below
                RTS                     ; Return

;*** Photon torpedo sanity checks **********************************************
SKIP138         LDA PL3SHAPTYPE,X       ; Next photon torpedo if PLAYER not a PHOTON TORPEDO
                BNE LOOP048             ;

                LDA PL3LIFE,X           ; Next photon torpedo if PLAYER not alive
                BEQ LOOP048             ;

;*** Check if our starship's photon torpedo has hit in x-y plane ***************
                LDA PL3HIT,X            ; Check Player/Missile collision register
                AND #$07                ; Next torpedo if no torpedo-to-PLAYER collision
                BEQ LOOP048             ;

                LSR @                  ; Find out which of PLAYER0..2 was hit in PLAYFIELD
                CMP #3                  ;
                BNE SKIP139             ;
                LSR @                  ;
SKIP139         TAY                     ; Save resulting index of hit PLAYER

                LDA PL0LIFE,Y           ; Next torpedo if PLAYER0..2 (= targets) not alive
                BEQ LOOP048             ;

;*** Has our starship's photon torpedo hit within valid z-coordinate interval? *
                LDA SHIPVIEW            ; Skip if in Front view
                BEQ SKIP140             ;
                LDA #$FF                ; Calculate range index...
SKIP140         STA L.VIEWDIR           ; Saves view direction
                EOR ZPOSHI,Y            ; Calc ABS(z-coordinate (high byte)) of hit object
                CMP #16                 ; Limit range index to 0..7
                BCC SKIP141             ;
                LDA #15                 ;
SKIP141         LSR @                  ;
                STY L.PLHIT             ; Save index of hit PLAYER

                TAY                     ;
                LDA L.VIEWDIR           ; Reload view direction
                EOR PL3ZPOSHI,X         ; Calc ABS(z-coordinate (high byte)) of torpedo

                CMP HITMAXZTAB,Y        ; Next torpedo if torpedo >= max hit z-coordinate
                BCS LOOP048             ;

                CMP HITMINZTAB,Y        ; Next torpedo if torpedo < min hit z-coordinate
                BCC LOOP048             ;

;*** Our starship's photon torpedo has hit within valid z-coordinate interval! *
                LDY L.PLHIT             ; Reload index of hit PLAYER
                SEC                     ; Calc "age" of photon torpedo in game loops to...
                LDA #255                ; delay playing ZYLON EXPLOSION noise sound pattern
                SBC PL3LIFE,X           ;
                STA NOISEZYLONTIM       ;

                CMP #15                 ; Skip if photon torpedo "age" < 15
                BCC SKIP142             ;
                LDA PL0SHAPTYPE,Y       ; CARRY := PLAYER is ZYLON BASESTAR (shape type 8)
                CMP #SHAP.ZBASESTAR     ; (and torpedo "age" good to destroy ZYLON BASESTAR)

;*** Clean up our starship's photon torpedo and hit PLAYER *********************
SKIP142         LDA #0                  ; Lock-on lifetime := 0 game loops
                STA LOCKONLIFE          ;
                STA PL3LIFE,X           ; Photon torpedo's lifetime := 0 game loops
                BCS SKIP144             ; If CARRY set do not score, just do explosion

                STA PL0LIFE,Y           ; Hit PLAYER lifetime := 0 game loops

                LDA PL0SHAPTYPE,Y       ; If hit PLAYER is...
                BEQ SKIP144             ; ...a PHOTON TORPEDO (shape type 0)...
                CMP #SHAP.METEOR        ; ...or a METEOR (shape type 6)...
                BEQ SKIP144             ; ...do not score, just do explosion

                LDA #0                  ; Clear photon torpedo tracking flag
                STA ISTRACKING          ;

;*** Zylon ship (or starbase) destroyed! ***************************************
                LDX CURRSECTOR          ; Decrement Zylon count on Galactic Chart
                DEC GCMEMMAP,X          ;
                BPL SKIP143             ; Skip if destroyed space object was Zylon ship

;*** Starbase destroyed! *******************************************************
                LDA #0                  ; Remove destroyed starbase from Galactic Chart
                STA GCMEMMAP,X          ;
                SEC                     ; SCORE := SCORE - 3 for destroying starbase
                LDA SCORE               ;
                SBC #3                  ;
                STA SCORE               ;
                LDA SCORE+1             ;
                SBC #0                  ;
                STA SCORE+1             ;
                RTS                     ; Return

;*** Zylon ship destroyed! *****************************************************
SKIP143         CLC                     ; SCORE := SCORE + 6 for destroying Zylon ship
                LDA SCORE               ;
                ADC #6                  ;
                STA SCORE               ;
                LDA SCORE+1             ;
                ADC #0                  ;
                STA SCORE+1             ;

                LDX #1                  ; Increment Zylon KILL COUNTER readout...
LOOP049         INC KILLCNTD1,X         ; ...of Control Panel Display
                LDA KILLCNTD1,X         ;
                CMP #[CCS.COL1|CCS.9]+1 ;
                BCC SKIP144             ;
                LDA #[CCS.COL1|CCS.0]   ;
                STA KILLCNTD1,X         ;
                DEX                     ;
                BPL LOOP049             ;

SKIP144         JSR INITEXPL            ; Init explosion at hit PLAYER

;*** Any Zylon ships left? *****************************************************
                LDX #127                ; Scan all sectors of Galactic Chart
LOOP050         LDA GCMEMMAP,X          ;
                BMI SKIP145             ;
                BNE SKIP146             ; Return if Zylon sector found
SKIP145         DEX                     ;
                BPL LOOP050             ;

;*** Game over (Mission Complete) **********************************************
                LDY #$3F                ; Set title phrase "MISSION COMPLETE"
                LDX #0                  ; Set mission bonus offset
                JSR GAMEOVER2           ; Game over
SKIP146         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  KEYBOARD                                   *
;*                                                                             *
;*                            Handle Keyboard Input                            *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; If a keyboard code has been collected during a keyboard IRQ in the Immediate
; Interrupt Request handler IRQHNDLR ($A751), the idle counter is reset and the
; PLAYER-PLAYFIELD priority arranges the PLAYERs in front of the PLAYFIELD.
;
; Then, the keyboard code is compared with keyboard codes of table KEYTAB
; ($BABE). If no match is found the "WHAT'S WRONG" message is displayed in the
; title line and code execution returns.
;
; If one of the speed keys '0'..'9' has been pressed, a pending hyperwarp is
; aborted in subroutine ABORTWARP ($A980) and code execution returns. Otherwise
; the Engines drain rate is adjusted as well as the new velocity of our
; starship. If the Engines are damaged, a maximum speed is possible equivalent
; to speed key '5'.
;
; If one of our starship's view keys 'F' (Front), 'A' (Aft), 'G' (Galactic
; Chart), or 'L' (Long-Range Scan) have been pressed, the Display List is
; modified accordingly in subroutine MODDLST ($ADF1) and a new star field of 12
; stars is created with the help of subroutine INITPOSVEC ($B764). Code
; execution returns via subroutine UPDSCREEN ($B07B).
;
; If one of the 'T' (Tracking Computer), 'S' (Shields) or 'C' (Attack Computer)
; keys have been pressed, the corresponding status bits are toggled and the
; title line is updated with the corresponding title phrase. The beeper sound
; pattern ACKNOWLEDGE is played in subroutine BEEP ($B3A6). The tracking letter
; of the Control Panel Display is updated and the PLAYFIELD is cleared in
; subroutine CLRPLAYFIELD ($AE0D). If the Attack Computer is on, the Front or
; Aft view cross hairs are drawn, depending on the current view of our starship,
; via subroutine DRAWLINES ($A76F).
;
; If the 'H' (Hyperwarp) key has been pressed then the hyperwarp is engaged. Our
; starship's velocity is set to the maximum value, the Engines drain rate is
; increased to the equivalent of speed key '7'. Star trails are prepared. The
; position vector of the Hyperwarp Target Marker (PLAYER3) is set to the
; following values:
;
;     x-coordinate :=   +0 (+$0000) <KM>
;     y-coordinate := +256 (+$0100) <KM>
;     z-coordinate :=    + (+$****) <KM> (sign only)
;
; The velocity vector is set to the following values:
;
;     x-velocity   :=  (not initialized)
;     y-velocity   :=  (not initialized)
;     z-velocity   :=          +0 <KM/H>
;
; The temporary arrival hyperwarp marker column and row numbers are saved. If we
; are not in a NOVICE mission, the maximum veer-off velocity of the Hyperwarp
; Target Marker during hyperwarp is picked from table VEERMASKTAB ($BED7). This
; value depends on the selected hyperwarp energy (and thus on the distance to
; hyperwarp). Finally, the title line displays the "HYPERWARP ENGAGED" message.
;
; If the 'M' (Manual target selector) key has been pressed, the tracked target
; space object is swapped and the corresponding digit of the Control Panel
; Display is toggled between 0 and 1.
;
; If the 'P' (Pause) key has been pressed, an endless loop waits until the
; joystick is pushed.
;
; BUG (at $B103): The endless loop branches back one instruction too far.
; Suggested fix: Branch to instruction LDA PORTA at $B0FE.
;
; If the 'INV' (Abort mission) key has been pressed, the mission is aborted by
; setting the mission bonus offset, then displaying the "MISSION ABORTED"
; message in the title line. Code execution continues into subroutine GAMEOVER
; ($B10A).
;
; NOTE: This subroutine has two additional entry points:
;
; (1)  SETVIEW ($B045), which is used to enforce the Front view. It is entered
;      from the game loop GAMELOOP ($A1F3) and subroutines INITSTART ($A15E) and
;      DECENERGY ($B86F).
;
; (2)  UPDSCREEN ($B07B), which draws the cross hairs and the Attack Computer
;      Display, and then sets the tracking letter of the Control Panel Display.
;      It is entered from subroutine DOCKING ($ACE6).

L.KEYCODE       = $6A                   ; Saves pressed keyboard code

KEYBOARD        LDA KEYCODE             ; Return if no keyboard code collected
                BEQ SKIP150             ;

                LDX #20                 ; Prep keyboard code table loop index
                STA L.KEYCODE           ; Save keyboard code

                LDA #0                  ; Reset idle counter
                STA IDLECNTHI           ;
                STA KEYCODE             ; Clear keyboard code

                LDA #$11                ; GTIA: Enable PLAYER4, prio: PLs > PFs > BGR
                STA PRIOR               ; (PLAYERs in front of stars - and cross hairs)

;*** Search keyboard code in lookup table **************************************

LOOP051         LDA KEYTAB,X            ; Loop over all valid keyboard codes
                CMP L.KEYCODE           ;
                BEQ SKIP147             ; Branch if matching entry found
                DEX                     ;
                BPL LOOP051             ; Next keyboard code

                LDY #$10                ; No match found...
                JMP SETTITLE            ; ...set title phrase "WHATS WRONG?" and return

;*** Handle '0'..'9' keyboard keys (speed) *************************************
SKIP147         CPX #10                 ; Skip section if keyboard code does not match
                BCS SKIP151             ;

                LDA WARPSTATE           ; Skip if hyperwarp disengaged...
                BEQ SKIP148             ;
                JMP ABORTWARP           ; ...else abort hyperwarp

SKIP148         BIT GCSTATENG           ; Skip if Engines are OK or destroyed
                BVC SKIP149             ;
                CPX #6                  ; Allow max velocity equivalent to speed key '5'
                BCC SKIP149             ;
                LDX #5                  ;

SKIP149         LDA DRAINRATETAB,X      ; Set Engines energy drain rate
                STA DRAINENGINES        ;
                LDA VELOCITYTAB,X       ; Set new velocity
                STA NEWVELOCITY         ;
SKIP150         RTS                     ; Return

;*** Handle 'F', 'A', 'L', 'G' keyboard keys (our starship's views) ************
SKIP151         CPX #14                 ; Skip section if keyboard code does not match
                BCS SKIP152             ;

;*** Entry to force Front view after game init and failed missions *************
SETVIEW         LDA VIEWMODETAB-10,X    ; Store our starship's view type
                STA SHIPVIEW            ;

                LDY DLSTFRAGOFFTAB-10,X ; Get DL fragment offset (Front, Aft, LRS, GC)
                LDX #$02                ; Switch to corresponding view
                LDA #$08                ;
                JSR MODDLST             ;

                LDX #NUMSPCOBJ.NORM-1   ; Create new star field of 12 stars
LOOP052         JSR INITPOSVEC          ;
                DEX                     ;
                CPX #NUMSPCOBJ.PL       ;
                BCS LOOP052             ;

                BCC UPDSCREEN           ; Return via updating screen (below)

;*** Handle 'T', 'S', 'C' keyboard keys (Tracking, Shields, Attack Computer) ***
SKIP152         CPX #17                 ; Skip section if keyboard code does not match
                BCS SKIP156             ;

                LDY MSGOFFTAB-14,X      ; Prep title phrase offset "... OFF"
                LDA ISTRACKCOMPON-14,X  ; Toggle status bits (also energy consumption values)
                EOR MSGBITTAB-14,X      ;
                STA ISTRACKCOMPON-14,X  ;
                BEQ SKIP153             ;
                LDY MSGONTAB-14,X       ; Prep title phrase offset "... ON"
SKIP153         JSR SETTITLE            ; Set title phrase to "... ON" or "... OFF" version

                LDX #$0C                ; Play beeper sound pattern ACKNOWLEDGE
                JSR BEEP                ;

;*** Update PLAYFIELD (Cross hairs, Attack Computer, set tracking letter) ******
UPDSCREEN       LDX #CCS.T              ; Get custom char 'T' (entry point TRANSFER COMPLETE)
                LDY ISTRACKCOMPON       ;
                BEQ SKIP154             ; Skip if Tracking Computer is on

                INX                     ; Get custom char 'C'

SKIP154         STX TRACKC1             ; Store tracking character in Control Panel Display
                JSR CLRPLAYFIELD        ; Clear PLAYFIELD
                LDA DRAINATTCOMP        ; Return if Attack Computer off
                BEQ SKIP150             ;

                LDX SHIPVIEW            ; If Aft view   -> Draw Aft cross hairs and return
                BEQ SKIP155             ; If Front view -> Draw Front cross hairs and ...
                CPX #$01                ;                  ...Attack Computer and return
                BNE SKIP150             ;
                LDX #$2A                ;
SKIP155         JMP DRAWLINES           ;

;*** Handle 'H' keyboard key (Hyperwarp) ***************************************
SKIP156         CPX #17                 ; Skip if keyboard code does not match
                BNE SKIP158             ;

;*** Engage Hyperwarp **********************************************************
                LDA WARPSTATE           ; Return if hyperwarp engaged
                BNE SKIP159             ;

                LDA #$7F                ; Engage hyperwarp
                STA WARPSTATE           ;
                LDA #255                ; Set new velocity
                STA NEWVELOCITY         ;
                LDA #30                 ; Set Engines energy drain rate (= speed key '7')
                STA DRAINENGINES        ;

                LDA #NUMSPCOBJ.ALL-1    ; Set space obj index of first star of star trail
                STA TRAILIND            ;
                LDA #0                  ; Clear star trail delay
                STA TRAILDELAY          ;

                STA PL3XPOSHI           ; Init position vector and velocity vector of...
                STA PL3XPOSLO           ; ... Hyperwarp Target Marker (PLAYER3):
                STA PL3YPOSLO           ; x-coordinate :=   +0 (+$0000) <KM>
                STA PL3ZVEL             ; y-coordinate := +256 (+$0100) <KM>
                LDA #1                  ; z-coordinate :=    + (+$****) <KM> (sign only)
                STA PL3ZPOSSIGN         ; z-velocity := +0 <KM/H>
                STA PL3XPOSSIGN         ;
                STA PL3YPOSSIGN         ;
                STA PL3YPOSHI           ;

                LDA WARPARRVCOLUMN      ; Store temp arrival hyperwarp marker column number
                STA WARPTEMPCOLUMN      ;
                LDA WARPARRVROW         ; Store temp arrival hyperwarp marker row number
                STA WARPTEMPROW         ;

                LDA MISSIONLEVEL        ; Skip if NOVICE mission
                BEQ SKIP157             ;

                LDA WARPENERGY          ; Bits B0..1 of hyperwarp energy index a table...
                ROL @                  ; ...containing the maximum value of how much the...
                ROL @                  ; ...Hyperwarp Target Marker will veer off during...
                ROL @                  ; ...hyperwarp
                AND #$03                ;
                TAY                     ;
                LDA VEERMASKTAB,Y       ;

SKIP157         STA VEERMASK            ; Store veer-off velocity limitation mask

                LDY #$11                ; Set title phrase "HYPERWARP ENGAGED" and return
                JMP SETTITLE            ;

;*** Handle 'M' keyboard key (Manual Target Selector) key **********************
SKIP158         CPX #19                 ; Skip if keyboard code does not match
                BCS SKIP160             ;

                LDA TRACKDIGIT          ; Toggle digit of tracked space object of...
                EOR #$01                ; ... Control Panel Display
                AND #$01                ;
                STA TRACKDIGIT          ;
SKIP159         RTS                     ; Return

;*** Handle 'P' keyboard key (Pause) *******************************************
SKIP160         BNE SKIP161             ; Skip if keyboard code does not match

                LDA PORTA               ; Push joystick to resume action
                CMP #$FF                ;
                BEQ SKIP160             ; (!)
                RTS                     ; Return

;*** Handle 'INV' keyboard key (Abort Mission) *********************************
SKIP161         LDY #$76                ; Preload title phrase "MISSION ABORTED..."
                LDX #$04                ; Set mission bonus offset

;*******************************************************************************
;*                                                                             *
;*                                  GAMEOVER                                   *
;*                                                                             *
;*                              Handle game over                               *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Handles game over, including calculating the scored rank and class.
;
; This subroutine has two entry points: 
;
; (1)  GAMEOVER ($B10A) is entered at the end of a failed mission (mission
;      aborted, zero energy, or starship destroyed by Zylon fire), essentially
;      shutting down our starship. Code execution continues into GAMEOVER2
;      ($B121) below.
;
; (2)  GAMEOVER2 ($B121) is entered at the end of a successful mission (all
;      Zylon ships destroyed). It puts the game in demo mode, enqueues the
;      corresponding game over message, and calculates the scored rank and
;      class.
;
;      The scored rank and class are based on the total score. This is the score
;      accumulated during the game plus a mission bonus, which depends on the
;      mission level and on how the mission ended (mission complete, mission
;      aborted, or starship destroyed by Zylon fire). The mission bonus is
;      picked from table BONUSTAB ($BEDD).
;
;      The scored rank index is taken from bits B8..4 of the total score and
;      limited to values of 0..18. It indexes table RANKTAB ($BEE9) for the rank
;      string. The rank string is displayed in subroutine SETTITLE ($B223).
;
;      The scored class index is taken from bits B3..0 (for rank indices 0,
;      11..14) and computed from bits B4..1 (for rank indices 1..10 and 15..18).
;      It takes values of 0..15. It indexes table CLASSTAB ($BEFC) for the class
;      digit. The class digit is displayed in subroutine SETTITLE ($B223).
;
;      For quick lookup, the following table lists rank and class from the total
;      score. Use the table as follows: Pick the cell with the closest value
;      less or equal to your score then read the rank and class off the left and
;      the top of the table, respectively.
;
;      For example: A score of 90 results in a ranking of "Novice Class 4", a
;      score of 161 results in a ranking of "Pilot Class 3".
;
; +------------------------------+---------------------------------------------------------------+
; |     Minimum Total Score      |                        Class Index                            |
; |                              |  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15|
; +-------+----------------------+---------------------------------------------------------------+
; | Rank  |                      |                           Class                               |
; | Index |         Rank         |  5   5   5   4   4   4   4   3   3   3   2   2   2   1   1   1|
; +-------+----------------------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
; |     0 | Galactic Cook        |  0|  1|  2|  3|  4|  5|  6|  7|  8|  9| 10| 11| 12| 13| 14| 15|
; |     1 | Garbage Scow Captain | 16| 18| 20| 22| 24| 26| 28| 30|   |   |   |   |   |   |   |   |
; |     2 | Garbage Scow Captain |   |   |   |   |   |   |   |   | 32| 34| 36| 38| 40| 42| 44| 46|
; |     3 | Rookie               | 48| 50| 52| 54| 56| 58| 60| 62|   |   |   |   |   |   |   |   |
; |     4 | Rookie               |   |   |   |   |   |   |   |   | 64| 66| 68| 70| 72| 74| 76| 78|
; |     5 | Novice               | 80| 82| 84| 86| 88| 90| 92| 94|   |   |   |   |   |   |   |   |
; |     6 | Novice               |   |   |   |   |   |   |   |   | 96| 98|100|102|104|106|108|110|
; |     7 | Ensign               |112|114|116|118|120|122|124|126|   |   |   |   |   |   |   |   |
; |     8 | Ensign               |   |   |   |   |   |   |   |   |128|130|132|134|136|138|140|142|
; |     9 | Pilot                |144|146|148|150|152|154|156|158|   |   |   |   |   |   |   |   |
; |    10 | Pilot                |   |   |   |   |   |   |   |   |160|162|164|166|168|170|172|174|
; |    11 | Ace                  |176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|
; |    12 | Lieutenant           |192|193|194|195|196|197|198|199|200|201|202|203|204|205|206|207|
; |    13 | Warrior              |208|209|210|211|212|213|214|215|216|217|218|219|220|221|222|223|
; |    14 | Captain              |224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|239|
; |    15 | Commander            |240|242|244|246|248|250|252|254|   |   |   |   |   |   |   |   |
; |    16 | Commander            |   |   |   |   |   |   |   |   |256|258|260|262|264|266|268|270|
; |    17 | Star Commander       |272|274|276|278|280|282|284|286|   |   |   |   |   |   |   |   |
; |    18 | Star Commander       |   |   |   |   |   |   |   |   |288|290|292|294|296|298|300|302|
; +-------+----------------------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
;
;      NOTE: This subroutine also clears the vertical and horizontal joystick
;      directions.
;
; INPUT
;
;   X = Offset to index table BONUSTAB ($BEDD) of mission bonus values. Used
;       values are:
;     $00 -> Mission complete
;     $04 -> Mission was aborted due to zero energy
;     $08 -> Our starship was destroyed by Zylon fire
;
;   Y = Title phrase offset. Used values are:
;     $3F -> "MISSION COMPLETE"
;     $31 -> "MISSION ABORTED ZERO ENERGY"
;     $23 -> "SHIP DESTROYED BY ZYLON FIRE"

;*** Game over (Mission failed) ************************************************
GAMEOVER        LDA #0                  ;
                STA PL3LIFE             ; PLAYER3 lifetime := 0 game loops
                STA BEEPPRIORITY        ; Mute beeper
                STA TITLEPHR            ; Clear title line
                STA REDALERTLIFE        ; Red alert flash lifetime := 0 game loops
                STA AUDC4               ; Mute audio channel 4
                STA NEWVELOCITY         ; Shut down Engines
                STA SHIELDSCOLOR        ; Set Shields color to {BLACK}
                STA DRAINSHIELDS        ; Switch off Shields
                STA WARPSTATE           ; Disengage hyperwarp
                STA VELOCITYHI          ; Turn off hyperwarp velocity

;*** Game over (Mission successful) ********************************************
GAMEOVER2       LDA #$FF                ; Enter demo mode
                STA ISDEMOMODE          ;

                STY NEWTITLEPHR         ; Enqueue title phrase

;*** Calculate total score *****************************************************
                TXA                     ;
                ORA MISSIONLEVEL        ;
                TAX                     ;
                LDA BONUSTAB,X          ; Retrieve mission bonus
                CLC                     ; Add mission bonus and game score
                ADC SCORE               ;
                TAX                     ;
                LDA #0                  ;

                STA JOYSTICKY           ; Clear vertical joystick delta
                STA JOYSTICKX           ; Clear horizontal joystick delta

                ADC SCORE+1             ;
                BMI SKIP165             ; Return if total score < 0 (= total score of 0)

;*** Calculate scored rank *****************************************************
                LSR @                  ;
                TXA                     ;
                ROR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ; Use bits B8..4 of total score as rank index
                CMP #19                 ; Limit scored rank index to 0..18
                BCC SKIP162             ;
                LDA #18                 ;
                LDX #15                 ; Prep class index of 15
SKIP162         STA SCOREDRANKIND       ; Store scored rank index

;*** Calculate scored class ****************************************************
                TAY                     ;
                TXA                     ;
                CPY #0                  ;
                BEQ SKIP164             ;
                CPY #11                 ;
                BCC SKIP163             ;
                CPY #15                 ;
                BCC SKIP164             ;
SKIP163         LSR @                  ;
                EOR #$08                ;
SKIP164         AND #$0F                ;
                STA SCOREDCLASSIND      ; Store scored class index, is 0..15

SKIP165         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 SELECTWARP                                  *
;*                                                                             *
;*             Select hyperwarp arrival location on Galactic Chart             *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine executes the following steps:
;
; (1)  Check if we are in Galactic Chart view and not in hyperwarp.
;
; (2)  Update the Galactic Chart in subroutine DRAWGC ($B4B9) if the Subspace
;      Radio is not damaged.
;
; (3)  Move the arrival hyperwarp marker (PLAYER4) across the Galactic Chart
;      every other game loop iteration. The current location of our starship is
;      indicated by the departure hyperwarp marker (PLAYER3).
;
; Code execution continues into subroutine CALCWARP ($B1A7) to calculate the
; required hyperwarp energy to hyperwarp from the departure hyperwarp marker
; position to the arrival hyperwarp marker position.
;
; NOTE: To calculate the horizontal position of PLAYER3..4 an offset of 61 is
; added (from left to right: 48 Player/Missile (PM) pixels to the left edge of
; the screen + 16 PM pixels to the left border of the Galactic Chart - 3 PM
; pixels relative offset of the PLAYER shape's horizontal center to its left
; edge = 61 PM pixels).
;
; NOTE: To calculate the vertical position of PLAYER3..4 an offset of 63 is
; added (from top to bottom: 8 Player/Missile (PM) pixels to the start of the
; Display List + 56 PM pixels to the first row of sectors - 1 PM pixel relative
; offset of the PLAYER shape's vertical center to its top edge (?) = 63 PM
; pixels).

SELECTWARP      LDA WARPSTATE           ; Return if hyperwarp engaged
                BNE SKIP166             ;

                LDA SHIPVIEW            ; Return if not in Galactic Chart view
                BMI SKIP167             ;
SKIP166         RTS                     ; Return

SKIP167         BIT GCSTATRAD           ; Skip if Subspace Radio is damaged or destroyed
                BMI SKIP168             ;

                JSR DRAWGC              ; Redraw Galactic Chart

SKIP168         LDA COUNT8              ; Move hyperwarp markers only every other game loop
                AND #$01                ; (slowing down movement of hyperwarp markers)
                BNE CALCWARP            ;

;*** Calc arrival hyperwarp marker column and row numbers, update PLAYER4 pos **
                CLC                     ;
                LDA WARPARRVCOLUMN      ; Load arrival hyperwarp marker column number
                ADC JOYSTICKX           ; Add joystick x-delta
                AND #$7F                ; Limit value to 0..127
                STA WARPARRVCOLUMN      ; Save new arrival hyperwarp marker column number
                CLC                     ;
                ADC #61                 ; Add offset of 61
                STA PL4COLUMN           ; Store as PLAYER4 column number

                CLC                     ;
                LDA WARPARRVROW         ; Load arrival hyperwarp marker row number
                ADC JOYSTICKY           ; Add joystick y-delta
                AND #$7F                ; Limit value to 0..127
                STA WARPARRVROW         ; Save new arrival hyperwarp marker row number
                CLC                     ;
                ADC #63                 ; Add offset of 63
                STA PL4ROWNEW           ; Store as PLAYER4 row number

;*** Calc departure hyperwarp marker column and row numbers, update PLAYER3 pos 
                LDA WARPDEPRROW         ; Load departure hyperwarp marker row number
                CLC                     ;
                ADC #63                 ; Add offset of 63
                STA PL3ROWNEW           ; Store as PLAYER3 row number

                LDA WARPDEPRCOLUMN      ; Load departure hyperwarp marker column number
                CLC                     ;
                ADC #61                 ; Add offset of 61
                STA PL3COLUMN           ; Store as PLAYER3 column number

;*******************************************************************************
;*                                                                             *
;*                                  CALCWARP                                   *
;*                                                                             *
;*                   Calculate and display hyperwarp energy                    *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Calculates and displays the hyperwarp energy in the Galactic Chart view.
;
; This subroutine executes the following steps:
;
; (1)  Determine the arrival sector from the arrival hyperwarp marker position.
;
; (2)  If the Subspace Radio is not destroyed, update the target number digit of
;      the Galactic Chart Panel Display.
;
; (3)  Calculate the hyperwarp energy that is required to hyperwarp from the
;      departure hyperwarp marker to the arrival hyperwarp marker based on the
;      "block-distance":
;
;          DISTANCE := DELTAR / 2 + DELTAC
;
;          where
;
;          DELTAR := ABS(WARPARRVROW - WARPDEPRROW)
;          DELTAC := ABS(WARPARRVCOLUMN - WARPDEPRCOLUMN)
;
;      NOTE: Dividing DELTAR by 2 compensates for PLAYERs at single-line
;      resolution having Player/Missile pixels that are half as high as they are
;      wide.
;
;      The hyperwarp energy, divided by 10, is the sum of a value picked from
;      the hyperwarp energy table WARPENERGYTAB ($BADD) indexed by DISTANCE / 8)
;      plus a remainder computed from Bits B1..0 of DISTANCE. 
;
; (4)  Store the hyperwarp energy value in WARPENERGY ($91).
;
; (5)  Update the HYPERWARP ENERGY readout of the Galactic Chart Panel Display.

L.WARPARRVCOL   = $6A                   ; Saves arrival sector column number
L.DELTAC        = $6A                   ; Saves diff column value

;*** Calculate arrival sector **************************************************
CALCWARP        LDA WARPARRVCOLUMN      ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                STA L.WARPARRVCOL       ; A := arrival sector column 0..15
                LDA WARPARRVROW         ;
                AND #$70                ; A := arrival sector row (0..7) * 16
                ORA L.WARPARRVCOL       ;
                STA ARRVSECTOR          ; Save arrival sector (format %0rrrcccc)

;*** Update target number digit of Galactic Chart Panel Display ****************
                TAX                     ;
                LDA GCMEMMAP,X          ; Get number of Zylon ships in arrival sector
                BPL SKIP169             ; Skip if no starbase in arrival sector
                LDA #0                  ; Clear number of Zylon ships
SKIP169         ORA #CCS.COL2|ROM.0     ; Merge COLOR2 bits with number of Zylon ships
                BIT GCSTATRAD           ; Skip if Subspace Radio destroyed
                BVS SKIP170             ;

                STA GCTRGCNT            ; Set target number digit of Galactic Chart Panel

;*** Calculate energy to hyperwarp between hyperwarp markers *******************
SKIP170         SEC                     ; A := DELTAC := ABS(WARPARRVCOLUMN - WARPDEPRCOLUMN)
                LDA WARPARRVCOLUMN      ; (Column value difference)
                SBC WARPDEPRCOLUMN      ;
                BCS SKIP171             ;
                EOR #$FF                ;
                ADC #1                  ;
SKIP171         STA L.DELTAC            ;

                SEC                     ; A := DELTAR := ABS(WARPARRVROW - WARPDEPRROW)
                LDA WARPARRVROW         ; (Row value difference)
                SBC WARPDEPRROW         ;
                BCS SKIP172             ;
                EOR #$FF                ;
                ADC #1                  ;

SKIP172         LSR @                  ; A := DISTANCE := DELTAR / 2 + DELTAC
                CLC                     ;
                ADC L.DELTAC            ;

                TAY                     ; Save DISTANCE
                LSR @                  ; Calc index into hyperwarp energy table
                LSR @                  ;
                LSR @                  ;
                TAX                     ;

                TYA                     ; Load DISTANCE value
                AND #$03                ; Get DISTANCE bits B1..0
                CLC                     ;
                ADC WARPENERGYTAB,X     ; Add hyperwarp energy from table
                STA WARPENERGY          ; Save hyperwarp energy

;*** Update HYPERWARP ENERGY readout of Galactic Chart Panel Display ***********
                TAY                     ; Prep with hyperwarp energy value

                LDA #ROM.0              ; Set HYPERWARP ENERGY readout digit1..3 to '0'
                STA GCWARPD1            ;
                STA GCWARPD1+1          ;
                STA GCWARPD1+2          ;

LOOP053         LDX #2                  ; Loop over HYPERWARP ENERGY readout digit3..1
LOOP054         INC GCWARPD1,X          ; Increment digit value
                LDA GCWARPD1,X          ;
                CMP #ROM.9+1            ;
                BCC SKIP173             ; Skip if energy digit <= '9'

                LDA #ROM.0              ; Replace energy digit with '0'
                STA GCWARPD1,X          ;
                DEX                     ;
                BPL LOOP054             ; Next energy digit

SKIP173         DEY                     ; Decrement HYPERWARP ENERGY readout value
                BNE LOOP053             ;
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  UPDTITLE                                   *
;*                                                                             *
;*                              Update title line                              *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Updates the title phrase displayed in the title line.
;
; If no title phrase has been set then fetch the offset of the next ("enqueued")
; title phrase to be displayed. If one has been set then code execution
; continues into subroutine SETTITLE ($B223), otherwise code execution returns.
;
; If a title phrase has been set then decrement the lifetime of the currently
; displayed title phrase segment. If its lifetime has reached a value of 0 then
; branch to subroutine SETTITLE ($B223) to display the next segment.

UPDTITLE        LDA TITLEPHR            ; Skip if no title phrase set
                BEQ SKIP175             ;

                DEC TITLELIFE           ; Decrement title phrase segment lifetime
                BEQ SKIP176             ; If lifetime expired show next title segment

SKIP174         RTS                     ; Return

SKIP175         LDY NEWTITLEPHR         ; Prep enqueued new title phrase
                BEQ SKIP174             ; Return if not set

;*******************************************************************************
;*                                                                             *
;*                                  SETTITLE                                   *
;*                                                                             *
;*                       Set title phrase in title line                        *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Displays a title phrase in the title line. 
;
; INTRODUCTION
;
; Title phrases are picked from the title phrase table PHRASETAB ($BBAA). They
; consist of one or more phrase tokens. Each token is a byte representing a word
; in word table WORDTAB ($BC2B). Two special tokens are placeholders for the
; scored class string ($FC) and scored rank string ($FD).
;
; A title phrase is split up into one or more title phrase segments, each
; fitting into the title line. One title phrase segment is displayed after the
; other after a delay called the "title segment lifetime".
;
; Phrase tokens, except the tokens for the scored class ($FC) and for the scored
; rank ($FD), contain the number of a word in word table WORDTAB ($BC2B) and may
; contain an end-of-segment or end-of-phrase marker bit.
;
; DETAILS
;
; The Display List is modified by subroutine MODDLST ($ADF1) to display the
; title line. Then, the title line is cleared and the words of the title phrase
; are copied into it using the passed offset into title phrase table PHRASETAB
; ($BBAA). If the offset has a value of $FF the title line is hidden in
; subroutine MODDLST ($ADF1). 
;
; INPUT
;
;   Y = Offset into title phrase table PHRASETAB ($BBAA). Used values are:
;     $FF  -> Hide title line
;     else -> Offset into title phrase table PHRASETAB ($BBAA), with explicitly
;             used values:
;
;     $01 -> "COMPUTER ON"
;     $04 -> "COMPUTER OFF"
;     $07 -> "SHIELDS ON"
;     $09 -> "SHIELDS OFF"
;     $0B -> "COMPUTER TRACKING ON"
;     $0E -> "TRACKING OFF"
;     $13 -> "STARBASE SURROUNDED"
;     $15 -> "STARBASE DESTROYED"
;     $1F -> "DOCKING ABORTED"
;     $21 -> "TRANSFER COMPLETE"
;     $4A -> "NOVICE MISSION"
;     $4C -> "PILOT MISSION"
;     $4E -> "WARRIOR MISSION"
;     $50 -> "COMMANDER MISSION"
;     $52 -> "DAMAGE CONTROL..."
;     $75 -> "RED ALERT"

L.WORD          = $6A                   ; Saves word number of WORDTAB ($BC2A). Used values
                                        ; are $00..$3F.
L.COLUMNPOS     = $6B                   ; Saves cursor column position during copying text
                                        ; into title line
L.TOKEN         = $6C                   ; Saves title phrase token from PHRASETAB ($BBAA),
                                        ; contains bit-encoded information about one word in
                                        ; the title phrase:
                                        ; B7..6 = %00 -> Copy next word to title line
                                        ; B7..6 = %01 -> End-of-phrase reached, apply short
                                        ;                delay, then hide title line. Title
                                        ;                segment lifetime = 60 game loops.
                                        ; B7..6 = %10 -> End-of-segment reached. Title
                                        ;                segment lifetime = 60 game loops
                                        ; B7..6 = %11 -> End-of-phrase reached, apply long
                                        ;                delay, then hide title line. Title
                                        ;                segment lifetime = 254 game loops.
                                        ;                Used with title phrases
                                        ;                  "STARBASE SURROUNDED"
                                        ;                  "STARBASE DESTROYED"
                                        ;                  "HYPERSPACE"
                                        ;                  "RED ALERT"
                                        ; B5..0       -> Word number of WORDTAB ($BC2A)

SETTITLE        STY TITLEPHR            ; Save title phrase offset

                LDY #$23                ; Show title line
                LDX #$0F                ;
                LDA #$07                ;
                JSR MODDLST             ;

;*** Init cursor column position and clear title line **************************
SKIP176         LDX #19                 ; There are 19(+1) characters to clear
                LDA #0                  ;
                STA L.COLUMNPOS         ; Init cursor column position

LOOP055         STA TITLETXT,X          ; Clear character in title line
                DEX                     ;
                BPL LOOP055             ;

;*** If title phrase offset = $FF then hide title line *************************
SKIP177         LDX TITLEPHR            ; Load title phrase offset
                INC TITLEPHR            ; Prepare title phrase offset for next word
                BNE SKIP178             ; ...skip if it turned 0

                LDX #$0F                ; Remove title line and return
                LDY #$80                ;
                LDA #$07                ;
                JMP MODDLST             ;

SKIP178         LDA PHRASETAB,X         ; Get phrase token

;*** Display scored class? *****************************************************
                CMP #$FC                ; Skip if not "scored class" token
                BNE SKIP179             ;

                LDY SCOREDCLASSIND      ; Get scored class index, is in 0..15
                LDA CLASSTAB,Y          ; Load scored class number digit
                LDX L.COLUMNPOS         ; Load cursor position
                STA TITLETXT,X          ; Store class in title line
                LDA #60                 ; Title segment lifetime := 60 game loops
                STA TITLELIFE           ;
                RTS                     ; Return

;*** Display scored rank? ******************************************************
SKIP179         CMP #$FD                ; Skip if not "scored rank" token
                BNE SKIP180             ;

                LDY SCOREDRANKIND       ; Get scored rank index, is in 0..18
                LDA RANKTAB,Y           ; Load rank word number

;*** Search word of token in word table ****************************************
SKIP180         STA L.TOKEN             ; Save phrase token
                AND #$3F                ; Strip bits B6..7 from phrase token
                STA L.WORD              ; Store word number (bits B5..0)

                LDA #<[WORDTAB-1]       ; Point MEMPTR to WORDTAB-1
                STA MEMPTR              ;
                LDA #>[WORDTAB-1]       ;
                STA MEMPTR+1            ;

LOOP056         INC MEMPTR              ; Increment MEMPTR
                BNE SKIP181             ;
                INC MEMPTR+1            ;

SKIP181         LDY #0                  ;
                LDA (MEMPTR),Y          ; Load character of word
                BPL LOOP056             ; Loop until end-of-word marker (bit B7) found
                DEC L.WORD              ;
                BNE LOOP056             ; Loop until word found

;*** Copy word to title line, add space ****************************************
LOOP057         AND #$3F                ; Strip color bits B6..7 from character
                EOR #CCS.COL2|$20       ; Merge COLOR2 bits and convert to ATASCII
                LDX L.COLUMNPOS         ; Copy character to title line
                INC L.COLUMNPOS         ; Increment cursor column position
                STA TITLETXT,X          ;
                INY                     ;
                LDA (MEMPTR),Y          ; Load next character of word
                BPL LOOP057             ; Next character of word if no end-of-word marker
                INC L.COLUMNPOS         ; Word was copied. Add space after word.

;*** Decide to copy another word, etc. *****************************************
                LDA #60                 ; SUMMARY:
                BIT L.TOKEN             ; If bits B7..6 of phrase token...
                BPL SKIP182             ; %00 -> Copy next word to title line
                BVC SKIP183             ; %01 -> End-of-phrase, short delay, hide title line
                LDA #254                ;        Title segment lifetime := 60 game loops
SKIP182         BVC SKIP177             ; %10 -> End-of-segment.
                LDY #$FF                ;        Title segment lifetime := 60 game loops
                STY TITLEPHR            ; %11 -> End-of-phrase, long delay, hide title line
SKIP183         STA TITLELIFE           ;        Title segment lifetime := 254 game loops
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                    SOUND                                    *
;*                                                                             *
;*                            Handle sound effects                             *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine handles the sound effects. It is called every vertical blank
; phase, that is, every TICK (1/60 s on an NTSC Atari 8-bit Home Computer
; system, 1/50 s on a PAL Atari 8-bit Home Computer system) from the Vertical
; Blank Interrupt handler VBIHNDLR ($A6D1).
;
; The game uses all of the available 4 audio channels: Audio channels 1, 2, and
; 3 are shared among the Engines sound effects and the "noise sound patterns"
; (explosion and photon torpedo sound effects), while audio channel 4 is used
; for "beeper sound patterns" (status report sound effects). The following
; sections explain the beeper sound patterns and the noise sound patterns:
;
; o   BEEPER SOUND PATTERNS
;
;     There are the following beeper sound patterns:
;
;     (1)  HYPERWARP TRANSIT
;     (2)  RED ALERT
;     (3)  ACKNOWLEDGE
;     (4)  DAMAGE REPORT
;     (5)  MESSAGE FROM STARBASE
;
;     They are encoded in table BEEPPATTAB ($BF3E) in 6-byte long "beeper sound
;     patterns". 
;
;     Another table, BEEPFRQTAB ($BF5C), stores the frequencies for the tones
;     of each beeper sound pattern, terminated by a marker byte ($FF).
;
;     BUG (at $BF5C): The pattern frequencies in table BEEPFRQTAB ($BF5C) at
;     offset $00 are unused. Suggested Fix: Remove from code.
;
;     Whenever the game calls subroutine BEEP ($B3A6), that subroutine sets up a
;     beeper sound pattern for playing by copying 6 bytes from the pattern table
;     BEEPPATTAB ($BF3E) to BEEPFRQIND ($D2)..BEEPFRQSTART ($D7). Subroutine
;     SOUND ($B2AB) detects the copied beeper sound pattern and plays the
;     encoded tones and pauses.
;
;     The relevant variables for playing a beeper sound pattern are the
;     following (see also figures at BEEPPATTAB ($BF3E)):
;
;     BEEPFRQIND    ($D2)   = Running index into table BEEPFRQTAB ($BF5C)
;     BEEPREPEAT    ($D3)   = Number of times that the beeper sound pattern is
;                             repeated - 1
;     BEEPTONELIFE  ($D4)   = Lifetime of tone in TICKs - 1
;     BEEPPAUSELIFE ($D5)   = Lifetime of pause in TICKs - 1 ($FF -> No pause)
;     BEEPPRIORITY  ($D6)   = Beeper sound pattern priority. A playing beeper
;                             sound pattern is stopped if a beeper sound pattern
;                             of higher priority is about to be played. A value
;                             of 0 indicates that no beeper sound pattern is
;                             playing at the moment.
;     BEEPFRQSTART  ($D7)   = Index to first byte of the beeper sound pattern in
;                             table BEEPFRQTAB ($BF5C)
;
;     BEEPLIFE      ($D8)   = Lifetime of the current tone or pause in TICKs
;     BEEPTOGGLE    ($D9)   = Indicates that either a tone (0) or a pause (not
;                             0) is currently playing.
;
; o   NOISE SOUND PATTERNS
;
;     There are the following noise sound patterns:
;
;     (1)  PHOTON TORPEDO LAUNCHED
;     (2)  SHIELD EXPLOSION
;     (3)  ZYLON EXPLOSION
;
;     They are encoded in table NOISEPATTAB ($BF20) in 10-byte long "noise sound
;     patterns". 
;
;     Whenever the game calls subroutine NOISE ($AEA8), that subroutine sets up
;     a noise sound pattern for being played by copying 10 bytes from the
;     pattern table NOISEPATTAB ($BF20) to NOISETORPTIM ($DA)..NOISELIFE ($E1)
;     and hardware sound registers AUDCTL ($D208) and AUDF3 ($D204).
;
;     The relevant variables for playing a noise sound pattern are the
;     following:
;
;     NOISETORPTIM  ($DA)   = Delay timer for PHOTON TORPEDO LAUNCHED noise
;                             sound pattern
;     NOISEEXPLTIM  ($DB)   = Delay timer for SHIELD EXPLOSION and ZYLON
;                             EXPLOSION noise sound patterns
;     NOISEAUDC2    ($DC)   = Audio channel 1/2 control shadow register
;     NOISEAUDC3    ($DD)   = Audio channel 3   control shadow register
;     NOISEAUDF1    ($DE)   = Audio channel 1 frequency shadow register
;     NOISEAUDF2    ($DF)   = Audio channel 2 frequency shadow register
;     NOISEFRQINC   ($E0)   = Audio channel 1/2 frequency increment
;     NOISELIFE     ($E1)   = Noise sound pattern lifetime
;
;     AUDCTL        ($D208) = POKEY: Audio control
;     AUDF3         ($D204) = POKEY: Audio channel 3 frequency audio register
;
;     There are two more variables that trigger noise effects. They are not part
;     of the noise sound pattern table:
;
;     NOISEZYLONTIM ($E2)   = Delay timer to trigger the ZYLON EXPLOSION noise
;                             sound pattern. It is set in subroutine COLLISION
;                             ($AF3D) when the impact of one of our starship's
;                             photon torpedoes with a target is imminent. The
;                             timer is decremented every TICK. When it reaches a
;                             value of 0 the ZYLON EXPLOSION noise sound pattern
;                             is played in subroutine SOUND ($B2AB). 
;     NOISEHITLIFE ($E3)    = Lifetime of the STARSHIP EXPLOSION noise when our
;                             starship was destroyed by a Zylon photon torpedo.
;                             It is set in GAMELOOP ($A1F3) to a value of 64
;                             TICKs. When it reaches a value of 0 the STARSHIP
;                             EXPLOSION noise is played in subroutine SOUND
;                             ($B2AB).
;
; SUBROUTINE DETAILS
;
; This subroutine executes the following steps:
;
; (1)  Play beeper sound pattern
;
;      The playing of a beeper sound pattern is started, continued, or stopped.
;
; (2)  Play ZYLON EXPLOSION noise sound pattern
;
;      If the explosion of a target space object is imminent (subroutine
;      COLLISION ($AF3D) has set NOISEZYLONTIM ($E2) to the number of game loop
;      iterations that will pass until our starship's photon torpedo will hit
;      the target), the timer NOISEZYLONTIM ($E2) is decremented every TICK. If
;      it reaches a value of 0, then the noise sound pattern ZYLON EXPLOSION is
;      played.
;
; (3)  Play starship's Engines sound
;
;      If the Engines are louder than the current noise sound pattern then the
;      noise sound pattern is terminated and the values for the audio channels
;      1..3 are updated: 
;
;      The velocity of our starship determines the pitch and the volume of the
;      Engines: the higher the velocity, the higher the pitch and the volume of
;      the Engines. The incremented value of VELOCITYLO ($70) is used as a "base
;      value" %abcdefgh.
;
;      Audio channels 1 and 2 are combined to a 16-bit audio channel 1/2,
;      clocked at 1.79 MHz. The inverted bits (represented by an overscore)
;      B7..0 of the base value form bits B12..5 of the 16-bit frequency value of
;      audio channel 1/2. Bits B7..4 of the base value form bits B3..0 of the
;      volume of audio channel 1/2, with noise distortion bit B7 set:
;                               ________
;      AUDF1/2 ($D202..3) := %000abcdefgh00000
;      AUDC2   ($D203)    := %1000abcd
;
;      Audio channel 3 is also clocked at 1.79 MHz. The inverted bits B7..0 of
;      the base value form bits B7..0 of the frequency value of audio channel 3.
;      Bits B6..4 of the base value form bits B3..0 of the volume of audio
;      channel 3, with noise distortion bit B7 set:
;                            ________
;      AUDF3   ($D204)    := %abcdefgh
;      AUDC3   ($D205)    := %10000bcd
;
;      Code execution returns at this point.
;
; (4)  Play ZYLON EXPLOSION or SHIELD EXPLOSION noise sound pattern
;
;      If the ZYLON EXPLOSION or SHIELD EXPLOSION noise sound pattern was set
;      up, the explosion noise timer NOISEEXPLTIM ($DB) is decremented every
;      TICK. It starts either with a value of 4 TICKs with a ZYLON EXPLOSION
;      noise sound pattern or with a value of 8 TICKs with a SHIELD EXPLOSION
;      noise sound pattern, set up in subroutine NOISE ($AEA8). If it reaches a
;      value of 0, then the shadow control register of audio channel 1/2
;      switches to "noise distortion" at maximum volume.
;
; (5)  Play PHOTON TORPEDO LAUNCHED noise sound pattern
;
;      If the PHOTON TORPEDO LAUNCHED noise sound pattern was set up, the photon
;      torpedo noise timer NOISETORPTIM ($DA) is decremented every TICK. It
;      starts with a value of 8 TICKs, set in subroutine TRIGGER ($AE29). The
;      noise distortion and volume for the shadow control register of audio
;      channel 3 is picked from table NOISETORPVOLTAB ($BFEB), the noise
;      frequency for audio channel 3 is picked from table NOISETORPFRQTAB
;      ($BFF3). If the photon torpedo noise timer reaches a value of 0, then the
;      shadow control registers of audio channel 1/2 switch to "tone distortion"
;      at maximum volume and a frequency of $0202.
;
;      NOTE: Using a real-time volume envelope stored in table NOISETORPVOLTAB
;      ($BFEB) for a launched photon torpedo results in producing the
;      distinctive "whooshing" photon torpedo sound.
;
; (6)  Play STARSHIP EXPLOSION noise
;
;      If our starship was hit by a Zylon photon torpedo then NOISEHITLIFE ($E3)
;      was set to 64 TICKs in routine GAMELOOP ($A1F3). While this value is
;      decremented every TICK, a random frequency value is stored to audio
;      channel 3 and the distortion bit of the shadow control register of audio
;      channel 3 is randomly toggled.
;
; (7)  Increase audio channels 1/2 frequency
;
;      The 16-bit frequency value of audio channels 1/2 (both shadow registers
;      and audio registers) is increased every TICK by an increment picked from
;      the currently playing noise sound pattern.
;
; (8)  Mute audio channels gradually
;
;      Toward the end of a noise sound pattern's lifetime all audio channels
;      gradually mute their volume every other TICK until completely silent. 

;*** Play beeper sound pattern *************************************************
SOUND           LDA BEEPPRIORITY        ; Skip if beeper sound pattern not in use
                BEQ SKIP185             ;

                DEC BEEPLIFE            ; Decrement beeper lifetime
                BPL SKIP185             ; Skip if beeper lifetime still counting down

                LDA BEEPTOGGLE          ; Load tone/pause toggle
                BEQ LOOP058             ; Skip if a tone is playing or is to be played

                LDA BEEPPAUSELIFE       ; Load pause lifetime
                BMI LOOP058             ; Skip if duration = $FF (no pause)
                STA BEEPLIFE            ; Store pause lifetime as beeper lifetime
                LDY #0                  ; Prep AUDC4 (zero volume)
                BEQ SKIP184             ; Skip unconditionally

LOOP058         LDA BEEPTONELIFE        ; Load tone lifetime
                STA BEEPLIFE            ; Store tone lifetime as beeper lifetime
                LDX BEEPFRQIND          ; Load frequency index
                INC BEEPFRQIND          ; Increment frequency index
                LDA BEEPFRQTAB,X        ; Store tone frequency from frequency table in AUDF4
                STA AUDF4               ;
                LDY #$A8                ; Prep AUDC4 (tone distortion + medium volume)
                CMP #$FF                ; Skip if frequency not $FF (there are more tones)
                BNE SKIP184             ;

                LDA BEEPFRQSTART        ; Rewind pattern frequency pointer
                STA BEEPFRQIND          ;
                DEC BEEPREPEAT          ; Decrement sequence counter
                BPL LOOP058             ; Keep playing until sequence counter < 0

                LDY #0                  ; Prep AUDC4 with zero volume
                STY BEEPPRIORITY        ; Stop playing beeper sound pattern

SKIP184         STY AUDC4               ; Store in AUDC4
                STY BEEPTOGGLE          ; Store in BEEPTOGGLE

;*** Play ZYLON EXPLOSION noise sound pattern **********************************
SKIP185         LDA NOISEZYLONTIM       ; Skip if ZYLON EXPLOSION timer not in use
                BEQ SKIP186             ;

                DEC NOISEZYLONTIM       ; Decrement ZYLON EXPLOSION timer
                BNE SKIP186             ; Skip if ZYLON EXPLOSION timer still counting down

                LDX #$14                ; Play noise sound pattern ZYLON EXPLOSION
                JSR NOISE               ;

;*** Play our starship's Engines sound *****************************************
SKIP186         LDX VELOCITYLO          ; Skip if Engines softer than noise sound pattern
                TXA                     ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                CMP NOISELIFE           ;
                BCC SKIP187             ;

                LDA #0                  ; Terminate noise sound pattern
                STA NOISELIFE           ;

                INX                     ;
                TXA                     ; A := %abcdefgh = VELOCITYLO + 1
                EOR #$FF                ;           ________
                STA AUDF3               ; AUDF3 := %abcdefgh

                TAX                     ;                ________
                ASL @                  ; AUDF2/1 := %000abcdefgh00000
                ASL @                  ;
                ASL @                  ;
                ASL @                  ;
                ASL @                  ;
                STA AUDF1               ;
                TXA                     ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                STA AUDF2               ;

                LSR @                  ; AUDC2 := %1000abcd
                EOR #$8F                ; (noise distortion + B7..B4 bits for volume)
                STA AUDC2               ;

                AND #$87                ; AUDC3 := %10000bcd
                STA AUDC3               ; (noise distortion + B6..B4 bits for volume)

                LDA #$70                ; Clock audio channel 1 and 3 @ 1.79 MHz and...
                STA AUDCTL              ; ...combine audio channel 1/2 to 16-bit channel

                RTS                     ; Return

;*** Play ZYLON EXPLOSION or SHIELD EXPLOSION noise ****************************
SKIP187         LDA NOISEEXPLTIM        ; Skip if explosion noise timer not in use
                BEQ SKIP188             ;

                DEC NOISEEXPLTIM        ; Decrement explosion noise timer (4 or 8 TICKs long)
                BNE SKIP188             ; Skip if explosion noise timer still counting down

                LDA #$8F                ; Shadow register AUDC2 := (noise dist. + max volume)
                STA NOISEAUDC2          ;

;*** Play PHOTON TORPEDO LAUNCHED noise sound **********************************
SKIP188         LDX NOISETORPTIM        ; Skip if photon torpedo noise timer not in use
                BEQ SKIP190             ;

                DEC NOISETORPTIM        ; Decrement photon torpedo noise timer (8 TICKs long)
                BNE SKIP189             ; Skip if torpedo noise timer still counting down

                LDA #$AF                ; Shadow register AUDC2 := (tone dist. + max volume)
                STA NOISEAUDC2          ;
                LDA #$02                ; Set frequency $0202 to AUDF1/2's shadow...
                STA NOISEAUDF1          ; ...registers
                STA NOISEAUDF2          ;

SKIP189         LDA NOISETORPVOLTAB-1,X ; Pick torpedo noise + volume shape (X in 1..8)...
                STA NOISEAUDC3          ; ...and store it in AUDC3's shadow register
                LDA NOISETORPFRQTAB-1,X ; Pick photon torpedo noise frequency (X in 1..8)...
                STA AUDF3               ; ...and store it in AUDF3
                STA STIMER              ; Reset POKEY audio timers

;*** Play STARSHIP EXPLOSION noise when our starship is hit ********************
SKIP190         LDA NOISEHITLIFE        ; Skip if STARSHIP EXPLOSION noise not in use
                BEQ SKIP191             ;

                DEC NOISEHITLIFE        ; Decrement STARSHIP EXPLOSION noise lifetime
                LDA RANDOM              ; Set random frequency to AUDF3
                STA AUDF3               ;
                AND #$20                ; Toggle noise/tone dist. of AUDC3's shadow register
                EOR NOISEAUDC3          ; ...randomly
                STA NOISEAUDC3          ;

;*** Increase 16-bit frequency of audio channels 1/2 (shadow registers also) ***
SKIP191         CLC                     ; Increase 16-bit frequency value of AUDF1/2...
                LDA NOISEAUDF1          ; ...and its shadow register by...
                ADC NOISEFRQINC         ; ...noise sound pattern frequency increment
                STA NOISEAUDF1          ; AUDF1/2 := NOISEAUDF1/2 := ...
                STA AUDF1               ; ...NOISEAUDF1/2 + NOISEFRQINC
                LDA NOISEAUDF2          ;
                ADC #0                  ;
                STA NOISEAUDF2          ;
                STA AUDF2               ;

;*** Gradually mute audio channels while noise sound pattern expires ***********
                LDX NOISEAUDC2          ; Prep AUDC2's shadow register value
                LDY NOISEAUDC3          ; Prep AUDC3's shadow register value

                LDA COUNT8              ; Decrement volumes every other TICK
                LSR @                  ;
                BCC SKIP193             ;

                LDA NOISELIFE           ; Skip if noise sound pattern not in use
                BEQ SKIP193             ;

                DEC NOISELIFE           ; Decrement noise sound pattern lifetime

                CMP #17                 ; Mute noise sound pattern only in...
                BCS SKIP193             ; ...the last 16 TICKs of its lifetime

                TXA                     ; Decrement volume of AUDC2's shadow register
                AND #$0F                ;
                BEQ SKIP192             ;
                DEX                     ;
                STX NOISEAUDC2          ;

SKIP192         TYA                     ; Decrement volume of AUDC3's shadow register
                AND #$0F                ;
                BEQ SKIP193             ;
                DEY                     ;
                STY NOISEAUDC3          ;

SKIP193         STX AUDC2               ; Store shadow register values to audio registers
                STY AUDC3               ;

                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                    BEEP                                     *
;*                                                                             *
;*                          Copy beeper sound pattern                          *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Copies a 6-byte beeper sound pattern from beeper sound pattern table
; BEEPPATTAB ($BF3E) to BEEPFRQIND ($D2)..BEEPFRQSTART ($D7), provided that no
; beeper sound pattern with higher priority is currently playing. The beeper
; sound pattern will then be automatically played in subroutine SOUND ($B2AB).
; See subroutine SOUND ($B2AB) for more information on beeper sound patterns. 
;
; NOTE: The bytes from table BEEPPATTAB ($BF3E) are copied in reverse order.
;
; INPUT
;
;   X = Offset to beeper sound pattern in table BEEPPATTAB ($BF3E). Used values
;       are:
;     $00 -> HYPERWARP TRANSIT
;     $06 -> RED ALERT
;     $0C -> ACKNOWLEDGE
;     $12 -> DAMAGE REPORT
;     $18 -> MESSAGE FROM STARBASE

BEEP            LDA BEEPPATTAB,X        ; Return if beeper sound pattern of...
                CMP BEEPPRIORITY        ; ...higher priority is playing
                BCC SKIP194             ;

                LDY #5                  ; Copy 6-byte beeper sound pattern (in reverse order)
LOOP059         LDA BEEPPATTAB,X        ;
                STA BEEPFRQIND,Y        ;
                INX                     ;
                DEY                     ;
                BPL LOOP059             ;

SKIP194         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 INITIALIZE                                  *
;*                                                                             *
;*                          More game initialization                           *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine executes the following initialization steps:
;
; (1)  Set up Display List
;
;      A Display List is created at DSPLST ($0280). It starts with 2 x 8 = 16
;      blank video lines, followed by 90 GRAPHICS7 rows. After a deliberate gap
;      in Display List instructions, which will be filled dynamically during the
;      game by calls to subroutine MODDLST ($ADF1), it ends with a Display List
;      wait-and-jump-back instruction to the start of the Display List at DSPLST
;      ($0280).
;
;      NOTE: The PLAYFIELD color table PFCOLORTAB ($BFA9) is copied to zero page
;      table PF0COLOR ($F2) by loop jamming.
;
; (2)  Create lookup tables
;
;      The first lookup table MAPTO80 ($0DE9) maps a byte value of 0..255 to
;      0..80. This table is used to map unsigned (absolute) position vector
;      components (coordinates) to pixel (or PLAYER) row and column numbers.
;
;      NOTE: The PLAYFIELD is 160 pixels wide. Pixel column numbers relative the
;      horizontal PLAYFIELD center are in -80..79, hence the range of this
;      lookup table. Pixel row numbers relative the vertical PLAYFIELD center
;      are in -50..49, thus they also fit in the range of this lookup table.
;
;      The second lookup table MAPTOBCD99 ($0EE9) maps a byte value of 0..255 to
;      a BCD-encoded value in 00..99. This table is used to convert byte values
;      into decimal 2-digit values displayed by the THETA (in "gradons"), PHI
;      (in "gradons"), RANGE (in "centrons"), and VELOCITY (in "metrons per
;      second") readouts of the Console Panel Display.
;
;      The third and fourth lookup tables accelerate drawing of PLAYFIELD space
;      objects: In combination they contain the 16-bit start addresses of each
;      of the 100 rows of PLAYFIELD memory. The low bytes of the 16-bit
;      addresses are stored in table PFMEMROWLO ($0800). The high bytes are
;      stored in table PFMEMROWHI ($0864).
;
;      NOTE: The address increment is 40 (40 bytes = 160 pixels in GRAPHICS7
;      mode = 1 PLAYFIELD row of pixels). 
;
;      NOTE: The PLAYFIELD consists of 90 GRAPHICS7 rows when the Control Panel
;      Display is displayed at the bottom. When the Control Panel Display is not
;      displayed, for example in demo mode, the PLAYFIELD contains additional
;      GRAPHICS7 rows.  
;
; (3)  Copy Control Panel Display and Galactic Chart Panel Display texts
;
;      The texts of the Control Panel Display and the Galactic Chart Panel
;      Display are copied to their respective locations in memory by loop
;      jamming.
;
; (4)  Initialize Zylon unit movement timer
;
;      The timer that triggers the movement of Zylon units in the Galactic Chart
;      is initialized to a value of 99. See subroutine FLUSHGAMELOOP ($B4E4) for
;      more information on Zylon unit movement.
;
; (5)  Create Galactic Chart
;
;      The Galactic Chart memory map GCMEMMAP ($08C9) is initialized. It
;      represents 16 columns x 8 rows of sectors. Each sector contains one of
;      the 4 sector types stored in table SECTORTYPETAB ($BBA6) (starbase, 4
;      Zylon ships, 3 Zylon ships, and 2 or 1 Zylon ships), and empty sectors.
;      Before distributing the sector types, the initial position of our
;      starship is blocked on the Galactic Chart at sector row 4, sector column
;      8, so that it will not be inadvertently occupied while other sector types
;      are distributed. The number of each of the sector types to be distributed
;      is the mission level plus 2. While Zylon units can be placed anywhere,
;      starbases are placed neither at the borders of the Galactic Chart nor in
;      a sector adjacent to an occupied sector. 
;
;      After having initialized the Galactic Chart memory map, the top border of
;      the Galactic Chart is drawn with characters from the custom character
;      set.
;
;      Finally, the sector in which our starship is located and the arrival and
;      departure hyperwarp marker column and row numbers are initialized.
;
; (6)  Apply a final tweak
;
;      The last entry of lookup table MAPTOBCD99 ($0EE9) is tweaked to a value
;      of CCS.INF * 16 + CCS.SPC. It is used to display an infinity symbol by
;      the RANGE readout of the Control Panel Display in subroutine SHOWCOORD
;      ($B8A7).
;
; Code execution continues into subroutine DRAWGC ($B4B9), which draws the
; content of the Galactic Chart with characters from the custom character set.

L.MEMPTR1       = $68                   ; 16-bit memory pointer
L.MEMPTR2       = $6A                   ; 16-bit memory pointer
L.SECTORTYPE    = $6A                   ; Saves sector type. Used values are:
                                        ;   $CF -> Sector contains starbase
                                        ;   $04 -> Sector contains 4 Zylon ships
                                        ;   $03 -> Sector contains 3 Zylon ships
                                        ;   $02 -> Sector contains 2 or 1 Zylon ships
L.SECTORCNT     = $6B                   ; Saves number of sectors of the current sector type

;*** Initialize Display List and copy color table ******************************
INITIALIZE      LDX #89                 ; Set 89(+1) GRAPHICS7 rows from DSPLST+5 on
LOOP060         LDA #$0D                ; Prep DL instruction $0D (one row of GRAPHICS7)
                STA DSPLST+5,X          ; DSPLST+5,X := one row of GRAPHICS7
                CPX #10                 ;
                BCS SKIP195             ;
                LDA PFCOLORTAB,X        ; Copy PLAYFIELD color table to zero page table
                STA PF0COLOR,X          ; (loop jamming)
SKIP195         DEX                     ;
                BPL LOOP060             ;

                LDA #$70                ; DSPLST     := BLK8
                STA DSPLST              ; DSPLST+1   := BLK8
                STA DSPLST+1            ;
                LDA #$41                ; DSPLST+103 := WAITJMP @ DSPLST
                STA DSPLST+103          ;
                LDA #<DSPLST            ;
                STA DSPLST+104          ;
                LDA #>DSPLST            ;
                STA DSPLST+105          ;

;*** Calculate lookup tables ***************************************************
                LDX #0                  ; Clear both 16-bit memory pointers
                STX L.MEMPTR1           ;
                STX L.MEMPTR1+1         ;
                STX L.MEMPTR2           ;
                STX L.MEMPTR2+1         ;

;*** Calc MAPTO80 map (converts value of $00..$FF to value in 0..80) ***********
LOOP061         CLC                     ;
                LDA L.MEMPTR1           ;
                ADC #81                 ;
                STA L.MEMPTR1           ;
                LDA L.MEMPTR1+1         ;
                STA MAPTO80,X           ;
                ADC #0                  ;
                STA L.MEMPTR1+1         ;

;*** Calc MAPTOBCD99 map (converts value of $00..$FF to BCD-value in 00..99) ***
                CLC                     ;
                LDA L.MEMPTR2           ;
                ADC #100                ;
                STA L.MEMPTR2           ;
                LDA L.MEMPTR2+1         ;
                STA MAPTOBCD99,X        ;
                SED                     ;
                ADC #0                  ;
                CLD                     ;
                STA L.MEMPTR2+1         ;
                INX                     ;
                BNE LOOP061             ;

;*** Calculate PLAYFIELD memory row addresses, copy Panel Display texts ********
                LDX #<PFMEM             ; Point L.MEMPTR1 to start of PLAYFIELD memory
                STX L.MEMPTR1           ; (X = 0, because PFMEM is at $1000)
                LDA #>PFMEM             ;
                STA L.MEMPTR1+1         ;

LOOP062         CLC                     ;
                LDA L.MEMPTR1           ;
                STA PFMEMROWLO,X        ; Store 16-bit value of L.MEMPTR1 in PFMEMROWHI/LO
                ADC #40                 ; Add 40 to L.MEMPTR
                STA L.MEMPTR1           ; (40 bytes = 160 pixels = 1 PLAYFIELD row)
                LDA L.MEMPTR1+1         ;
                STA PFMEMROWHI,X        ;
                ADC #0                  ;
                STA L.MEMPTR1+1         ;

                LDA PANELTXTTAB,X       ; Copy Control and Galactic Chart Panel Display texts
                STA PANELTXT,X          ; (loop jamming)

                INX                     ;
                CPX #100                ;
                BCC LOOP062             ; Loop 100 times

;*** Set Zylon unit movement timer *********************************************
                DEX                     ;
                STX ZYLONUNITTIM        ; Init Zylon unit movement timer to 99 game loops

;*** Create memory map of the Galactic Chart ***********************************
                LDX #3                  ; Loop over all 3(+1) sector types
                STX GCMEMMAP+4*16+8     ; Block our starship's initial position at center of
                                        ; ...Galactic Chart (sector row 4, sector column 8)

LOOP063         LDA SECTORTYPETAB,X     ; Prep sector type
                STA L.SECTORTYPE        ;

                LDY MISSIONLEVEL        ; Number sectors of current type := mission level + 2
                INY                     ;
                INY                     ;
                STY L.SECTORCNT         ;

LOOP064         LDA RANDOM              ; Load random sector 0..127 from GC memory map
                AND #$7F                ;
                TAY                     ;
                LDA GCMEMMAP,Y          ;
                BNE LOOP064             ; If sector already occupied, pick another

                LDA L.SECTORTYPE        ; Reload sector type
                BPL SKIP196             ; Skip if sector not to be occupied by starbase

                CPY #$10                ; Place starbase...
                BCC LOOP064             ; ...not in first sector row of Galactic Chart
                CPY #$70                ;
                BCS LOOP064             ; ...not in last sector row of Galactic Chart
                TYA                     ;
                AND #$0F                ;
                BEQ LOOP064             ; ...not in first sector column of Galactic Chart
                CMP #15                 ;
                BEQ LOOP064             ; ...not in last sector column of Galactic Chart
                LDA GCMEMMAP-1,Y        ; ...not east  of an occupied sector
                ORA GCMEMMAP+1,Y        ; ...not west  of an occupied sector
                ORA GCMEMMAP+16,Y       ; ...not south of an occupied sector
                ORA GCMEMMAP-16,Y       ; ...not north of an occupied sector
                BNE LOOP064             ;

                LDA L.SECTORTYPE        ; Reload sector type

SKIP196         STA GCMEMMAP,Y          ; Store sector type in Galactic Chart memory map
                DEC L.SECTORCNT         ;
                BPL LOOP064             ; Next sector
                DEX                     ;
                BPL LOOP063             ; Next sector type

;*** Clear Galactic Chart and draw top border **********************************
                LDX #180                ; Clear Galactic Chart PLAYFIELD
LOOP065         LDA #CCS.SPC            ;
                STA GCPFMEM-1,X         ;
                DEX                     ;
                BNE LOOP065             ;

                LDX #15                 ; Draw top border (15(+1) characters)
LOOP066         LDA #CCS.BORDERS        ;
                STA GCPFMEM+2,X         ;
                DEX                     ;
                BPL LOOP066             ;

                LDA #CCS.CORNERSW       ; Draw NORTHEAST corner (1 character)
                STA GCPFMEM+18          ;

                LDA #0                  ; Release starship's position at center of Galactic
                STA GCMEMMAP+4*16+8     ; ...Chart (sector row 4, sector column 8)

;*** Initialize current sector and hyperwarp marker column and row numbers *****
                LDA #$48                ; Place our starship's current sector at
                STA CURRSECTOR          ; ...sector row 4, sector column 8
                LDA #$43                ; Init departure & arrival hyperwarp marker column
                STA WARPDEPRCOLUMN      ;
                STA WARPARRVCOLUMN      ;
                LDA #$47                ; Init departure & arrival hyperwarp marker row
                STA WARPARRVROW         ;
                STA WARPDEPRROW         ;

;*** Tweak last entry of MAPTOBCD99 ********************************************
                LDA #CCS.INF*16+CCS.SPC ; Last entry of MAPTOBCD99: 'INFINITY'+'SPACE' char
                STA MAPTOBCD99+255      ;

;*******************************************************************************
;*                                                                             *
;*                                   DRAWGC                                    *
;*                                                                             *
;*                             Draw Galactic Chart                             *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Draws the content of the Galactic Chart memory map in GCMEMMAP ($08C9) to the
; Galactic Chart PLAYFIELD memory at GCPFMEM ($0D35). 
;
; NOTE: CPU register X indexes the Galactic Chart memory map GCMEMMAP ($08C9)
; (16 x 8 bytes). CPU register Y indexes the Galactic Chart PLAYFIELD memory
; GCPFMEM ($0D35) (20 x 9 bytes).
;
; NOTE: Sectors with 1 or 2 Zylon ships display the same symbol in the Galactic
; Chart.

L.GCMEMMAPIND   = $6A                   ; Saves Galactic Chart memory map index

DRAWGC          LDY #0                  ; Clear Galactic Chart PLAYFIELD memory index
                STY L.GCMEMMAPIND       ; Clear Galactic Chart memory map index

LOOP067         LDX L.GCMEMMAPIND       ; Load sector of Galactic Chart memory map
                LDA GCMEMMAP,X          ;
                BPL SKIP197             ; Skip if not a starbase sector
                LDA #5                  ; Prep sector character index for starbase

SKIP197         TAX                     ; Load sector character index
                LDA SECTORCHARTAB,X     ; Load custom character set code from table...
                STA GCPFMEM+22,Y        ; ...and store it in Galactic Chart PLAYFIELD memory
                INY                     ; Increment Galactic Chart PLAYFIELD memory index
                INC L.GCMEMMAPIND       ; Increment Galactic Chart memory map index
                LDA L.GCMEMMAPIND       ;
                AND #$0F                ;
                BNE LOOP067             ; Next sector column until right border reached

                LDA #CCS.BORDERW        ; Draw right border
                STA GCPFMEM+22,Y        ;

                INY                     ; Adjust Galactic Chart PLAYFIELD memory index
                INY                     ;
                INY                     ;
                INY                     ;
                CPY #$A0                ;
                BCC LOOP067             ; Next sector until bottom-right sector reached

                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                FLUSHGAMELOOP                                *
;*                                                                             *
;*         Handle remaining tasks at the end of a game loop iteration          *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine handles at the end of a game loop iteration the following
; tasks:
;
; (1)  Increment counters COUNT256 ($76) and COUNT8 ($72).
;
; (2)  If our starship's energy has dropped below 1000 units then flash a {PINK}
;      alert that changes to {DARK GREY BLUE} and back to {PINK} every 128 game
;      loop iterations.
;
; (3)  Set the Shields color and the Control Panel background color every 8 game
;      loop iterations:
;
;      o   If the Shields are up and OK then set the Shields color to {DARK
;          GREEN} and the Control Panel background color to {DARK BLUE}.
;
;      o   If the Shields are up and damaged there is a probability of 78%
;          (200:256) that the Shield color is not changed.
;
;      o   If the Shields are down, damaged, or destroyed then set the Shields
;          color to {BLACK}.
;
;      o   If the Shields are destroyed then set the Control Panel background
;          color to {ORANGE}.
;
; (4)  Decrement the lifetime of our starship's and Zylon photon torpedoes.
;
; (5)  Decrement the lifetime of an explosion. If the explosion lifetime is less
;      than 112 game loop iterations, clear HITBADNESS ($8A) (thus the explosion
;      cannot destroy our starship). If the explosion lifetime is less than 24
;      (?) game loops decrement the number of explosion fragments. This makes
;      explosion fragments disappear gradually toward the end of an explosion.
;
; (6)  Increment every 40 game loop iterations the stardate clock of the
;      Galactic Chart Panel Display.
;
; (7)  Move Zylon units in the Galactic Chart.
;
;      Every 50 game loop iterations (or 100 game loop iterations when a
;      starbase is surrounded by Zylon units) decrement the score.
;
; Code execution continues if the game is not in demo mode with the following
; steps:
;
; (1)  Search the Galactic Chart for starbases surrounded by Zylon units.
;      Destroy any such starbase: Replace it with a 2-Zylon sector and subtract
;      18 points from the score. If the Subspace Radio was not destroyed, then
;      flash the title phrase "STARBASE DESTROYED" and play the beeper sound
;      pattern MESSAGE FROM STARBASE in subroutine BEEP ($B3A6).
;
; (2)  Every 8 game loop iterations the Zylon units decide, which starbase to
;      hunt: First, 128 randomly picked sectors are searched for a starbase. If
;      no starbase was found in this way, the sectors of the Galactic Chart are
;      scanned systematically left-to-right, top-to-bottom. If a starbase was
;      found then its sector, sector column, and sector row are saved, otherwise
;      code execution returns.
;
; (3)  Now the Zylon units converge toward the sector of the hunted starbase:
;      All sectors of the Galactic Chart are scanned. For any sector with a
;      Zylon unit that was not moved yet (its sector does not have the temporary
;      "already-moved" bit B5 set) its movement probability value is picked from
;      table MOVEPROBTAB ($BFBB):
;
;      +---------------+-------------+----------------+
;      |  Sector Type  |  Movement   |   Movement     | 
;      |               | Probability |  Probability   |
;      |               |    Value    |                |
;      +---------------+-------------+----------------+
;      | Empty sector  |       0     |   0% (  0:256) | 
;      | 1 Zylon ship  |     255     | 100% (255:256) |
;      | 2 Zylon ships |     255     | 100% (255:256) | 
;      | 3 Zylon ships |     192     |  75% (192:256) | 
;      | 4 Zylon ships |      32     |  13% ( 32:256) |
;      +---------------+-------------+----------------+
;
;      If this value is less or equal than a random number in 0..255 then the
;      Zylon unit is moved to another sector. A Zylon unit that currently
;      occupies the sector of our starship is not moved.
;
;      BUG (at $B620): The instruction to check the marker bit B5 of the sector
;      is CPY #$0A. This works, as sectors containing Zylon units that need to
;      be moved have values of 2..4, see table SECTORTYPETAB ($BBA6). Suggested
;      fix: Replace CPY #$0A with CPY #$20, which may make the code clearer.
;
; (4)  For every Zylon unit that is about to be moved, 9 distances ("block
;      distances") between the Zylon unit and the starbase are calculated by
;      tentatively moving the Zylon unit into each of its 8 adjacent sectors -
;      and by moving it not at all. The sector offsets are taken from table
;      COMPASSOFFTAB ($BFC0) which stores direction offsets in the following
;      order: NORTH, NORTHWEST, WEST, SOUTHWEST, SOUTH, SOUTHEAST, EAST,
;      NORTHEAST, CENTER. All 9 distances are stored in 9 consecutive bytes at
;      NEWZYLONDIST ($96).
;
;      NOTE: The last calculated distance is the current distance between Zylon
;      unit and starbase.
;
;      The Zylon unit moves to the first of the 8 adjacent sectors that matches
;      the following conditions: 
;
;      (1)  It is closer to the starbase than the Zylon unit's current sector.
;
;      (2)  It is located inside the Galactic Chart.
;
;      (3)  It is empty.
;
;      (4)  It is not the sector containing our starship.
;
;      If a suitable new sector was found then the Zylon unit is moved to this
;      sector, which is marked with the "already-moved" marker bit B5 in the
;      Galactic Chart memory map. This marker bit prevents a Zylon unit that has
;      been already moved from being moved again. The old Zylon unit sector is
;      cleared. 
;
;      If no suitable new sector was found then the above distance calculations
;      are repeated once again by adding 1 to the current distance between the
;      Zylon unit and the starbase. This may provoke a Zylon unit to move that
;      would not have moved in the previous set of distance calculations.
;
;      After having moved all Zylon units the sectors are stripped of the
;      "already-moved" marker bit B5.
;
; (5)  If a starbase has been surrounded then the Zylon unit movement timer is
;      reset to 99, buying our starship some time to destroy one of the
;      surrounding Zylon units. If the Subspace Radio is not destroyed, then the
;      message "STARBASE SURROUNDED" is flashed in the title line and the beeper
;      sound pattern MESSAGE FROM STARBASE is played in subroutine BEEP ($B3A6).

L.ISDESTROYED   = $6A                   ; Flags the destruction of a starbase.
                                        ; Used values are:
                                        ;   $00 -> Starbase not destroyed
                                        ;   $02 -> Starbase has been destroyed
L.NEWSECTOR     = $6A                   ; Sector to which the Zylon unit is tentatively moved
L.ABSDIFFCOLUMN = $6B                   ; Absolute difference between new Zylon and starbase
                                        ;   column on Galactic Chart in PM pixels
L.LOOPCNT2      = $6B                   ; Loop counter. Used values are: 0..1.
L.DIRECTIONIND  = $6A                   ; Compass rose direction index.
                                        ; Used values are: 0..7.

;*** Increment counters and flash low-energy alert *****************************
FLUSHGAMELOOP   INC COUNT256            ; Increment COUNT256 counter

                LDX #$90                ; Prep DLI background color {DARK GREY BLUE}
                LDA COUNT256            ;
                BPL SKIP198             ; Skip if counter < 128.

                LDY ENERGYD1            ; When energy drops below 1000 units...
                CPY #CCS.COL2|CCS.0     ;
                BNE SKIP198             ;
                LDX #$44                ; ...prep new DLI background color {PINK}

SKIP198         AND #$03                ; Increment COUNT8
                STA COUNT8              ;
                BNE SKIP202             ; Skip setting colors but every 8 game loops

;*** Set Shields and Control Panel background color ****************************
                LDY DRAINSHIELDS        ; Skip if Shields are off
                BEQ SKIP201             ;

                LDY #$A0                ; Prep Shields color {DARK GREEN}
                BIT GCSTATSHL           ; Skip if Shields are OK
                BPL SKIP200             ;
                BVS SKIP199             ; Skip if Shields are destroyed
                LDA RANDOM              ; If Shields are damaged, Shields colors are...
                CMP #200                ; ...unchanged with probability of 78% (200:256)
                BCC SKIP201             ;

SKIP199         LDY #$00                ; Prep Shields color {BLACK}
SKIP200         TYA                     ;
                BNE SKIP201             ;

                LDX #$26                ; Prep Control Panel background color {ORANGE}

SKIP201         STY SHIELDSCOLOR        ; Store Shields color
                STX BGRCOLORDLI         ; Store Control Panel background color

;*** Decrement lifetime of our starship's and Zylon photon torpedoes ***********
SKIP202         LDX #2                  ; Loop over PLAYER2..4

LOOP068         LDA PL2SHAPTYPE,X       ; Next PLAYER if not PHOTON TORPEDO (shape type 0)
                BNE SKIP203             ;

                LDA PL2LIFE,X           ; Next PLAYER if this PLAYER not alive
                BEQ SKIP203             ;

                DEC PL2LIFE,X           ; Decrement photon torpedo PLAYER lifetime

SKIP203         DEX                     ;
                BPL LOOP068             ; Next PLAYER

;*** Decrement lifetime of explosion *******************************************
                LDA EXPLLIFE            ; Skip if explosion lifetime expired
                BEQ SKIP206             ;

                DEC EXPLLIFE            ; Decrement explosion lifetime
                BNE SKIP204             ; Skip if explosion lifetime still counting

                LDX #NUMSPCOBJ.NORM     ; Explosion finished,...
                STX MAXSPCOBJIND        ; ...restore normal number of space objects

SKIP204         CMP #112                ; Skip if explosion lifetime >= 112 game loops
                BCS SKIP205             ;

                LDX #0                  ; HITBADNESS := NO HIT
                STX HITBADNESS          ;

SKIP205         CMP #24                 ; Skip if explosion lifetime >= 24 game loops (?)
                BCS SKIP206             ;

                DEC MAXSPCOBJIND        ; Decrement number of explosion fragment space objs

;*** Increment stardate clock **************************************************
SKIP206         DEC CLOCKTIM            ; Decrement stardate clock timer
                BPL SKIP209             ; Return if timer is still counting

                LDA #40                 ; Reset stardate clock timer to 40 game loops
                STA CLOCKTIM            ;

                LDX #4                  ; Increment stardate clock of Galactic Chart Panel
LOOP069         INC GCSTARDAT,X         ;
                LDA GCSTARDAT,X         ;
                CMP #[CCS.COL3|ROM.9]+1 ;
                BCC SKIP208             ;
                LDA #[CCS.COL3|ROM.0]   ;
                STA GCSTARDAT,X         ;
                CPX #3                  ;
                BNE SKIP207             ;
                DEX                     ;
SKIP207         DEX                     ;
                BPL LOOP069             ;

;*** Decrement Zylon unit movement timer ***************************************
SKIP208         DEC ZYLONUNITTIM        ; Decrement Zylon unit movement timer
                BMI SKIP210             ; If timer < 0 move Zylon units

SKIP209         RTS                     ; Return

;*** Restore Zylon unit movement timer and decrement score *********************
SKIP210         LDA #49                 ; Reset Zylon unit movement timer to 49
                STA ZYLONUNITTIM        ;

                LDA SCORE               ; SCORE := SCORE - 1
                BNE SKIP211             ;
                DEC SCORE+1             ;
SKIP211         DEC SCORE               ;

                LDX ISDEMOMODE          ; Return if in demo mode
                BNE SKIP209             ;

;*** Is starbase surrounded? ***************************************************
                STX L.ISDESTROYED       ; Init L.ISDESTROYED with 0 (starbase not destroyed)
LOOP070         LDA GCMEMMAP,X          ; Loop over all sectors, load sector type
                BPL SKIP212             ; Skip if not a starbase sector

                JSR ISSURROUNDED        ; Skip if starbase sector not completely surrounded
                BEQ SKIP212             ;

;*** Starbase is surrounded, destroy starbase **********************************
                LDA #2                  ; Replace starbase sector with 2-Zylon sector
                STA GCMEMMAP,X          ;
                STA L.ISDESTROYED       ; Flag destruction of starbase

                SEC                     ; SCORE := SCORE - 18
                LDA SCORE               ;
                SBC #18                 ;
                STA SCORE               ;
                LDA SCORE+1             ;
                SBC #0                  ;
                STA SCORE+1             ;

SKIP212         INX                     ;
                BPL LOOP070             ; Next sector

;*** Report starbase destruction ***********************************************
                LDA L.ISDESTROYED       ; Skip if no starbase has been destroyed
                BEQ SKIP213             ;

                BIT GCSTATRAD           ; Skip notification if Subspace Radio destroyed
                BVS SKIP213             ;

                LDY #$15                ; Set title phrase "STARBASE DESTROYED"
                JSR SETTITLE            ;

                LDX #$18                ; Play beeper sound pattern MESSAGE FROM STARBASE
                JSR BEEP                ;

;*** Pick new starbase to be hunted by Zylon units *****************************
SKIP213         DEC HUNTTIM             ; Decrement hunting timer
                BMI SKIP214             ; If timer < 0 decide which starbase to hunt

                LDX HUNTSECTOR          ; Skip if Zylon units already picked starbase to hunt
                LDA GCMEMMAP,X          ;
                BMI SKIP215             ;

SKIP214         LDA #7                  ; Reset hunting timer
                STA HUNTTIM             ;

                LDY #127                ; Loop over 127(+1) randomly picked sectors
LOOP071         LDA RANDOM              ;
                AND #$7F                ;
                TAX                     ;
                LDA GCMEMMAP,X          ; Skip if starbase sector found
                BMI SKIP215             ;
                DEY                     ;
                BPL LOOP071             ; Next sector

                LDX #127                ; Loop over all sectors of the Galactic Chart
LOOP072         LDA GCMEMMAP,X          ;
                BMI SKIP215             ; Skip if starbase sector found
                DEX                     ;
                BPL LOOP072             ; Next sector

                RTS                     ; Return (no starbase sector found)

;*** Store coordinates of starbase to be hunted ********************************
SKIP215         STX HUNTSECTOR          ; Store hunted starbase sector column and row
                TXA                     ;
                AND #$0F                ;
                STA HUNTSECTCOLUMN      ;
                TXA                     ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                STA HUNTSECTROW         ;

;*** Move all Zylon units toward hunted starbase *******************************
                LDX #$FF                ;
LOOP073         INX                     ; Loop over all sectors to move Zylon units
                BPL SKIP218             ; Jump into loop body below

;*** Strip marker bits from moved Zylon units **********************************
                LDX #0                  ;
LOOP074         LDA GCMEMMAP,X          ; Loop over all sectors
                AND #$DF                ;
                STA GCMEMMAP,X          ; Strip marker bit B5 from moved Zylon units
                INX                     ;
                BPL LOOP074             ; Next sector

;*** Handle surrounded starbase ************************************************
                BIT GCSTATRAD           ; Return if Subspace Radio is destroyed
                BVS SKIP217             ;

                LDX #0                  ; Loop over all sectors
LOOP075         LDA GCMEMMAP,X          ;
                BPL SKIP216             ; Skip if not a starbase sector
                JSR ISSURROUNDED        ; Skip if starbase not surrounded
                BEQ SKIP216             ;

                LDA #99                 ; Yes, starbase surrounded...
                STA ZYLONUNITTIM        ; ...set Zylon unit movement timer to 99

                LDY #$13                ; Set title phrase "STARBASE SURROUNDED"
                JSR SETTITLE            ;

                LDX #$18                ; Play beeper sound pattern MESSAGE FROM STARBASE...
                JMP BEEP                ; ...and return

SKIP216         INX                     ;
                BPL LOOP075             ; Next sector

SKIP217         RTS                     ; Return

;*** Move single Zylon unit ****************************************************
SKIP218         LDY GCMEMMAP,X          ; X contains current sector
                CPY #$0A                ; Next sector if it has marker bit B5 set (!)
                BCS LOOP073             ;

                LDA RANDOM              ; Get random number
                CMP MOVEPROBTAB,Y       ; Get movement probability
                BCS LOOP073             ; Next sector if movement probability < random number

                CPX CURRSECTOR          ; Next sector if this is our starship's sector
                BEQ LOOP073             ;

;*** Compute distance to starbase by moving Zylon unit into 9 directions *******
                LDY #8                  ; Loop over 8(+1) possible directions
LOOP076         CLC                     ;
                TXA                     ;
                ADC COMPASSOFFTAB,Y     ; Add direction offset to current sector
                STA L.NEWSECTOR         ; Store new sector

                AND #$0F                ; Calc distance ("block distance") between...
                SEC                     ; ...starbase sector and tentative new Zylon sector
                SBC HUNTSECTCOLUMN      ;
                BCS SKIP219             ;
                EOR #$FF                ;
                ADC #1                  ;
SKIP219         STA L.ABSDIFFCOLUMN     ;
                LDA L.NEWSECTOR         ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                SEC                     ;
                SBC HUNTSECTROW         ;
                BCS SKIP220             ;
                EOR #$FF                ;
                ADC #1                  ;
SKIP220         CLC                     ;
                ADC L.ABSDIFFCOLUMN     ;

                STA NEWZYLONDIST,Y      ; Store distance in distance array
                DEY                     ;
                BPL LOOP076             ; Next direction

;*** Pick the shortest distance to starbase ************************************
                LDA #1                  ; Loop over compass rose directions twice to...
                STA L.LOOPCNT2          ; ...provoke movement regardless of truncation errors

LOOP077         LDY #7                  ;
LOOP078         LDA NEWZYLONDIST,Y      ; Loop over all 7(+1) compass rose directions
                CMP OLDZYLONDIST        ;
                BCS SKIP222             ; Next direction if new distance > current distance

                CLC                     ; Calc new Galactic Chart sector for Zylon unit
                TXA                     ;
                ADC COMPASSOFFTAB,Y     ;
                BMI SKIP222             ; Next direction if new sector outside Galactic Chart

                STY L.DIRECTIONIND      ; Save compass rose direction index
                TAY                     ;
                LDA GCMEMMAP,Y          ;
                BNE SKIP221             ; Next direction if new sector not empty

                LDA GCMEMMAP,X          ; Preload Zylon sector type to be moved
                CPY CURRSECTOR          ;
                BEQ SKIP221             ; Next direction if sector is our starship's sector

                ORA #$20                ; New sector for Zylon unit found!
                STA GCMEMMAP,Y          ; Temporarily mark that sector with marker bit B5
                LDA #0                  ;
                STA GCMEMMAP,X          ; Clear old Zylon unit sector
                BEQ SKIP223             ; Next sector (unconditional branch)

SKIP221         LDY L.DIRECTIONIND      ; Restore compass rose direction index
SKIP222         DEY                     ; Next compass rose direction
                BPL LOOP078             ;

                INC OLDZYLONDIST        ; Increment center distance
                DEC L.LOOPCNT2          ;
                BPL LOOP077             ; Loop over all compass rose directions one more time

SKIP223         JMP LOOP073             ; Next sector

; *******************************************************************************
; *                                                                             *
; *                                   ROTATE                                    *
; *                                                                             *
; *        Rotate position vector component (coordinate) by fixed angle         *
; *                                                                             *
; *******************************************************************************

; DESCRIPTION
;
; This subroutine rotates a position vector component (coordinate) of a space
; object by a fixed angle around the center of the 3D coordinate system, the
; location of our starship. This is used in the Front, Aft, and Long-Range Scan
; views to rotate space objects in and out of the view. Although the code is
; deceptively short, there is some interesting math involved, so a more detailed
; discussion is in order.
;
; ROTATION MATHEMATICS
;
; The game uses a left-handed 3D coordinate system with the positive x-axis
; pointing to the right, the positive y-axis pointing up, and the positive
; z-axis pointing into flight direction.
;
; A rotation in this coordinate system around the y-axis (horizontal rotation)
; can be expressed as 
;
;     x' :=   cos(ry) * x + sin(ry) * z    (1a)
;     z' := - sin(ry) * x + cos(ry) * z    (1b)
;
; where ry is the clockwise rotation angle around the y-axis, x and z are the
; coordinates before this rotation, and the primed coordinates x' and z' the
; coordinates after this rotation. The y-coordinate is not changed by this
; rotation.
;
; A rotation in this coordinate system around the x-axis (vertical rotation) can
; be expressed as 
;
;     z' :=   cos(rx) * z + sin(rx) * y    (2a)
;     y' := - sin(rx) * z + cos(rx) * y    (2b)
;
; where rx is the clockwise rotation angle around the x-axis, z and y are the
; coordinates before this rotation, and the primed coordinates z' and y' the
; coordinates after this rotation. The x-coordinate is not changed by this
; rotation.
;
; SUBROUTINE IMPLEMENTATION OVERVIEW
;
; A single call of this subroutine is able to compute one of the four
; expressions (1a)-(2b). To compute all four expressions to get the new set of
; coordinates, this subroutine has to be called four times. This is done twice
; in pairs in GAMELOOP ($A1F3) at $A391 and $A398, and at $A3AE and $A3B5,
; respectively.
;
; The first pair of calls calculates the new x and z coordinates of a space
; object due to a horizontal (left/right) rotation of our starship around the
; y-axis following expressions (1a) and (1b).
;
; The second pair of calls calculates the new y and z coordinates of the same
; space object due to a vertical (up/down) rotation of our starship around the
; x-axis following expressions (2a) and (2b).
;
; If you look at the code, you may be wondering how this calculation is actually
; executed, as there is neither a sin() nor a cos() function call. What you'll
; actually find implemented, however, are the following calculations:
;
;     Joystick left                        Joystick right
;     ---------------------                ---------------------
;     x :=  x      + z / 64    (3a)        x :=  x      - z / 64    (4a)
;     z := -x / 64 + z         (3b)        z :=  x / 64 + z         (4b)
;
;     Joystick down                        Joystick up
;     ---------------------                ---------------------
;     y :=  y      + z / 64    (5a)        y :=  y      - z / 64    (6a)
;     z := -y / 64 + z         (5b)        z :=  y / 64 + z         (6b)
;
; CORDIC ALGORITHM
;
; When you compare expressions (1a)-(2b) with (3a)-(6b), notice the similarity
; between the expressions if you substitute
;
;     sin(ry) -> 1 / 64, 
;     cos(ry) -> 1,
;     sin(rx) -> 1 / 64, and
;     cos(rx) -> 1.
;
; From sin(ry) = 1 / 64 and sin(rx) = 1 / 64 you can derive that the rotation
; angles ry and rx by which the space object is rotated per game loop iteration
; have a constant value of 0.89 degrees, as arcsine(1 / 64) = 0.89 degrees.
;
; What about cos(ry) and cos(rx)? The substitution does not match our derived
; angle exactly, because cos(0.89 degrees) = 0.99988 and is not exactly 1.
; However, this value is so close to 1 that substituting cos(0.89 degrees) with
; 1 is a very good approximation, simplifying calculations significantly.
;
; Another significant simplification results from the division by 64, because
; the actual division operation can be replaced with a much faster bit shift
; operation.
;
; This calculation-friendly way of computing rotations is known as the "CORDIC
; (COordinate Rotation DIgital Computer)" algorithm.
;
; MINSKY ROTATION
;
; There is one more interesting mathematical subtlety: Did you notice that
; expressions (1a)-(2b) use a new (primed) pair of variables to store the
; resulting coordinates, whereas in the implemented expressions (3a)-(6b) the
; value of the first coordinate of a coordinate pair is overwritten with its new
; value and this value is used in the subsequent calculation of the second
; coordinate? For example, when the joystick is pushed left, the first call of
; this subroutine calculates the new value of x according to expression (3a),
; overwriting the old value of x. During the second call to calculate z
; according to expression (3b), the new value of x is used instead of the old
; one. Is this to save the memory needed to temporarily store the old value of
; x? Is this a bug? If so, why does the rotation calculation actually work?
;
; Have a look at the expression pair (3a) and (3b) (the other expression pairs
; (4a)-(6b) work in a similar fashion):
;
;     x :=  x      + z / 64
;     z := -x / 64 + z
;
; With the substitution 1 / 64 -> e, we get
;
;     x :=  x     + e * z
;     z := -e * x + z
;
; Note that x is calculated first and then used in the second expression. When
; using primed coordinates for the resulting coordinates after calculating the
; two expressions we get
;
;     x' := x + e * z
;     z' := -e * x' + z = -e * (x + e * z) + z = -e * x + (1 - e^2) * z
;
; or in matrix form
;
;     |x'| := | 1       e   | * |x|
;     |z'|    |-e  (1 - e^2)|   |z|
;
; Surprisingly, this turns out to be a rotation matrix, because its determinant
; is (1 * (1 - e^2) - (e * -e)) = 1.
;
; (Incidentally, the column vectors of this matrix do not form an orthogonal
; basis, as their scalar product is 1 * e + (-e * (1 - e^2)) = -e^2.
; Orthogonality holds for e = 0 only.)
;
; This kind of rotation calculation is described by Marvin Minsky in ["AIM 239
; HAKMEM", Item 149, p. 73, MIT AI Lab, February 1972] and is called "Minsky
; Rotation".
;
; SUBROUTINE IMPLEMENTATION DETAILS
;
; To better understand how the implementation of this subroutine works, have
; again a look at expressions (3a)-(6b). If you rearrange the expressions a
; little their structure is always of the form
;
;     TERM1 := TERM1 SIGN TERM2 / 64
;
;     or shorter
;
;     TERM1 := TERM1 SIGN TERM3
;
;     where
;
;     TERM3 := TERM2 / 64
;     SIGN := + or -
;
; and where TERM1 and TERM2 are position vector components (coordinates). In
; fact, this is all this subroutine actually does: It simply adds TERM2 divided
; by 64 to TERM1 or subtracts TERM2 divided by 64 from TERM1. 
;
; When calling this subroutine the correct indices for the appropriate position
; vector components (coordinates) TERM1 and TERM2 are passed in the Y and X
; registers, respectively.
;
; What about SIGN between TERM1 and TERM3? Have again a look at expressions
; (3a)-(6b). To compute the two new coordinates after a rotation, the SIGN
; toggles from plus to minus and vice versa. The SIGN is initialized with
; JOYSTICKDELTA ($6D) before calling subroutine ROTATE ($B69B) and is toggled
; inside every call of this subroutine before the addition or subtraction of the
; terms takes place there. The initial value of SIGN should be positive (+) if
; the rotation is clockwise (the joystick is pushed right or up) and negative
; (-) if the rotation is counter-clockwise (the joystick is pushed left or
; down), respectively. Because SIGN is always toggled inside the subroutine
; before the addition or subtraction of the terms actually happens there, you
; have to pass the already toggled value with the first call.
;
; NOTE: Unclear still are three instructions starting at address $B6AD. They
; seem to set the two least significant bits of TERM3 in a random fashion. Could
; this be some quick hack to avoid messing with exact but potentially lengthy
; two-complement's arithmetic here?
;
; INPUT
;
;   X = Position vector component index of TERM2. Used values are:
;     $00..$30 -> z-component (z-coordinate) of position vector 0..48
;     $31..$61 -> x-component (x-coordinate) of position vector 0..48
;     $62..$92 -> y-component (y-coordinate) of position vector 0..48
;
;   Y = Position vector component index of TERM1. Used values are: 
;     $00..$30 -> z-component (z-coordinate) of position vector 0..48
;     $31..$61 -> x-component (x-coordinate) of position vector 0..48
;     $62..$92 -> y-component (y-coordinate) of position vector 0..48
;
;   JOYSTICKDELTA ($6D) = Initial value of SIGN. Used values are:
;     $01 -> (= Positive) Rotate right or up
;     $FF -> (= Negative) Rotate left or down

                                        ; TERM3 is a 24-bit value, represented by 3 bytes as
                                        ; $(sign)(high byte)(low byte)
L.TERM3LO       = $6A                   ; TERM3 (high byte), where TERM3 := TERM2 / 64
L.TERM3HI       = $6B                   ; TERM3 (low byte),  where TERM3 := TERM2 / 64
L.TERM3SIGN     = $6C                   ; TERM3 (sign),      where TERM3 := TERM2 / 64

ROTATE          LDA ZPOSSIGN,X          ;
                EOR #$01                ;
                BEQ SKIP224             ; Skip if sign of TERM2 is positive
                LDA #$FF                ;

SKIP224         STA L.TERM3HI           ; If TERM2 pos. -> TERM3 := $0000xx (= TERM2 / 256)
                STA L.TERM3SIGN         ; If TERM2 neg. -> TERM3 := $FFFFxx (= TERM2 / 256)
                LDA ZPOSHI,X            ; where xx := TERM2 (high byte)
                STA L.TERM3LO           ;

                LDA RANDOM              ; (?) Hack to avoid messing with two-complement's
                ORA #$BF                ; (?) arithmetic? Provides two least significant
                EOR ZPOSLO,X            ; (?) bits B1..0 in TERM3.

                ASL @                  ; TERM3 := TERM3 * 4 (= TERM2 / 256 * 4 = TERM2 / 64)
                ROL L.TERM3LO           ;
                ROL L.TERM3HI           ;
                ASL @                  ;
                ROL L.TERM3LO           ;
                ROL L.TERM3HI           ;

                LDA JOYSTICKDELTA       ; Toggle SIGN for next call of ROTATE
                EOR #$FF                ;
                STA JOYSTICKDELTA       ;
                BMI SKIP225             ; If SIGN negative then subtract, else add TERM3

;*** Addition ******************************************************************
                CLC                     ; TERM1 := TERM1 + TERM3
                LDA ZPOSLO,Y            ; (24-bit addition)
                ADC L.TERM3LO           ;
                STA ZPOSLO,Y            ;

                LDA ZPOSHI,Y            ;
                ADC L.TERM3HI           ;
                STA ZPOSHI,Y            ;

                LDA ZPOSSIGN,Y          ;
                ADC L.TERM3SIGN         ;
                STA ZPOSSIGN,Y          ;
                RTS                     ;

;*** Subtraction ***************************************************************
SKIP225         SEC                     ; TERM1 := TERM1 - TERM3
                LDA ZPOSLO,Y            ; (24-bit subtraction)
                SBC L.TERM3LO           ;
                STA ZPOSLO,Y            ;

                LDA ZPOSHI,Y            ;
                SBC L.TERM3HI           ;
                STA ZPOSHI,Y            ;

                LDA ZPOSSIGN,Y          ;
                SBC L.TERM3SIGN         ;
                STA ZPOSSIGN,Y          ;
                RTS                     ;

;*******************************************************************************
;*                                                                             *
;*                                SCREENCOLUMN                                 *
;*                                                                             *
;*       Calculate pixel column number from centered pixel column number       *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Converts a pixel column number relative to the horizontal screen center to a
; pixel column number relative to the top-left corner of the screen and stores
; the result in table PIXELCOLUMN ($0C2A). The passed relative pixel column
; number is always positive. The sign is picked from the corresponding
; x-component of the position vector (x-coordinate).
;
; If the passed relative pixel column number is offscreen horizontally the
; calculation is skipped and code execution returns. If the position vector
; corresponding to this pixel represents a PLAYFIELD space object (star,
; explosion fragments) a new position vector is initialized before code
; execution returns. If it represents a PLAYER space object the PLAYER is pushed
; offscreen before code execution returns.
;
; NOTE: The horizontal screen center's pixel column number for PLAYFIELD space
; objects has a value of 80 = 160 PLAYFIELD pixels / 2. For PLAYER space objects
; it has a value of 125 Player/Missile (PM) pixels (from left to right: 128 PM
; pixels to the horizontal screen center - 3 PM pixels relative offset of the
; PLAYER shape's horizontal center to its left edge = 125 PM pixels).
;
; INPUT
;
;   A = Pixel column number relative to the horizontal screen center, always
;       positive. Used values are:
;     0..80 -> Regular values, pixel is onscreen
;     $FF   -> Pixel is offscreen
;
;   X = Position vector index. Used values are:
;     0..4  -> Position vector of a PLAYER space object
;     5..48 -> Position vector of a PLAYFIELD space object

L.PIXELCOLUMN   = $6D                   ; Saves relative pixel column number

SCREENCOLUMN    CMP #80                 ; If pixel is offscreen (A > 79)...
                BCS SKIP233             ; ...return via initializing a new position vector

                STA L.PIXELCOLUMN       ; Save relative pixel column number
                LDA #80                 ; If PLAYFIELD space object -> A := CENTERCOL = 80
                CPX #NUMSPCOBJ.PL       ; If PLAYER space object    -> A := CENTERCOL = 125
                BCS SKIP226             ;
                LDA #125                ;

SKIP226         LDY XPOSSIGN,X          ; Skip if x-coordinate positive
                BNE SKIP227             ;

                SEC                     ; Pixel in left screen half (x-coordinate negative)
                INC L.PIXELCOLUMN       ;
                SBC L.PIXELCOLUMN       ;
                STA PIXELCOLUMN,X       ; Pixel column := CENTERCOL - (rel. pixel column + 1)
                RTS                     ; Return

SKIP227         CLC                     ; Pixel in right screen half (x-coordinate positive)
                ADC L.PIXELCOLUMN       ;
                STA PIXELCOLUMN,X       ; Pixel column := CENTERCOL + relative pixel column
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  SCREENROW                                  *
;*                                                                             *
;*          Calculate pixel row number from centered pixel row number          *
;*                                                                             *
;*******************************************************************************

; Converts a pixel row number relative to the vertical screen center to a pixel
; row number relative to the top-left corner of the screen and stores the result
; in table PIXELROWNEW ($0BF9). The passed relative pixel row number is always
; positive. The sign is picked from the corresponding y-component of the
; position vector (y-coordinate).
;
; If the passed relative pixel row number is offscreen vertically the
; calculation is skipped and code execution returns. If the position vector
; corresponding to this pixel represents a PLAYFIELD space object (star,
; explosion fragments) a new position vector is initialized in subroutine
; INITPOSVEC ($B764) before code execution returns. If it represents a PLAYER
; space object the PLAYER is pushed offscreen before code execution returns.
;
; NOTE: The vertical screen center's pixel row number for PLAYFIELD space
; objects has a value of 50 = 100 PLAYFIELD pixels / 2. For PLAYER space objects
; it has a value of 122 Player/Missile (PM) pixels (from top to bottom: 8 PM
; pixels to start of Display List + 16 PM pixels to begin of PLAYFIELD + 100 PM
; pixels to vertical screen center - 2 PM pixels (?) = 122 PM pixels).
;
; NOTE: If the position vector corresponding to the pixel represents a PLAYER
; space object the passed pixel row number is doubled because 1 PLAYFIELD pixel
; has the same height as 2 PM pixels at single-line resolution.
;
; When in Long-Range Scan view the z-coordinate takes the place of the
; y-coordinate of the Front or Aft view. If the Long-Range Scan is damaged the
; passed pixel row number is treated randomly as a negative or positive value
; (mirror effect).
;
; INPUT
;
;   A = Pixel row number relative to the vertical screen center, always
;       positive. Used values are:
;     0..50 -> Regular values, pixel is onscreen
;     $FF   -> Pixel is offscreen
;
;   X = Position vector index. Used values are:
;     0..4  -> Position vector of a PLAYER space object
;     5..48 -> Position vector of a PLAYFIELD space object

L.PIXELROW      = $6D                   ; Saves relative pixel row number

SCREENROW       CMP #50                 ; If pixel is offscreen (A > 49)...
                BCS SKIP233             ; ...return via initializing a new position vector

                STA L.PIXELROW          ; Save relative pixel row number
                LDA #50                 ; If PLAYFIELD space object -> A := CENTERROW = 50
                CPX #NUMSPCOBJ.PL       ;
                BCS SKIP228             ;
                ASL L.PIXELROW          ; If PLAYER space object -> Double pixel row number
                LDA #122                ; If PLAYER space object ->    A := CENTERROW = 122

SKIP228         BIT SHIPVIEW            ; Skip if not in Long-Range Scan view
                BVC SKIP230             ;

                BIT GCSTATLRS           ; Skip if Long-Range Scan OK
                BPL SKIP229             ;

                BIT RANDOM              ; Long-Range Scan damaged...
                BVC SKIP231             ; ...branch randomly to pixel row number calculation
                BVS SKIP232             ; ...(mirror effect)

SKIP229         LDY ZPOSSIGN,X          ;
                BNE SKIP231             ; Skip if z-coordinate pos. (Long-Range Scan view)
                BEQ SKIP232             ; Skip if z-coordinate neg. (Long-Range Scan view)

SKIP230         LDY YPOSSIGN,X          ;
                BEQ SKIP232             ; Skip if y-coordinate neg. (Front or Aft view)

SKIP231         SEC                     ; Pixel in upper screen half (z or y coordinate pos.)
                INC L.PIXELROW          ;
                SBC L.PIXELROW          ;
                STA PIXELROWNEW,X       ; Pixel row  := CENTERROW - (rel. pixel row + 1)
                RTS                     ; Return

SKIP232         CLC                     ; Pixel in lower screen half (y or z coordinate neg.)
                ADC L.PIXELROW          ;
                STA PIXELROWNEW,X       ; Pixel row := CENTERROW + relative pixel row
                RTS                     ; Return

SKIP233         CPX #NUMSPCOBJ.PL       ; Space object is offscreen. If it is a...
                BCS INITPOSVEC          ; ...PLAYFIELD space object -> New position vector
                LDA #251                ; ...PLAYER space object    -> Push PLAYER offscreen
                STA PIXELROWNEW,X       ;                              Why a value of 251 (?)
SKIP234         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                 INITPOSVEC                                  *
;*                                                                             *
;*                Initialize position vector of a space object                 *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Initializes the position vector of a space object.
;
; This subroutine executes the following steps:
;
; (1)  Set the pixel row and column number to an offscreen value (= 99).
;
; (2)  If the position vector represents an explosion fragment space object then
;      return code execution immediately. This avoids generating new explosion
;      fragment space objects. They are separately initialized in subroutine
;      COPYPOSVEC ($ACAF), which is called from subroutine INITEXPL ($AC6B).
;
; (3)  Assign default values (see below) to the position vector components
;      (coordinates) depending on our starship's view.
;
; Code execution continues into subroutine RNDINVXY ($B7BE) where x and y
; coordinates are inverted randomly.
;
; After passing through this and the next subroutine RNDINVXY ($B7BE) the
; components of a position vector (coordinates) are assigned to one of the
; following values depending on our starship's view:
;
; o   FRONT VIEW
;
;     +------------+---------------------------------------+
;     | Coordinate |                 Values                |
;     +------------+---------------------------------------+
;     |     x      |  -4095..+4095 (-($0***)..+$0***) <KM> |
;     |     y      |  -4095..+4095 (-($0***)..+$0***) <KM> | 
;     |     z      |  +3840..+4095 (          +$0F**) <KM> |
;     +------------+---------------------------------------+
;
; o   AFT VIEW
;
;     +------------+---------------------------------------+
;     | Coordinate |                 Values                |
;     +------------+---------------------------------------+ 
;     |     x      |  -3840..+3840 (-($0*00)..+$0*00) <KM> |
;     |     y      |  -3840..+3840 (-($0*00)..+$0*00) <KM> |
;     |     z      |  -3968.. -128 (-($0*80)        ) <KM> |
;     +------------+---------------------------------------+ 
;     Values of x, y, and z coordinates change in increments of 256.
;     Second digit of z-coordinate is -MAX(RNDY,RNDX), where
;     RNDY := RND($00..$0F), RNDX := RND($00..$0F).
;
; o   LONG-RANGE SCAN VIEW
;
;     +------------+---------------------------------------+
;     | Coordinate |                 Values                |
;     +------------+---------------------------------------+
;     |     x      | -65535..+65535 (-($****)..$****) <KM> |
;     |     y      |  -4095..+4095  (-($0***)..$0***) <KM> |
;     |     z      | -65535..+65535 (-($****)..$****) <KM> |
;     +------------+---------------------------------------+
;
; INPUT
;
;   X = Position vector index. Used values are: 0..48.

L.MAXRNDXY      = $6A                   ; Saves MAX(new y-coordinate (high byte), ...
                                        ;  ...new x-coordinate (high byte))

INITPOSVEC      LDA #99                 ; Init to offscreen pixel row and column numbers
                STA PIXELROWNEW,X       ;
                STA PIXELCOLUMN,X       ;

                CPX #NUMSPCOBJ.NORM     ; Return if pos vector is explosion frag space obj
                BCS SKIP234             ; This avoids creating new explosion frag space objs

                LDA RANDOM              ; RNDY := RND($00..$0F)
                AND #$0F                ;
                STA L.MAXRNDXY          ; Save RNDY
                STA YPOSHI,X            ; y-coordinate (high byte) := RNDY

                LDA RANDOM              ; RNDX := RND($00..$0F)
                AND #$0F                ;
                CMP L.MAXRNDXY          ;
                BCC SKIP235             ;
                STA L.MAXRNDXY          ; Save MAX(RNDY,RNDX)
SKIP235         STA XPOSHI,X            ; x-coordinate (high byte) := RNDX

                LDA #$0F                ; z-coordinate (high byte) := $0F
                STA ZPOSHI,X            ;

                LDA SHIPVIEW            ; z-coordinate (sign) := 1 or 0 (Front or Aft view)
                EOR #$01                ;
                AND #$01                ;
                STA ZPOSSIGN,X          ;
                BNE SKIP236             ; Skip if in Front or Long-Range Scan view

                                        ; Aft view only:
                STA XPOSLO,X            ; x-coordinate (low byte) := 0
                STA YPOSLO,X            ; y-coordinate (low byte) := 0
                SEC                     ; z-coordinate (high byte) := -MAX(RNDY,RNDX)
                SBC L.MAXRNDXY          ;
                STA ZPOSHI,X            ;
                LDA #$80                ; z-coordinate (low byte) := $80
                STA ZPOSLO,X            ;

SKIP236         BIT SHIPVIEW            ; If not in Long-Range Scan view skip to RNDINVXY
                BVC RNDINVXY            ;

                                        ; Long-Range Scan view only:
                LDA RANDOM              ; x-coordinate (high byte) := RND($00..$FF)
                STA XPOSHI,X            ;
                LDA RANDOM              ; z-coordinate (high byte) := RND($00..$FF)
                STA ZPOSHI,X            ;
                AND #$01                ; Invert z-coordinate randomly
                STA ZPOSSIGN,X          ;

;*******************************************************************************
;*                                                                             *
;*                                  RNDINVXY                                   *
;*                                                                             *
;*         Randomly invert the x and y components of a position vector         *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Randomly inverts the x and y components of a position vector (x and y
; coordinates). See also subroutine INITPOSVEC ($B764).
;
; INPUT
;
;   X = Position vector index. Used values are: 0..48.

RNDINVXY        LDA RANDOM              ; Set sign of y-coordinate randomly
                AND #$01                ;
                STA YPOSSIGN,X          ;
                BNE SKIP237             ; Skip if sign positive

                SEC                     ; Sign negative -> Calc negative y-coordinate
                SBC YPOSLO,X            ; (calculate two's-complement of 16-bit value)
                STA YPOSLO,X            ;
                LDA #0                  ;
                SBC YPOSHI,X            ;
                STA YPOSHI,X            ;

SKIP237         LDA RANDOM              ; Set sign of x-coordinate randomly
                AND #$01                ;
                STA XPOSSIGN,X          ;
                BNE SKIP238             ; Skip if sign positive

                SEC                     ; Sign negative -> Calc negative x-coordinate
                SBC XPOSLO,X            ; (calculate two's-complement of 16-bit value)
                STA XPOSLO,X            ;
                LDA #0                  ;
                SBC XPOSHI,X            ;
                STA XPOSHI,X            ;
SKIP238         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                ISSURROUNDED                                 *
;*                                                                             *
;*               Check if a sector is surrounded by Zylon units                *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Checks if a sector of the Galactic Chart is surrounded by Zylon units in the
; adjacent NORTH, EAST, SOUTH, and WEST sectors.
;
; INPUT
;
;   X = Sector of Galactic Chart. Used values are: $00..$7F with, for example,
;     $00 -> NORTHWEST corner sector
;     $0F -> NORTHEAST corner sector
;     $70 -> SOUTHWEST corner sector
;     $7F -> SOUTHWEST corner sector
;
; OUTPUT
;
;   A = Returns if the sector is surrounded by Zylon units in the adjacent
;       NORTH, EAST, SOUTH, and WEST sectors.
;       0 -> Sector is not surrounded
;     > 0 -> Sector is surrounded

ISSURROUNDED    LDA GCMEMMAP-1,X        ; Check WEST sector
                BEQ SKIP239             ;
                LDA GCMEMMAP+1,X        ; Check EAST sector
                BEQ SKIP239             ;
                LDA GCMEMMAP-16,X       ; Check NORTH sector
                BEQ SKIP239             ;
                LDA GCMEMMAP+16,X       ; Check SOUTH sector
SKIP239         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  UPDPANEL                                   *
;*                                                                             *
;*                        Update Control Panel Display                         *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; This subroutine executes the following steps: 
;
; (1)  Accelerate or decelerate our starship, update the VELOCITY readout
;
;      If the new velocity value is different from the current one either
;      increment or decrement the current velocity value toward the new one.
;
;      If the Engines are damaged or destroyed (and hyperwarp is not engaged)
;      then store a random value (less or equal than the current velocity) as
;      the current velocity.
;
;      Display the updated velocity by the VELOCITY readout of the Control Panel
;      Display.
;
; (2)  Update THETA, PHI, and RANGE readouts.
;
;      If the Attack Computer is working then display the x, y, and z
;      coordinates of the currently tracked space object as THETA, PHI, and
;      RANGE readout values of the Control Panel Display.
;
; (3)  Calculate overall energy consumption.
;
;      Add the overall energy consumption per game loop iteration to the energy
;      counter. This value is given in energy subunits (256 energy subunits = 1
;      energy unit displayed by the 4-digit ENERGY readout of the Console Panel
;      Display). It is the total of the following items:
;
;      (1)  8 energy subunits if the Shields are up
;
;      (2)  2 energy subunits if the Attack Computer is on
;
;      (3)  1 energy subunit of the life support system
;
;      (4)  Our starship's Engines energy drain rate (depending on its velocity)
;
;      If there is a carryover of the energy counter then decrement the ENERGY
;      readout of the Control Panel Display by one energy unit after code
;      execution has continued into subroutine DECENERGY ($B86F). 

;*** Accelerate or decelerate our starship *************************************
UPDPANEL        LDX VELOCITYLO          ; Skip if new velocity = current velocity
                CPX NEWVELOCITY         ;
                BEQ SKIP241             ;

                BCC SKIP240             ; In/decrement current velocity toward new velocity
                DEC VELOCITYLO          ;
                BCS SKIP242             ;
SKIP240         INC VELOCITYLO          ;

SKIP241         LDA WARPSTATE           ; Skip if hyperwarp engaged
                BNE SKIP242             ;

                BIT GCSTATENG           ; Skip if Engines are OK
                BPL SKIP242             ;

                LDA NEWVELOCITY         ; Store RND(0..current velocity) to current velocity
                AND RANDOM              ;
                STA VELOCITYLO          ;

SKIP242         LDY #VELOCD1-PANELTXT-1 ; Update digits of VELOCITY readout
                JSR SHOWDIGITS          ;

;*** Display coordinates of tracked space object of Control Panel Display ******
                BIT GCSTATCOM           ; Skip if Attack Computer damaged or destroyed
                BMI SKIP243             ;

                LDA #$31                ; Update THETA readout (x-coordinate)
                LDY #THETAC1-PANELTXT   ;
                JSR SHOWCOORD           ;

                LDA #$62                ; Update PHI readout (y-coordinate)
                LDY #PHIC1-PANELTXT     ;
                JSR SHOWCOORD           ;

                LDA #$00                ; Update RANGE readout (z-coordinate)
                LDY #RANGEC1-PANELTXT   ;
                JSR SHOWCOORD           ;

                LDA RANGEC1+2           ; Hack to clear RANGE digit 3 when in hyperwarp:
                STA RANGEC1+3           ; Copy RANGE digit 2 to digit 3
                CMP #CCS.9+1            ; Skip if digit character > '9' (= 'infinity' char)
                BCS SKIP243             ;

                LDX TRACKDIGIT          ; Get z-coordinate (low byte) of tracked space object
                LDA ZPOSLO,X            ;
                LSR @                  ; ...divide it by 16...
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                TAX                     ;
                LDA MAPTOBCD99,X        ; ...map value of $00..$0F to BCD value 0..9
                STA RANGEC1+3           ; ...and store it to RANGE digit 3

;*** Calculate overall energy consumption **************************************
SKIP243         CLC                     ;
                LDA ENERGYCNT           ; Load energy counter
                ADC DRAINSHIELDS        ; Add energy drain rate of Shields
                ADC DRAINENGINES        ; Add energy drain rate of our starship's Engines
                ADC DRAINATTCOMP        ; Add energy drain rate of Attack Computer
                ADC #$01                ; Add 1 energy subunit of life support system
                CMP ENERGYCNT           ;
                STA ENERGYCNT           ;
                BCS SKIP246             ; Return if no energy counter carryover

                LDX #3                  ; Will decrement third energy digit

;*******************************************************************************
;*                                                                             *
;*                                  DECENERGY                                  *
;*                                                                             *
;*                               Decrease energy                               *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; When not in demo mode, subtract energy from the 4-digit ENERGY readout of the
; Control Panel Display. If crossing a 100-energy-unit boundary during
; subtraction the score is decremented by one unit. If the energy is zero the
; game is over.
;
; INPUT
;
;   X = ENERGY readout digit to be decremented. Used values are:
;     1 -> Subtract 100 units from ENERGY readout
;     2 -> Subtract  10 units from ENERGY readout
;     3 -> Subtract   1 unit  from ENERGY readout

;*** Display ENERGY readout ****************************************************
DECENERGY       BIT ISDEMOMODE          ; Return if in demo mode
                BVS SKIP246             ;

                DEC ENERGYD1,X          ; Decrement energy digit character
                LDA ENERGYD1,X          ;
                CMP #CCS.COL2|CCS.0     ;
                BCS SKIP246             ; Return if digit character >= '0'
                LDA #CCS.COL2|CCS.9     ;
                STA ENERGYD1,X          ; Store digit character '9'

;*** Decrement score when crossing a 100-energy-unit boundary while subtracting 
                CPX #2                  ; Skip if no crossing of 100-energy-unit boundary
                BNE SKIP245             ;

                LDA SCORE               ; SCORE := SCORE - 1
                BNE SKIP244             ;
                DEC SCORE+1             ;
SKIP244         DEC SCORE               ;

SKIP245         DEX                     ;
                BPL DECENERGY           ; Next digit

;*** Energy is zero, game over *************************************************
                LDX #CCS.SPC            ; Clear 4-digit ENERGY readout
                TXA                     ;
                LDY #3                  ;
LOOP079         STA ENERGYD1,Y          ;
                DEY                     ;
                BPL LOOP079             ;

                JSR SETVIEW             ; Set Front view

                LDY #$31                ; Set title phrase "MISSION ABORTED ZERO ENERGY"
                LDX #$04                ; Set mission bonus offset
                JSR GAMEOVER            ; Game over

SKIP246         RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                                  SHOWCOORD                                  *
;*                                                                             *
;*  Display a position vector component (coordinate) in Control Panel Display  *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Displays a position vector component (coordinate) by one of the THETA, PHI, or
; RANGE readouts of the Control Panel Display.
;
; Write the sign to the Control Panel Display, then map the high byte of the
; respective coordinate (x -> THETA, y -> PHI, z -> RANGE) to a BCD-value in
; 00..99. Code execution continues into subroutine SHOWDIGITS ($B8CD) where the
; digits are actually stored in the Control Panel Display.
;
; NOTE: If the digits of either the THETA or PHI readout are to be displayed and
; the x or y position vector component (high byte) is $FF then tweak the value
; to $FE. This avoids accessing table MAPTOBCD99 ($0EE9) with an index of $FF
; that would return the special value $EA. This value represents the CCS.INF
; ($0E) and CCS.SPC ($0A) characters (see comments in subroutine INITIALIZE
; ($B3BA)) that are displayed by the RANGE readout only.
;
; INPUT
;
;   A = Position vector component (coordinate) offset. Used values are: 
;     $00 -> z-coordinate
;     $31 -> x-coordinate
;     $62 -> y-coordinate
;
;   Y = Offset into the Control Panel Display memory map. Used values are:
;     $17 -> First character (sign) of THETA readout (x-coordinate of tracked
;            space object)
;     $1D -> First character (sign) of PHI readout   (y-coordinate of tracked
;            space object)
;     $23 -> First character (sign) of RANGE readout (z-coordinate of tracked
;            space object)

L.SIGNCHAR      = $6A                   ; Saves sign character

SHOWCOORD       CLC                     ; Add index of tracked space object...
                ADC TRACKDIGIT          ; ...to position vector component offset
                TAX                     ; Save position vector component index

;*** Display sign in Control Panel Display *************************************
                LDA #CCS.PLUS           ; Save '+' (CCS.PLUS) to sign character
                STA L.SIGNCHAR          ;

                LDA ZPOSSIGN,X          ; Prep sign of coordinate
                LSR @                  ;
                LDA ZPOSHI,X            ; Prep coordinate (high byte)
                BCS SKIP247             ; Skip if sign is positive

                EOR #$FF                ; Invert coordinate (high byte)
                DEC L.SIGNCHAR          ; Change saved sign character to '-' (CCS.MINUS)

SKIP247         TAX                     ; Save coordinate (high byte)
                LDA L.SIGNCHAR          ; Store sign character in Control Panel Display
                STA PANELTXT,Y          ;

;*** Get RANGE digits **********************************************************
                TYA                     ; Skip if RANGE is to be displayed
                AND #$10                ;
                BEQ SHOWDIGITS          ;

                CPX #$FF                ; If coordinate (high byte) = $FF decrement value
                BNE SHOWDIGITS          ; This avoids output of CCS.INFINITY in...
                DEX                     ; ...THETA and PHI readouts

;*******************************************************************************
;*                                                                             *
;*                                 SHOWDIGITS                                  *
;*                                                                             *
;*          Display a value by a readout of the Control Panel Display          *
;*                                                                             *
;*******************************************************************************

; DESCRIPTION
;
; Converts a binary value in $00..$FF to a BCD-value in 0..99 and displays it as
; a 2-digit number in the Control Panel Display.
;
; INPUT
;
;   X = Value to be displayed as a 2-digit BCD-value. Used values are: $00..$FF.
;
;   Y = Offset into the Control Panel Display memory map relative to the first
;       character of the Control Panel Display (the 'V' of the VELOCITY
;       readout). Used values are: 
;     $01 -> Character before first digit of VELOCITY readout
;     $17 -> First character (sign) of THETA readout (x-coordinate of tracked
;            space object)
;     $1D -> First character (sign) of PHI readout   (y-coordinate of tracked
;            space object)
;     $23 -> First character (sign) of RANGE readout (z-coordinate of tracked
;            space object)

SHOWDIGITS      LDA MAPTOBCD99,X        ; Map binary value to BCD-value
                TAX                     ;
                AND #$0F                ;
                STA PANELTXT+2,Y        ; Store 'ones' digit in Control Panel Display
                TXA                     ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                LSR @                  ;
                STA PANELTXT+1,Y        ; Store 'tens' digit in Control Panel Display
                RTS                     ; Return

;*******************************************************************************
;*                                                                             *
;*                G A M E   D A T A   ( P A R T   2   O F   2 )                *
;*                                                                             *
;*******************************************************************************

;*** Color register offsets of PLAYER0..4 **************************************
PLCOLOROFFTAB   .BYTE 0                               ; PLAYER0
                .BYTE 1                               ; PLAYER1
                .BYTE 2                               ; PLAYER2
                .BYTE 3                               ; PLAYER3
                .BYTE 7                               ; PLAYER4

;*** Shape table 1 (PLAYER2..4) ************************************************
PLSHAP1TAB      .BYTE $00                             ; ........
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $76                             ; .###.##.
                .BYTE $F7                             ; ####.###
                .BYTE $DF                             ; ##.#####
                .BYTE $DF                             ; ##.#####
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $F7                             ; ####.###
                .BYTE $76                             ; .###.##.
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $7C                             ; .#####..
                .BYTE $FE                             ; #######.
                .BYTE $DE                             ; ##.####.
                .BYTE $DA                             ; ##.##.#.
                .BYTE $FA                             ; #####.#.
                .BYTE $EE                             ; ###.###.
                .BYTE $EE                             ; ###.###.
                .BYTE $7C                             ; .#####..
                .BYTE $7C                             ; .#####..
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $6E                             ; .##.###.
                .BYTE $7A                             ; .####.#.
                .BYTE $7E                             ; .######.
                .BYTE $76                             ; .###.##.
                .BYTE $7E                             ; .######.
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $74                             ; .###.#..
                .BYTE $7C                             ; .#####..
                .BYTE $6C                             ; .##.##..
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $10                             ; ...#....
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $2C                             ; ..#.##..
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $08                             ; ....#...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $28                             ; ..#.#...
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $24                             ; ..#..#..
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $5A                             ; .#.##.#.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $1C                             ; ...###..
                .BYTE $1C                             ; ...###..
                .BYTE $14                             ; ...#.#..
                .BYTE $3E                             ; ..#####.
                .BYTE $3E                             ; ..#####.
                .BYTE $3E                             ; ..#####.
                .BYTE $2A                             ; ..#.#.#.
                .BYTE $7F                             ; .#######
                .BYTE $7F                             ; .#######
                .BYTE $22                             ; ..#...#.
                .BYTE $22                             ; ..#...#.
                .BYTE $22                             ; ..#...#.
                .BYTE $22                             ; ..#...#.
                .BYTE $22                             ; ..#...#.
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $24                             ; ..#..#..
                .BYTE $24                             ; ..#..#..
                .BYTE $24                             ; ..#..#..
                .BYTE $24                             ; ..#..#..
                .BYTE $10                             ; ...#....
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $18                             ; ...##...
                .BYTE $7E                             ; .######.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $E7                             ; ###..###
                .BYTE $E7                             ; ###..###
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $00                             ; ........
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $E7                             ; ###..###
                .BYTE $66                             ; .##..##.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $00                             ; ........
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $E7                             ; ###..###
                .BYTE $66                             ; .##..##.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $E7                             ; ###..###
                .BYTE $66                             ; .##..##.
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $7E                             ; .######.
                .BYTE $3C                             ; ..####..
                .BYTE $00                             ; ........
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $FF                             ; ########
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $EE                             ; ###.###.
                .BYTE $00                             ; ........
                .BYTE $00                             ; ........
                .BYTE $EE                             ; ###.###.
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...
                .BYTE $28                             ; ..#.#...

;*** Shape table 2 (PLAYER0..1) ************************************************
PLSHAP2TAB      .BYTE $00                             ; ........
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $BD                             ; #.####.#
                .BYTE $FF                             ; ########
                .BYTE $FF                             ; ########
                .BYTE $BD                             ; #.####.#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $82                             ; #.....#.
                .BYTE $82                             ; #.....#.
                .BYTE $BA                             ; #.###.#.
                .BYTE $FE                             ; #######.
                .BYTE $FE                             ; #######.
                .BYTE $BA                             ; #.###.#.
                .BYTE $82                             ; #.....#.
                .BYTE $82                             ; #.....#.
                .BYTE $42                             ; .#....#.
                .BYTE $5A                             ; .#.##.#.
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $5A                             ; .#.##.#.
                .BYTE $42                             ; .#....#.
                .BYTE $44                             ; .#...#..
                .BYTE $54                             ; .#.#.#..
                .BYTE $7C                             ; .#####..
                .BYTE $7C                             ; .#####..
                .BYTE $54                             ; .#.#.#..
                .BYTE $44                             ; .#...#..
                .BYTE $24                             ; ..#..#..
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $24                             ; ..#..#..
                .BYTE $28                             ; ..#.#...
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $28                             ; ..#.#...
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $10                             ; ...#....
                .BYTE $E0                             ; ###.....
                .BYTE $F8                             ; #####...
                .BYTE $F8                             ; #####...
                .BYTE $FE                             ; #######.
                .BYTE $57                             ; .#.#.###
                .BYTE $FE                             ; #######.
                .BYTE $F8                             ; #####...
                .BYTE $F8                             ; #####...
                .BYTE $C0                             ; ##......
                .BYTE $C0                             ; ##......
                .BYTE $F0                             ; ####....
                .BYTE $C0                             ; ##......
                .BYTE $F0                             ; ####....
                .BYTE $F0                             ; ####....
                .BYTE $FC                             ; ######..
                .BYTE $BE                             ; #.#####.
                .BYTE $FC                             ; ######..
                .BYTE $F0                             ; ####....
                .BYTE $80                             ; #.......
                .BYTE $80                             ; #.......
                .BYTE $C0                             ; ##......
                .BYTE $C0                             ; ##......
                .BYTE $F0                             ; ####....
                .BYTE $BC                             ; #.####..
                .BYTE $F0                             ; ####....
                .BYTE $C0                             ; ##......
                .BYTE $07                             ; .....###
                .BYTE $1F                             ; ...#####
                .BYTE $1F                             ; ...#####
                .BYTE $7F                             ; .#######
                .BYTE $EA                             ; ###.#.#.
                .BYTE $7F                             ; .#######
                .BYTE $1F                             ; ...#####
                .BYTE $1F                             ; ...#####
                .BYTE $03                             ; ......##
                .BYTE $03                             ; ......##
                .BYTE $0F                             ; ....####
                .BYTE $03                             ; ......##
                .BYTE $0F                             ; ....####
                .BYTE $0F                             ; ....####
                .BYTE $3F                             ; ..######
                .BYTE $7D                             ; .#####.#
                .BYTE $3F                             ; ..######
                .BYTE $0F                             ; ....####
                .BYTE $01                             ; .......#
                .BYTE $01                             ; .......#
                .BYTE $03                             ; ......##
                .BYTE $03                             ; ......##
                .BYTE $0F                             ; ....####
                .BYTE $3D                             ; ..####.#
                .BYTE $0F                             ; ....####
                .BYTE $03                             ; ......##
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $7E                             ; .######.
                .BYTE $DB                             ; ##.##.##
                .BYTE $C3                             ; ##....##
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $81                             ; #......#
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $7C                             ; .#####..
                .BYTE $D6                             ; ##.#.##.
                .BYTE $C6                             ; ##...##.
                .BYTE $82                             ; #.....#.
                .BYTE $82                             ; #.....#.
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $3C                             ; ..####..
                .BYTE $66                             ; .##..##.
                .BYTE $66                             ; .##..##.
                .BYTE $42                             ; .#....#.
                .BYTE $42                             ; .#....#.
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $6C                             ; .##.##..
                .BYTE $44                             ; .#...#..
                .BYTE $44                             ; .#...#..
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $24                             ; ..#..#..
                .BYTE $24                             ; ..#..#..
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $28                             ; ..#.#...
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $FF                             ; ########
                .BYTE $18                             ; ...##...
                .BYTE $18                             ; ...##...
                .BYTE $FF                             ; ########
                .BYTE $7E                             ; .######.
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $FE                             ; #######.
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $FE                             ; #######.
                .BYTE $7C                             ; .#####..
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $7E                             ; .######.
                .BYTE $18                             ; ...##...
                .BYTE $7E                             ; .######.
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $7C                             ; .#####..
                .BYTE $10                             ; ...#....
                .BYTE $7C                             ; .#####..
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $3C                             ; ..####..
                .BYTE $18                             ; ...##...
                .BYTE $10                             ; ...#....
                .BYTE $38                             ; ..###...
                .BYTE $38                             ; ..###...
                .BYTE $10                             ; ...#....

;*** Display List fragments ****************************************************
;
; LOCAL VARIABLES
PFMEM.C0R0      = PFMEM+0*40                          ; Start address of PLAYFIELD row 0
PFMEM.C0R5      = PFMEM+5*40                          ; Start address of PLAYFIELD row 5
PFMEM.C0R17     = PFMEM+17*40                         ; Start address of PLAYFIELD row 17

;*** Display List fragment for Control Panel Display (bottom text window) ******
DLSTFRAG        .BYTE $8D                             ; GR7 + DLI
                .BYTE $00                             ; BLK1
                .BYTE $46,<PANELTXT,>PANELTXT         ; GR1 @ PANELTXT
                .BYTE $20                             ; BLK3
                .BYTE $06                             ; GR1
                .BYTE $00                             ; BLK1

;*** Display List fragment for Galactic Chart view *****************************
DLSTFRAGGC      .BYTE $01,<DLSTGC,>DLSTGC             ; JMP @ DLSTGC

;*** Display List fragment for Long-Range Scan view ****************************
DLSTFRAGLRS     .BYTE $00                             ; BLK1
                .BYTE $00                             ; BLK1
                .BYTE $46,<LRSHEADER,>LRSHEADER       ; GR1 @ LRSHEADER
                .BYTE $4D,<PFMEM.C0R5,>PFMEM.C0R5     ; GR7 @ PFMEM.C0R5

;*** Display List fragment for Aft view ****************************************
DLSTFRAGAFT     .BYTE $00                             ; BLK1
                .BYTE $00                             ; BLK1
                .BYTE $46,<AFTHEADER,>AFTHEADER       ; GR1 @ AFTHEADER
                .BYTE $4D,<PFMEM.C0R5,>PFMEM.C0R5     ; GR7 @ PFMEM.C0R5

;*** Display List fragment for Front view and Title text line ******************
DLSTFRAGFRONT   .BYTE $4D,<PFMEM.C0R0,>PFMEM.C0R0     ; GR7 @ PFMEM.C0R0
                .BYTE $0D                             ; GR7
                .BYTE $0D                             ; GR7
                .BYTE $0D                             ; GR7
                .BYTE $0D                             ; GR7
                .BYTE $0D                             ; GR7
                .BYTE $30                             ; BLK4
                .BYTE $46,<TITLETXT,>TITLETXT         ; GR1 @ TITLETXT
                .BYTE $4D,<PFMEM.C0R17,>PFMEM.C0R17   ; GR7 @ PFMEM.C0R17

;*** Display List fragment offsets relative to DLSTFRAG ************************
DLSTFRAGOFFTAB  .BYTE DLSTFRAGFRONT-DLSTFRAG          ; Front view
                .BYTE DLSTFRAGAFT-DLSTFRAG            ; Aft view
                .BYTE DLSTFRAGLRS-DLSTFRAG            ; Long-Range Scan view
                .BYTE DLSTFRAGGC-DLSTFRAG             ; Galactic Chart view

;*** 1-byte bit patterns for 4 pixels of same color for PLAYFIELD space objects 
FOURCOLORPIXEL  .BYTE $FF                             ; COLOR3
                .BYTE $FF                             ; COLOR3
                .BYTE $FF                             ; COLOR3
                .BYTE $FF                             ; COLOR3
                .BYTE $AA                             ; COLOR2
                .BYTE $FF                             ; COLOR3
                .BYTE $AA                             ; COLOR2
                .BYTE $FF                             ; COLOR3
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $FF                             ; COLOR3
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $AA                             ; COLOR2
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1
                .BYTE $AA                             ; COLOR2
                .BYTE $55                             ; COLOR1
                .BYTE $AA                             ; COLOR2
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1
                .BYTE $AA                             ; COLOR2
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1
                .BYTE $55                             ; COLOR1

;*** Masks to filter 1 pixel (2 bits) from 4 pixels (1 byte of PLAYFIELD memory)
PIXELMASKTAB    .BYTE $C0                             ; ##......
                .BYTE $30                             ; ..##....
                .BYTE $0C                             ; ....##..
                .BYTE $03                             ; ......##

;*** Velocity table ************************************************************
VELOCITYTAB     .BYTE 0                               ; Speed 0 =   0 <KM/H>
                .BYTE 1                               ; Speed 1 =   1 <KM/H>
                .BYTE 2                               ; Speed 2 =   2 <KM/H>
                .BYTE 4                               ; Speed 3 =   4 <KM/H>
                .BYTE 8                               ; Speed 4 =   8 <KM/H>
                .BYTE 16                              ; Speed 5 =  16 <KM/H>
                .BYTE 32                              ; Speed 6 =  32 <KM/H>
                .BYTE 64                              ; Speed 7 =  64 <KM/H>
                .BYTE 96                              ; Speed 8 =  96 <KM/H>
                .BYTE 112                             ; Speed 9 = 112 <KM/H>

;*** Keyboard code lookup table ************************************************
KEYTAB          .BYTE $F2                             ; '0'   - Speed 0
                .BYTE $DF                             ; '1'   - Speed 1
                .BYTE $DE                             ; '2'   - Speed 2
                .BYTE $DA                             ; '3'   - Speed 3
                .BYTE $D8                             ; '4'   - Speed 4
                .BYTE $DD                             ; '5'   - Speed 5
                .BYTE $DB                             ; '6'   - Speed 6
                .BYTE $F3                             ; '7'   - Speed 7
                .BYTE $F5                             ; '8'   - Speed 8
                .BYTE $F0                             ; '9'   - Speed 9
                .BYTE $F8                             ; 'F'   - Front view
                .BYTE $FF                             ; 'A'   - Aft view
                .BYTE $C0                             ; 'L'   - Long-Range Scan view
                .BYTE $FD                             ; 'G'   - Galactic Chart view
                .BYTE $ED                             ; 'T'   - Tracking on/off
                .BYTE $FE                             ; 'S'   - Shields on/off
                .BYTE $D2                             ; 'C'   - Attack Computer on/off
                .BYTE $F9                             ; 'H'   - Hyperwarp
                .BYTE $E5                             ; 'M'   - Manual Target Selector
                .BYTE $CA                             ; 'P'   - Pause
                .BYTE $E7                             ; 'INV' - Abort Mission

;*** Engines energy drain rates per game loop iteration in energy subunits *****
DRAINRATETAB    .BYTE 0                               ;
                .BYTE 4                               ;
                .BYTE 6                               ;
                .BYTE 8                               ;
                .BYTE 10                              ;
                .BYTE 12                              ;
                .BYTE 14                              ;
                .BYTE 30                              ;
                .BYTE 45                              ;
                .BYTE 60                              ;

;*** Hyperwarp energy depending on distance ************************************
WARPENERGYTAB   .BYTE 10                              ; =  100 energy units
                .BYTE 13                              ; =  130 energy units
                .BYTE 16                              ; =  160 energy units
                .BYTE 20                              ; =  200 energy units
                .BYTE 23                              ; =  230 energy units
                .BYTE 50                              ; =  500 energy units
                .BYTE 70                              ; =  700 energy units
                .BYTE 80                              ; =  800 energy units
                .BYTE 90                              ; =  900 energy units
                .BYTE 120                             ; = 1200 energy units
                .BYTE 125                             ; = 1250 energy units
                .BYTE 130                             ; = 1300 energy units
                .BYTE 135                             ; = 1350 energy units
                .BYTE 140                             ; = 1400 energy units
                .BYTE 155                             ; = 1550 energy units
                .BYTE 170                             ; = 1700 energy units
                .BYTE 184                             ; = 1840 energy units
                .BYTE 200                             ; = 2000 energy units
                .BYTE 208                             ; = 2080 energy units
                .BYTE 216                             ; = 2160 energy units
                .BYTE 223                             ; = 2230 energy units
                .BYTE 232                             ; = 2320 energy units
                .BYTE 241                             ; = 2410 energy units
                .BYTE 250                             ; = 2500 energy units

;*** Joystick increments *******************************************************
STICKINCTAB     .BYTE 0                               ; Centered
                .BYTE 1                               ; Right or up
                .BYTE -1                              ; Left or down
                .BYTE 0                               ; Centered

;*** 3-byte elements to draw cross hairs and Attack Computer Display ***********
;   Byte 1 : Pixel column number of line start
;   Byte 2 : Pixel row number of line start
;   Byte 3 : B7 = 0 -> Draw line to the right
;            B7 = 1 -> Draw line down
;            B6..0  -> Length of line in pixels. Possible values are: 0..127.
;
;                   #
;                   #                              4
;                   #                      ##############################
;                   #1                     #             #              #
;                   #                      #             #11            #
;                   #                      #             #              #
;                   #                      #5            #    8         #6
;                                          #      ###############       #
;                                          #      #             #       #
;         15                  16           #   7  #             #   10  #
; ###############       ###############    ########             #########
;                                          #      #12           #       #
;                                          #      #             #13     #
;                                          #      ###############       #
;                   #                      #         9   #              #
;                   #                      #             #              #
;                   #                      #             #14            #
;                   #                      #       3     #              #
;                   #2                     ##############################
;                   #
;                   #
;
;         Front/Aft Cross Hairs                Attack Computer Display
;
; LOCAL VARIABLES
DOWN            = $80
RIGHT           = $00

DRAWLINESTAB    .BYTE 80,40,DOWN|7                    ; Line 1
                .BYTE 80,54,DOWN|7                    ; Line 2

                .BYTE 119,70,RIGHT|30                 ; Line 3
                .BYTE 119,86,RIGHT|30                 ; Line 4
                .BYTE 119,70,DOWN|17                  ; Line 5
                .BYTE 148,70,DOWN|17                  ; Line 6
                .BYTE 120,78,RIGHT|6                  ; Line 7
                .BYTE 126,75,RIGHT|15                 ; Line 8
                .BYTE 126,81,RIGHT|15                 ; Line 9
                .BYTE 141,78,RIGHT|7                  ; Line 10
                .BYTE 133,71,DOWN|4                   ; Line 11
                .BYTE 126,76,DOWN|5                   ; Line 12
                .BYTE 140,76,DOWN|5                   ; Line 13
                .BYTE 133,82,DOWN|4                   ; Line 14

                .BYTE 62,50,RIGHT|15                  ; Line 15
                .BYTE 84,50,RIGHT|15                  ; Line 16
                .BYTE $FE                             ; End marker

;*** 3-byte elements to draw our starship's shape in Long-Range Scan view ******
;
;   Line  17 18 19 20 21
;               ##
;               ##
;            ## ## ##
;         ## ## ## ## ##
;         ##    ##    ##

                .BYTE 78,53,DOWN|2                    ; Line 17
                .BYTE 79,52,DOWN|2                    ; Line 18
                .BYTE 80,50,DOWN|5                    ; Line 19
                .BYTE 81,52,DOWN|2                    ; Line 20
                .BYTE 82,53,DOWN|2                    ; Line 21
                .BYTE $FE                             ; End marker

;*** Initial x and y coordinates of a star during hyperwarp ********************
; The following two tables are used to determine the initial x and y coordinates
; (high byte) of a star during hyperwarp. An index in 0..3 picks both the x and
; y coordinate, thus 4 pairs of coordinates are possible:
;
; Y           +-------+----------------------------+----------------------------+
; ^           | Index |        x-coordinate        |        y-coordinate        |
; |           +-------+----------------------------+----------------------------+
; |.32.       |   0   | +1024..+1279 (+$04**) <KM> |  +512..+767  (+$02**) <KM> |
; |...1       |   1   | +1024..+1279 (+$04**) <KM> |  +768..+1023 (+$03**) <KM> |
; |...0       |   2   |  +768..+1023 (+$03**) <KM> | +1024..+1279 (+$04**) <KM> |
; |....       |   3   |  +512..+767  (+$02**) <KM> | +1024..+1279 (+$04**) <KM> |
; 0----->X    +-------+----------------------------+----------------------------+

;*** Initial x-coordinate (high byte) of star in hyperwarp *********************
WARPSTARXTAB    .BYTE $04                             ; +1024..+1279 (+$04**) <KM>
                .BYTE $04                             ; +1024..+1279 (+$04**) <KM>
                .BYTE $03                             ;  +768..+1023 (+$03**) <KM>
                .BYTE $02                             ;  +512..+767  (+$02**) <KM>

;*** Initial y-coordinate (high byte) of star in hyperwarp *********************
WARPSTARYTAB    .BYTE $02                             ;  +512..+767  (+$02**) <KM>
                .BYTE $03                             ;  +768..+1023 (+$03**) <KM>
                .BYTE $04                             ; +1024..+1279 (+$04**) <KM>
                .BYTE $04                             ; +1024..+1279 (+$04**) <KM>

;*** Text of Control Panel Display (encoded in custom character set) ***********
; Row 1: "V:00 K:00 E:9999 T:0"
; Row 2: " O:-00 O:-00 R:-000 "

PANELTXTTAB     .BYTE CCS.V
                .BYTE CCS.COLON
                .BYTE CCS.0
                .BYTE CCS.0
                .BYTE CCS.SPC
                .BYTE CCS.COL1|CCS.K
                .BYTE CCS.COL1|CCS.COLON
                .BYTE CCS.COL1|CCS.0
                .BYTE CCS.COL1|CCS.0
                .BYTE CCS.SPC
                .BYTE CCS.COL2|CCS.E
                .BYTE CCS.COL2|CCS.COLON
                .BYTE CCS.COL2|CCS.9
                .BYTE CCS.COL2|CCS.9
                .BYTE CCS.COL2|CCS.9
                .BYTE CCS.COL2|CCS.9
                .BYTE CCS.SPC
                .BYTE CCS.T
                .BYTE CCS.COLON
                .BYTE CCS.0

                .BYTE CCS.SPC
                .BYTE CCS.THETA
                .BYTE CCS.COLON
                .BYTE CCS.MINUS
                .BYTE CCS.0
                .BYTE CCS.0
                .BYTE CCS.SPC
                .BYTE CCS.COL1|CCS.PHI
                .BYTE CCS.COL1|CCS.COLON
                .BYTE CCS.MINUS
                .BYTE CCS.0
                .BYTE CCS.0
                .BYTE CCS.SPC
                .BYTE CCS.COL2|CCS.R
                .BYTE CCS.COL2|CCS.COLON
                .BYTE CCS.MINUS
                .BYTE CCS.0
                .BYTE CCS.0
                .BYTE CCS.0
                .BYTE CCS.SPC

;*** Text of Galactic Chart Panel Display **************************************
; Row 1: "WARP ENERGY:   0    "
; Row 2: "TARGETS:  DC:PESCLR "
; Row 3: "STAR DATE:00.00     "

                .BYTE ROM.W
                .BYTE ROM.A
                .BYTE ROM.R
                .BYTE ROM.P
                .BYTE ROM.SPC
                .BYTE ROM.E
                .BYTE ROM.N
                .BYTE ROM.E
                .BYTE ROM.R
                .BYTE ROM.G
                .BYTE ROM.Y
                .BYTE ROM.COLON
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.0
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC

                .BYTE CCS.COL2|ROM.T
                .BYTE CCS.COL2|ROM.A
                .BYTE CCS.COL2|ROM.R
                .BYTE CCS.COL2|ROM.G
                .BYTE CCS.COL2|ROM.E
                .BYTE CCS.COL2|ROM.T
                .BYTE CCS.COL2|ROM.S
                .BYTE CCS.COL2|ROM.COLON
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.D
                .BYTE ROM.C
                .BYTE ROM.COLON
                .BYTE ROM.P
                .BYTE ROM.E
                .BYTE ROM.S
                .BYTE ROM.C
                .BYTE ROM.L
                .BYTE ROM.R
                .BYTE ROM.SPC

                .BYTE CCS.COL3|ROM.S
                .BYTE CCS.COL3|ROM.T
                .BYTE CCS.COL3|ROM.A
                .BYTE CCS.COL3|ROM.R
                .BYTE ROM.SPC
                .BYTE CCS.COL3|ROM.D
                .BYTE CCS.COL3|ROM.A
                .BYTE CCS.COL3|ROM.T
                .BYTE CCS.COL3|ROM.E
                .BYTE CCS.COL3|ROM.COLON
                .BYTE CCS.COL3|ROM.0
                .BYTE CCS.COL3|ROM.0
                .BYTE CCS.COL3|ROM.DOT
                .BYTE CCS.COL3|ROM.0
                .BYTE CCS.COL3|ROM.0
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC
                .BYTE ROM.SPC

;*** Galactic Chart sector type table ******************************************
SECTORTYPETAB   .BYTE $CF                             ; Starbase
                .BYTE $04                             ; 4 Zylon ships
                .BYTE $03                             ; 3 Zylon ships
                .BYTE $02                             ; 1 or 2 Zylon ships

;*** Phrase table **************************************************************
; Phrases consist of phrase tokens. These are bytes that encode words, segments
; (multiple words that fit into a single line of text), and how they are displayed.
;
; LOCAL VARIABLES
EOP             = $40                                 ; End of phrase
EOS             = $80                                 ; End of segment
LONG            = $C0                                 ; Display title phrase for a long time

                                                      ; Title Phrase Offset, Text
PHRASETAB       .BYTE $00                             ; (unused)
                .BYTE $05,$06,$02|EOP                 ; $01  "ATTACK COMPUTER ON"
                .BYTE $05,$06,$03|EOP                 ; $04  "ATTACK COMPUTER OFF"
                .BYTE $04,$02|EOP                     ; $07  "SHIELDS ON"
                .BYTE $04,$03|EOP                     ; $09  "SHIELDS OFF"
                .BYTE $06,$07,$02|EOP                 ; $0B  "COMPUTER TRACKING ON"
                .BYTE $07,$03|EOP                     ; $0E  "TRACKING OFF"
                .BYTE $08|EOP                         ; $10  "WHATS WRONG?"
                .BYTE $09,$0A|EOP                     ; $11  "HYPERWARP ENGAGED"
                .BYTE $0B,$0D|LONG                    ; $13  "STARBASE SURROUNDED"
                .BYTE $0B,$0C|LONG                    ; $15  "STARBASE DESTROYED"
                .BYTE $09,$0E|EOP                     ; $17  "HYPERWARP ABORTED"
                .BYTE $09,$0F|EOP                     ; $19  "HYPERWARP COMPLETE"
                .BYTE $10|LONG                        ; $1B  "HYPERSPACE"
                .BYTE $11,$12|EOS                     ; $1C  "ORBIT ESTABLISHED"
                .BYTE $16|EOP                         ; $1E  "STANDBY"
                .BYTE $13,$0E|EOP                     ; $1F  "DOCKING ABORTED"
                .BYTE $15,$0F|EOP                     ; $21  "TRANSFER COMPLETE"
                .BYTE $38|EOS                         ; $23  " "
                .BYTE $17|EOS                         ; $24  "STAR FLEET TO"
                .BYTE $19|EOS                         ; $25  "ALL UNITS"
                .BYTE $18|EOS                         ; $26  "STAR CRUISER 7"
                .BYTE $0C|EOS                         ; $27  "DESTROYED"
                .BYTE $1D|EOS                         ; $28  "BY ZYLON FIRE"
                .BYTE $1E,$1F|EOS                     ; $29  "POSTHUMOUS RANK IS:"
                .BYTE $FD                             ; $2B  "<PLACEHOLDER FOR RANK>"
                .BYTE $25,$FC                         ; $2C  "CLASS <PLACEHOLDER FOR CLASS>"
                .BYTE $38|EOP                         ; $2E  " "
                .BYTE $1B|EOS                         ; $2F  "STAR RAIDERS"
                .BYTE $20|EOP                         ; $30  "COPYRIGHT ATARI 1979"
                .BYTE $38|EOS                         ; $31  " "
                .BYTE $17|EOS                         ; $32  "STAR FLEET TO"
                .BYTE $18|EOS                         ; $33  "STAR CRUISER 7"
                .BYTE $1A,$0E|EOS                     ; $34  "MISSION ABORTED"
                .BYTE $1C,$14|EOS                     ; $36  "ZERO ENERGY"
                .BYTE $24,$1F|EOS                     ; $38  "NEW RANK IS"
                .BYTE $FD                             ; $3A  "<PLACEHOLDER FOR RANK>"
                .BYTE $25,$FC                         ; $3B  "CLASS <PLACEHOLDER FOR CLASS>"
                .BYTE $27|EOS                         ; $3D  "REPORT TO BASE"
                .BYTE $28|EOP                         ; $3E  "FOR TRAINING"
                .BYTE $38|EOS                         ; $3F  " "
                .BYTE $17|EOS                         ; $40  "STAR FLEET TO"
                .BYTE $18|EOS                         ; $41  "STAR CRUISER 7"
                .BYTE $1A,$0F|EOS                     ; $42  "MISSION COMPLETE"
                .BYTE $24,$1F|EOS                     ; $44  "NEW RANK IS:"
                .BYTE $FD                             ; $46  "<PLACEHOLDER FOR RANK>"
                .BYTE $25,$FC                         ; $47  "CLASS <PLACEHOLDER FOR CLASS>"
                .BYTE $26|EOP                         ; $49  "CONGRATULATIONS"
                .BYTE $2C,$1A|EOP                     ; $4A  "NOVICE MISSION"
                .BYTE $2E,$1A|EOP                     ; $4C  "PILOT MISSION"
                .BYTE $31,$1A|EOP                     ; $4E  "WARRIOR MISSION"
                .BYTE $33,$1A|EOP                     ; $50  "COMMANDER MISSION"
                .BYTE $38|EOS                         ; $52  " "
                .BYTE $34,$36|EOP                     ; $53  "DAMAGE CONTROL"
                .BYTE $37,$35|EOS                     ; $55  "PHOTONS DAMAGED"
                .BYTE $38|EOP                         ; $57  " "
                .BYTE $37,$0C|EOS                     ; $58  "PHOTONS DESTROYED"
                .BYTE $38|EOP                         ; $5A  " "
                .BYTE $23,$35|EOS                     ; $5B  "ENGINES DAMAGED"
                .BYTE $38|EOP                         ; $5D  " "
                .BYTE $23,$0C|EOS                     ; $5E  "ENGINES DESTROYED"
                .BYTE $38|EOP                         ; $60  " "
                .BYTE $04,$35|EOS                     ; $61  "SHIELDS DAMAGED"
                .BYTE $38|EOP                         ; $63  " "
                .BYTE $04,$0C|EOS                     ; $64  "SHIELDS DESTROYED"
                .BYTE $38|EOP                         ; $66  " "
                .BYTE $06,$35|EOS                     ; $67  "COMPUTER DAMAGED"
                .BYTE $38|EOP                         ; $69  " "
                .BYTE $06,$0C|EOS                     ; $6A  "COMPUTER DESTROYED"
                .BYTE $38|EOP                         ; $6C  " "
                .BYTE $22|EOS                         ; $6D  "SECTOR SCAN"
                .BYTE $35|EOP                         ; $6E  "DAMAGED"
                .BYTE $22|EOS                         ; $6F  "SECTOR SCAN"
                .BYTE $0C|EOP                         ; $70  "DESTROYED"
                .BYTE $21|EOS                         ; $71  "SUB-SPACE RADIO"
                .BYTE $35|EOP                         ; $72  "DAMAGED"
                .BYTE $21|EOS                         ; $73  "SUB-SPACE RADIO"
                .BYTE $0C|EOP                         ; $74  "DESTROYED"
                .BYTE $01|LONG                        ; $75  "RED ALERT"
                .BYTE $38|EOS                         ; $76  " "
                .BYTE $17|EOS                         ; $77  "STAR FLEET TO"
                .BYTE $18|EOS                         ; $78  "STAR CRUISER 7"
                .BYTE $1A,$0E|EOS                     ; $79  "MISSION ABORTED"
                .BYTE $24,$1F|EOS                     ; $7B  "NEW RANK IS:"
                .BYTE $FD                             ; $7D  "<PLACEHOLDER FOR RANK>"
                .BYTE $25,$FC                         ; $7E  "CLASS <PLACEHOLDER FOR CLASS>"
                .BYTE $26|EOP                         ; $80  "CONGRATULATIONS"

;*** Word table ****************************************************************
; Bit B7 of the first byte of a word is the end-of-word marker of the preceding
; word
;
; LOCAL VARIABLES
EOW             = $80                                 ; End of word

WORDTAB         .BYTE EOW|$20,'    RED ALERT'         ; Word $01
                .BYTE EOW|'O','N'                     ; Word $02
                .BYTE EOW|'O','FF'                    ; Word $03
                .BYTE EOW|'S','HIELDS'                ; Word $04
                .BYTE EOW|'A','TTACK'                 ; Word $05
                .BYTE EOW|'C','OMPUTER'               ; Word $06
                .BYTE EOW|'T','RACKING'               ; Word $07
                .BYTE EOW|'W','HATS WRONG?'           ; Word $08
                .BYTE EOW|'H','YPERWARP'              ; Word $09
                .BYTE EOW|'E','NGAGED'                ; Word $0A
                .BYTE EOW|'S','TARBASE'               ; Word $0B
                .BYTE EOW|'D','ESTROYED'              ; Word $0C
                .BYTE EOW|'S','URROUNDED'             ; Word $0D
                .BYTE EOW|'A','BORTED'                ; Word $0E
                .BYTE EOW|'C','OMPLETE'               ; Word $0F
                .BYTE EOW|'H','YPERSPACE'             ; Word $10
                .BYTE EOW|'O','RBIT'                  ; Word $11
                .BYTE EOW|'E','STABLISHED'            ; Word $12
                .BYTE EOW|'D','OCKING'                ; Word $13
                .BYTE EOW|'E','NERGY'                 ; Word $14
                .BYTE EOW|'T','RANSFER'               ; Word $15
                .BYTE EOW|'S','TANDBY'                ; Word $16
                .BYTE EOW|'S','TAR FLEET TO'          ; Word $17
                .BYTE EOW|'S','TAR CRUISER 7'         ; Word $18
                .BYTE EOW|'A','LL UNITS'              ; Word $19
                .BYTE EOW|'M','ISSION'                ; Word $1A
                .BYTE EOW|$20,'   STAR RAIDERS'       ; Word $1B
                .BYTE EOW|'Z','ERO'                   ; Word $1C
                .BYTE EOW|'B','Y ZYLON FIRE'          ; Word $1D
                .BYTE EOW|'P','OSTHUMOUS'             ; Word $1E
                .BYTE EOW|'R','ANK IS:'               ; Word $1F
                .BYTE EOW|'C','OPYRIGHT ATARI 1979'   ; Word $20
                .BYTE EOW|'S','UB-SPACE RADIO'        ; Word $21
                .BYTE EOW|'S','ECTOR SCAN'            ; Word $22
                .BYTE EOW|'E','NGINES'                ; Word $23
                .BYTE EOW|'N','EW'                    ; Word $24
                .BYTE EOW|'C','LASS'                  ; Word $25
                .BYTE EOW|'C','ONGRATULATIONS'        ; Word $26
                .BYTE EOW|'R','EPORT TO BASE'         ; Word $27
                .BYTE EOW|'F','OR TRAINING'           ; Word $28
                .BYTE EOW|'G','ALACTIC COOK'          ; Word $29
                .BYTE EOW|'G','ARBAGE SCOW CAPTAIN'   ; Word $2A
                .BYTE EOW|'R','OOKIE'                 ; Word $2B
                .BYTE EOW|'N','OVICE'                 ; Word $2C
                .BYTE EOW|'E','NSIGN'                 ; Word $2D
                .BYTE EOW|'P','ILOT'                  ; Word $2E
                .BYTE EOW|'A','CE'                    ; Word $2F
                .BYTE EOW|'L','IEUTENANT'             ; Word $30
                .BYTE EOW|'W','ARRIOR'                ; Word $31
                .BYTE EOW|'C','APTAIN'                ; Word $32
                .BYTE EOW|'C','OMMANDER'              ; Word $33
                .BYTE EOW|'D','AMAGE'                 ; Word $34
                .BYTE EOW|'D','AMAGED'                ; Word $35
                .BYTE EOW|'C','ONTROL'                ; Word $36
                .BYTE EOW|'P','HOTONS'                ; Word $37
                .BYTE EOW|$20                         ; Word $38
                .BYTE EOW|'S','TAR COMMANDER'         ; Word $39
                .BYTE EOW|$00                         ;

;*** View modes ****************************************************************
VIEWMODETAB     .BYTE $00                             ; Front view
                .BYTE $01                             ; Aft view
                .BYTE $40                             ; Long-Range Scan view
                .BYTE $80                             ; Galactic Chart view

;*** Title phrase offsets of "TRACKING OFF", "SHIELDS OFF", "COMPUTER OFF" *****
MSGOFFTAB       .BYTE $0E                             ; "TRACKING OFF"
                .BYTE $09                             ; "SHIELDS OFF"
                .BYTE $04                             ; "COMPUTER OFF"

;*** Masks to test if Tracking Computer, Shields, or Attack Computer are on ****
MSGBITTAB       .BYTE $FF                             ; Mask Tracking Computer
                .BYTE $08                             ; Mask Shields
                .BYTE $02                             ; Mask Attack Computer

;*** Title phrase offsets of "COMPUTER TRACKING ON", "SHIELDS ON", "COMPUTER ON"
MSGONTAB        .BYTE $0B                             ; "COMPUTER TRACKING ON"
                .BYTE $07                             ; "SHIELDS ON"
                .BYTE $01                             ; "COMPUTER ON"

;*** The following two tables encode the PLAYER shapes *************************
;
; PHOTON TORPEDO (shape type 0, data in shape table PLSHAP1TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $01..$10  $11..$1E  $1F..$2A  $2B..$34  $35..$3C  $3D..$42  $75..$76  $7A..$7B
; ...##...  ...#....  ...##...  ...#....  ...#....  ...#....  ...##...  ...#....
; ..####..  ..###...  ..####..  ..###...  ...##...  ..###...  ...##...  ...#....
; .######.  .#####..  ..####..  ..###...  ..####..  ..###...
; .######.  .#####..  .######.  .#####..  ..#.##..  ..#.#...
; .###.##.  #######.  .##.###.  .###.#..  ..####..  ..###...
; ####.###  ##.####.  .####.#.  .#####..  ..####..  ...#....
; ##.#####  ##.##.#.  .######.  .##.##..  ...##...
; ##.#####  #####.#.  .###.##.  ..###...  ....#...
; ########  ###.###.  .######.  ..###...
; ########  ###.###.  ..####..  ...#....
; ####.###  .#####..  ..####..
; .###.##.  .#####..  ...##...
; .######.  ..###...
; .######.  ...#....
; ..####..
; ...##...
;
; ZYLON FIGHTER (shape type 1, data in shape table PLSHAP2TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $01..$0C  $0D..$14  $15..$1A  $1B..$20  $21..$24  $25..$28  $29..$2A  $2B..$2C
; #......#  #.....#.  .#....#.  .#...#..  ..#..#..  ..#.#...  ...##...  ...#....
; #......#  #.....#.  .#.##.#.  .#.#.#..  ..####..  ..###...  ...##...  ...#....
; #......#  #.###.#.  .######.  .#####..  ..####..  ..###...
; #......#  #######.  .######.  .#####..  ..#..#..  ..#.#...
; #.####.#  #######.  .#.##.#.  .#.#.#..
; ########  #.###.#.  .#....#.  .#...#..
; ########  #.....#.
; #.####.#  #.....#.
; #......#
; #......#
; #......#
; #......#
;
; STARBASE RIGHT (shape type 2, data in shape table PLSHAP2TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $2D..$36  $38..$40  $41..$46  $36..$38  $36       $00       $00       $00
; ###.....  ##......  ##......  ##......  ##......  ........  ........  ........
; #####...  ####....  ##......  ####....
; #####...  ####....  ####....  ##......
; #######.  ######..  #.####..
;  #.#.###  #.#####.  ####....
; #######.  ######..  ##......
; #####...  ####....
; #####...  #.......
; ##......  #.......
; ##......
;
; STARBASE CENTER (shape type 3, data in shape table PLSHAP1TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $7E..$8D  $8E..$9C  $9D..$A9  $AA..$B3  $B4..$BB  $BC..$C0  $7B..$7D  $7A..$7B
; ...##...  ........  ........  ...##...  ........  ...##...  ...#....  ...#....
; .######.  ...##...  ...##...  ..####..  ...##...  ..####..  ..###...  ...#....
; ########  ..####..  ..####..  ########  ..####..  ########  ...#....
; ########  .######.  .######.  ########  ########  ..####..
; ########  ########  ########  ###..###  ########  ...##...
; ########  ########  ########  .##..##.  ########
; ########  ########  ###..###  ########  ..####..
; ###..###  ###..###  .##..##.  ########  ...##...
; ###..###  .##..##.  ########  .######.
; ########  ########  ########  ..####..
; ########  ########  ########
; ########  ########  ########
; ########  ########  ..####..
; ########  .######.
; .######.  .######.
; .######.
;
; STARBASE LEFT (shape type 4, data in shape table PLSHAP2TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $47..$50  $52..$5A  $5B..$60  $50..$52  $50       $00       $00       $00
; .....###  ......##  ......##  ......##  ......##  ........  ........  ........
; ...#####  ....####  ......##  ....####
; ...#####  ....####  ....####  ......##
; .#######  ..######  ..####.#
; ###.#.#.  .#####.#  ....####
; .#######  ..######  ......##
; ...#####  ....####
; ...#####  .......#
; ......##  .......#
; ......##
;
; TRANSFER VESSEL (shape type 5, data in shape table PLSHAP1TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $43..$52  $53..$60  $61..$6B  $6C..$74  $75..$79  $7A..$7D  $75..$76  $7A..$7B
; ..####..  ...###..  ...##...  ...#....  ...##...  ...#....  ...##...  ...#....
; ..####..  ...###..  ...##...  ...#....  ...##...  ...#....  ...##...  ...#....
; ..#..#..  ...#.#..  ..####..  ..###...  ..####..  ..###...
; ..####..  ..#####.  ..####..  ..###...  ...##...  ...#....
; .######.  ..#####.  ..####..  ..###...  ...##...
; .######.  ..#####.  ..####..  .#####..
; .######.  ..#.#.#.  .######.  ..#.#...
; .#.##.#.  .#######  ..#..#..  ..#.#...
; ########  .#######  ..#..#..  ..#.#...
; ########  ..#...#.  ..#..#..
; .#....#.  ..#...#.  ..#..#..
; .#....#.  ..#...#.
; .#....#.  ..#...#.
; .#....#.  ..#...#.
; .#....#.
; .#....#.
;
; METEOR (shape type 6, data in shape table PLSHAP1TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $01..$10  $11..$1E  $1F..$2A  $2B..$34  $35..$3C  $3D..$42  $75..$76  $7A..$7B
; ...##...  ...#....  ...##...  ...#....  ...#....  ...#....  ...##...  ...#....
; ..####..  ..###...  ..####..  ..###...  ...##...  ..###...  ...##...  ...#....
; .######.  .#####..  ..####..  ..###...  ..####..  ..###...
; .######.  .#####..  .######.  .#####..  ..#.##..  ..#.#...
; .###.##.  #######.  .##.###.  .###.#..  ..####..  ..###...
; ####.###  ##.####.  .####.#.  .#####..  ..####..  ...#....
; ##.#####  ##.##.#.  .######.  .##.##..  ...##...
; ##.#####  #####.#.  .###.##.  ..###...  ....#...
; ########  ###.###.  .######.  ..###...
; ########  ###.###.  ..####..  ...#....
; ####.###  .#####..  ..####..
; .###.##.  .#####..  ...##...
; .######.  ..###...
; .######.  ...#....
; ..####..
; ...##...
;
; ZYLON CRUISER (shape type 7, data in shape table PLSHAP2TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $61..$69  $6A..$71  $72..$78  $79..$7E  $7F..$82  $83..$85  $29..$2A  $2B..$2C
; ...##...  ...#....  ...##...  ...#....  ...##...  ...#....  ...##...  ...#....
; ..####..  ..###...  ..####..  ..###...  ..####..  ..###...  ...##...  ...#....
; .######.  .#####..  ..####..  ..###...  ..#..#..  ..#.#...
; .######.  .#####..  .##..##.  .##.##..  ..#..#..
; ##.##.##  ##.#.##.  .##..##.  .#...#..
; ##....##  ##...##.  .#....#.  .#...#..
; #......#  #.....#.  .#....#.
; #......#  #.....#.
; #......#
;
; ZYLON BASESTAR (shape type 8, data in shape table PLSHAP2TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $86..$8F  $90..$99  $9A..$A0  $A1..$A7  $A8..$AC  $AD..$B0  $29..$2A  $2B..$2C
; ...##...  ...#....  ...##...  ...#....  ...##...  ...#....  ...##...  ...#....
; ..####..  ..###...  ..####..  ..###...  ..####..  ..###...  ...##...  ...#....
; .######.  .#####..  .######.  .#####..  ...##...  ..###...
; ########  #######.  ...##...  ...#....  ..####..  ...#....
; ...##...  ..###...  .######.  .#####..  ...##...
; ...##...  ..###...  ..####..  ..###...
; ########  #######.  ...##...  ...#....
; .######.  .#####..
; ..####..  ..###...
; ...##...  ...#....
;
; HYPERWARP TARGET MARKER (shape type 9, data in shape table PLSHAP1TAB)
; Numbers at top indicate the shape table offset of the first and last shape row
;
; $C1..$CC  $C1..$CC  $C1..$CC  $C1..$CC  $C1..$CC  $C1..$CC  $75..$76  $C1..$CC
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ...##...  ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ...##...  ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...
; ###.###.  ###.###.  ###.###.  ###.###.  ###.###.  ###.###.            ###.###.
; ........  ........  ........  ........  ........  ........            ........
; ........  ........  ........  ........  ........  ........            ........
; ###.###.  ###.###.  ###.###.  ###.###.  ###.###.  ###.###.            ###.###.
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...
; ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...  ..#.#...            ..#.#...

;*** Shape type 0..9 offset table (10 shape cell offsets of shape type...) *****
PLSHAPOFFTAB    .BYTE $01,$11,$1F,$2B,$35,$3D,$75,$7A ; ...0 into PLSHAP1TAB
                .BYTE $01,$0D,$15,$1B,$21,$25,$29,$2B ; ...1 into PLSHAP2TAB
                .BYTE $2D,$38,$41,$36,$36,$00,$00,$00 ; ...2 into PLSHAP2TAB
                .BYTE $7E,$8E,$9D,$AA,$B4,$BC,$7B,$7A ; ...3 into PLSHAP1TAB
                .BYTE $47,$52,$5B,$50,$50,$00,$00,$00 ; ...4 into PLSHAP2TAB
                .BYTE $43,$53,$61,$6C,$75,$7A,$75,$7A ; ...5 into PLSHAP1TAB
                .BYTE $01,$11,$1F,$2B,$35,$3D,$75,$7A ; ...6 into PLSHAP1TAB
                .BYTE $61,$6A,$72,$79,$7F,$83,$29,$2B ; ...7 into PLSHAP2TAB
                .BYTE $86,$90,$9A,$A1,$A8,$AD,$29,$2B ; ...8 into PLSHAP2TAB
                .BYTE $C1,$C1,$C1,$C1,$C1,$C1,$75,$C1 ; ...9 into PLSHAP1TAB

;*** Shape type 0..9 height table (10 shape cell heights of shape type...) *****
PLSHAPHEIGHTTAB .BYTE $0F,$0D,$0B,$09,$07,$05,$01,$01 ; ...0
                .BYTE $0B,$07,$05,$05,$03,$03,$01,$01 ; ...1
                .BYTE $09,$08,$05,$02,$00,$00,$00,$00 ; ...2
                .BYTE $0F,$0E,$0C,$09,$07,$04,$02,$01 ; ...3
                .BYTE $09,$08,$05,$02,$00,$00,$00,$00 ; ...4
                .BYTE $0F,$0D,$0A,$08,$04,$03,$01,$01 ; ...5
                .BYTE $0F,$0D,$0B,$09,$07,$05,$01,$01 ; ...6
                .BYTE $08,$07,$06,$05,$03,$02,$01,$01 ; ...7
                .BYTE $09,$09,$06,$06,$04,$03,$01,$01 ; ...8
                .BYTE $0B,$0B,$0B,$0B,$0B,$0B,$01,$0B ; ...9

;*** Keyboard codes to switch to Front or Aft view when Tracking Computer is on 
TRACKKEYSTAB    .BYTE $F8                             ; 'F' - Front view
                .BYTE $FF                             ; 'A' - Aft view

;*** Galactic Chart sector character codes (encoded in custom character set) ***
SECTORCHARTAB   .BYTE CCS.BORDERSW                    ; Empty sector
                .BYTE CCS.2ZYLONS                     ; Sector contains 1 Zylon ship
                .BYTE CCS.2ZYLONS                     ; Sector contains 2 Zylon ships
                .BYTE CCS.3ZYLONS                     ; Sector contains 3 Zylon ships
                .BYTE CCS.4ZYLONS                     ; Sector contains 4 Zylon ships
                .BYTE CCS.STARBASE                    ; Sector contains starbase

;*** Mask to limit veer-off velocity of Hyperwarp Target Marker in hyperwarp ***
VEERMASKTAB     .BYTE NEG|31                          ;  -31..+31  <KM/H> (unused)
                .BYTE NEG|63                          ;  -63..+63  <KM/H> PILOT mission
                .BYTE NEG|95                          ;  -95..+95  <KM/H> WARRIOR mission
                .BYTE NEG|127                         ; -127..+127 <KM/H> COMMANDER mission

;*** Horizontal PLAYER offsets for PLAYER0..1 (STARBASE LEFT, STARBASE RIGHT) **
PLSTARBAOFFTAB  .BYTE -8                              ; -8 Player/Missile pixels
                .BYTE 8                               ; +8 Player/Missile pixels

;*** Mission bonus table *******************************************************
BONUSTAB        .BYTE 80                              ; Mission complete   NOVICE mission
                .BYTE 76                              ; Mission complete   PILOT mission
                .BYTE 60                              ; Mission complete   WARRIOR mission
                .BYTE 111                             ; Mission complete   COMMANDER mission

                .BYTE 60                              ; Mission aborted    NOVICE mission
                .BYTE 60                              ; Mission aborted    PILOT mission
                .BYTE 50                              ; Mission aborted    WARRIOR mission
                .BYTE 100                             ; Mission aborted    COMMANDER mission

                .BYTE 40                              ; Starship destroyed NOVICE mission
                .BYTE 50                              ; Starship destroyed PILOT mission
                .BYTE 40                              ; Starship destroyed WARRIOR mission
                .BYTE 90                              ; Starship destroyed COMMANDER mission

;*** Title phrase offsets of scored class rank *********************************
RANKTAB         .BYTE $29|EOS                         ; "GALACTIC COOK"
                .BYTE $2A|EOS                         ; "GARBAGE SCOW CAPTAIN"
                .BYTE $2A|EOS                         ; "GARBAGE SCOW CAPTAIN"
                .BYTE $2B|EOS                         ; "ROOKIE"
                .BYTE $2B|EOS                         ; "ROOKIE"
                .BYTE $2C|EOS                         ; "NOVICE"
                .BYTE $2C|EOS                         ; "NOVICE"
                .BYTE $2D|EOS                         ; "ENSIGN"
                .BYTE $2D|EOS                         ; "ENSIGN"
                .BYTE $2E|EOS                         ; "PILOT"
                .BYTE $2E|EOS                         ; "PILOT"
                .BYTE $2F|EOS                         ; "ACE"
                .BYTE $30|EOS                         ; "LIEUTENANT"
                .BYTE $31|EOS                         ; "WARRIOR"
                .BYTE $32|EOS                         ; "CAPTAIN"
                .BYTE $33|EOS                         ; "COMMANDER"
                .BYTE $33|EOS                         ; "COMMANDER"
                .BYTE $39|EOS                         ; "STAR COMMANDER"
                .BYTE $39|EOS                         ; "STAR COMMANDER"

;*** Scored class number table *************************************************
CLASSTAB        .BYTE CCS.COL2|ROM.5                  ; Class 5
                .BYTE CCS.COL2|ROM.5                  ; Class 5
                .BYTE CCS.COL2|ROM.5                  ; Class 5
                .BYTE CCS.COL2|ROM.4                  ; Class 4
                .BYTE CCS.COL2|ROM.4                  ; Class 4
                .BYTE CCS.COL2|ROM.4                  ; Class 4
                .BYTE CCS.COL2|ROM.4                  ; Class 4
                .BYTE CCS.COL2|ROM.3                  ; Class 3
                .BYTE CCS.COL2|ROM.3                  ; Class 3
                .BYTE CCS.COL2|ROM.3                  ; Class 3
                .BYTE CCS.COL2|ROM.2                  ; Class 2
                .BYTE CCS.COL2|ROM.2                  ; Class 2
                .BYTE CCS.COL2|ROM.2                  ; Class 2
                .BYTE CCS.COL2|ROM.1                  ; Class 1
                .BYTE CCS.COL2|ROM.1                  ; Class 1
                .BYTE CCS.COL2|ROM.1                  ; Class 1

;*** Title phrase offsets of mission level *************************************
MISSIONPHRTAB   .BYTE $4A                             ; "NOVICE MISSION"
                .BYTE $4C                             ; "PILOT MISSION"
                .BYTE $4E                             ; "WARRIOR MISSION"
                .BYTE $50                             ; "COMMANDER MISSION"

;*** Damage probability of subsystems depending on mission level ***************
DAMAGEPROBTAB   .BYTE 0                               ;  0% (  0:256) NOVICE mission
                .BYTE 80                              ; 31% ( 80:256) PILOT mission
                .BYTE 180                             ; 70% (180:256) WARRIOR mission
                .BYTE 254                             ; 99% (254:256) COMMANDER mission

;*** Title phrase offsets of damaged subsystems ********************************
DAMAGEPHRTAB    .BYTE $55                             ; "PHOTON TORPEDOS DAMAGED"
                .BYTE $5B                             ; "ENGINES DAMAGED"
                .BYTE $61                             ; "SHIELDS DAMAGED"
                .BYTE $67                             ; "COMPUTER DAMAGED"
                .BYTE $6D                             ; "LONG RANGE SCAN DAMAGED"
                .BYTE $71                             ; "SUB-SPACE RADIO DAMAGED"

;*** Title phrase offsets of destroyed subsystems ******************************
DESTROYPHRTAB   .BYTE $58                             ; "PHOTON TORPEDOS DESTROYED"
                .BYTE $5E                             ; "ENGINES DESTROYED"
                .BYTE $64                             ; "SHIELDS DESTROYED"
                .BYTE $6A                             ; "COMPUTER DESTROYED"
                .BYTE $6F                             ; "LONG RANGE SCAN DESTROYED"
                .BYTE $73                             ; "SUB-SPACE RADIO DESTROYED"

;*** 3 x 10-byte noise sound patterns (bytes 0..7 stored in reverse order) *****
;
; (9) AUDCTL        ($D208) POKEY: Audio control
; (8) AUDF3         ($D204) POKEY: Audio channel 3 frequency
; (7) NOISETORPTIM  ($DA)   Timer for PHOTON TORPEDO LAUNCHED noise sound patterns
; (6) NOISEEXPLTIM  ($DB)   Timer for SHIELD and ZYLON EXPLOSION noise sound patterns
; (5) NOISEAUDC2    ($DC)   Audio channel 1/2 control shadow register
; (4) NOISEAUDC3    ($DD)   Audio channel 3   control shadow register
; (3) NOISEAUDF1    ($DE)   Audio channel 1 frequency shadow register
; (2) NOISEAUDF2    ($DF)   Audio channel 2 frequency shadow register
; (1) NOISEFRQINC   ($E0)   Audio channel 1/2 frequency increment
; (0) NOISELIFE     ($E1)   Noise sound pattern lifetime
;
;                     (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)
NOISEPATTAB     .BYTE $18,$FF,$02,$00,$8A,$A0,$00,$08,$50,$00; PHOTON TORPEDO LAUNCHED
                .BYTE $40,$40,$01,$03,$88,$AF,$08,$00,$50,$04; SHIELD EXPLOSION
                .BYTE $30,$40,$01,$03,$84,$A8,$04,$00,$50,$04; ZYLON EXPLOSION

;*** 5 x 6-byte beeper sound patterns (bytes 0..5 stored in reverse order) *****
;
; (5) BEEPFRQIND    ($D2) Running index into frequency table BEEPFRQTAB ($BF5C)
; (4) BEEPREPEAT    ($D3) Number of times the beeper sound pattern sequence is repeated - 1
; (3) BEEPTONELIFE  ($D4) Lifetime of tone in TICKs - 1
; (2) BEEPPAUSELIFE ($D5) Lifetime of pause in TICKs - 1 ($FF -> No pause)
; (1) BEEPPRIORITY  ($D6) Beeper sound pattern priority. A playing beeper sound pattern is
;                         stopped if a beeper sound pattern of higher priority is about to be
;                         played. A value of 0 indicates that no beeper sound pattern is
;                         playing at the moment.
; (0) BEEPFRQSTART  ($D7) Index to first byte of the beeper sound pattern frequency in table
;                         BEEPFRQTAB ($BF5C)
;
; Frequency-over-TICKs diagrams for all beeper sound patterns:
;
; HYPERWARP TRANSIT
;
;      FRQ
;       |
;   $18 |-4--
;       |
;   $00 |    -3-
;       +-------> TICKS
;        <13 x >
;
; RED ALERT
;
;      FRQ
;       |
;   $60 |                 --------17-------
;       |
;   $40 |--------17-------
;       |
;       +----------------------------------> TICKS
;        <-------------- 8 x ------------->
;
; ACKNOWLEDGE
;
;      FRQ
;       |
;   $10 |-3-   -3-   -3-
;       |
;   $00 |   -3-   -3-   -3-
;       +------------------> TICKS
;        <------ 1 x ----->
;
; DAMAGE REPORT (not to scale)
;
;      FRQ
;       |
;   $40 |------------33-------------
;       |
;   $20 |                           ------------33-------------
;       |
;       +------------------------------------------------------> TICKS
;        <------------------------ 3 x ----------------------->
;
; MESSAGE FROM STARBASE (not to scale)
;
;      FRQ
;       |
;   $51 |                                  -----33-----
;   $48 |-----33-----
;   $40 |                 -----33-----
;       |
;   $00 |            --9--            --9--            --9--
;       +----------------------------------------------------> TICKS
;        <---------------------- 1 x ---------------------->
;
;                     (0),(1),(2),(3),(4),(5)
BEEPPATTAB      .BYTE $02,$02,$02,$03,$0C,$02         ; HYPERWARP TRANSIT
                .BYTE $04,$03,$FF,$10,$07,$04         ; RED ALERT
                .BYTE $07,$04,$02,$02,$00,$07         ; ACKNOWLEDGE
                .BYTE $0B,$05,$FF,$20,$02,$0B         ; DAMAGE REPORT
                .BYTE $0E,$06,$08,$20,$00,$0E         ; MESSAGE FROM STARBASE

;*** Beeper sound pattern frequency table **************************************
BEEPFRQTAB      .BYTE $10,$FF                         ; (unused) (!)
                .BYTE $18,$FF                         ; HYPERWARP TRANSIT
                .BYTE $40,$60,$FF                     ; RED ALERT
                .BYTE $10,$10,$10,$FF                 ; ACKNOWLEDGE
                .BYTE $40,$20,$FF                     ; DAMAGE REPORT
                .BYTE $48,$40,$51,$FF                 ; MESSAGE FROM STARBASE

;*** Shape of blip in Attack Computer Display **********************************
BLIPSHAPTAB     .BYTE $84                             ; #....#..
                .BYTE $B4                             ; #.##.#..
                .BYTE $FC                             ; ######..
                .BYTE $B4                             ; #.##.#..
                .BYTE $84                             ; #....#..

;*** Initial x-coordinate (high byte) of our starship's photon torpedo *********
BARRELXTAB      .BYTE $FF                             ; Left barrel  = -256 (-$FF00) <KM>
                .BYTE $01                             ; Right barrel = +256 (+$0100) <KM>

;*** Maximum photon torpedo hit z-coordinate (high byte) ***********************
HITMAXZTAB      .BYTE $0C                             ; < 3328 ($0C**) <KM>
                .BYTE $0C                             ; < 3328 ($0C**) <KM>
                .BYTE $0C                             ; < 3328 ($0C**) <KM>
                .BYTE $0C                             ; < 3328 ($0C**) <KM>
                .BYTE $0E                             ; < 3840 ($0E**) <KM>
                .BYTE $0E                             ; < 3840 ($0E**) <KM>
                .BYTE $0E                             ; < 3840 ($0E**) <KM>
                .BYTE $20                             ; < 8448 ($20**) <KM>

;*** Minimum photon torpedo hit z-coordinate (high byte) ***********************
HITMINZTAB      .BYTE $00                             ; >=    0 ($00**) <KM>
                .BYTE $00                             ; >=    0 ($00**) <KM>
                .BYTE $00                             ; >=    0 ($00**) <KM>
                .BYTE $02                             ; >=  512 ($02**) <KM>
                .BYTE $04                             ; >= 1024 ($04**) <KM>
                .BYTE $06                             ; >= 1536 ($06**) <KM>
                .BYTE $08                             ; >= 2048 ($08**) <KM>
                .BYTE $0C                             ; >= 3072 ($0C**) <KM>

;*** Velocity of homing Zylon photon torpedo ***********************************
ZYLONHOMVELTAB  .BYTE NEG|1                           ;  -1 <KM/H> NOVICE mission
                .BYTE NEG|4                           ;  -4 <KM/H> PILOT mission
                .BYTE NEG|8                           ;  -8 <KM/H> WARRIOR mission
                .BYTE NEG|20                          ; -20 <KM/H> COMMANDER mission

;*** Zylon shape type table ****************************************************
ZYLONSHAPTAB    .BYTE SHAP.ZBASESTAR                  ; ZYLON BASESTAR
                .BYTE SHAP.ZFIGHTER                   ; ZYLON FIGHTER
                .BYTE SHAP.ZFIGHTER                   ; ZYLON FIGHTER
                .BYTE SHAP.ZFIGHTER                   ; ZYLON FIGHTER
                .BYTE SHAP.ZCRUISER                   ; ZYLON CRUISER
                .BYTE SHAP.ZCRUISER                   ; ZYLON CRUISER
                .BYTE SHAP.ZCRUISER                   ; ZYLON CRUISER
                .BYTE SHAP.ZFIGHTER                   ; ZYLON FIGHTER

;*** Zylon flight pattern table ************************************************
ZYLONFLPATTAB   .BYTE 4                               ; Flight pattern 4
                .BYTE 4                               ; Flight pattern 4
                .BYTE 0                               ; Attack Flight Pattern 0
                .BYTE 0                               ; Attack Flight Pattern 0
                .BYTE 0                               ; Attack Flight Pattern 0
                .BYTE 1                               ; Flight pattern 1
                .BYTE 0                               ; Attack Flight Pattern 0
                .BYTE 0                               ; Attack Flight Pattern 0

;*** Zylon velocity table ******************************************************
ZYLONVELTAB     .BYTE 62                              ; +62 <KM/H>
                .BYTE 30                              ; +30 <KM/H>
                .BYTE 16                              ; +16 <KM/H>
                .BYTE 8                               ;  +8 <KM/H>
                .BYTE 4                               ;  +4 <KM/H>
                .BYTE 2                               ;  +2 <KM/H>
                .BYTE 1                               ;  +1 <KM/H>
                .BYTE 0                               ;   0 <KM/H>
                .BYTE 0                               ;   0 <KM/H>
                .BYTE NEG|1                           ;  -1 <KM/H>
                .BYTE NEG|2                           ;  -2 <KM/H>
                .BYTE NEG|4                           ;  -4 <KM/H>
                .BYTE NEG|8                           ;  -8 <KM/H>
                .BYTE NEG|16                          ; -16 <KM/H>
                .BYTE NEG|30                          ; -30 <KM/H>
                .BYTE NEG|62                          ; -62 <KM/H>

;*** PLAYFIELD colors (including PLAYFIELD colors during DLI) ******************
PFCOLORTAB      .BYTE $A6                             ; PF0COLOR    = {GREEN}
                .BYTE $AA                             ; PF1COLOR    = {LIGHT GREEN}
                .BYTE $AF                             ; PF2COLOR    = {VERY LIGHT GREEN}
                .BYTE $00                             ; PF3COLOR    = {BLACK}
                .BYTE $00                             ; BGRCOLOR    = {BLACK}
                .BYTE $B8                             ; PF0COLORDLI = {LIGHT MINT}
                .BYTE $5A                             ; PF1COLORDLI = {MEDIUM PINK}
                .BYTE $FC                             ; PF2COLORDLI = {LIGHT ORANGE}
                .BYTE $5E                             ; PF3COLORDLI = {LIGHT PINK}
                .BYTE $90                             ; BGRCOLORDLI = {DARK BLUE}

;*** Vicinity mask table. Confines coordinates of space objects in sector ******
VICINITYMASKTAB .BYTE $FF                             ; <= 65535 ($FF**) <KM>
                .BYTE $FF                             ; <= 65535 ($FF**) <KM>
                .BYTE $3F                             ; <= 16383 ($3F**) <KM>
                .BYTE $0F                             ; <=  4095 ($0F**) <KM>
                .BYTE $3F                             ; <= 16383 ($3F**) <KM>
                .BYTE $7F                             ; <= 32767 ($7F**) <KM>
                .BYTE $FF                             ; <= 65535 ($FF**) <KM>
                .BYTE $FF                             ; <= 65535 ($FF**) <KM>

;*** Movement probability of sector types in Galactic Chart ********************
MOVEPROBTAB     .BYTE 0                               ; Empty sector    0% (  0:256)
                .BYTE 255                             ; 1 Zylon ship  100% (255:256)
                .BYTE 255                             ; 2 Zylon ships 100% (255:256)
                .BYTE 192                             ; 3 Zylon ships  75% (192:256)
                .BYTE 32                              ; 4 Zylon ships  13% ( 32:256)

;*** Galactic Chart sector offset to adjacent sector ***************************
COMPASSOFFTAB   .BYTE -16                             ; NORTH
                .BYTE -17                             ; NORTHWEST
                .BYTE -1                              ; WEST
                .BYTE 15                              ; SOUTHWEST
                .BYTE 16                              ; SOUTH
                .BYTE 17                              ; SOUTHEAST
                .BYTE 1                               ; EAST
                .BYTE -15                             ; NORTHEAST
                .BYTE 0                               ; CENTER

;*** Homing velocities of photon torpedoes 0..1 depending on distance to target 
HOMVELTAB       .BYTE 0                               ;  +0 <KM/H>
                .BYTE 8                               ;  +8 <KM/H>
                .BYTE 16                              ; +16 <KM/H>
                .BYTE 24                              ; +24 <KM/H>
                .BYTE 40                              ; +40 <KM/H>
                .BYTE 48                              ; +48 <KM/H>
                .BYTE 56                              ; +56 <KM/H>
                .BYTE 64                              ; +64 <KM/H>

;*** PLAYER shape color table (bits B7..4 of color/brightness) *****************
PLSHAPCOLORTAB  .BYTE $50                             ; PHOTON TORPEDO          = {PURPLE}
                .BYTE $00                             ; ZYLON FIGHTER           = {GRAY}
                .BYTE $20                             ; STARBASE RIGHT          = {ORANGE}
                .BYTE $20                             ; STARBASE CENTER         = {ORANGE}
                .BYTE $20                             ; STARBASE LEFT           = {ORANGE}
                .BYTE $00                             ; TRANSFER VESSEL         = {GRAY}
                .BYTE $A0                             ; METEOR                  = {GREEN}
                .BYTE $00                             ; ZYLON CRUISER           = {GRAY}
                .BYTE $00                             ; ZYLON BASESTAR          = {GRAY}
                .BYTE $9F                             ; HYPERWARP TARGET MARKER = {SKY BLUE}

;*** PLAYER shape brightness table (bits B3..0 of color/brightness) ************
PLSHAPBRITTAB   .BYTE $0E                             ; ##############..
                .BYTE $0E                             ; ##############..
                .BYTE $0E                             ; ##############..
                .BYTE $0C                             ; ############....
                .BYTE $0C                             ; ############....
                .BYTE $0C                             ; ############....
                .BYTE $0A                             ; ##########......
                .BYTE $0A                             ; ##########......
                .BYTE $0A                             ; ##########......
                .BYTE $08                             ; ########........
                .BYTE $08                             ; ########........
                .BYTE $08                             ; ########........
                .BYTE $06                             ; ######..........
                .BYTE $06                             ; ######..........
                .BYTE $04                             ; ####............
                .BYTE $04                             ; ####............

;*** PHOTON TORPEDO LAUNCHED noise bit and volume (stored in reverse order) ****
NOISETORPVOLTAB .BYTE $8A                             ; ##########.....
                .BYTE $8F                             ; ###############
                .BYTE $8D                             ; #############..
                .BYTE $8B                             ; ###########....
                .BYTE $89                             ; #########......
                .BYTE $87                             ; #######........
                .BYTE $85                             ; ######.........
                .BYTE $83                             ; ###............

;*** PHOTON TORPEDO LAUNCHED noise frequency table (stored in reverse order) ***
NOISETORPFRQTAB .BYTE $00                             ;
                .BYTE $04                             ;
                .BYTE $01                             ;
                .BYTE $04                             ;
                .BYTE $01                             ;
                .BYTE $04                             ;
                .BYTE $01                             ;
                .BYTE $04                             ;

                .BYTE $07                             ; (unused)

                .BYTE $00                             ; Always 0 for cartridges
                .BYTE $80                             ; On SYSTEM RESET jump to INITCOLD via
                .WORD INITCOLD                        ; Cartridge Initialization Address
