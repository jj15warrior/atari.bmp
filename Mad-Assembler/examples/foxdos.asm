// https://github.com/pfusik/numen/blob/master/dos.asx
// changes: 24-05-2020

// $0980

/*

- installs the D: device like any other Atari DOS
- loads the executable file AUTORUN at startup
- supports the standard DOS 2 file system
- the supported sector size (128 or 256 bytes) is determined at the foxDOS compilation stage
- foxDOS allows you to read the file by D:
- only one file can be read at a time, but it can be of any length
- foxDOS allows you to overwrite an existing file located in one sector
- other operations like reading the directory, deleting, renaming etc. are not supported
- foxDOS fits entirely in the boot sectors
- foxDOS does not set MEMLO, but it only takes up $0700 .. $097F
- foxDOS does not disable the ROM during transmission

*/

SECTOR_SIZE equ	256
DIR_SECTOR equ	$169

iccomz	equ	$22
icbalz	equ	$24
icax1z	equ	$2a
dsctln	equ	$2d5
runad	equ	$2e0
initad	equ	$2e2
memlo	equ	$2e7
dcomnd	equ	$302
dbuflo	equ	$304
dbufhi	equ	$305
daux1	equ	$30a
daux2	equ	$30b
hatabs	equ	$31a
dskinv	equ	$e453
pentv	equ	$e486

file_id	equ	$43
load_ptr equ	$44
load_end equ	$46
buffer	equ	$700

	opt	h-f+

	ift	SECTOR_SIZE=128
	org 	$07eb
	els
	org	$07e1
	eif
main
	dta	c'F',3,a(main),	a(ret)

:SECTOR_SIZE!=128	mwy	#SECTOR_SIZE	dsctln

	sta	dbufhi			; A = $07

	mva	<dos_end	memlo
	mva	>dos_end	memlo+1	; A = $09

	ldx	#'D'
;	ldy	<handler_table		; $0909
;	lda	>handler_table
	tay
	jsr	pentv

bload
	jsr	open_findFile
	bmi	load_error

	ert * <> $809

load_1
	jsr	read
	bmi	load_run
	sta	load_ptr
	jsr	read
	bmi	load_error
	sta	load_ptr+1
;	and	load_ptr
	cmp	#$ff
	bcs	load_1
	jsr	read
	bmi	load_error
	sta	load_end
	jsr	read
	bmi	load_error
	sta	load_end+1
;	mwa	#ret	initad
	lda	>ret			; $0909
	sta	initad
	sta	initad+1
load_2
	jsr	read
	bmi	load_error
	ldy	#0
	sta	(load_ptr),y
	ldy	load_ptr
	lda	load_ptr+1
	inw	load_ptr
	cpy	load_end
	sbc	load_end+1
	bcc	load_2
	lda:pha:pha	>load_1-1	; $808
;	lda:pha	<load_1-1
	jmp	(initad)
load_run
	jmp	(runad)


special
	lda	iccomz
	cmp	#$28
	bne	load_error

	jsr	open
	bpl	bload

load_error
	sec
	rts

	ert * <> $0861

open
	mvx	#0	file_id

	lda	#':'
	ldy	#1
	cmp	(icbalz),y
	seq:iny

open_getName1
	iny
open_getName2
	lda	(icbalz),y
	cmp	#'_'+1
	bcs	open_getName3
	cmp	#'0'
	bcs	open_getName4
	cmp	#'.'
	bne	open_getName3
	cpx	#8
	beq	open_getName1
open_getName3
	dey
	lda	#' '
open_getName4
	sta	file_name,x+
	cpx	#11
	bcc	open_getName1

open_findFile
	ldy	#<DIR_SECTOR
	lda	#>DIR_SECTOR
	ldx	#'R'
	jsr	sio_sector
	bmi	open_ret
open_findFile1
	ldx	#11
open_findFile2
	lda	buffer-11,x
	beq	open_notFound
	and	#$df
	cmp	#$42
	bne	open_findFile4
	ldy	#11
open_findFile3
	lda	buffer+4,x
	cmp	file_name-1,y
	bne	open_findFile4
	dex
	dey
	bne	open_findFile3
	mva	buffer+3,x	buffer+SECTOR_SIZE-2
	lda	file_id
	asl:asl	@
	eor	buffer+4,x
	sta	buffer+SECTOR_SIZE-3
	;tya	;#0
	sty	buffer+SECTOR_SIZE-1
	sty	buffer_ofs
	ldy	#SECTOR_SIZE-3
	sta:rne	buffer-1,y-
	iny	;#1
open_ret
	rts
open_findFile4
	inc	file_id
	txa
	and	#$f0
	add	#$1b
	tax
	bpl	open_findFile2
	inc	daux1
	ldx	#'R'
	jsr	sio_command
	bpl	open_findFile1
	rts


read
	ldy	#0
buffer_ofs	equ *-1
	cpy	buffer+SECTOR_SIZE-1
	bcc	read_get
	ldx	#'R'
	jsr	sio_next
	bmi	read_ret
	ldy	buffer+SECTOR_SIZE-1
	beq	eof
	ldy	#0
read_get
	lda	buffer,y+
	sty	buffer_ofs

	ldy	#1
	rts

open_notFound
	ldy	#170

	ert * <> $909

read_ret
ret	;rts

;	l(open-1) = $60 (rts)

handler_table

//	dta	a(open-1,close-1,read-1,write-1,status-1,special-1)
	dta	a(open-1,close-1,read-1,write-1,ret-1,special-1)


eof	ldy	#136
	rts


write
	ldy:inc	buffer+SECTOR_SIZE-1
	sta	buffer,y
success
	ldy	#1
	rts


close
	lda	icax1z
	cmp	#8
	bne	success
	ldx	#'W'
sio_next
	lda	buffer+SECTOR_SIZE-3
	and	#$03
	ldy	buffer+SECTOR_SIZE-2
	bne	sio_sector
	cmp	#0
	beq	eof
sio_sector
	sty	daux1
	sta	daux2
	eor:sta	buffer+SECTOR_SIZE-3
	mva	#0	buffer+SECTOR_SIZE-2
sio_command
	stx	dcomnd
;	mwa	#buffer	dbuflo
;	mva	>buffer	dbufhi
	jmp	dskinv


file_name
	dta	c'AUTORUN    '

dos_end
	org main+$17f
	.byte 0			;Ensure $180 bytes size

.print *

	end