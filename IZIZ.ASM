;=====================================================================
;   subject : IZMIR 3D texture mapped SHOOTING game in protected mode
;
;   file name : iziz.ASM
;
;   coding : Kim Seong-Wan
;
;   make : tasm /ml iziz.asm
;          wcl386 /fm=izmir /fe=izmir start.obj iziz.obj....
;
;   Copyright (C) 1994, 1995  MIRINAE SOFTWARE, Inc.
;	License : Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
;   
;	Under DOS4GW  DOS extender
;
;   TEXTURE ENGIN developing
;   1994. 10. 28  PM keyboard interrupt handler corrected
;                 ES segment overriding
;   1994. 11. 3   convert to 13h plane mode routine
;         11. 4   bp vs ebp Bug fixed in procdure hline
;      .....
;   GAME ENGIN developing
;   1994. 11.     3D collision check routine
;                 3D sprite routine
;         12.     PM SFX lib
;		  3D course script
;   1995.  1.     convert to 13h plane mode (X mode) routine
;          2.     convert to 13h plane mode (X mode) routine
;================================================================
	LOCALS

	.386

	include keyscan.inc

SC_INDEX                equ     03c4h   ;Sequence Controller Index
CRTC_INDEX              equ     03d4h   ;CRT Controller Index
GRP_INDEX               equ     03ceh   ;Graphic Controller Index
MISC_OUTPUT             equ     03c2h   ;Miscellaneous Output register
SCREEN_OFF              equ     0a0000h ;segment of display memory in Xmode
MAP_MASK                equ     02h     ;Map Mask register index in SC
START_ADDRESS_HIGH      equ     0ch     ;start address high db
START_ADDRESS_LOW       equ     0dh     ;start address low db

COPX                    equ     1024
LBOUND                  equ     0
RBOUND                  equ     319
ABOUND                  equ     0
BBOUND                  equ     149
SCROL                   equ     16

OBJNO                   equ     40 	;(10 + 20 + 5 + 5 + 2)
BEAMNO			equ	10      ; numbers of beam
ENEMYNO                 equ     20      ; numbers of enemy
BULLETNO                equ     5       ; numbers of bullet
FLAMENO                	equ     5       ; numbers of flame

BEAMTYPENO		equ	5       ; numbers of beam type
_GOTO                   equ     230

TEXMAPLEN               equ     102492    ;  stage 3
ENMAPLEN                equ     8192      ;  stage 1
OBJDATLEN               equ     618000    ;  stage 3
BACKDATLEN              equ     27204     ;  stage 2

DEAD    	equ     0                 ; stage flag
CLEAR   	equ     1                 ;
ESCAPE  	equ     2                 ;

ON		equ	1
OFF		equ	0

COPSON		equ	30                ;
DELAY		equ	50                ; stage clear delay loop counter
BSPEED		equ	35                ; enemy bullet speed
BOSSCREA	equ	250		  ;250  boss creation time

JAX         	equ	1                 ; joystick mask
JAY         	equ	2                 ;
JBX         	equ	4                 ;
JBY         	equ	5                 ;
JABTN1      	equ	10h               ;
JABTN2      	equ	20h               ;
JBBTN1      	equ	40h               ;
JBBTN2      	equ	50h               ;
DETECTA     	equ	03h               ;
DETECTB     	equ	0Ch               ;

object  struc

	obj_no          dd      ?       ; 0

	x               dw      ?       ; coordinate
	y               dw      ?       ;
	z               dw      ?       ;

	dlx             dw      ?       ; delta x
	dly             dw      ?       ; delta y
	dlz             dw      ?       ; delta z

	ix              dw      ?       ; interaction
	iy              dw      ?       ;
	iz              dw      ?       ;

	interaction     dw      ?       ;
	z_clip          dw      ?       ;
	sco           	dw      ?       ;

	stat            dd      ?       ; status
	spr_no          dd      ?       ; sprite number
	sfactor         dd      ?       ; scale
	spr_data        dd      ?       ; pointer of sprite image data
	course          dd      ?       ; pointer of course

	crea_rt         dd      ?       ; object creation routine
	spr_rt          dd      ?       ; sprite routine
	course_rt       dd      ?       ; course routine
	course_off      dd      ?       ; course offset

object  ends

cfgstru	struc		; 27 bytes

	sound		db	?
	game_speed	db	?
	control1	db	?
	jaxl		dw	?
	jaxc		dw	?
	jaxr		dw	?
	jayu		dw	?
	jayc		dw	?
	jayd		dw	?
	jbxl		dw	?
	jbxc		dw	?
	jbxr		dw	?
	jbyu		dw	?
	jbyc		dw	?
	jbyd		dw	?

cfgstru	ends


DGROUP  group   _DATA,_BSS

_DATA   segment use32 dword public 'DATA'


;extrn   _soundpar: dword
extrn   _stagepar: dword
extrn   SAVE_CONT: dword

extrn   cops_spr_data: dword

extrn   beam_spr_data: dword
extrn   beam_spr_data2: dword
extrn   beam_spr_data3: dword
extrn   gcl_spr_data: dword
extrn   valk_spr_data: dword
extrn   bigf_spr_data: dword

extrn   bullet_spr_data1: dword
extrn   bullet_spr_data2: dword

extrn   flm_spr_data: dword
extrn   flm_spr_data2: dword
extrn   flm_spr_data3: dword

extrn   ship_spr_data: dword
extrn	item_spr_data1 : dword
extrn	item_spr_data2 : dword
extrn	item_spr_data3 : dword
extrn	item_spr_data4 : dword
extrn	item_spr_data5 : dword
extrn	item_spr_data6 : dword
extrn	ien_spr_data : dword
extrn	isld_spr_data : dword
extrn	panback
extrn	wnumback
extrn	wnumber_spr : dword
extrn	snumback
extrn	snumber_spr : dword
extrn	player_no_spr

eye_x   dw      COPX    ;1024 observer's coordinates
eye_y   dw      -100                    ;
eye_z   dw      0                       ;
eye_th  dw      0                       ;observer's viewing direction
d_th    dw      64                      ;observer's moving direction
dif     dw      0                       ;forward moving
pers    dw      128                     ;word perspective factor

th      dw      0

xxx     dw      0
yyy     dw      0
zzz     dw      0

align 4
persd   dd      128                     ;dword perspective factor
;
;----------------------------------------------
XD      dd      32
YD      dd      25

xxxx    dd      0
yyyy    dd      0
zzzz    dd      0
dii     dd      80*25

xl      dd      0                       ; for cliping
xr      dd      0                       ;
ya      dd      0                       ;
yb      dd      0                       ;
					;
sx_start        dd      0               ;
sy_start        dd      0               ;
put_sprRT       dd      0               ;
;----------------------------------------------------
sx      dd      0
sy      dd      0
sxsy    dd      0
sxq     dd      0
sy80    dd      0

sxy     dd      0

ex1     dw      0
ex2     dw      0

zz      dw      0

rx      dw      0
ry      dw      0
rz      dw      0

x1      dw      0
y1      dw      0
z1      dw      0
x2      dw      0
y2      dw      0
z2      dw      0

align 4
xx_     dd      0
yy_     dd      0
zz_     dd      0

xa_     dd      0
ya_     dd      0
za_     dd      0

xa1_    dd      0
za1_    dd      0

xs_     dd      0
zs_     dd      0

lstart  dd      0
hdia    dd      0
xdd_    dd      0
ydd_    dd      0

ydd     dw      0
ydu     dw      0
y_d     dw      0
yinc    dw      0

plane   dd      11111111h
maps    db      0

align 2
sine    dw      0
cosine  dw      0

SIN     label   word
	include sintable.inc

PANNEL  label   word
	include pannel.inc

SYSPAL	label	byte
	include syspal.inc

passtry		dd	3
passinput	dd	0,0,0
passinputX	dd	0
passinputY	dd	0
passon		dd	0
passtable	label	byte
	include pass.inc

align 4

Menu    dd      0
oMenu   dd      1

_menu0  label   dword
	dd offset start0, offset help0, offset quit0

_menu1  label   dword
	dd offset start1, offset help1, offset quit1

start0  label   word
	dw	88,24
	db	88*24 dup(0)
;	include start0.spr
start1  label   word
	dw	88,24
	db	88*24 dup(0)
;	include start1.spr

help0   label   word
	dw	88,24
	db	88*24 dup(0)
;	include help0.spr
help1   label   word
	dw	88,24
	db	88*24 dup(0)
;	include help1.spr

quit0   label   word
	dw	88,24
	db	88*24 dup(0)
;	include quit0.spr
quit1   label   word
	dw	88,24
	db	88*24 dup(0)
;	include quit1.spr

enbar0  label   word
	include enbar0.spr
enbar   label   word
	include enbar.spr

sldbar0 label   word
	include sldbar0.spr
sldbar  label   word
	include sldbar.spr

align 4
GAMMA   label   dword
	dd      offset GAMMA1, offset GAMMA2, offset GAMMA3, offset GAMMA4
	dd      offset GAMMA5

gammano dd      0

GAMMA1  label   byte
	include gamma11.dat
GAMMA2  label   byte
	include gamma12.dat
GAMMA3  label   byte
	include gamma13.dat
GAMMA4  label   byte
	include gamma14.dat
GAMMA5  label   byte
	include gamma15.dat

maxobj          dd      10
maxobjdata      dd      10,10,9,12,10,7,10

boss_on		dd	0
obj_counter	dd	0

file_name00     db      "izmir.cfg", 0
file_name01     db      "config.dat", 0
PCX_name00      db      "menu.pcx",0
PCX_name01      db      "helpe.pcx",0
PCX_name02      db      "menuitem.pcx",0

file_name       dd      offset file_name11, offset file_name12
		dd      offset file_name13, offset file_name14
		dd      offset file_name15

		dd      offset file_name21, offset file_name22
		dd      offset file_name23, offset file_name24
		dd      offset file_name25

		dd      offset file_name31, offset file_name32
		dd      offset file_name33, offset file_name34
		dd      offset file_name35

		dd      offset file_name41, offset file_name42
		dd      offset file_name43, offset file_name44
		dd      offset file_name45

		dd      offset file_name51, offset file_name52
		dd      offset file_name53, offset file_name54
		dd      offset file_name55

		dd      offset file_name61, offset file_name62
		dd      offset file_name63, offset file_name64
		dd      offset file_name65

		dd      offset file_name71, offset file_name72
		dd      offset file_name73, offset file_name74
		dd      offset file_name75

file_name11     db      "texmap1.bod", 0
file_name12     db      "enmap1.bod", 0
file_name13     db      "object1.bod", 0
file_name14     db      "st1.pal", 0
file_name15     db      "back1.bod", 0

file_name21     db      "texmap2.bod", 0
file_name22     db      "enmap2.bod", 0
file_name23     db      "object2.bod", 0
file_name24     db      "st2.pal", 0
file_name25     db      "back2.bod", 0

file_name31     db      "texmap3.bod", 0
file_name32     db      "enmap3.bod", 0
file_name33     db      "object3.bod", 0
file_name34     db      "st3.pal", 0
file_name35     db      "back3.bod", 0

file_name41     db      "texmap4.bod", 0
file_name42     db      "enmap4.bod", 0
file_name43     db      "object4.bod", 0
file_name44     db      "st4.pal", 0
file_name45     db      "back4.bod", 0

file_name51     db      "texmap5.bod", 0
file_name52     db      "enmap5.bod", 0
file_name53     db      "object5.bod", 0
file_name54     db      "st5.pal", 0
file_name55     db      "back5.bod", 0

file_name61     db      "texmap6.bod", 0
file_name62     db      "enmap6.bod", 0
file_name63     db      "object6.bod", 0
file_name64     db      "st6.pal", 0
file_name65     db      "back6.bod", 0

file_name71     db      "endmap.bod", 0
file_name72     db      "enmap7.bod", 0
file_name73     db      "nameobj.bod", 0
file_name74     db      "end.pal", 0
file_name75     db      "back7.bod", 0

message00       db      "Press any key to start..$"
message01       db      "File loading error..$"

align 4
cops_x          dw      160 - 20
cops_y          dw      104
cops_dx         dw      0
cops_dy         dw      0
copstat         dd      0
Ocops_energy    dd      0
cops_energy     dd      15
cops_wepon      dd      0
wepon_energy    dd      999,200,  0,  0,  0, 0, 0, 0
energy_add	dd	999,200,150,100, 30, 0, 0, 0
cops_spr_no     dd      0
Oshield         dd      0
shield          dd      0
wnumber		dd	0,0,0
score		dd	0
snumber    	dd      0,0,0,0, 0,0,0,0
cops_on		dd	COPSON
enddelay	dd	DELAY
godmode		dd	OFF
RedOut          db      0
BlueOut         db      0

align	4
;-----------------------------------------------------------------------
beam_type       object  <100, 0, 0, 0,,,,,,, 0,  800, 0, 1, 0,  0, offset beam_spr_data3, offset beam_course, 0, 1,0,0>
		object  <101, 0, 0, 0,,,,,,, 0,  800, 0, 2, 0,  0, offset beam_spr_data2, offset beam_course, 0, 1,0,0>
		object  <102, 0, 0, 0,,,,,,, 0,  800, 0, 3, 0, 64, offset gcl_spr_data, offset gcl_course, 0, 0,0,0>
		object  <103, 0, 0, 0,,,,,,, 0,  700, 0, 2, 0, 64, offset valk_spr_data, offset valk_course, 0, 0,0,0>
		object  <104, 0, 0, 0,,,,,,, 0,  800, 0, 4, 0, 64, offset bigf_spr_data, offset bigf_course, 0, 1,0,0>

flm_type        object  <200, 0, 0, 0,,,,,,, 0, 2500, 0, 0, 0, 128, offset flm_spr_data, 0, 0, 1, 0, 0>
		object  <201, 0, 0, 0,,,,,,, 0, 2500, 0, 0, 0, 128, offset flm_spr_data2, 0, 0, 1, 0, 0>
		object  <202, 0, 0, 0,,,,,,, 0, 2500, 0, 0, 0, 128, offset flm_spr_data3, 0, 0, 1, 0, 0>

bullet_type     object  <300, 0, 0, 0,,,,,,, 0, 1000, 0, 1, 0, 64, offset bullet_spr_data1, 0, 0, 1,0,0>
		object  <301, 0, 0, 0,,,,,,, 0, 1000, 0, 2, 0, 64, offset bullet_spr_data2, 0, 0, 1,0,0>

ship            object  <400, 0, -400, 150,,,,,,, 0, 2500, 0, 2, 0, 128, offset ship_spr_data, offset ship_course, 0, 1, 0, 0>

item_type       object  <500, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data1, offset item_course, 0, 0, 0, 0>
		object  <501, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data2, offset item_course, 0, 0, 0, 0>
		object  <502, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data4, offset item_course, 0, 0, 0, 0>
		object  <503, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data3, offset item_course, 0, 0, 0, 0>
		object  <504, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data5, offset item_course, 0, 0, 0, 0>
		object  <505, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset item_spr_data6, offset item_course, 0, 0, 0, 0>
		object  <506, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset ien_spr_data, offset item_course, 0, 0, 0, 0>
		object  <507, 0, 0, 0,,,,,,, 0, 2500, 0, 1,  0, 64, offset isld_spr_data, offset item_course, 0, 0, 0, 0>

beam_course     label   word
	dw 202,1+256, 202,3+256, 202,4+256, 202,5+256, 202,6+256
	dw _GOTO
	dd beam_course

valk_course     label   word
	dw 0,0,0,50, 1,5,5,50, 2,10,10,50, 3,5,5,50
	dw 0,0,0,50, 1,-5,-5,50, 2,-10,-10,50, 3,-5,-5,50
	dw _GOTO
	dd valk_course

gcl_course      label   word
	dw 0,0,0,45, 1,0,5,40, 2,0,10,35, 1,0,15,30
ddown:  dw 2,0,20,20
	dw 231,0
	dd ddown, conti2, conti1
conti1: dw 203,0                        ; Y set 0
conti2: dw 1,0,0,30
	dw 202,3, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8
	dw 3,0,0,45, 202,4, 202,5, 202,6, 202,7, 202,8, -1

bigf_course     label   word
	dw 0,0,0,50
	dw 202,1, 202,2, 202,3, 202,4
	dw 232,500
	dd bigf_course,bigf_course,bloom
bloom:
	dw 202,5, 202,6, 202,7, 202,8, 202,9, 202,10
	dw 202,11, 202,12, 202,13, 202,14, 202,15, 202,16, -1

ship_course	label	word
	dw 0,0,0,60
	dw 0,0,0,60
	dw 200,6
	dw 0,0,0,60
	dw 0,0,0,60
	dw 0,0,0,60
	dw 1,0,5,60
	dw 1,0,5,60
	dw 1,0,10,60
	dw 1,0,10,60
	dw 1,0,10,60
	dw 2,0,10,60
rept:
	dw 2,0,0,60
	dw 232,1200
	dd rept,itemgo,itemgo
itemgo:
	dw 2,0,0,60
	dw 206,6
	dw 2,0,0,60
	dw 2,0,0,60
	dw 2,0,0,60
	dw 206,7
	dw 2,0,0,60
	dw 2,0,0,60
	dw 2,0,0,60, -1

item_course	label	word
	dw 0,0,15,0
	dw 202,1, 202,2
	dw 231,0
	dd item_course,icont2,icont1
icont1: dw 203,0

icont2: dw 0,0,0,0, 202,1, 202,2
	dw _GOTO
	dd icont2
;-----------------------------------------------------------------------


;--------------------------------------------------------------------
align 4

hline   dd      hline1
hlrtno  dd      0
hline_routine   dd  hline1, hline2, hline3

iix     dw      40
iiy     dw      40

CourseRoutine   label dword
	dd      cos200, cos201, cos202, cos203, cos204, cos205, cos206, cos207, cos208, cos209
	dd      cos210, cos211, cos212, cos213, cos214, cos215, cos216, cos217, cos218, cos219
	dd      cos220, cos221, cos222, cos223, cos224, cos225, cos226, cos227, cos228, cos229
	dd      cos230, cos231, cos232, cos233, cos234, cos235, cos236, cos237, cos238, cos239

item_routine	label	dword
	dd	item505, item506, item507

_DATA   ends


;-----------------------------------------------------------------------
_BSS    segment dword public use32 'BSS'

public	pcx_buffer0
public  _vptr
public  _l
public  keyboard

_vptr   dd      0,0,0,0,0,0,0,0,0,0,0,0,0
_l      dw      0,0,0,0,0,0,0,0,0,0,0,0,0

Jxmask	db	?		; joystick mask
Jymask	db	?
Jbtn1	db	?
Jbtn2	db	?

JLTH	dw	?               ; joystick theres
JRTH	dw	?
JUTH	dw	?
JDTH	dw	?

Pal     label   byte
	db      768 dup(?)

Paltmp  label   byte
	db 768 dup(?)

Paltmp2 label   byte
	db 768 dup(?)

Tstart  dw      ?, ?                    ;clock ticks of start time
Tend    dw      ?, ?                    ;clock ticks of end time
frames  dd      ?                       ;
fps     db      ?, ?                    ;frames per second

esc_on		db	?
pass_ok		db	?
player_no	db	?

align 4
VertRetrace	dd	?
DelayTime	dd	?
stage_no        dd      ?               ;
stage_flag      dd      ?		;DEAD

StartOffset     dd      ?               ;visual page
PageOffset      dd      ?               ;active page

tangent dd      200 dup(?)

int09seg        dw      ?
int09off        dd      ?

key_hit         db      ?
keyboard        db      128 dup (?)
key_edge        db      128 dup (?)

config	cfgstru	< >

;--------------------------------------------------------------
align 4
obj_ptr         dd      OBJNO dup(?)

;  64 offset

obj_table       label
beam    object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >

enemy   object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >
	object  < >

blt     object  < >
	object  < >
	object  < >
	object  < >
	object  < >

flm     object  < >
	object  < >
	object  < >
	object  < >
	object  < >

SqrTable        dd      10000 dup(?)

sqr1    dd      ?
sqr2    dd      ?
sqr3    dd      ?
aimx    dd      ?
aimy    dd      ?
aimz    dd      ?

seed	dd	?

_blx    dw      ?
_bly    dw      ?

_flmx   dw      ?
_flmy   dw      ?

TEXTBL  label   dword
	dd      23 dup(?)
TEXMAP  label   dword
	dd      16*128 dup(?)
TEX1    label   byte
SKY     label   byte
	db      TEXMAPLEN - ((16*128)+23)*4 dup (?)

ENMAP   label   dword
	db      ENMAPLEN dup(?)
ENMAPOFF        dd      ENMAPLEN
OldENMAP        dd      ?

OBJ_DATA        label
enemy_type      label   word
	db      OBJDATLEN dup(?)

back_spr_data   label
	db      BACKDATLEN dup(?)

pcx_buffer0:
	db      65536 dup(?)

pcx_buffer1:
	dw      ?,?
	db      65536 dup(?)

_BSS    ends

;-----------------------------------------------------------
;-----------------------------------------------------------
; Code segment
;
;-----------------------------------------------------------
_TEXT   segment use32 dword public 'CODE'
	assume  cs:_TEXT,ds:DGROUP,es:DGROUP

public	xmode

extrn   sayPCM_        	:near
extrn   SBLAutoDetect_ 	:near
extrn   initVoice_     	:near
extrn   setSampleRate_ 	:near
extrn   waitmSec_      	:near

extrn	SET_SYX	  	:near
extrn	STAGE_MUSIC    	:near
extrn	MENU_MUSIC     	:near
extrn	OVER_MUSIC     	:near
extrn	END_MUSIC      	:near
extrn	OPENING        	:near
extrn	PLAY_MUSIC      :near
extrn	STOP_MUSIC      :near
extrn	SETTIME      	:near
extrn	INTTIME     	:near
extrn	INTERVIZ     	:near

;------------------------------------------
; esi : filemame
; edi : pointer
; ecx : file length
;------------------------------------------
load_file       proc

	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,esi
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     edx,edi
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h

	ret

@@error:
	mov     ah,09h
	mov     edx,offset message01   ; "file loading error.."
	int     21h

	ret

load_file       endp

;------------------------------------------
; load map
;------------------------------------------
load_map       proc

	mov     esi,stage_no
	imul    esi,20

;PAL--------------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,file_name[esi + 12]  ; palette
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,768
	mov     edx,offset Pal       ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h


;ENMAP--------------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,file_name[esi + 4]
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,ENMAPLEN
	mov     edx,offset ENMAP       ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h

;;	cmp	stage_no,2		; password chk
;;	jl	@@skipchk
;;	cmp	pass_ok,1
;;	jne	@@error
@@skipchk:

;OBJ----------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,file_name[esi + 8]
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,OBJDATLEN
	mov     edx,offset OBJ_DATA      ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h

;BACK----------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,file_name[esi + 16]
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,BACKDATLEN
	mov     edx,offset back_spr_data      ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h

;TEXMAP---------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,file_name[esi]
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,TEXMAPLEN
	mov     edx,offset TEXTBL       ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h

; texture map table init.
	mov     ebx,offset TEXTBL
	mov     edi,offset TEXTBL
	mov     ecx,23
@@next1:
	add     dword ptr[edi],ebx
	add     edi,4
	loop    @@next1

	mov     ebx,offset TEXTBL
	mov     edi,offset TEXMAP
	mov     ecx,16*128
@@next2:
	mov     edx,dword ptr[edi]
	mov     eax,dword ptr[ebx][edx*4]
	mov     dword ptr[edi],eax
	add     edi,4
	loop    @@next2

	mov	esi,offset SYSPAL
	mov	edi,offset Pal
	mov	ecx,76*3
	rep	movsb

@@error:
	ret

load_map       endp

;------------------------------------------
;
;------------------------------------------
load_cfg        proc

	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,OFFSET file_name00  ; "izmir.cfg"
	int     21h
	jc      @@error

	mov     bx,ax                   ; file handle
	mov     ah,3fh
	mov     ecx,4
	mov     edx,offset gammano      ; read file
	int     21h
	jc      @@error

	mov     ah,3fh
	mov     ecx,4
	mov     edx,offset DelayTime    ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h
	;------------------
	mov     ah,3dh                  ; open file
	mov     al,0                    ; read only
	mov     edx,OFFSET file_name01  ; "config.dat"
	int     21h
	jc      @@error

	mov     bx,ax                  ; file handle
	mov     ah,3fh
	mov     ecx,27                 ; 27 bytes
	mov     edx,offset config      ; read file
	int     21h
	jc      @@error

	mov     ah,3eh                  ; close
	int     21h
@@error:
	ret

load_cfg        endp

;------------------------------------------
; save izmir.cfg file
;------------------------------------------
save_cfg        proc

@@open:
	mov     ah,3dh                  ; open file
	mov     al,1                    ; write only
	mov     edx,OFFSET file_name00
	int     21h
	jc      @@openerror

	mov     bx,ax                   ; file handle
	mov     ah,40h
	mov     ecx,4
	mov     edx,offset gammano      ; write file
	int     21h
	jc      @@writeerror

	mov     ah,40h
	mov     ecx,4
	mov     edx,offset DelayTime      ; write file
	int     21h
	jc      @@writeerror
	jmp     @@out

@@openerror:
	mov     ah,3ch                  ; create file
	mov     cx,0                    ; write only
	mov     edx,OFFSET file_name00
	int     21h
	jc      @@out

	jmp     @@open
@@writeerror:
@@out:
	mov     ah,3eh                  ; close
	int     21h

	ret

save_cfg        endp

;-------------------------------------
; esi : file name ( no header )
;-------------------------------------
load_put_PCX    proc

loading:
	mov     edi,offset pcx_buffer0
	mov     ecx,64000
	call    load_file
encoding:
	mov     esi,offset pcx_buffer0
	add	esi,128;;;;;;;;;;;;;;;;;;;;;;;;; skip PCX header
	mov     edi,4
@@next:
	mov     al,[esi]
	cmp     al,0C0h
	jbe     @@norpt
	and     al,3Fh
	movzx   cx,al
	movzx   ecx,cx
	inc     esi
	mov     al,[esi]
@@rpt:
	mov     byte ptr pcx_buffer1[edi],al
	inc     edi
	loop    @@rpt
	jmp     @@chk
@@norpt:
	mov     byte ptr pcx_buffer1[edi],al
	inc     edi
@@chk:
	inc     esi
	cmp     edi,64004
	jb      @@next
;;;-------
	mov     edi,offset Pal
	mov     ecx,768
	inc     esi
@@nextp:
	mov     al,[esi]
	shr     al,2
	mov     [edi],al
	inc     esi
	inc     edi
	loop    @@nextp
;;;------------
	mov     esi,offset Pal
	call    set_palette

	mov     ebx,gammano
	sub     ebx,1
	jc	@@skipg
	mov     edx,GAMMA[ebx * 4]
	call    gamma_correction
	jmp	SHORT putPCX
@@skipg:
	call	init_palette
putPCX:
	mov     word ptr [pcx_buffer1],320
	mov     word ptr [pcx_buffer1+2],200
	mov     esi,offset pcx_buffer1
	mov     eax,0
	mov     edx,0
	call    put_spr

	ret

load_put_PCX    endp

;-------------------------------------
; esi : file name ( no header )
;-------------------------------------
load_put_SPR    proc

;loading:
	mov     edi,offset pcx_buffer0
	mov     ecx,64000
	call    load_file
;encoding:
	mov     esi,offset pcx_buffer0
	add	esi,128;;;;;;;;;;;;;;;;;;;;;;;;; skip PCX head
	mov     edi,4  ;;;;;;;;;;;;;;;;;;;;;;;;;
@@next:
	mov     al,[esi]
	cmp     al,0C0h
	jbe     @@norpt
	and     al,3Fh
	movzx   cx,al
	movzx   ecx,cx
	inc     esi
	mov     al,[esi]
@@rpt:
	mov     byte ptr pcx_buffer1[edi],al
	inc     edi
	loop    @@rpt
	jmp     @@chk
@@norpt:
	mov     byte ptr pcx_buffer1[edi],al
	inc     edi
@@chk:
	inc     esi
	cmp     edi,64004
	jb      @@next
;;;-------
	mov     edi,offset Pal
	mov     ecx,768
	inc     esi
@@nextp:
	mov     al,[esi]
	shr     al,2
	mov     [edi],al
	inc     esi
	inc     edi
	loop    @@nextp
;;;------------
putSPR:
	mov	esi,offset pcx_buffer1
	add	esi,4
	mov	edi,offset start1
	add	edi,4

	mov	ecx,24
@@nextl1:
	push	ecx
	mov	ecx,88
@@nextb1:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb1
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl1
;;;;
	mov	esi,offset pcx_buffer1
	add	esi,4 + 88
	mov	edi,offset start0
	add	edi,4

	mov	ecx,24
@@nextl11:
	push	ecx
	mov	ecx,88
@@nextb11:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb11
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl11
;-----------------------------------------
	mov	esi,offset pcx_buffer1
	add	esi,4 + 24*320
	mov	edi,offset help1
	add	edi,4

	mov	ecx,24
@@nextl2:
	push	ecx
	mov	ecx,88
@@nextb2:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb2
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl2
;;;;
	mov	esi,offset pcx_buffer1
	add	esi,4 + 24*320 + 88
	mov	edi,offset help0
	add	edi,4

	mov	ecx,24
@@nextl22:
	push	ecx
	mov	ecx,88
@@nextb22:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb22
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl22
;--------------------------------------------
	mov	esi,offset pcx_buffer1
	add	esi,4 + 2*(24*320)
	mov	edi,offset quit1
	add	edi,4

	mov	ecx,24
@@nextl3:
	push	ecx
	mov	ecx,88
@@nextb3:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb3
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl3
;;;;
	mov	esi,offset pcx_buffer1
	add	esi,4 + 2*(24*320) + 88
	mov	edi,offset quit0
	add	edi,4

	mov	ecx,24
@@nextl33:
	push	ecx
	mov	ecx,88
@@nextb33:
	mov	al,byte ptr[esi]
	mov	byte ptr[edi],al
	inc	esi
	inc	edi
	loop	@@nextb33
	add	esi,320 - 88

	pop	ecx
	loop	@@nextl33

	ret

load_put_SPR    endp

;--------------------------------------
; ax: random number range ( 0 ... N-1 )
;--------------------------------------
rand    proc

	push	edx
	push	ebx

	mov	bx,ax

	mov     eax,1107030247
	mul     seed
	add     eax,97177
	mov     seed,eax
	shr     eax,15
	xor	dx,dx
	div	bx
	mov	ax,dx

	pop	ebx
	pop	edx

	ret

rand    endp

;---------------------------
; set palette registers
; esi : palette offset
;---------------------------
set_palette      proc   near

;       lea     esi,Pal                 ; Pal : palette data
	mov     al,0                    ;
	mov     dx,3c8h                 ; I/O port of palette reg
	out     dx,al                   ; 0 - 255
	mov     dx,3c9h                 ;
	mov     ecx,768                 ; RGB * 256
@invid: lodsb
	out     dx,al
	loop    @invid
	ret
set_palette      endp

;----------------------------------
;       SCREEN OFF
;----------------------------------
screen_off	proc
	CLI
	MOV     AL,1
	MOV     DX,03C4H
	OUT     DX,AL
	INC     DX
	IN      AL,DX
	OR      AL,20H
	OUT     DX,AL
	STI
	RET
screen_off	endp

;---------------------------
;       SCREEN ON
;---------------------------
screen_on	proc

	CLI
	MOV     AL,1
	MOV     DX,03C4H
	OUT     DX,AL
	INC     DX
	IN      AL,DX
	AND     AL,0DFH
	OUT     DX,AL
	STI
	RET

screen_on	endp

;-------------------------------------------
;
;-------------------------------------------
MakeSqrTable    proc    near

	mov     ecx,0
@@next:
	mov     eax,ecx
	mov     ebx,ecx
	mul     ebx
	mov     SqrTable[ecx*4],eax
	inc     ecx
	cmp     ecx,10000
	jb      SHORT @@next

	ret

MakeSqrTable    endp

;-------------------------------
;
;-------------------------------
FindSqrt_       proc

	push    ebx
	push    edx
	push    esi
	push    edi

	mov     edx,5000
	mov     esi,0
	mov     edi,9999
@@sss:
	cmp     eax,SqrTable[edx*4]
	je      SHORT @@out
	ja      SHORT @@aaa
	jb      SHORT @@bbb
@@aaa:
	mov     esi,edx
	mov     ebx,edi
	sub     ebx,esi
	shr     ebx,1
	jz      SHORT @@out
	add     edx,ebx

	jmp     SHORT @@sss
@@bbb:
	mov     edi,edx
	mov     ebx,edi
	sub     ebx,esi
	shr     ebx,1
	jz      SHORT @@out
	sub     edx,ebx

	jmp     SHORT @@sss
@@out:
	mov     eax,edx

	pop     edi
	pop     esi
	pop     edx
	pop     ebx

	ret
FindSqrt_       endp

;---------------------------
;  initialize PALETTE TABLE
;---------------------------
init_palette    proc

	mov     esi,offset Pal
	mov     edi,offset Paltmp

	cld
	mov     ecx,768/4
	rep     movsd

	ret

init_palette    endp

;---------------------------
; set board palette
;---------------------------
set_board       proc   near

	cmp     copstat,2
	jne     @@zero
	mov     al,0                    ;
	mov     dx,3c8h                 ; I/O port of palette reg
	out     dx,al                   ; 0
	mov     dx,3c9h                 ;
	mov     al,63
	out     dx,al
	mov     al,0
	out     dx,al
	out     dx,al
	ret
@@zero:
	mov     al,0                    ;
	mov     dx,3c8h                 ; I/O port of palette reg
	out     dx,al                   ; 0
	mov     dx,3c9h                 ;
	xor     al,al
	out     dx,al
	out     dx,al
	out     dx,al
	ret
set_board       endp

;---------------------------
;  edx : GAMMA
;---------------------------
gamma_correction        proc

	mov     esi,offset Pal
	mov     edi,offset Paltmp

	mov     ecx,768
@@npal:
	xor     ebx,ebx
	mov     bl,byte ptr[esi]
	movzx   bx,bl
	mov     al,[edx][ebx]
	mov     byte ptr[edi],al

	inc     esi
	inc     edi

	loop    @@npal

	mov     esi,offset Paltmp
	call    set_palette

	ret

gamma_correction        endp

;---------------------------
;  RED OUT
;---------------------------
turn2red        proc

	cmp     copstat,2
	jne     @@nzero

	cmp     RedOut,1
	je      @@out

	mov     RedOut,1
	mov     esi,offset Paltmp
	mov     edi,offset Paltmp2

	xor     eax,eax
	cld
	mov     ecx,768/4
	rep     stosd

	mov     edi,offset Paltmp2

	xor	eax,eax			; RED
	add     esi,eax
	add     edi,eax
	mov     ecx,768/3
@@next:
	mov     al,[esi]
	mov     [edi],al
	add     esi,3
	add     edi,3

	loop    @@next

	mov     esi,offset Paltmp2
	call    set_palette
	ret
@@nzero:
	cmp     RedOut,0
	je      SHORT @@out

	mov     RedOut,0
	mov     esi,offset Paltmp
	call    set_palette
@@out:
	ret
turn2red        endp

;---------------------------
;  blue OUT
;---------------------------
turn2blue        proc

	cmp     copstat,9
	jne     @@nzero

	cmp     BlueOut,1
	je      @@out

	mov     BlueOut,1
	mov     esi,offset Paltmp
	mov     edi,offset Paltmp2

	xor     eax,eax
	cld
	mov     ecx,768/4
	rep     stosd

	mov     edi,offset Paltmp2

	mov	eax,2			; BLUE
	add     esi,eax
	add     edi,eax
	mov     ecx,768/3
@@next:
	mov     al,[esi]
	mov     [edi],al
	add     esi,3
	add     edi,3

	loop    @@next

	mov     esi,offset Paltmp2
	call    set_palette
	ret
@@nzero:
	cmp     BlueOut,0
	je      SHORT @@out

	mov     BlueOut,0
	mov     esi,offset Paltmp
	call    set_palette
@@out:
	ret
turn2blue        endp

;------------------------
; 13h plane mode
;------------------------
xmode   PROC

	mov     ax,13h                  ; BIOS call
	int     10h                     ; Ordinary 320 x 200 MCGA
	mov     dx,SC_INDEX             ; Sequencer controller
	mov     ax,0604h                ; 0110b  index 4  Memory mode reg.
	out     dx,ax                   ; |__________ chain 4 bit 0

	mov     dx,SC_INDEX             ;
	mov     ax,0f02h                ; 1111b  index 2  Map mask reg
	out     dx,ax
	mov     edi,SCREEN_OFF          ;
	xor     eax,eax                 ;
	mov     ecx,4000h               ;
	rep     stosd                   ; clean the screen

	mov     dx,CRTC_INDEX           ; CRT controller
	mov     ax,0014h                ; index 14 Underline Location reg.
	out     dx,ax                   ; double word mode bit 0
	mov     ax,0E317h               ; index 17 Mode Control reg.
	out     dx,ax                   ; word/byte mode bit 1 (byte mode)
	ret

xmode   ENDP

;------------------------------------
; wait for start of vertical retrace
;------------------------------------
wait_vrt       PROC

	push    ax
	push    dx

	mov     dx,3dah
@@wvrt1:
	in      al,dx
	test    al,8
	je     @@wvrt1
@@wvrt2:
	in      al,dx
	test    al,8
	jne     @@wvrt2

	pop     dx
	pop     ax

	ret

wait_vrt        ENDP

;--------------------------------
; clean active Page (not visual)
;--------------------------------
clean   PROC
	push    es

	mov     ax,ds
	mov     es,ax

	mov     dx,SC_INDEX
	mov     ax,0f02h
	out     dx,ax

	mov     edi,SCREEN_OFF
	add     edi,PageOffset

	cld
	xor     eax,eax
	mov     ecx,1000h
	rep     stosd

	pop     es

	ret

clean   ENDP

;-------------------------------------------
; clean active Page (not visual) with color
; eax : color
;-------------------------------------------
cleanC  PROC
	push    es
	push	ds
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi

	mov	ebx,eax

	mov     ax,ds
	mov     es,ax

	mov     dx,SC_INDEX
	mov     ax,0f02h
	out     dx,ax

	mov     edi,SCREEN_OFF
	add     edi,PageOffset

	mov	eax,ebx
	shl     eax,8
	or	eax,ebx
	shl	eax,8
	or	eax,ebx
	shl	eax,8
	or	eax,ebx

	cld
	mov     ecx,1000h
	rep     stosd

	pop	edi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	pop	ds
	pop     es

	ret

cleanC  ENDP

set_startP      proc

	push    bx
	push    cx
	push    dx
	push    ax

	mov     bl,START_ADDRESS_LOW
	mov     bh,Byte ptr [StartOffset]
	mov     cl,START_ADDRESS_HIGH
	mov     ch,Byte ptr [StartOffset+1]
	mov     dx,CRTC_INDEX
	mov     ax,bx
	out     dx,ax
	mov     ax,cx
	out     dx,ax

	pop     ax
	pop     dx
	pop     cx
	pop     bx

	ret

set_startP      endp

;------------------------
; Page flip
;------------------------
showp   PROC

	push    bx
	push    cx
	push    dx
	push    ax

	mov     bl,START_ADDRESS_LOW
	mov     bh,Byte ptr [StartOffset]
	mov     cl,START_ADDRESS_HIGH
	mov     ch,Byte ptr [StartOffset+1]
	mov     dx,CRTC_INDEX
	mov     ax,bx
	out     dx,ax
	mov     ax,cx
	out     dx,ax

	cmp     PageOffset,0
	jne     @@Page0
	mov     PageOffset,4000h
	mov     StartOffset,4000h
	pop     ax
	pop     dx
	pop     cx
	pop     bx
	ret
@@Page0:
	mov     PageOffset,0
	mov     StartOffset,0
	pop     ax
	pop     dx
	pop     cx
	pop     bx
	ret

showp   ENDP

;----------------------------------
; cops sprite initial
;----------------------------------
copspr  PROC

	mov     eax,48
	mov     sx,eax
	shr     eax,2
	mov     sxq,eax

	mov     eax,47
	mov     sy,eax
	mul     sx
	mov     sxsy,eax

	mov     eax,80
	mul     sy
	mov     sy80,eax

	ret

copspr  ENDP

panspr  PROC

	mov     eax,320
	mov     sx,eax
	shr     eax,2
	mov     sxq,eax

	mov     eax,50
	mov     sy,eax
	mul     sx
	mov     sxsy,eax

	mov     eax,80
	mul     sy
	mov     sy80,eax

	ret

panspr  ENDP

;--------------------------------------
; put sprite
; esi, eax, edx
;--------------------------------------
put_sprP        PROC

;       movzx   eax,word ptr[esi]
;       mov     sx,eax
;       shr     eax,2
;       mov     sxq,eax

;       movzx   eax,word ptr[esi+2]
;       mov     sy,eax
;       mul     sx
;       mov     sxsy,eax

;       mov     eax,80
;       mul     sy
;       mov     sy80,eax

	mov     maps,11h
	mov     ecx,eax
	and     ecx,3
	rol     maps,cl

	shr     eax,2                   ; 3  X / 4
	lea     edx,[edx * 8]           ; 2  Y * 8
	lea     edx,[edx * 2]           ; 2  Y * 8 * 2
	lea     edx,[edx * 4][edx]      ; 2  Y * 8 * 2 * 5
	add     eax,edx                 ; 2  X / 4 + Y * 80
					; total 11 clock

	mov     edi,eax
	add     edi,SCREEN_OFF          ;Calculate Init Pixel on dest.
	add     edi,PageOffset          ;
	mov     lstart,edi

	mov     dx,SC_INDEX             ;Let's prepare SC_INDEX
	mov     al,MAP_MASK             ;For the MAP_MASK
	out     dx,al                   ;.....

	xor     ebp,ebp

	mov     ecx,4
@@nextp: ; 4-planes loop
	mov     dx,SC_INDEX+1           ;set Map Mask reg.
	mov     al,maps                 ;
	out     dx,al                   ;

	xor     ebx,ebx
	add     ebx,ebp

	mov     edi,lstart

	push    ecx
	mov     ecx,sxq
@@x:    ; X-offset loop

	push    ecx
	mov     ecx,sy
@@y:    ; Y-offset loop

	mov     al,byte ptr[esi+ebx+4]
	cmp     al,0
	jz      SHORT @@skip0
	mov     byte ptr[edi],al
@@skip0:
	add     ebx,sx
	add     edi,80
	loop    @@y

	sub     ebx,sxsy
	add     ebx,4
	sub     edi,sy80
	add     edi,1

	pop     ecx
	loop    @@x

	rol     maps,1
	adc     lstart,0
	add     ebp,1
	pop     ecx
	loop    @@nextp

;;;;;-------------------
	mov     ecx,sx
	and     ecx,3
	jz      @@here
@@x1:
	mov     al,maps                 ;
	out     dx,al                   ;

	push    ecx
	mov     ecx,sy
@@y1:    ; Y-offset loop

	mov     al,byte ptr[esi+ebx+4]
	cmp     al,0
	jz      SHORT @@skip00
	mov     byte ptr[edi],al
@@skip00:
	add     ebx,sx
	add     edi,80
	loop    @@y1

	sub     ebx,sxsy
	add     ebx,1
	sub     edi,sy80

	rol     maps,1
	adc     edi,0

	pop     ecx
	loop    @@x1
@@here:
	ret
put_sprP        ENDP

;--------------------------------------
; put sprite
; esi : sprite
; eax, edx : X, Y
;--------------------------------------
put_spr PROC

	push    eax
	push    ecx
	push    edx

	mov     maps,11h
	mov     ecx,eax
	and     ecx,3
	rol     maps,cl

	shr     eax,2                   ; 3  X / 4
	lea     edx,[edx * 8]           ; 2  Y * 8
	lea     edx,[edx * 2]           ; 2  Y * 8 * 2
	lea     edx,[edx * 4][edx]      ; 2  Y * 8 * 2 * 5
	add     eax,edx                 ; 2  X / 4 + Y * 80
					; total 11 clock

	mov     edi,eax
	add     edi,SCREEN_OFF          ;Calculate Init Pixel on dest.
	add     edi,PageOffset          ;
	mov     lstart,edi

	movzx   eax,word ptr[esi]       ;sx
	mov     sx,eax                  ;
	shr     eax,2                   ;
	mov     sxq,eax                 ;sxq = sx / 4

	movzx   eax,word ptr[esi+2]     ;sy
	mov     sy,eax                  ;
	mul     sx                      ;
	mov     sxsy,eax                ;sxsy = sx * sy

	mov     eax,80                  ;
	mul     sy                      ;
	mov     sy80,eax                ;sy80 = sy * 80

	mov     dx,SC_INDEX             ;Let's prepare SC_INDEX
	mov     al,MAP_MASK             ;For the MAP_MASK
	out     dx,al                   ;.....

	xor     ebp,ebp

	cmp     sxq,0
	je      @@pppp

	mov     ecx,4
@@nextp: ; 4-planes loop
	mov     dx,SC_INDEX+1           ;set Map Mask reg.
	mov     al,maps                 ;
	out     dx,al                   ;

	xor     ebx,ebx
	add     ebx,ebp

	mov     edi,lstart

	push    ecx
	mov     ecx,sxq
@@x:    ; X-offset loop

	push    ecx
	mov     ecx,sy
@@y:    ; Y-offset loop

	mov     al,byte ptr[esi+ebx+4]
	cmp     al,0
	jz      SHORT @@skip0
	mov     byte ptr[edi],al
@@skip0:
	add     ebx,sx
	add     edi,80
	loop    @@y

	sub     ebx,sxsy
	add     ebx,4
	sub     edi,sy80
	add     edi,1

	pop     ecx
	loop    @@x

	rol     maps,1
	adc     lstart,0
	add     ebp,1
	pop     ecx
	loop    @@nextp

;;;;;-------------------
@@pppp:
	mov     ecx,sx
	and     ecx,3
	jz      SHORT @@here

	mov     ebx,sx
	sub     ebx,ecx

	ror     maps,1
	jc      SHORT @@noo
	sub     edi,1
@@noo:
	rol     maps,1

@@x1:
	mov     al,maps                 ;
	out     dx,al                   ;

	push    ecx
	mov     ecx,sy
@@y1:    ; Y-offset loop

	mov     al,byte ptr[esi+ebx+4]
	cmp     al,0
	jz      SHORT @@skip00
	mov     byte ptr[edi],al
@@skip00:
	add     ebx,sx
	add     edi,80
	loop    @@y1

	sub     ebx,sxsy
	add     ebx,1
	sub     edi,sy80

	rol     maps,1
	adc     edi,0

	pop     ecx
	loop    @@x1
@@here:
	pop     edx
	pop     ecx
	pop     eax
	ret

put_spr ENDP

;------------------------------------
;  Keep picture in PAGE 2
;------------------------------------
keep_pic        PROC

	mov     dx,SC_INDEX             ;Let's prepare SC_INDEX
	mov     al,MAP_MASK             ;For the MAP_MASK
	out     dx,al                   ;.....

	xor     ebp,ebp

	mov     bx,1
	mov     cx,4
@@nextp: ; 4-planes loop
	mov     dx,SC_INDEX+1           ;set Map Mask reg.
	mov     al,bl                   ;
	out     dx,al                   ;

	mov     esi,0
	add     esi,ebp

	mov     edi,SCREEN_OFF          ;Calculate Init Pixel on dest.
	add     edi,8000h               ; Page 2

	push    ecx
	mov     ecx,80
@@x:    ; X-offset loop

	push    ecx
	mov     ecx,79
@@y:    ; Y-offset loop

	mov     al,byte ptr back_spr_data[esi+4]
	mov     byte ptr[edi],al

	add     esi,320
	add     edi,80
	loop    @@y

	sub     esi,320*79
	add     esi,4
	sub     edi,80*79
	add     edi,1

	pop     ecx
	loop    @@x

	shl     bx,1
	add     ebp,1
	pop     ecx
	loop    @@nextp

	ret
keep_pic        ENDP

;---------------------------------------
; put picture
; si : source
; di : destination  di = x / 4 + y * 80
;---------------------------------------
put_pic PROC

	push    ds

	mov     dx,GRP_INDEX            ;graphic controller
	mov     ax,4105h                ;index 5 Mode reg.
	out     dx,ax                   ;256 color write mode 1

	mov     dx,SC_INDEX             ;SC_INDEX
	mov     ax,0f02h                ;For the MAP_MASK 1111b
	out     dx,ax                   ;all four planes enable

	mov     edi,SCREEN_OFF           ;Calculate Init Pixel on dest.
	add     edi,PageOffset           ;

	mov     esi,SCREEN_OFF           ;Calculate Init Pixel on source
	add     esi,8000h               ; Page 2

	cld

	mov     ecx,80*55               ;  (320/4) * 55
	rep     movsb

;       add     esi,80
;       add     edi,80

	mov     dx,GRP_INDEX            ;graphic controller
	mov     ax,4005h                ;index 5 Mode reg.
	out     dx,ax                   ;256 color write mode 0

	pop     ds

	ret

put_pic ENDP

;-----------------------------------
; put sprite scaling  : cliping
; esi :
; edi : mirror or not
; eax, edx, ebx :  x, y, z
; ecx : sfactor
;-----------------------------------
put_sprS        proc

	push    pers

	mov     xxxx,eax
	mov     yyyy,edx
	mov     zzzz,ebx

	mov     eax,offset put_sprS5
	cmp     di,0
	jnz     @@mirror1
	mov     eax,offset put_sprS6
@@mirror1:
	mov     put_sprRT,eax

	movsx   ebx,pers
	add     ebx,ecx
	mov     pers,bx

	mov     sx_start,0
	mov     sy_start,0

	movzx   eax,word ptr[esi]
	imul    ebx
	cdq
	idiv    zzzz
	mov     XD,eax
	cmp     eax,2
	jb      @@quit

	movzx   eax,word ptr[esi+2]
	imul    ebx
	cdq
	idiv    zzzz
	mov     YD,eax
	cmp     eax,2
	jb      @@quit

;       shr     eax,1
	sub     yyyy,eax

	mov     eax,XD
	shr     eax,1
	sub     xxxx,eax

	cmp     xxxx,RBOUND
	jg      @@quit

	mov     ebp,XD
	add     ebp,xxxx
	mov     xr,ebp

	cmp     xr,LBOUND
	jl      @@quit

	mov     ebp,YD
	add     ebp,yyyy
	mov     yb,ebp

	cmp     ebp,ABOUND
	jl      @@quit

	mov     eax,xxxx
	mov     xl,eax

	mov     edx,yyyy
	mov     ya,edx

	cmp     edx,BBOUND               ; yb > BBOUND
	jg      @@quit            ;

	movzx   eax,word ptr[esi]
	shl     eax,16
	cdq
	mov     ebx,XD
	div     ebx
	mov     xdd_,eax

	movzx   eax,word ptr[esi+2]
	shl     eax,16
	cdq
	mov     ebx,YD
	div     ebx
	mov     ydd_,eax

	mov     ydd,ax
	shr     eax,16
	mov     ydu,ax
	mul     word ptr[esi]
	mov     yinc,ax

;;---- cliping check ----------
@@xclip:                                ; clip right
	sub     xr,RBOUND
	jle     SHORT @@lclip
	mov     ebp,xr
	sub     XD,ebp
	inc     XD
@@lclip:                                ; clip left
	sub     xl,LBOUND
	jge     @@yclip
	mov     ebp,xl
	add     XD,ebp
	inc     XD
	neg     ebp
;       inc     ebp
	imul    ebp,xdd_
	mov     sx_start,ebp
	mov     xxxx,0

@@yclip:
	mov     eax,YD
	sub     yb,BBOUND               ; clip below
	jle     SHORT @@uclip           ;
	mov     ebp,yb
	sub     YD,ebp
	mov     eax,YD
	inc     YD
@@uclip:                                ; clip above
	sub     ya,ABOUND               ; yb <= BBOUND
	jge     @@noclip
	mov     YD,eax
	mov     ebp,ya
	add     YD,ebp
	inc     YD
	neg     ebp
	sub     ebp,1
	imul    ebp,ydd_
	shr     ebp,16
	movzx   ecx,word ptr[esi]
	imul    ebp,ecx
	mov     sy_start,ebp
	mov     yyyy,0

@@noclip:
	mov     eax,xxxx
	mov     edx,yyyy
	shr     eax,2                   ; 3  X / 4
	lea     edx,[edx * 8]           ; 2  Y * 8
	lea     edx,[edx * 2]           ; 2  Y * 8 * 2
	lea     edx,[edx * 4][edx]      ; 2  Y * 8 * 2 * 5
	add     eax,edx                 ; 2  X / 4 + Y * 80
					; total 11 clock
	mov     edi,eax
	add     edi,SCREEN_OFF           ;Calculate Init Pixel on dest.
	add     edi,PageOffset           ;

	mov     eax,YD
	lea     eax,[eax * 8]           ; dii = YD * 80
	lea     eax,[eax * 2]           ;
	lea     eax,[eax * 4][eax]      ;
	mov     dii,eax                 ;

	mov     maps,11h
	mov     ecx,xxxx                ; xxxx
	and     ecx,3
	rol     maps,cl

	call    [put_sprRT]

@@quit:
	pop     pers

	ret
put_sprS        endp

;-----------------------------------
; put sprite scaling  : CENTER
;
; esi : sprite image offset
; di : mirror or not
; eax, edx, ebx :  x, y, z
; ecx : scale
;-----------------------------------
put_sprSC       proc

	push    pers

	mov     xxxx,eax              ; screen X
	mov     yyyy,edx              ; screen Y
	mov     zzzz,ebx              ; Z

	mov     eax,offset put_sprS5
	cmp     di,0
	jnz     @@mirror1
	mov     eax,offset put_sprS6
@@mirror1:
	mov     put_sprRT,eax

	movsx   ebx,pers
	add     ebx,ecx
	mov     pers,bx

	mov     sx_start,0
	mov     sy_start,0

	movzx   eax,word ptr[esi]
	imul    ebx
	cdq
	idiv    zzzz
	mov     XD,eax
	cmp     eax,2
	jb      @@quit

	movzx   eax,word ptr[esi+2]
	imul    ebx
	cdq
	idiv    zzzz
	mov     YD,eax
	cmp     eax,2
	jb      @@quit

	shr     eax,1
	sub     yyyy,eax

	mov     eax,XD
	shr     eax,1
	sub     xxxx,eax

	mov     ebp,XD
	add     ebp,xxxx
	mov     xr,ebp

	cmp     xr,LBOUND
	jl      @@quit

	mov     ebp,YD
	add     ebp,yyyy
	mov     yb,ebp

	cmp     ebp,ABOUND
	jl      @@quit

	mov     eax,xxxx
	mov     xl,eax
	mov     edx,yyyy
	mov     ya,edx

	cmp     edx,BBOUND        ; yb > BBOUND
	jg      @@quit            ;

	movzx   eax,word ptr[esi]   ; image sx
	shl     eax,16
	cdq
	mov     ebx,XD
	div     ebx
	mov     xdd_,eax

	movzx   eax,word ptr[esi+2]  ; image sy
	shl     eax,16
	cdq
	mov     ebx,YD
	div     ebx
	mov     ydd_,eax
	mov     ydd,ax
	shr     eax,16
	mov     ydu,ax
	mul     word ptr[esi]
	mov     yinc,ax

@@xclip:
	sub     xr,RBOUND
	jle     SHORT @@lclip
	cmp     xl,RBOUND
	jg      @@quit
	mov     ebp,xr
	sub     XD,ebp
	inc     XD
@@lclip:
	sub     xl,LBOUND
	jge     @@yclip
	mov     ebp,xl
	add     XD,ebp
	inc     XD
	neg     ebp
;;;;    inc     ebp
	imul    ebp,xdd_
	mov     sx_start,ebp
	mov     xxxx,0

@@yclip:
	mov     eax,YD
	sub     yb,BBOUND
	jle     SHORT @@uclip           ;
	mov     ebp,yb
	sub     YD,ebp
	mov     eax,YD
	inc     YD
@@uclip:                                ; yb <= BBOUND
	sub     ya,ABOUND
	jge     @@noclip
	mov     YD,eax
	mov     ebp,ya
	add     YD,ebp
	inc     YD
	neg     ebp
	sub     ebp,1
	imul    ebp,ydd_
	shr     ebp,16
	movzx   ecx,word ptr[esi]
	imul    ebp,ecx
	mov     sy_start,ebp
	mov     yyyy,0

@@noclip:
	mov     eax,xxxx
	mov     edx,yyyy
	shr     eax,2                   ; 3  X / 4
	lea     edx,[edx * 8]           ; 2  Y * 8
	lea     edx,[edx * 2]           ; 2  Y * 8 * 2
	lea     edx,[edx * 4][edx]      ; 2  Y * 8 * 2 * 5
	add     eax,edx                 ; 2  X / 4 + Y * 80
					; total 11 clock
	mov     edi,eax
	add     edi,SCREEN_OFF           ;Calculate Init Pixel on dest.
	add     edi,PageOffset           ;

	mov     eax,YD
	lea     eax,[eax * 8]           ; dii = YD * 80
	lea     eax,[eax * 2]           ;
	lea     eax,[eax * 4][eax]      ;
	mov     dii,eax                 ;

	mov     maps,11h
	mov     ecx,xxxx                ; xxxx
	and     ecx,3
	rol     maps,cl

	call    [put_sprRT]

@@quit:
	pop     pers

	ret

put_sprSC       endp

;--------------------------------------
; normal sprite
;--------------------------------------
put_sprS5       PROC    near

	mov     dx,SC_INDEX             ;Let's prepare SC_INDEX
	mov     al,MAP_MASK             ;For the MAP_MASK
	out     dx,al                   ;.....

	mov     ebp,sx_start            ; ebx = sx_start  source X

	mov     ecx,XD
@@X:
	mov     dx,SC_INDEX+1           ;set Map Mask reg.
	mov     al,maps
	out     dx,al                   ;
	;
	mov     ebx,sy_start
	mov     y_d,0

	push    ecx
	mov     ecx,YD
@@Y:
	mov     eax,ebp
	shr     eax,16

	add     eax,ebx

	mov     al,byte ptr[esi+eax+4]
	cmp     al,0
	jz      SHORT @@skip0
	mov     byte ptr[edi],al
@@skip0:
	mov     ax,ydd
	add     y_d,ax
	jnc     @@noinc
	add     bx,word ptr[esi]
@@noinc:
	add     bx,yinc

	add     edi,80

	loop    @@Y
	;
	add     ebp,xdd_

	sub     edi,dii

	rol     maps,1
	adc     edi,0

	pop     ecx
	loop    @@X

@@quit:
	ret

put_sprS5       ENDP

;------------------------------------
;  mirrored sprite
;------------------------------------
put_sprS6       PROC    near

	mov     dx,SC_INDEX             ;Let's prepare SC_INDEX
	mov     al,MAP_MASK             ;For the MAP_MASK
	out     dx,al                   ;.....

	movzx   ebp,word ptr[esi]
	shl     ebp,16
	sub     ebp,sx_start            ; ebp = sx_start  source X
	dec     ebp

	mov     ecx,XD                  ;XD = dest. X length
@@X:
	mov     dx,SC_INDEX+1           ;set Map Mask reg.
	mov     al,maps
	out     dx,al                   ;
	;
	mov     ebx,sy_start
	mov     y_d,0

	push    ecx
	mov     ecx,YD                  ;YD = dest. Y length
@@Y:
	mov     eax,ebp                 ;ebp = source x index
	shr     eax,16                  ;

	add     eax,ebx                 ;ebx = source y index

	mov     al,byte ptr[esi+eax+4]  ;eax = source index
	cmp     al,0
	jz      SHORT @@skip0
	mov     byte ptr[edi],al
@@skip0:
	mov     ax,ydd
	add     y_d,ax
	jnc     @@noinc
	add     bx,word ptr[esi]
@@noinc:
	add     bx,yinc

	add     edi,80

	loop    @@Y
	;
	sub     ebp,xdd_

	sub     edi,dii

	rol     maps,1
	adc     edi,0

	pop     ecx
	loop    @@X

@@quit:
	ret

put_sprS6       ENDP

;=================================================================
;-------------------------------------------------
; save orignal key int. handler & set new handler
;-------------------------------------------------
keyint_on       proc       near

	; key-intr. handler 09h
	push    es                     ; save es
	mov     ax,3509h               ; get interrupt vector ah = 35h
	int     21h                    ; al = int No.
	mov     ax,es                  ; ret  es:ebx
	mov     int09seg,ax            ; get original int. vector
	mov     int09off,ebx           ; and store
	pop     es

	push    ds                     ; save ds reg.
	mov     ax,2509h               ; set interrupt vector ah = 25h
	mov     edx,offset newint09    ; ds:edx  =  cs:eip
	mov     bx,cs                  ; al = int No.
	mov     ds,bx                  ; set new int. handler
	int     21h                    ;
	pop     ds

	ret
keyint_on       endp

;-----------------------------------
;  restore original key-int. vector
;-----------------------------------
keyint_off      proc    near

	mov     ax,2509h               ; set int. vector ah = 25h
	mov     edx,int09off           ; ds:edx
	push    ds                     ;
	mov     bx,int09seg            ;
	mov     ds,bx
	int     21h
	pop     ds

	ret
keyint_off      endp

;---------------------------
; key-interrupt handler
;---------------------------
newint09        proc    far
	cli
	push    es
	push    eax                    ; save used reg.
	push    ebx                    ;

	mov     bx,DGROUP              ; es = dgroup
	mov     es,bx                  ;

	in      al,60h                 ; read pressed key
	cmp     al,127                 ; from I/O port 60h
	ja      @up

	xor     ebx,ebx                ; which key?
	and     al,127                 ;
	mov     es:key_hit,al          ;
	mov     bl,al                  ; Don't forget to remember
	cmp     es:keyboard[ebx],0     ; es segment overriding
	jne     @keys                  ; data acsessed in int. handler
	mov     es:key_edge[ebx],1     ; needs ES segment overriding
@keys:                                 ; under DOS/4G FLAT model
	mov     es:keyboard[ebx],1
	jmp     @eoi
@up:
	xor     ebx,ebx
	and     al,127
	mov     bl,al
	mov     es:keyboard[ebx],0     ;
@eoi:
	mov     al,20h                ; EOI to 8259-1
	out     20h,al                ; (interrupt controller)

	pop     ebx                    ;
	pop     eax
	pop     es
	sti
	iretd
newint09        endp

;===========================================================================
;-------------------------------
; set table of tangent value
;-------------------------------
set_tangent     proc      near

	mov     ecx,200
	mov     esi,-100
	xor     edi,edi
	movsx   ebx,pers
@ntan:
	mov     eax,esi
	shl     eax,16
	cdq
	idiv    ebx
	mov     tangent[edi],eax

	add     esi,1
	add     edi,4

	loop    @ntan

	ret
set_tangent     endp

;---------------------------------
;
;---------------------------------
world2eye       proc
	push    ebp

	mov     si,ax
	mov     di,dx
	mov     bp,bx

	movsx   ebx,eye_th              ;
	and     ebx,255                 ; sine table indexing
	shl     ebx,1                   ; for word ptr
	mov     dx,SIN[ebx]             ; sin(eye_th)
	mov     sine,dx                 ;

	movsx   ebx,eye_th              ;
	add     ebx,64                  ; cosine
	and     ebx,255                 ;
	shl     ebx,1                   ;
	mov     dx,SIN[ebx]             ; dx = cos(eye_th)
	mov     cosine,dx
@@next1:
	mov     ax,si           ;
	sub     ax,eye_x                ; rx = x - eye_x
	mov     rx,ax
	mov     ax,di   ;
	sub     ax,eye_y                ; ry = y - eye_y
	mov     yyy,ax
	mov     ax,bp   ;
;       sub     ax,eye_z                ; rz = z - eye_z
	mov     rz,ax

	mov     ax,rx                   ; rx * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ; rx * cos(eye_th) / 32768
	mov     xxx,dx

	mov     ax,rz                   ;
	imul    sine                    ; rz * sin(eye_th)
	shld    dx,ax,1                 ; rz * sin(eye_th) / 32768
	sub     xxx,dx          ;

	mov     ax,rz                   ; rz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ; rz * cos(eye_th) / 32768
	mov     zzz,dx

	mov     ax,rx                   ;
	imul    sine                    ; rx * sin(eye_th)
	shld    dx,ax,1                 ; rx * sin(eye_th) / 32768
	add     zzz,dx          ;

	movsx   eax,xxx
	movsx   edx,yyy
	movsx   ebx,zzz

	pop     ebp

	ret

world2eye       endp

;----------------------------------
;
;----------------------------------
eye2screen      proc

	movsx   ebp,eye_x
	sub     eax,ebp                 ; X

	movsx   ebp,eye_y
	sub     edx,ebp                 ; Y

	movsx   ebp,eye_z
	sub     ebx,ebp                 ; Z

	ret
eye2screen      endp

;----------------------------------------------
;  calculate angle of forward moving direction
;----------------------------------------------
dirf    PROC    near

	movzx   ebx,d_th                 ;
	and     ebx,255                  ; sine table indexing
	shl     ebx,1                    ; for word ptr
	mov     dx,SIN[ebx]              ; sin(eye_th)
	mov     sine,dx                  ;

	movzx   ebx,d_th                 ;
	add     ebx,64                   ; cosine
	and     ebx,255                  ;
	shl     ebx,1                    ;
	mov     dx,SIN[ebx]              ; dx = cos(eye_th)
	mov     cosine,dx                ;

	mov     ax,dif                   ; rx * cos(eye_th)
	cmp     ax,0
	jge     @@ppp

	neg     ax
	imul    cosine                  ;
	shld    dx,ax,1                 ; rx * cos(eye_th) / 32768
	sub     eye_x,dx

	mov     ax,dif                  ;
	neg     ax
	imul    sine                    ; rz * sin(eye_th)
	shld    dx,ax,1                 ; rz * sin(eye_th) / 32768
	sub     eye_z,dx                ;
	jmp     enddir
@@ppp:
	imul    cosine                  ;
	shld    dx,ax,1                 ; rx * cos(eye_th) / 32768
	add     eye_x,dx

	mov     ax,dif                  ;
	imul    sine                    ; rz * sin(eye_th)
	shld    dx,ax,1                 ; rz * sin(eye_th) / 32768
	add     eye_z,dx                ;
enddir:
	ret

dirf    endp

;-------------------------------------------------
; Horizental Line drawing : called from draw_floor
;-------------------------------------------------
hline1  PROC    near

	push    esi
	push    edi
	push    ebp

	movzx   eax,bp                  ; Be careful!! BP, Not ebp
	add     eax,50
	mov     edx,80
	mul     edx
	add     eax,SCREEN_OFF
	add     eax,PageOffset
	mov     lstart,eax

	mov     ax,5                    ;640 / 128(pers) = 5
	mov     dx,zz                   ;
	mul     dx                      ;5 * zz
	shr     ax,2                    ;

	mov     ex2,ax
	neg     ax
	mov     ex1,ax
	;
	movzx   ebx,eye_th              ;
	and     ebx,255                 ;sine table indexing
	shl     ebx,1                   ;for word ptr
	mov     dx,SIN[ebx]             ;sin(eye_th)
	mov     sine,dx                 ;

	movzx   ebx,eye_th              ;
	add     ebx,64                  ;cosine
	and     ebx,255                 ;
	shl     ebx,1                   ;
	mov     dx,SIN[ebx]             ;dx = cos(eye_th)
	mov     cosine,dx
; x1, z1
	mov     ax,ex1                  ;ex1 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex1 * cos(eye_th) / 32768
	mov     x1,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x1,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z1,dx

	mov     ax,ex1                  ;
	imul    sine                    ;ex1 * sin(eye_th)
	shld    dx,ax,1                 ;ex1 * sin(eye_th) / 32768
	sub     z1,dx                   ;

; x2, z2
	mov     ax,ex2                  ;ex2 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex2 * cos(eye_th) / 32768
	mov     x2,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x2,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z2,dx

	mov     ax,ex2                  ;
	imul    sine                    ;ex2 * sin(eye_th)
	shld    dx,ax,1                 ;ex2 * sin(eye_th) / 32768
	sub     z2,dx                   ;
	;
	mov     ax,eye_x
	add     x1,ax
	add     x2,ax

	mov     ax,eye_z
	add     z1,ax
	add     z2,ax
	;
	mov     ax,x1
	shl     eax,16
	mov     xs_,eax

	mov     ax,z1
	shl     eax,16
	mov     zs_,eax

	mov     ax,x2
	sub     ax,x1
	inc     ax
	shl     eax,16
	cdq
	mov     ebx,320
	idiv    ebx
	mov     xa1_,eax
	shl     eax,2
	mov     xa_,eax

	mov     ax,z2
	sub     ax,z1
	inc     ax
	shl     eax,16
	cdq
	idiv    ebx
	mov     za1_,eax
	shl     eax,2
	mov     za_,eax

	cld
	mov     maps,1                  ;Map Mask
	mov     ecx,4
@@nextm:
	mov     dx,SC_INDEX+1           ;index 2 Mask
	mov     al,maps                 ;
	out     dx,al                   ;

	mov     edi,lstart

	mov     esi,xs_
	mov     ebp,zs_

	push    ecx
	mov     ecx,80
	align	4
@@nextp:
	mov	eax,ebp
	neg     eax
	mov     edx,eax
	shr     eax,17
	and     eax,63
	shl     eax,6                   ;zz * 64

	mov     ebx,esi                 ; xx
	shr     ebx,17
	and     ebx,63
	add     ebx,eax
;
	shr     edx,17+6
	and     edx,127
	shl     edx,4                   ;mapz * 16

	mov     eax,esi                 ;mapx
	shr     eax,17+6
	and     eax,15
	add     eax,edx

	mov     eax,TEXMAP[eax * 4]
	mov     al,byte ptr[eax][ebx]
	stosb
;       mov     es:byte ptr[edi],al
;       inc     edi

	add     esi,xa_
	add     ebp,za_

	dec     ecx
	jnz     @@nextp

	mov     eax,xa1_
	add     xs_,eax
	mov     eax,za1_
	add     zs_,eax

	shl     maps,1

	pop     ecx

	dec     ecx
	jnz     @@nextm

	pop     ebp
	pop     edi
	pop     esi

	ret

hline1  ENDP


hline2  PROC    near

	push    esi
	push    edi
	push    ebp

	movzx   eax,bp                  ; Be careful!! BP, Not ebp
	add     eax,50
	mov     edx,80
	mul     edx
	add     eax,SCREEN_OFF
	add     eax,PageOffset
	mov     lstart,eax

	mov     ax,5                    ;640 / 128(pers) = 5
	mov     dx,zz                   ;
	mul     dx                      ;5 * zz
	shr     ax,2                    ;

	mov     ex2,ax
	neg     ax
	mov     ex1,ax
	;
	movzx   ebx,eye_th              ;
	and     ebx,255                 ;sine table indexing
	shl     ebx,1                   ;for word ptr
	mov     dx,SIN[ebx]             ;sin(eye_th)
	mov     sine,dx                 ;

	movzx   ebx,eye_th              ;
	add     ebx,64                  ;cosine
	and     ebx,255                 ;
	shl     ebx,1                   ;
	mov     dx,SIN[ebx]             ;dx = cos(eye_th)
	mov     cosine,dx
; x1, z1
	mov     ax,ex1                  ;ex1 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex1 * cos(eye_th) / 32768
	mov     x1,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x1,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z1,dx

	mov     ax,ex1                  ;
	imul    sine                    ;ex1 * sin(eye_th)
	shld    dx,ax,1                 ;ex1 * sin(eye_th) / 32768
	sub     z1,dx                   ;

; x2, z2
	mov     ax,ex2                  ;ex2 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex2 * cos(eye_th) / 32768
	mov     x2,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x2,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z2,dx

	mov     ax,ex2                  ;
	imul    sine                    ;ex2 * sin(eye_th)
	shld    dx,ax,1                 ;ex2 * sin(eye_th) / 32768
	sub     z2,dx                   ;
	;
	mov     ax,eye_x
	add     x1,ax
	add     x2,ax

	mov     ax,eye_z
	add     z1,ax
	add     z2,ax
	;
	mov     ax,x1
	shl     eax,16
	mov     xs_,eax

	mov     ax,z1
	shl     eax,16
	mov     zs_,eax

	mov     ax,x2
	sub     ax,x1
	inc     ax
	shl     eax,16
	cdq
	mov     ebx,320
	idiv    ebx
	mov     xa1_,eax
	shl     eax,2
	mov     xa_,eax

	mov     ax,z2
	sub     ax,z1
	inc     ax
	shl     eax,16
	cdq
	idiv    ebx
	mov     za1_,eax
	shl     eax,2
	mov     za_,eax

	cld
	mov     maps,11b              ;Map Mask
	mov     cx,2
@@nextm:
	mov     dx,SC_INDEX+1           ;index 2 Mask
	mov     al,maps                 ;
	out     dx,al                   ;

	mov     edi,lstart

	mov     esi,xs_
	mov     ebp,zs_

	push    cx
	mov     cx,80
@@nextp:
	mov     eax,ebp
	neg     eax
	mov     edx,eax
	shr     eax,17
	and     eax,63
	shl     eax,6                   ;zz * 64

	mov     ebx,esi
	shr     ebx,17
	and     ebx,63
	add     ebx,eax
;
	shr     edx,17+6
	and     edx,127
	shl     edx,4                   ;mapz * 16

	mov     eax,esi
	shr     eax,17+6
	and     eax,15
	add     eax,edx

	mov     eax,TEXMAP[eax * 4]
	mov     al,byte ptr[ebx][eax]
	stosb
;       mov     es:byte ptr[edi],al
;       inc     edi

	add     esi,xa_
	add     ebp,za_

	loop    @@nextp

	mov     eax,xa1_
	add     xs_,eax
	mov     eax,za1_
	add     zs_,eax

	shl     maps,2

	pop     cx

	dec     cx
	cmp     cx,0
	jnz     @@nextm

	pop     ebp
	pop     edi
	pop     esi

	ret

hline2  ENDP

hline3  PROC    near

	push    esi
	push    edi
	push    ebp

	movzx   eax,bp                  ; Be careful!! BP, Not ebp
	add     eax,50
	mov     edx,80
	mul     edx
	add     eax,SCREEN_OFF
	add     eax,PageOffset
	mov     lstart,eax

	mov     ax,5                    ;640 / 128(pers) = 5
	mov     dx,zz                   ;
	mul     dx                      ;5 * zz
	shr     ax,2                    ;

	mov     ex2,ax
	neg     ax
	mov     ex1,ax
	;
	movzx   ebx,eye_th              ;
	and     ebx,255                 ;sine table indexing
	shl     ebx,1                   ;for word ptr
	mov     dx,SIN[ebx]             ;sin(eye_th)
	mov     sine,dx                 ;

	movzx   ebx,eye_th              ;
	add     ebx,64                  ;cosine
	and     ebx,255                 ;
	shl     ebx,1                   ;
	mov     dx,SIN[ebx]             ;dx = cos(eye_th)
	mov     cosine,dx
; x1, z1
	mov     ax,ex1                  ;ex1 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex1 * cos(eye_th) / 32768
	mov     x1,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x1,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z1,dx

	mov     ax,ex1                  ;
	imul    sine                    ;ex1 * sin(eye_th)
	shld    dx,ax,1                 ;ex1 * sin(eye_th) / 32768
	sub     z1,dx                   ;

; x2, z2
	mov     ax,ex2                  ;ex2 * cos(eye_th)
	imul    cosine                  ;
	shld    dx,ax,1                 ;ex2 * cos(eye_th) / 32768
	mov     x2,dx

	mov     ax,zz                   ;
	imul    sine                    ;zz * sin(eye_th)
	shld    dx,ax,1                 ;zz * sin(eye_th) / 32768
	add     x2,dx                   ;

	mov     ax,zz                   ;zz * cos(eye_th)
	imul    cosine
	shld    dx,ax,1                 ;zz * cos(eye_th) / 32768
	mov     z2,dx

	mov     ax,ex2                  ;
	imul    sine                    ;ex2 * sin(eye_th)
	shld    dx,ax,1                 ;ex2 * sin(eye_th) / 32768
	sub     z2,dx                   ;
	;
	mov     ax,eye_x
	add     x1,ax
	add     x2,ax

	mov     ax,eye_z
	add     z1,ax
	add     z2,ax
	;
	mov     ax,x1
	shl     eax,16
	mov     xs_,eax

	mov     ax,z1
	shl     eax,16
	mov     zs_,eax

	mov     ax,x2
	sub     ax,x1
	inc     ax
	shl     eax,16
	cdq
	mov     ebx,320
	idiv    ebx
	mov     xa1_,eax
	shl     eax,2
	mov     xa_,eax

	mov     ax,z2
	sub     ax,z1
	inc     ax
	shl     eax,16
	cdq
	idiv    ebx
	mov     za1_,eax
	shl     eax,2
	mov     za_,eax

	cld
	mov     maps,1111b              ;Map Mask
	mov     dx,SC_INDEX+1           ;index 2 Mask
	mov     al,maps                 ;
	out     dx,al                   ;

	mov     edi,lstart

	mov     esi,xs_
	mov     ebp,zs_

	mov     cx,80
@@nextp:
	mov     eax,ebp
	neg     eax
	mov     edx,eax
	shr     eax,17
	and     eax,63
	shl     eax,6                   ;zz * 64

	mov     ebx,esi
	shr     ebx,17
	and     ebx,63
	add     ebx,eax
;
	shr     edx,17+6
	and     edx,127
	shl     edx,4                   ;mapz * 16

	mov     eax,esi
	shr     eax,17+6
	and     eax,15
	add     eax,edx

	mov     eax,TEXMAP[eax * 4]
	mov     al,byte ptr[ebx][eax]
	stosb
;       mov     es:byte ptr[edi],al
;       inc     edi

	add     esi,xa_
	add     ebp,za_

	loop    @@nextp

	pop     ebp
	pop     edi
	pop     esi

	ret

hline3  ENDP

;------------------------------
; draw floor
;------------------------------
draw_floor      PROC

	mov     dx,SC_INDEX             ;prepare SC_INDEX
	mov     al,MAP_MASK             ;index 2 MAP_MASK
	out     dx,al                   ;.....

	mov     edi,SCREEN_OFF           ;Calculate Init Pixel on dest.
	add     edi,PageOffset           ;

	mov     bp,99                   ;starting Y
@@upy:
	xor     dx,dx
	mov     ax,eye_y
	neg     ax
	mov     bx,pers
	mul     bx
	mov     bx,bp
	div     bx
	mov     zz,ax

	cmp     bp,4
	jl      @@sout

	call    [hline]

	sub     bp,1

	jmp     @@upy
@@sout:
	ret

draw_floor      ENDP

;---------------------------------------
;
;---------------------------------------
init_obj_ptr    proc

	mov     ecx,OBJNO
	mov     eax,offset obj_table
	mov     ebx,offset obj_ptr
@@next:
	mov     ds:dword ptr[ebx],eax

	add     eax,64
	add     ebx,4

	loop    @@next

	ret

init_obj_ptr    endp

;---------------------------------
;
;---------------------------------
depth_sort      proc

	xor     esi,esi
@@nbeam:
	mov     edi,esi
	inc     edi
@@nobj:
	mov     ebx,obj_ptr[esi * 4]
	mov     ax,[ebx].z
	mov     ebp,obj_ptr[edi * 4]
	cmp     ax,[ebp].z
	jle     @@nchg
	xchg    ebx,obj_ptr[edi*4]
	mov     obj_ptr[esi*4],ebx
@@nchg:
	inc     edi
	cmp     edi,OBJNO-1
	jbe     @@nobj
@@here:
	inc     esi
	cmp     esi,OBJNO-2
	jbe     @@nbeam
@@quit:
	ret

depth_sort      endp

;---------------------------------------
; eax: type no
;---------------------------------------
crea_beam       proc

	cmp	wepon_energy[eax*4],0
	jle     @@quit

	mov	ebx,eax

	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,beam_type[eax]

	mov     ecx,10
@@nbeam:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     beam[ebp].stat,0
	jg      @@here

	lea     edi,beam[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx

;;	mov     beam[ebp].stat,1

	xor     edx,edx
	mov     dx,_l
	mov     eax,_vptr
	call    sayPCM_

	mov     ax,eye_x
	add     ax,cops_x
	sub     ax,135
	mov     beam[ebp].x,ax

	mov     ax,eye_y
	add     ax,cops_y
	sub     ax,99-50-10
	mov     beam[ebp].y,ax

	mov     ax,pers
;       add     ax,eye_z
	mov     beam[ebp].z,ax

	mov     beam[ebp].spr_no,0

	mov     ax,SCROL               ;
	add     ax,35                  ; beam speed
	mov     beam[ebp].dlz,ax

	sub	wepon_energy[ebx*4],1
	jnc	SHORT @@quit
	mov	wepon_energy[ebx*4],0

	jmp     SHORT @@quit
@@here:
	dec     ecx
	jnz     @@nbeam
@@quit:
	ret
crea_beam       endp

;---------------------------------------
; eax: type no
; edx: enemy offset
; _blx , _bly : x, y
;---------------------------------------
crea_bullet       proc

	push    ebp
	push    ecx
	push    esi

	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,bullet_type[eax]

	mov     ecx,BULLETNO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     blt[ebp].stat,0
	jg      @@here

	push    edi
	lea     edi,blt[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx
	pop     edi

	mov     ax,[edx].x
	add     ax,_blx
	mov     blt[ebp].x,ax

	mov     ax,[edx].y
	add     ax,_bly
	mov     blt[ebp].y,ax

	mov     ax,[edx].z
	cmp	ax,150
	jg      SHORT @@skip000
	mov	blt[ebp].stat,0
	jmp	@@here
@@skip000:
	mov     blt[ebp].z,ax

	mov     ax,eye_x
	add     ax,cops_x
	sub     ax,160-24
	sub     ax,blt[ebp].x
	movsx   eax,ax
	mov     aimx,eax
	imul    eax,eax
	jo      @@quit
	mov     sqr1,eax

	mov     ax,eye_y
	add     ax,cops_y
	sub     ax,100-70
	sub     ax,blt[ebp].y
	movsx   eax,ax
	mov     aimy,eax
	imul    eax,eax
	jo      @@quit
	mov     sqr2,eax

	mov     ax,128             ; cops_z
	sub     ax,blt[ebp].z
	movsx   eax,ax
	mov     aimz,eax
	imul    eax,eax
	jo      @@quit
	add     eax,sqr2
	add     eax,sqr1

	cmp     eax,9998001
	jae     @@quit

	call    FindSqrt_
	mov     ebx,eax

;;;	mov     blt[ebp].stat,2

	push    edx

	mov     eax,aimx
	mov     edx,BSPEED
	imul    edx
	idiv    ebx
	mov     blt[ebp].dlx,ax

	mov     eax,aimy
	mov     edx,BSPEED
	imul    edx
	idiv    ebx
	mov     blt[ebp].dly,ax
	sub     blt[ebp].dly,1

	mov     eax,aimz
	mov     edx,BSPEED
	imul    edx
	idiv    ebx
	mov     blt[ebp].dlz,ax

	pop     edx

	mov     blt[ebp].spr_no,0

	jmp     SHORT @@quit
@@here:
	dec     ecx
	jnz     @@next
@@quit:
	pop     esi
	pop     ecx
	pop     ebp

	ret

crea_bullet       endp

;--------------------------
; input eax : flame type no
;       edi : enemy pointer
;       ebx : beam pointer
;--------------------------
crea_flm        proc

	push    ebp
	push    ecx

	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,flm_type[eax]

	mov     ecx,FLAMENO
@@nflm:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     flm[ebp].stat,0
	jg      @@heref

	push    edi

	lea     edi,flm[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx

	pop     edi

	mov     flm[ebp].stat,1

	xor     edx,edx
	mov     dx,[_l+2]            ; SFX NO 1
	mov     eax,[_vptr+4]        ;
	call    sayPCM_

	mov     ax,[ebx].x
	mov     flm[ebp].x,ax
	mov     ax,[ebx].y
	mov     flm[ebp].y,ax
	mov     ax,[edi].z
	mov     flm[ebp].z,ax
	sub     flm[ebp].z,2

	mov     ax,[edi].dlx
	mov     flm[ebp].dlx,ax
	mov     ax,[edi].dly
	mov     flm[ebp].dly,ax
	mov     ax,[edi].dlz
	mov     flm[ebp].dlz,ax

	mov     flm[ebp].spr_no,0
	jmp     @@flmout
@@heref:
	dec     ecx
	jnz     @@nflm
@@flmout:

	pop     ecx
	pop     ebp

	ret

crea_flm        endp

;--------------------------
; input eax : flame type no
;       edi : enemy pointer
;--------------------------
crea_flm0       proc

	push    ebp
	push    ecx
	push	esi

	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,flm_type[eax]

	mov     ecx,FLAMENO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     flm[ebp].stat,0
	jg      @@heref

	push    edi

	lea     edi,flm[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx

	pop     edi

	mov     flm[ebp].stat,1

	xor     edx,edx
	mov     dx,[_l+2*9]
	mov     eax,[_vptr+4*9]
	call    sayPCM_

	mov     ax,[edi].x
	add	ax,_flmx
	mov     flm[ebp].x,ax
	mov     ax,[edi].y
	add	ax,_flmy
	mov     flm[ebp].y,ax

	mov     ax,[edi].z
	mov     flm[ebp].z,ax
	sub     flm[ebp].z,5

	mov     ax,[edi].dlx
	mov     flm[ebp].dlx,ax
	mov     ax,[edi].dly
	mov     flm[ebp].dly,ax
	mov     ax,[edi].dlz
	mov     flm[ebp].dlz,ax

	mov     flm[ebp].spr_no,0
	jmp     @@flmout
@@heref:
	dec     ecx
	jnz     @@next
@@flmout:

	pop	esi
	pop     ecx
	pop     ebp

	ret

crea_flm0       endp

;--------------------------
; input eax : item type no
;       edi : obj pointer
;--------------------------
crea_item        proc

	push    ebp
	push    ecx
	push	esi

	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,item_type[eax]

	mov     ecx,ENEMYNO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     enemy[ebp].stat,0
	jg      @@here

	push    edi

	lea     edi,enemy[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx

	pop     edi

	mov     enemy[ebp].stat,1

	mov     ax,[edi].x
	mov     enemy[ebp].x,ax
	mov     ax,[edi].y
	mov     enemy[ebp].y,ax
	mov     ax,[edi].z
	mov     enemy[ebp].z,ax

	jmp     @@out
@@here:
	dec     ecx
	jnz     @@next
@@out:

	pop	esi
	pop     ecx
	pop     ebp

	ret

crea_item        endp

;---------------------------------------
;  eax : obj TYPE no (<100) or Pointer
;  dx : x
;---------------------------------------
crea_obj        proc
	push    ecx

	mov	esi,eax
	cmp	eax,99
	ja      @@skipno
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	lea     esi,enemy_type[eax]
@@skipno:

	cmp	boss_on,1
	jne	@@noboss
	cmp	[esi].interaction,1
	je      @@quit
@@noboss:

	mov     ecx,ENEMYNO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     enemy[ebp].stat,0
	jg      SHORT @@here

	inc	obj_counter

	lea     edi,enemy[ebp]
	cld
	push    ecx
	mov     ecx,16
	rep     movsd
	pop     ecx

	mov	eax,maxobj
	cmp	enemy[ebp].obj_no,eax
	jne	@@skipbosson
	mov	boss_on,1
@@skipbosson:
	mov	eax,OFFSET OBJ_DATA   ;;;;;;;;;;;;;
	cmp	enemy[ebp].obj_no,100;;;;;;;;;;;;;
	jb	@@skip0
	xor	eax,eax
@@skip0:
	cmp     enemy[ebp].course,0
	je      @@skip
	add     enemy[ebp].course,eax
@@skip:
	add     enemy[ebp].spr_data,eax

;       mov     ax,eye_z
;       add     enemy[ebp].z,ax
	mov     enemy[ebp].x,dx
;       mov     ax,dif
;       sub     enemy[ebp].dlz,ax

	jmp     SHORT @@quit
@@here:
	dec     ecx
	jnz     @@next
@@quit:
	pop     ecx

	ret
crea_obj        endp

;---------------------------------------
; read enenmy creation map
;---------------------------------------
read_enmap      proc

	movzx   eax,eye_z
	add     eax,2500
	neg     eax
	mov     ebx,eax
	shr     ebx,7           ; eye_z / 128
	and     ebx,127         ;

	cmp     OldENMAP,ebx
	je      @@out

	mov     OldENMAP,ebx

	shl     ebx,4           ; * 16
	shl     ebx,2

	add     ebx,offset ENMAP

	mov     ecx,0
@@next:
	mov     eax,dword ptr[ebx]
	cmp	eax,maxobj             ; if obj_no == maxobj(boss)
	jne	@@skipboss             ;
	cmp	obj_counter,BOSSCREA   ; boss creation check
	jb      @@skip                 ;
@@skipboss:

	cmp     eax,maxobj
	ja      @@skip                 ;( 0< obj_no <= maxobj )
	sub     eax,1                  ;
	jc      @@skip                 ;

	mov     edx,ecx
	shl     edx,7
	add     edx,64
	call    crea_obj
@@skip:
	add     ebx,4
	add     ecx,1

	cmp     ecx,16
	jb      @@next
@@out:
	ret

read_enmap      endp

;-------------------------------------------
;
;-------------------------------------------
obj_course      proc

	mov     ecx,BEAMNO + ENEMYNO  ; beam & enemy
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     obj_table[ebp].stat,0
	jle     @@here

@@rcos:
	mov     esi,dword ptr[obj_table][ebp].course
	cmp     esi,0
	je      @@here
	cmp     esi,-1
	je      @@here

	movsx   eax,word ptr[esi]       ; sprite no
	cmp     eax,-1                  ; end of course
	jne     @@checkcos
	mov     obj_table[ebp].course,-1
	jmp     @@here

@@checkcos:
	cmp     eax,200                 ;
	jl      @@normal                ; normal course

	cmp     eax,256                 ; mirriored sprite
	jae     @@normal                ; normal course

	sub     eax,200                 ; script course
	jmp     CourseRoutine[eax * 4]  ;

cos200:
;-----> SFX [200,SFX_no]
;------------------------------------------;
	movzx   eax,word ptr[esi + 2]

	movzx   edx,word ptr[_l][eax*2]
	mov     eax,dword ptr[_vptr][eax*4]
	call    sayPCM_

	add     obj_table[ebp].course,4
	jmp     @@rcos

cos201:
;----------> fire bullet [201,bullet_type,x,y]
;------------------------------------------;
	movzx   eax,word ptr[esi + 2]
	mov   	bx,word ptr[esi + 4]
	mov     _blx,bx
	mov   	bx,word ptr[esi + 6]
	mov     _bly,bx
	lea     edx,obj_table[ebp]
	call    crea_bullet

	add     obj_table[ebp].course,8
	jmp     @@rcos

cos202:
;-----------> sprite no change [202,no]
;-----------------------------------------;
	movzx   eax,word ptr[esi + 2]
	mov     obj_table[ebp].spr_no,eax

	add     obj_table[ebp].course,4
	jmp     @@here

cos203:
;-----------> set Y [203,y]
;-------------------------------------;
	mov     ax,word ptr[esi + 2]
	mov     obj_table[ebp].y,ax

	add     obj_table[ebp].course,4
	jmp     @@rcos

cos204:
;-----------> set interaction [204,interaction]
;-------------------------------------;
	mov     ax,word ptr[esi + 2]
	mov     obj_table[ebp].interaction,ax

	add     obj_table[ebp].course,4
	jmp     @@rcos

cos205:
;----------> crea flame[205,flame_type,x,y]
;------------------------------------------;
	movzx   eax,word ptr[esi + 2]
	mov   	bx,word ptr[esi + 4]
	mov     _flmx,bx
	mov   	bx,word ptr[esi + 6]
	mov     _flmy,bx
	lea     edi,obj_table[ebp]
	call    crea_flm0

	add     obj_table[ebp].course,8
	jmp     @@rcos

cos206:
;----------> crea ITEM[206,item_type]
;------------------------------------------;
	movzx   eax,word ptr[esi + 2]
	mov	ax,8
	call	rand
	movzx	eax,ax
	lea     edi,obj_table[ebp]
	call    crea_item

	add     obj_table[ebp].course,4
	jmp     @@rcos

cos207:
cos208:

cos209:
;----------> BOSS SELF DESTRUCTION & STAGE CLEAR[209]
;             only for BOSS
;------------------------------------------;
	mov	obj_table[ebp].stat,0
	mov	stage_flag,CLEAR
	jmp	@@here


cos210:
;-----------> speed change [210,dlx,dly,dlz]
;-----------------------------------------;
	mov     ax,word ptr[esi + 2]
	mov     obj_table[ebp].dlx,ax

	mov     ax,word ptr[esi + 4]
	mov     obj_table[ebp].dly,ax

	mov     ax,word ptr[esi + 6]
	mov     obj_table[ebp].dlz,ax

	add     obj_table[ebp].course,8
	jmp     @@here


cos211:
cos212:
cos213:
cos214:
cos215:
cos216:
cos217:
cos218:
cos219:
cos220:
cos221:
cos222:
cos223:
cos224:
cos225:
cos226:
cos227:
cos228:
cos229:

;--------- JUMP STYLE COURSE ------------------;
;----------------------------------------------;
cos230:
;------------> _GOTO [ 230,add ]
;----------------------------------------------;
	mov     eax,dword ptr[esi + 2]

	cmp     obj_table[ebp].obj_no,100
	jae     @@addskip1
	add     eax,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip1:
	mov     obj_table[ebp].course,eax
	jmp     @@rcos

cos231:
;----------> Y_check [ 232,y,add1,add2,add3 ]
;----------------------------------------------
	movzx   eax,word ptr[esi + 2]
	cmp     obj_table[ebp].y,ax

@@jumpcheck:
	jg      SHORT @@sw3
	je      SHORT @@sw2
@@sw1: ;-----------------------
	mov     eax,dword ptr[esi + 4]
	cmp     obj_table[ebp].obj_no,100
	jae     @@addskip2
	add     eax,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip2:
	mov     obj_table[ebp].course,eax
	jmp     @@rcos

@@sw2: ;-----------------------
	mov     eax,dword ptr[esi + 8]
	cmp     obj_table[ebp].obj_no,100
	jae     @@addskip3
	add     eax,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip3:
	mov     obj_table[ebp].course,eax
	jmp     @@rcos

@@sw3: ;------------------------
	mov     eax,dword ptr[esi + 12]
	cmp     obj_table[ebp].obj_no,100
	jae     @@addskip4
	add     eax,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip4:
	mov     obj_table[ebp].course,eax
	jmp     @@rcos

cos232:
;------> Z_check [232,z,add1,add2,add3]
;--------------------------------------;
	movzx   eax,word ptr[esi + 2]
	cmp     obj_table[ebp].z,ax
	jmp     @@jumpcheck

cos233:
;------> status check [232,status,add1,add2,add3]
;------------------------------------------------;
	movzx   eax,word ptr[esi + 2]
	cmp     obj_table[ebp].stat,eax
	jmp     @@jumpcheck

cos234:
;------> COPS X check [234,xrange,add1,add2,add3]
;--------------------------------------;
	mov     ax,word ptr[esi + 2]
	mov     bx,cops_x
	add     bx,eye_x
	sub	bx,160-20
	sub     bx,obj_table[ebp].x
	cmp     bx,ax
	jg      @@sw3
	neg     ax
	cmp     bx,ax
	jge     @@sw2
	jmp     @@sw1

cos235:
;------> COPS Y check [234,xrange,add1,add2,add3]
;--------------------------------------;
	mov     ax,word ptr[esi + 2]
	mov     bx,cops_y
	add     bx,eye_y
	sub     bx,obj_table[ebp].y
	cmp     bx,ax
	jg      @@sw3
	neg     ax
	cmp     bx,ax
	jge     @@sw2
	jmp     @@sw1

cos236:
cos237:
cos238:
cos239:

;-------------------------------------------;
;----- NORMAL COURSE -----------------------;
@@normal:
	mov     obj_table[ebp].spr_no,eax
	add     obj_table[ebp].course,8
@@conti:
	mov     ax,word ptr[esi + 2]       ; x
	mov     obj_table[ebp].dlx,ax
	mov     ax,word ptr[esi + 4]       ; y
	mov     obj_table[ebp].dly,ax
	mov     ax,word ptr[esi + 6]       ; z
	mov     obj_table[ebp].dlz,ax

@@here:
	dec     ecx
	jnz     @@next
@@quit:
	ret

obj_course      endp

;----------------------------------------
;
;----------------------------------------
password	proc

	mov	esi,offset SYSPAL
	call	set_palette

	mov     ecx,OBJNO * 64 / 4       ; object table clear
	mov     edi,offset obj_table     ;
	mov	eax,1                  	 ;
	rep     stosd                    ;
	mov	passtry,3

@@reinput:
	mov	keyboard[_ENTER],0
	mov	key_edge[_UPKEY],0
	mov	key_edge[_DNKEY],0
	mov	key_edge[_LTKEY],0
	mov	key_edge[_RTKEY],0

	mov	eax,20
	call	rand
	movzx	eax,ax
	mov   	passon,eax               ; password table index

	mov	passinput,0
	mov	passinput+4,0
	mov	passinput+8,0

	mov	passinputX,0

	mov	frames,0
@@nextf:
	call    wait_vrt

	inc	frames

	mov	eax,31	; gray color
	call	cleanC

	cmp	keyboard[_ENTER],1
	je	@@yess

	cmp	key_edge[_UPKEY],1
	jne	@@key1
	mov	key_edge[_UPKEY],0
	mov	eax,passinputX
	sub	passinput[eax*4],1
	jnc	@@key1
	mov	passinput[eax*4],30
@@key1:
	cmp	key_edge[_DNKEY],1
	jne	@@key2
	mov	key_edge[_DNKEY],0
	mov	eax,passinputX
	add	passinput[eax*4],1
	cmp	passinput[eax*4],30
	jle	@@key2
	mov	passinput[eax*4],0
@@key2:
	cmp	key_edge[_LTKEY],1
	jne	@@key3
	mov	key_edge[_LTKEY],0
	sub	passinputX,1
	jmp	@@key4
@@key3:
	cmp	key_edge[_RTKEY],1
	jne	@@key4
	mov	key_edge[_RTKEY],0
	add	passinputX,1
@@key4:

	cmp	passinputX,0
	jge	@@skip1
	mov	passinputX,0
@@skip1:
	cmp	passinputX,2
	jle	@@skip2
	mov	passinputX,2
@@skip2:
	mov	eax,passon
	call	pass_num

	mov	eax,passinput
	mov	esi,cops_spr_data[eax*4]
	mov	eax,88
	mov	edx,50
	call	put_spr

	mov	eax,passinput+4
	mov	esi,cops_spr_data[eax*4]
	mov	eax,88+48
	mov	edx,50
	call	put_spr

	mov	eax,passinput+8
	mov	esi,cops_spr_data[eax*4]
	mov	eax,88+48*2
	mov	edx,50
	call	put_spr

	mov	eax,frames
	and	eax,1
	mov	esi,ien_spr_data[eax*4]
	mov	eax,passinputX
	mov	edx,48
	mul	edx
	add	eax,93
	mov	edx,100
	call	put_spr

	call	showp

	jmp	@@nextf

@@yess:
	mov	eax,passon

	mov	bl,byte ptr[passinput]
	cmp	byte ptr[passtable][eax*4],bl
	jne	@@trial
	mov	bl,byte ptr[passinput+4]
	cmp	byte ptr[passtable][eax*4+1],bl
	jne	@@trial
	mov	bl,byte ptr[passinput+8]
	cmp	byte ptr[passtable][eax*4+2],bl
	jne	@@trial
	jmp	@@passOK

@@trial:
	dec	passtry
	jnz     @@reinput
	mov	eax,-1
	jmp	@@quit

@@passOK:
	mov	pass_ok,1
	mov     ecx,OBJNO * 64 / 4       ; object table clear
	mov     edi,offset obj_table     ;
	xor	eax,eax                	 ;
	cld
	rep     stosd                    ;
@@quit:
	ret

password	endp

;---------------------------------
;
;---------------------------------
sprite  proc

	mov     ecx,OBJNO
@@next:
	mov     eax,ecx
	dec     eax
	mov     ebp,obj_ptr[eax * 4]

	cmp     [ebp].stat,0
	jle     @@here

	mov   	ax,[ebp].x
	mov   	dx,[ebp].y
	mov   	bx,[ebp].z

	call    world2eye

	push    edx                     ;Y

	imul    persd                   ; eax : X
	cdq
	idiv    ebx
	mov     edi,eax                 ; x

	pop     eax                     ;Y

	imul    persd                   ; eax : Y
	cdq
	idiv    ebx
	mov     edx,eax                 ; y
	mov     eax,edi                 ; x

	add     eax,160
	add     edx,99-50

;	cmp     ebx,120
;	jge     SHORT @@nchk
;	mov     [ebp].stat,0
@@nchk:
	cmp     bx,[ebp].z_clip
	jle     SHORT @@tospr
	mov     [ebp].stat,0

@@tospr:
	mov     edi,[ebp].spr_no
	cmp     edi,256
	jge     @@mirror1

	mov     esi,dword ptr[ebp].spr_data
	mov     esi,dword ptr[esi + edi * 4]
	cmp     [ebp].obj_no,100
	jae     @@addskip1
	add     esi,offset OBJ_DATA        ;;;;;;;;;;
@@addskip1:
	mov     edi,1
	jmp     @@nomirror

@@mirror1:
	and     edi,255
	mov     esi,dword ptr[ebp].spr_data
	mov     esi,dword ptr[esi + edi * 4]
	cmp     [ebp].obj_no,100
	jae     @@addskip2
	add     esi,offset OBJ_DATA        ;;;;;;;;;;
@@addskip2:
	xor     edi,edi

@@nomirror:

	push    ecx
	push    ebp
	mov     ecx,[ebp].sfactor
	cmp     [ebp].spr_rt,0
	jne     SHORT @@center
	call    put_sprS
	jmp     SHORT @@nocenter
@@center:
	call    put_sprSC
@@nocenter:
	pop     ebp
	pop     ecx

@@here:
	dec     ecx
	jnz     @@next
@@quit:
	ret

sprite  endp

;---------------------------------
;
;---------------------------------
obj_ani proc

	mov     ecx,OBJNO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     obj_table[ebp].stat,0
	jle     @@here

	mov     ax,obj_table[ebp].dlx
	add     obj_table[ebp].x,ax

	mov     ax,obj_table[ebp].dly
	add     obj_table[ebp].y,ax

	mov     ax,obj_table[ebp].dlz
	cmp	obj_table[ebp].obj_no,300
	jae	@@nodif1
	mov	bx,dif
	sub	ax,bx
	jmp	@@nodif2
@@nodif1:
	cmp	obj_table[ebp].obj_no,400
	jb	@@nodif2
	mov	bx,dif
	sub	ax,bx
@@nodif2:
	add     obj_table[ebp].z,ax

	cmp     obj_table[ebp].z,120
	jge     SHORT @@nchk
	mov     obj_table[ebp].stat,0
@@nchk:

@@here:
	dec     ecx
	jnz     @@next
@@quit:
	ret

obj_ani endp

;---------------------------------
;
;---------------------------------
flm_ani proc

	mov     ecx,5
@@nflm:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     flm[ebp].stat,0
	jle     @@here

	cmp     flm[ebp].obj_no,200
	jne     @@ntype1
	mov     eax,9
@@ntype1:
	cmp     flm[ebp].obj_no,201
	jne     @@ntype2
	mov     eax,12
@@ntype2:
	cmp     flm[ebp].obj_no,202
	jne     @@ntype3
	mov     eax,4
@@ntype3:

	add     flm[ebp].spr_no,1
	cmp     flm[ebp].spr_no,eax
	jle     @@incY
	mov     flm[ebp].stat,0
@@incY:

@@here:
	dec     ecx
	cmp     ecx,0
	jnz     @@nflm
@@quit:
	ret

flm_ani endp

;---------------------------------
;
;---------------------------------
blt_ani proc

	mov     ecx,5
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     blt[ebp].stat,0
	jle     @@here

	cmp     blt[ebp].obj_no,300
	jne     @@ntype1
	mov     eax,2
@@ntype1:
	cmp     blt[ebp].obj_no,301
	jne     @@ntype2
	mov     eax,1
@@ntype2:

	add     blt[ebp].spr_no,1
	cmp     blt[ebp].spr_no,eax
	jle     @@incY
	mov     blt[ebp].spr_no,0
@@incY:

@@here:
	dec     ecx
	cmp     ecx,0
	jnz     @@next
@@quit:
	ret

blt_ani endp

;------------------------------------------
; cops animation
;------------------------------------------
cops_ani        PROC

	cmp     copstat,0               ; standing
	jne     SHORT @@nstat1
	mov     cops_spr_no,0
	jmp     @@quit
	;-------------------------------
@@nstat1:
	cmp     copstat,1               ; running
	jne     SHORT @@nstat2

	mov     eax,cops_spr_no
	cmp     eax,1
	jb      SHORT @@NOK
	cmp     eax,10
	jbe     SHORT @@OK
@@NOK:
	mov     cops_spr_no,1
@@OK:
;       mov     eax,frames
;       and     eax,1
;       add     cops_spr_no,eax
	add     cops_spr_no,1
	cmp     cops_spr_no,10
	jbe     @@quit
	mov     cops_spr_no,1
	jmp     @@quit
	;--------------------------
@@nstat2:
	cmp     copstat,2               ; demage
	jne     SHORT @@nstat3

	mov     cops_spr_no,14
	mov     eax,cops_spr_no
	cmp     eax,11
	jb      SHORT @@NOK1
	cmp     eax,14
	jbe     SHORT @@OK1
@@NOK1:
	mov     cops_spr_no,14
@@OK1:
	add     cops_spr_no,1
	cmp     cops_spr_no,14
	jbe     @@quit
	mov     cops_spr_no,11
	jmp     @@quit
	;---------------------------
@@nstat3:
	cmp     copstat,3               ; left move
	jne     SHORT @@nstat4

	mov     eax,cops_spr_no
	cmp     eax,15
	jb      SHORT @@NOK3
	cmp     eax,17
	jbe     SHORT @@OK3
@@NOK3:
	mov     cops_spr_no,15
@@OK3:
;       mov     eax,frames
;       and     eax,1
	add     cops_spr_no,1
	cmp     cops_spr_no,17
	jbe     @@quit
	mov     cops_spr_no,17
	jmp     @@quit
	;-----------------------
@@nstat4:
	cmp     copstat,4               ; right move
	jne     SHORT @@nstat5

	mov     eax,cops_spr_no
	cmp     eax,18
	jb      SHORT @@NOK4
	cmp     eax,20
	jbe     SHORT @@OK4
@@NOK4:
	mov     cops_spr_no,18
@@OK4:
;	mov     eax,frames
;       and     eax,1
	add     cops_spr_no,1
	cmp     cops_spr_no,20
	jbe     @@quit
	mov     cops_spr_no,20
	jmp     @@quit
	;-------------------------------
@@nstat5:
	; sprite no  21 - 23
	cmp     copstat,5               ; up move
	jne     SHORT @@nstat6

	mov     eax,cops_spr_no
	cmp     eax,21
	jb      SHORT @@NOK5
	cmp     eax,23
	jbe     SHORT @@OK5
@@NOK5:
	mov     cops_spr_no,21
@@OK5:
	mov     eax,frames
	and     eax,1
	add     cops_spr_no,eax
	cmp     cops_spr_no,23
	jbe     @@quit
	mov     cops_spr_no,22
	jmp     @@quit
	;-------------------------------
@@nstat6:
	; sprite no 24 - 26
	cmp     copstat,6               ; down move
	jne     SHORT @@nstat7

	mov     eax,cops_spr_no
	cmp     eax,24
	jb      SHORT @@NOK6
	cmp     eax,26
	jbe     SHORT @@OK6
@@NOK6:
	mov     cops_spr_no,24
@@OK6:
	mov     eax,frames
	and     eax,1
	add     cops_spr_no,eax
	cmp     cops_spr_no,26
	jbe     SHORT @@quit
	mov     cops_spr_no,25
	jmp     SHORT @@quit
	;-------------------------------
@@nstat7:
	; sprite no 27 - 28
	cmp     copstat,7               ; NORMAL
	jne     SHORT @@nstat8
	mov     eax,frames
	and     eax,1
	add     eax,27
	mov     cops_spr_no,eax
	jmp     SHORT @@quit
	;-------------------------------
@@nstat8:
	; sprite no 29 - 30
	cmp     copstat,8               ; fire
	jne     SHORT @@nstat9
	mov     eax,frames
;       shr     eax,1
	and     eax,1
	add     eax,29
	mov     cops_spr_no,eax
	jmp     SHORT @@quit
	;-------------------------------
@@nstat9:
@@quit:
	;-------------------------------
	;----- put sprite ---------------
	cmp	cops_on,0
	jle     @@normalspr
	dec	cops_on
	mov     eax,frames
	shr     eax,1
	and     eax,1
	je	@@skipspr
	jmp	@@dospr
@@normalspr:
	mov	godmode,OFF
@@dospr:
	mov     eax,cops_spr_no
	mov     esi,dword ptr[cops_spr_data + eax * 4]
	movsx   eax,cops_x
	movsx   edx,cops_y
	call    put_spr
@@skipspr:
	;-----------------------
	cmp     shield,0
	jz      @@out

	mov     eax,frames
;       shr     eax,1
	and     eax,1
	add     eax,31
	mov     esi,dword ptr[cops_spr_data + eax * 4]
	mov     ax,cops_x
	add     ax,-1
	movsx   edx,cops_y
	call    put_spr

@@out:
	ret
cops_ani        ENDP

;---------------------------------------
; beam vs object collision
;---------------------------------------
collision       proc

	mov     ecx,BEAMNO
@@nbeam:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     beam[ebp].stat,0
	jle     @@hereo

	push    ecx
	mov     ecx,ENEMYNO
@@nenemy:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     edi,eax

	cmp     enemy[edi].stat,0
	jle     @@herei
	cmp     enemy[edi].interaction,-1
	je     	@@herei

	cmp     enemy[edi].sfactor,0
	jne     @@scale

	mov     ebx,enemy[edi].spr_data
	mov     eax,enemy[edi].spr_no
	and     eax,255                         ; right left check
	mov     ebx,dword ptr[ebx][eax*4]       ; mirror image

	cmp     enemy[edi].obj_no,100
	jae     @@addskip1
	add     ebx,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip1:

	mov     ax,word ptr[ebx]
	shr     ax,1
	mov     iix,ax
	mov     ax,word ptr[ebx+2]
	shr     ax,1
	mov     iiy,ax
	jmp     @@skips
@@scale:
	mov     ebx,enemy[edi].spr_data
	mov     eax,enemy[edi].spr_no
	and     eax,255
	mov     ebx,dword ptr[ebx][eax*4]

	cmp     enemy[edi].obj_no,100
	jae     @@addskip2
	add     ebx,offset OBJ_DATA     ;;;;;;;;;;;;;;;;
@@addskip2:

	mov     ax,word ptr[ebx]
;;      shr     ax,1
	mov     iix,ax
	mov     ax,word ptr[ebx+2]
;;      shr     ax,1
	mov     iiy,ax
@@skips:
	mov     ax,enemy[edi].x
	sub     ax,beam[ebp].x
	cmp     ax,0
	jge     @@plus1
	neg     ax
@@plus1:
	cmp     ax,iix
	ja      @@nocoll

	mov     ax,enemy[edi].y
	cmp     enemy[edi].spr_rt,1
	je      @@center
	sub     ax,iiy
@@center:
	sub     ax,beam[ebp].y
	cmp     ax,0
	jge     @@plus2
	neg     ax
@@plus2:
	cmp     ax,iiy
	ja      @@nocoll

	mov     ax,enemy[edi].z
	sub     ax,beam[ebp].z
	cmp     ax,0
	jge     @@plus3
	neg     ax
@@plus3:
	cmp     ax,40
	ja      @@nocoll

@@coll:
	cmp	enemy[edi].obj_no,500
	jae     @@itemcoll

	cmp     enemy[edi].interaction,1
	jne     @@cflm

	mov	eax,beam[ebp].stat
	sub     enemy[edi].stat,eax

@@cflm:
	mov     beam[ebp].stat,0
	cmp     enemy[edi].stat,0
	jle     @@sflm
	mov     eax,2
	jmp     SHORT @@yess
@@sflm:
	movzx	eax,enemy[edi].sco
	shl	eax,4
	add	score,eax
	xor     eax,eax
	cmp     enemy[edi].y,0
	jl      SHORT @@yess
	mov     eax,1

@@yess:
	push    edi
	lea     edi,enemy[edi]
	lea     ebx,beam[ebp]
	call    crea_flm
	pop     edi
	jmp	SHORT @@nocoll

@@itemcoll:
	mov     beam[ebp].stat,0

	cmp	enemy[edi].obj_no,507
	jne	SHORT @@nocoll

	mov     eax,shield
	mov     Oshield,eax
	mov	shield,3


@@nocoll:

@@herei:
	dec     ecx
	jnz     @@nenemy

	pop     ecx
@@hereo:
	dec     ecx
	jnz     @@nbeam
@@quit:

	ret
collision       endp

;---------------------------------------
;  cops VS enemy & bulllet
;---------------------------------------
collision2      proc

	cmp	godmode,ON
	je      @@quit

	mov     ecx,ENEMYNO + BULLETNO
@@next:
	mov     eax,ecx
	dec     eax
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     ebp,eax

	cmp     enemy[ebp].stat,0
	jle     @@here
	cmp     enemy[ebp].interaction,-1
	je     	@@here

	cmp     enemy[ebp].sfactor,0
	jne     @@scale

	mov     ebx,enemy[ebp].spr_data
	mov     eax,enemy[ebp].spr_no
	and     eax,255
	mov     ebx,dword ptr[ebx][eax*4]
	cmp     enemy[ebp].obj_no,100
	jae     @@addskip1
	add     ebx,offset OBJ_DATA  ;;;;;;;;;;;;;;;
@@addskip1:
	mov     ax,word ptr[ebx]
	shr     ax,1
	add     ax,12
	mov     iix,ax
	mov     ax,word ptr[ebx+2]
	shr     ax,1
	add     ax,16
	mov     iiy,ax
	jmp     SHORT @@skips
@@scale:
	mov     ebx,enemy[ebp].spr_data
	mov     eax,enemy[ebp].spr_no
	and     eax,255
	mov     ebx,dword ptr[ebx][eax*4]
	cmp     enemy[ebp].obj_no,100
	jae     SHORT @@addskip2
	add     ebx,offset OBJ_DATA  ;;;;;;;;;;;;;;;
@@addskip2:
	mov     ax,word ptr[ebx]
;       shr     ax,1
	add     ax,12
	mov     iix,ax
	mov     ax,word ptr[ebx+2]
;       shr     ax,1
	add     ax,16
	mov     iiy,ax
@@skips:

	mov     ax,eye_x
	add     ax,cops_x
	sub     ax,160 - 24; 135

	sub     ax,enemy[ebp].x
	cmp     ax,0
	jge     @@plus1
	neg     ax
@@plus1:
	cmp     ax,iix
	ja      @@nocoll

	mov     bx,enemy[ebp].y
	cmp     enemy[ebp].spr_rt,1
	je      @@center
	sub     bx,iiy
@@center:
	mov     ax,eye_y
	add     ax,cops_y
	sub     ax,99-70
	sub     ax,bx           ; enemy[ebp].y

	cmp     ax,0
	jge     @@plus2
	neg     ax
@@plus2:
	cmp     ax,iiy
	ja      @@nocoll

;       mov     ax,eye_z
;       add     ax,128
	mov     ax,128
	sub     ax,enemy[ebp].z
	cmp     ax,0
	jge     @@plus3
	neg     ax
@@plus3:
	cmp     ax,20
	ja      @@nocoll

@@coll:
;;;;-----------------------------------
	mov	edx,enemy[ebp].stat
	cmp	edx,7
	jb	@@skip7
	mov	edx,7
@@skip7:
	cmp	enemy[ebp].obj_no,300
	jl	@@skipstat
	mov	enemy[ebp].stat,0
@@skipstat:

	cmp	enemy[ebp].obj_no,500
	jae	@@itemcoll

	cmp     shield,0
	jne     @@skipen
	mov     eax,cops_energy
	mov     Ocops_energy,eax
	sub     cops_energy,edx
	jnc     @@skipz
	mov     cops_energy,0
	jmp     @@skipz
@@skipen:
	mov     eax,shield
	mov     Oshield,eax
	sub     shield,1
	jnc     SHORT @@skipz
	mov     shield,0
@@skipz:
	mov     copstat,2
	mov     eax,8
	movzx   edx,word ptr[_l][eax*2]
	mov     eax,dword ptr[_vptr][eax*4]
	call    sayPCM_
	jmp	@@nocoll

;;;;-----------------------------------
@@itemcoll:
	mov     copstat,9		; item collision
	mov     eax,7
	movzx   edx,word ptr[_l][eax*2]
	mov     eax,dword ptr[_vptr][eax*4]
	call    sayPCM_

	cmp	enemy[ebp].obj_no,505
	jb	@@item

	mov	eax,enemy[ebp].obj_no
	sub     eax,505
	jmp	item_routine[eax*4]


item505: ;; rounds

	xor	eax,eax
@@nextwepon:
	mov	ebx,energy_add[eax*4]
	add	wepon_energy[eax*4],ebx
	cmp	wepon_energy[eax*4],999
	jbe	SHORT @@nonormal
	mov	wepon_energy[eax*4],999
@@nonormal:
	inc	eax
	cmp	eax,5
	jb	SHORT @@nextwepon

	jmp	@@nocoll

item506: ;; energy

	mov	eax,cops_energy
	mov	Ocops_energy,eax
	add	cops_energy,15
	cmp	cops_energy,21
	jb	@@nocoll
	mov	cops_energy,21

	jmp	SHORT @@nocoll

item507: ;; shield
	mov     eax,shield
	mov     Oshield,eax
	mov	shield,3

	jmp	SHORT @@nocoll

@@item:
	mov	eax,enemy[ebp].obj_no
	sub	eax,500
	mov	ebx,energy_add[eax*4]
	add	wepon_energy[eax*4],ebx
	cmp	wepon_energy[eax*4],999
	jbe	SHORT @@nocoll
	mov	wepon_energy[eax*4],999

@@nocoll:

@@here:
	dec     ecx
	jnz     @@next
@@quit:

	ret

collision2      endp

;---------------------------------------
; keyboard input  & joystick
;---------------------------------------
key_check       proc

	mov     cops_dx,0
	mov     cops_dy,0

;JOYSTICK INPUT
	cmp	config.control1,1               ; joy
	jb	@@keychk

	mov	al,Jxmask
	call	read_joy
	cmp	ax,JRTH
	jbe	SHORT @@ltchk
	mov	keyboard[_RTKEY],1
	jmp	SHORT @@jychk
@@ltchk:
	cmp	ax,JLTH
	ja	@@nojx
	mov	keyboard[_LTKEY],1
	jmp	SHORT @@jychk
@@nojx:
	mov	keyboard[_RTKEY],0
	mov	keyboard[_LTKEY],0

@@jychk:
	mov	al,Jymask
	call	read_joy
	cmp	ax,JDTH
	jb	@@upchk
	mov	keyboard[_DNKEY],1
	jmp	SHORT @@jbtn1chk
@@upchk:
	cmp	ax,JUTH
	ja	@@nojy
	mov	keyboard[_UPKEY],1
	jmp	SHORT @@jbtn1chk
@@nojy:
	mov	keyboard[_DNKEY],0
	mov	keyboard[_UPKEY],0

@@jbtn1chk:
	mov	al,Jbtn1
	call	read_joy
	cmp	ax,1
	jne	SHORT @@nobtn1
	mov	keyboard[_CTRL],1
	jmp	SHORT @@jbtn2chk
@@nobtn1:
	mov	keyboard[_CTRL],0

@@jbtn2chk:
	mov	al,Jbtn2
	call	read_joy
	cmp	ax,1
	jne	SHORT @@nobtn2
	cmp	keyboard[_ALT],0
	jne     SHORT @@noedge
	mov	key_edge[_ALT],1
@@noedge:
	mov	keyboard[_ALT],1
	jmp	SHORT @@keychk
@@nobtn2:
	mov	keyboard[_ALT],0

@@keychk:
	;KEYBOARD INPUT

	cmp     keyboard[_UPKEY],1               ; UP key
	jne     SHORT @nextk1
	mov     cops_dy,-4
	add     eye_y,-5
	cmp     eye_y,-200
	jge     @nextk1
	mov     eye_y,-200
@nextk1:

	cmp     keyboard[_DNKEY],1               ; DN key
	jne     SHORT @nextk2
	mov     cops_dy,4
	add     eye_y,5
	cmp     eye_y,-100
	jle     @nextk2
	mov     eye_y,-100
@nextk2:

	cmp     keyboard[_LTKEY],1               ; LFT key
	jne     SHORT @nextk3
	mov     cops_dx,-4
	add     eye_x,-15
	cmp     eye_x,-400+COPX
	jge     @@noeye1
	mov     eye_x,-400+COPX
@@noeye1:
	jmp     @nextk4

@nextk3:
	cmp     keyboard[_RTKEY],1               ; RIT key
	jne     SHORT @nextk4
	mov     cops_dx,4
	add     eye_x,15
	cmp     eye_x,400+COPX
	jle     @@noeye2
	mov     eye_x,400+COPX
@@noeye2:

@nextk4:
	cmp     key_edge[_F5],1               ; F5 key
	jne     SHORT @nextf6
	mov     key_edge[_F5],0
	add     hlrtno,4
	cmp     hlrtno,8
	jbe     @@skiphl
	mov     hlrtno,0
@@skiphl:
	mov     ebx,hlrtno
	mov     eax,hline_routine[ebx]
	mov     hline,eax

@nextf6:        ;
	cmp     key_edge[_F6],1            ; F6 key  vertical retrace
	jne     SHORT @nextf7
	mov	key_edge[_F6],0
	add     VertRetrace,1
	cmp     VertRetrace,1
	jle     @nextf7
	mov     VertRetrace,0

@nextf7:
	cmp     keyboard[_F7],1            ; F7 key
	jne     SHORT @nextk8
	sub     DelayTime,1
	cmp     DelayTime,0
	jge     @nextk8
	mov     DelayTime,0

@nextk8:
	cmp     keyboard[_F8],1            ; F8 key
	jne     SHORT @@pause
	add     DelayTime,1
	cmp     DelayTime,50
	jle     @@pause
	mov     DelayTime,50

@@pause:
	cmp     key_edge[_P],1               ; P key
	jne     SHORT @nextk11
	mov     key_edge[_P],0
@@pause1:
	cmp     key_edge[_P],1               ; P key
	jne     SHORT @@pause1
	mov     key_edge[_P],0

@nextk11:
	cmp	key_edge[_F11],1               ; F11 key
	jne     SHORT @nextk9
	mov     key_edge[_F11],0
	add     gammano,1
	cmp     gammano,5
	jbe     @@contigm
	mov     gammano,0
	mov     esi,offset Pal
	call    set_palette
	call	init_palette
	jmp     @nextk9
@@contigm:
	mov     ebx,gammano
	dec	ebx
	mov     edx,GAMMA[ebx * 4]
	call    gamma_correction

@nextk9:
	cmp     key_edge[_ALT],1               ; Alt key
	jne     SHORT @nextk10
	mov     key_edge[_ALT],0
	xor     edx,edx
	mov     dx,[_l+2*11]
	mov     eax,[_vptr+4*11]
	call    sayPCM_
	add     cops_wepon,1
	cmp     cops_wepon,BEAMTYPENO - 1
	jbe     @@skipw
	mov     cops_wepon,0
@@skipw:

@nextk10:

	ret

key_check       endp

;----------------------------------------------------;
;  read_joy(byte mask)   	                     ;
;  al : mask
;----------------------------------------------------;
read_joy 	proc

	mov	dx, 201h		;joystick port
	mov	ah, al			; mask
	cmp	ah, 0fh                 ;if btn check
	ja      button

	mov	ecx,65536               ;65536
loop1:
	in    	al, dx                  ;wait until proper time
	test  	al, ah                  ;
	loopnz 	loop1                   ;

	mov   	ecx,65536               ;65536
	xor	al, al
	out	dx, al                  ; initialize port

	cli
loop2:
	in    	al, dx                  ; time counting for x, y
	test  	al, ah
	loopnz 	loop2

	sti

	xor	ax, ax
	sub	ax, cx

	ret
button:
	xor	al, al
	out   	dx, al    ; port  initialization
	in    	al, dx
	test  	al, ah
	jz 	btn

	xor	ax, ax
	ret
btn:
	mov	ax, 1
	ret
read_joy 	endp

;--------------------------------------------
;
;--------------------------------------------
stage   proc

	mov     frames,0
@frame:
	MOV	ECX,-1
	CALL	SETTIME
	;
	inc     frames                  ; increse frame counter

	call    key_check

	cmp     keyboard[_ESC],1                 ; ESC key
	jne     SHORT @@skipesc
	mov     stage_flag,ESCAPE
	jmp     @fine
@@skipesc:

	mov     ax,dif
	add     eye_z,ax
;	call    dirf
	;
	cmp	VertRetrace,1
	je	@@skipvrt
	call    wait_vrt
@@skipvrt:

	call    put_pic                 ; background
	call    draw_floor
;       mov     dif,0

;--------------------------------
copstat_set:

	mov     ax,cops_dx
	add     cops_x,ax
	cmp     cops_x,1
	jge     @@ncops1
	mov     cops_x,1
@@ncops1:
	cmp     cops_x,319 - 42
	jle     @@ncops2
	mov     cops_x,319 - 42
@@ncops2:
	mov     ax,cops_dy
	add     cops_y,ax
	cmp     cops_y,0
	jge     @@ncops3
	mov     cops_y,0
@@ncops3:
	cmp     cops_y,104
	jle     @@ncops4
	mov     cops_y,104
@@ncops4:

	mov     copstat,1               ; running

	cmp     dif,0
	jne     SHORT @@nstat1
	mov     copstat,0               ; standing
@@nstat1:
	cmp     cops_y,100
	jge     @@nstat5
	mov     copstat,7               ; buster
@@nstat6:
	;
	cmp     keyboard[48h],1       ; UP key
	jne     SHORT @@nstat2
	mov     copstat,5
	jmp     SHORT @@nstat3

@@nstat2:
	cmp     keyboard[50h],1       ; DN key
	jne     SHORT @@nstat3
	mov     copstat,6
	;
@@nstat3:
	cmp     keyboard[4Bh],1       ; LFT key
	jne     SHORT @@nstat4
	mov     copstat,4
	jmp     SHORT @@nstat5
@@nstat4:
	cmp     keyboard[4Dh],1       ; RIT key
	jne     SHORT @@nstat5
	mov     copstat,3

;;;;;;;;        ;
@@nstat5:
	cmp     keyboard[_CTRL],1       ; fire CTRL key
	jne     SHORT @@nstat7
	cmp     copstat,7
	jne     @@fire
	mov     copstat,8
@@fire:
	mov     eax,frames
	and     eax,1
	jz      @@nstat7
	mov     eax,cops_wepon
	call    crea_beam
@@nstat7:
;-------------------------------------------
	call    depth_sort
	call    sprite

	call    read_enmap

;item creation
	mov	eax,frames
	and	eax,5Fh
	jnz	@@skipship
	mov	eax,offset ship
	mov	dx,1024
	add	dx,cops_x
	call	crea_obj
@@skipship:

	call    collision
	call    collision2

	call    obj_course

	call    turn2red
	call    turn2blue

	call    obj_ani
	call    flm_ani
	call    blt_ani

	call    cops_ani

	mov     eax,cops_energy
	cmp     eax,Ocops_energy
	je      @@skipen
	call    energy_bar
@@skipen:
	mov     eax,shield
	cmp     eax,Oshield
	je      @@skipsld
	call    shield_bar
@@skipsld:

	call	wepon
	call	wepon_num
	call	score_num

	cmp	copstat,2
	jne	@@skipdif
	mov     dif,-16
@@skipdif:
	;DIF CHECK
	cmp     dif,SCROL
	jle     SHORT @conti1
	mov     dif,SCROL
@conti1:
	cmp     dif,-20
	jge     SHORT @conti2
	mov     dif,-20
@conti2:

	cmp     cops_energy,0
	jne     SHORT @@conti01
	mov     stage_flag,DEAD
	jmp     @fine
@@conti01:
	cmp     stage_flag,CLEAR
	jne     SHORT @@conti3
	dec	enddelay
	jz	@fine
@@conti3:

	add     dif,4

;	mov     eax,DelayTime
;	call    waitmSec_

	call    showp

	XOR	ECX,ECX
	MOV	ECX,DWORD PTR SAVE_CONT
	CALL	INTTIME
	;
	jmp     @frame

@fine:
	mov	esc_on,OFF

	ret

stage   endp

;-------------------------------------
;  SFX sound device init.
;-------------------------------------
sound_init      proc

	cmp	config.sound,2   ; 0:none 1:adlib 2:SB 3:MT 4:GS
	jb	@@skipSB

	call    SBLAutoDetect_
	cmp     eax,1
	jne     @@skipSB
	mov     ax,1            ;SB
	call    initVoice_
	mov     eax,8000
	call    setSampleRate_
	jmp     @@gogo
@@skipSB:
	mov     eax,0           ;NO SOUND
	call    initVoice_
@@gogo:
	ret

sound_init      endp

;-------------------------------------------
;
;-------------------------------------------
joystick_init	proc

	cmp	config.control1,1
	jb	@@quit
	cmp	config.control1,1
	jne	@@joyb
@@joya:
	mov	Jxmask,JAX		; mask setting
	mov	Jymask,JAY
	mov	Jbtn1,JABTN1
	mov	Jbtn2,JABTN2

	mov	ax,config.jaxr
	sub	ax,config.jaxc
	shr	ax,1			; C + (R - C)/4 = JRTH
	add	ax,config.jaxc
	mov	JRTH,ax

	mov	ax,config.jaxc
	mov	JLTH,ax
	sub	ax,config.jaxl
	shr	ax,1			; C - (C - L)/4 = JLTH
	sub	JLTH,ax
	;
	mov	ax,config.jayd
	sub	ax,config.jayc
	shr	ax,1			; C + (D - C)/4 = JDTH
	add	ax,config.jayc
	mov	JDTH,ax

	mov	ax,config.jayc
	mov	JUTH,ax
	sub	ax,config.jayu
	shr	ax,1			; C - (C - U)/4 = JUTH
	sub	JUTH,ax

	jmp	@@quit

@@joyb:
	mov	Jxmask,JBX		; mask setting
	mov	Jymask,JBY
	mov	Jbtn1,JBBTN1
	mov	Jbtn2,JBBTN2

	mov	ax,config.jbxr
	sub	ax,config.jbxc
	shr	ax,1			; C + (R - C)/4 = JRTH
	add	ax,config.jbxc
	mov	JRTH,ax

	mov	ax,config.jbxc
	mov	JLTH,ax
	sub	ax,config.jbxl
	shr	ax,1			; C - (C - L)/4 = JLTH
	sub	JLTH,ax
	;
	mov	ax,config.jbyd
	sub	ax,config.jbyc
	shr	ax,1			; C + (D - C)/4 = JDTH
	add	ax,config.jbyc
	mov	JDTH,ax

	mov	ax,config.jbyc
	mov	JUTH,ax
	sub	ax,config.jbyu
	shr	ax,1			; C - (C - U)/4 = JUTH
	sub	JUTH,ax

@@quit:
	ret

joystick_init	endp


;-------------------------------------
; stage initial
;-------------------------------------
stage_init      proc

	mov     eye_x,COPX
	mov     eye_y,-100
	mov     eye_z,0

	mov     cops_x,160 - 20
	mov     cops_y,104

	mov     cops_energy,15
	mov     Oshield,1
	mov     shield,0

	mov	boss_on,0
	mov	enddelay,DELAY
	mov	obj_counter,0

	mov     ebx,stage_no
	mov     eax,maxobjdata[ebx*4]
	mov     maxobj,eax

	cmp	stage_no,1
	jne	@@clearobjtable
;	cmp	esc_on,ON
;	jne	@@skipclear
;;	cmp	pass_ok,1
;;	jne     @@skipclear

@@clearobjtable:
	mov     ecx,OBJNO * 64 / 4       ; object table clear
	mov     edi,offset obj_table     ;
	xor	eax,eax                  ;
	rep     stosd                    ;
@@skipclear:

	ret

stage_init      endp



;-------------------------------
;
;-------------------------------
energy_bar      proc

	mov     ecx,21
	mov     eax,118
	mov     edx,162
@@next0:
	mov     esi,offset enbar0
	call    put_spr
	add     eax,4
	loop    @@next0

	cmp     cops_energy,0
	jg      @@skipen
	mov     cops_energy,0
	ret
@@skipen:
	mov     ecx,cops_energy
	mov     eax,118
	mov     edx,162
@@next:
	mov     esi,offset enbar
	call    put_spr
	add     eax,4
	loop    @@next

	ret

energy_bar      endp

;-------------------------------
;
;-------------------------------
shield_bar      proc

	mov     ecx,3
	mov     eax,118
	mov     edx,174
@@next0:
	mov     esi,offset sldbar0
	call    put_spr
	add     eax,28
	loop    @@next0

	cmp     shield,0
	je      @@out
	mov     ecx,shield
	mov     eax,118
	mov     edx,174
@@next:
	mov     esi,offset sldbar
	call    put_spr
	add     eax,28
	loop    @@next
@@out:
	ret

shield_bar      endp

;-------------------------------
;
;-------------------------------
player_no_bar   proc

	mov     eax,252
	mov     edx,182
	xor	ecx,ecx
	mov     cl,player_no
@@next:
	mov     esi,offset player_no_spr
	call    put_spr
	add     eax,6
	loop    @@next

	ret

player_no_bar   endp

;-------------------------------
; print selected wepon
;-------------------------------
wepon	proc

	mov	esi,offset panback
	mov     eax,230
	mov     edx,159
	call    put_spr

	mov	eax,cops_wepon
	lea     eax,[eax*8]
	lea     eax,[eax*8]
	mov     esi,item_type[eax].spr_data
	mov	esi,dword ptr[esi]
	mov     eax,230
	mov     edx,160
	call    put_spr

	ret

wepon   endp

;-------------------------------
; print wepon rounds
;-------------------------------
wepon_num      proc

	mov	esi,offset wnumback
	mov	eax,272
	mov	edx,162
	call	put_spr

	mov     ebx,10
	mov	eax,cops_wepon
	mov	eax,wepon_energy[eax * 4]
	cdq
	div     ebx
	mov     [wnumber],edx
	cdq
	div     ebx
	mov     [wnumber+4],edx
	cdq
	div     ebx
	mov     [wnumber+8],edx

	mov	eax,[wnumber+8]
	mov	esi,wnumber_spr[eax * 4]
	mov	eax,272
	mov	edx,162
	call	put_spr

	mov	eax,[wnumber+4]
	mov	esi,wnumber_spr[eax * 4]
	mov	eax,272+7
	mov	edx,162
	call	put_spr

	mov	eax,[wnumber]
	mov	esi,wnumber_spr[eax * 4]
	mov	eax,272+14
	mov	edx,162
	call	put_spr


	ret

wepon_num      endp

;-------------------------------
; print password page
; eax : page number
;-------------------------------
pass_num      proc

	inc	eax
	mov     ebx,10
	cdq
	div     ebx
	mov     [wnumber],edx
	cdq
	div     ebx
	mov     [wnumber+4],edx

	mov	eax,[wnumber+4]
	mov	esi,wnumber_spr[eax * 4]
	mov	eax,153
	mov	edx,30
	call	put_spr

	mov	eax,[wnumber]
	mov	esi,wnumber_spr[eax * 4]
	mov	eax,153+7
	mov	edx,30
	call	put_spr


	ret

pass_num      endp

;-------------------------------
;  print score
;-------------------------------
score_num      	proc

	mov	esi,offset snumback
	mov	eax,162
	mov	edx,192
	call	put_spr

	mov     ebx,10
	mov	eax,score
	cdq
	div     ebx
	mov     [snumber],edx      ;  0
	cdq
	div     ebx
	mov     [snumber+4],edx    ;  1
	cdq
	div     ebx
	mov     [snumber+8],edx    ;  2
	cdq
	div     ebx
	mov     [snumber+12],edx   ;  3
	cdq
	div     ebx
	mov     [snumber+16],edx   ;  4
	cdq
	div     ebx
	mov     [snumber+20],edx   ;  5
	cdq
	div     ebx
	mov     [snumber+24],edx   ;  6
	cdq
	div     ebx
	mov     [snumber+28],edx   ;  7
	;---------------------------------;
	mov	eax,[snumber+28]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+24]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+20]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*2
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+16]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*3
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+12]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*4
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+8]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*5
	mov	edx,192
	call	put_spr

	mov	eax,[snumber+4]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*6
	mov	edx,192
	call	put_spr

	mov	eax,[snumber]
	mov	esi,snumber_spr[eax * 4]
	mov	eax,162+6*7
	mov	edx,192
	call	put_spr


	ret

score_num   endp

;------------------------------------------
;  print frames per second ( in TEXT mode)
;------------------------------------------
print_fps       proc

	mov     eax,dword ptr[Tend]
	sub     eax,dword ptr[Tstart]
	mov     ebx,5
	mul     ebx
	mov     ebx,91                  ;18.2 * 5
	div     ebx
	mov     ebx,eax
	mov     eax,frames
	cdq
	div     ebx
	mov     ebx,10
	cdq
	div     ebx
	mov     [fps],dl
	cdq
	div     ebx
	mov     [fps+1],dl
	;
	mov     ah,0eh
	mov     al,[fps+1]
	add     al,30h
	mov     bh,0
	int     10h
	;
	mov     ah,0eh
	mov     al,[fps]
	add     al,30h
	mov     bh,0
	int     10h
	ret

print_fps       endp

opening proc
	ret
opening endp

;----------------------------------------
; main menu
;----------------------------------------
main_menu       proc
	push	dword ptr[Tstart]
	push	dword ptr[Tend]

@@start:
	call	MENU_MUSIC
	call	PLAY_MUSIC
	mov     key_edge[48h],0
	mov     key_edge[50h],0
	mov     keyboard[_ENTER],0

	call	screen_off
	mov     esi,offset PCX_name00    ; menu.pcx
	call    load_put_PCX

	mov     esi,offset PCX_name02    ; menu-txt.pcx
	call    load_put_SPR

	call	screen_on

	mov	Menu,0
	mov     oMenu,1

	mov     esi,[_menu1]
	mov     eax,187
	mov     edx,37
	call    put_spr

	add     edx,30
	mov     esi,[_menu0 + 4]
	call    put_spr

	add     edx,30
	mov     esi,[_menu0 + 8]
	call    put_spr

	mov     ah,0                    ;read system clock ticks
	int     1Ah                     ;
	mov     word ptr[Tstart+2],cx   ;
	mov     word ptr[Tstart],dx     ;
@@rpt:
	cmp     key_edge[48h],1               ; UP key
	jne     SHORT @@nextk1
	mov     key_edge[48h],0
	mov     eax,Menu
	mov     oMenu,eax
	sub     Menu,1
	jnc     @@nextk1
	mov     Menu,2
@@nextk1:
	cmp     key_edge[50h],1               ; DN key
	jne     SHORT @@nextk2
	mov     key_edge[50h],0
	mov     eax,Menu
	mov     oMenu,eax
	add     Menu,1
	cmp     Menu,3
	jb      SHORT @@nextk2
	mov     Menu,0
@@nextk2:

	cmp     keyboard[_ENTER],1               ; ENTER key
	jne     SHORT @@nextk3
	call	STOP_MUSIC

	pop	dword ptr[Tend]
	pop	dword ptr[Tstart]
	ret

@@nextk3:
	mov     ebx,oMenu
	mov     esi,_menu0[ebx*4]
	mov     eax,187
	mov     edx,37
	imul    ebx,30
	add     edx,ebx
	call    put_spr

	mov     ebx,Menu
	mov     esi,_menu1[ebx*4]
	mov     eax,187
	mov     edx,37
	imul    ebx,30
	add     edx,ebx
	call    put_spr

	mov     ah,0                    ; read clock ticks
	int     1Ah                     ;
	mov     word ptr[Tend+2],cx     ;
	mov     word ptr[Tend],dx       ;

	mov	eax,dword ptr [Tend]
	sub	eax,dword ptr [Tstart]
	cmp	eax,11 * 18
	jb	@@rpt

	mov	Menu,-1

	call	STOP_MUSIC

	pop	dword ptr[Tend]
	pop	dword ptr[Tstart]

	ret

main_menu       endp

ending  proc
	ret
ending  endp

;===========================================================================

;--------------------------------------
; MAIN procdure called from  START.C
;--------------------------------------
	public  start_

start_  proc    near

	push    ds
	push    es
	push    eax
	push    ebx
	push    ecx
	push    edx
	push    esi
	push    edi
	push    ebp

	mov	stage_no,0        ;        eax

	call    load_cfg
	call    sound_init
	call	joystick_init

	call    MakeSqrTable

;	mov     ah,09h
;	mov     edx,offset message00   ; "Press any key to start.."
;	int     21h

;	mov     ah,08h                  ; get key
;	int     21h

	call	SET_SYX			; music drive init
	call    keyint_on               ;install key interrupt handler
@@sog:
	mov	player_no,5	;
	call    OPENING

	call    xmode
@@menu:
	mov     StartOffset,0
	mov     PageOffset,0
	call    clean
	call    set_startP
	call    main_menu

	call    showp
	cmp	Menu,1	; help
	je	@@help
	cmp     Menu,2	; quit
	je      @@eog
	cmp	Menu,-1	; no key input
	je	@@sog
	jmp	SHORT @@nextstage
;---------------------------------------------
@@help:
	call	clean
	call	screen_off
	mov     esi,offset PCX_name01    ; help.grp
	call    load_put_PCX
	call	showp
	call	screen_on
@@mloop:
	cmp	keyboard[_ESC],1
	je      @@menu
	jmp	@@mloop
;---------------------------------------------
@@nextstage:
;;	push	ebx

;;;	call	password

	mov	ax,13h    		; inter visiual play
	int	10h                     ;
	mov	eax,stage_no            ;
	call	INTERVIZ                ;
	call	xmode                   ;

;;	pop	ebx

	cmp	stage_no,1
	jne	@@skippass
	cmp	esc_on,ON
	je	@@skippass
;;	cmp	pass_ok,1
;;	je	@@skippass
;;	xor	eax,eax
;;	call	ebx		 ; call password
;;	cmp	eax,-1
;;	je      @@eog
@@skippass:

@@deadrestart:
	mov	eax,stage_no            ; stage music setting
	call	STAGE_MUSIC             ;

	mov	stage_flag,DEAD

	call    stage_init
	call    load_map

	mov	eax,12
	movzx   edx,word ptr[_l][eax*2]
	mov     eax,dword ptr[_vptr][eax*4]
	call    sayPCM_

	call	screen_off

	mov     esi,offset Pal
	call    set_palette
	call    init_palette

	mov     ebx,gammano
	cmp     ebx,0
	je      @@skipgm
	dec	ebx
	mov     edx,GAMMA[ebx * 4]
	call    gamma_correction
@@skipgm:

	call	screen_on

	call    keep_pic
	call    panspr
	call    copspr
	call    init_obj_ptr
	mov     dif,SCROL

	call	PLAY_MUSIC

@@startstage:
	mov     PageOffset,0
	call	clean
	mov     eax,0               ;  x
	mov     edx,150             ;  y
	mov     esi,offset PANNEL   ;
	call    put_spr
	call	player_no_bar

	mov     PageOffset,4000h
	mov     eax,0
	mov     edx,150
	mov     esi,offset PANNEL   ;
	call    put_spr
	call	player_no_bar

;	mov     ah,0                    ;read system clock ticks
;	int     1Ah                     ;
;	mov     word ptr[Tstart+2],cx   ;
;	mov     word ptr[Tstart],dx     ;

	call    stage
	;
;	mov     ah,0
;	int     1Ah
;	mov     word ptr[Tend+2],cx
;	mov     word ptr[Tend],dx

	cmp     stage_flag,DEAD
	jne     SHORT @@chkclear

	;-------------
	; player DEAD
	;-------------
	call	STOP_MUSIC
	call	OVER_MUSIC

	dec	player_no
	jz	@@endg

	mov     eye_x,COPX
	mov     eye_y,-100

	mov	cops_energy,15
	mov     cops_x,160 - 20
	mov     cops_y,104

	mov     Oshield,1
	mov     shield,0
	mov	cops_on,COPSON
	mov	godmode,ON

;;	jmp	@@startstage
;;	jmp	@@nextstage
	jmp	@@deadrestart

@@chkclear:
	cmp	stage_flag,CLEAR
	jne	@@esc                 ;
	jmp	@@clear

@@esc:
	;--------------------
	;  ESC
	;--------------------
	call	STOP_MUSIC
	mov	esc_on,ON
	jmp	@@menu

@@clear:
	;-------------
	;stage CLEAR
	;-------------
	call	STOP_MUSIC

	add	score,50000
;;	cmp	stage_no,0
;;	jne	@@skipEBX
;;	xor	eax,eax
;;	mov	ebx,offset password
@@skipEBX:

	inc     stage_no
	cmp     stage_no,7
	jb      @@nextstage

@@endg:

	call    ending
	mov     stage_no,0
	mov	player_no,5	;
	mov	wepon_energy,999
	mov	wepon_energy +4,100
	mov	wepon_energy +8,0
	mov	wepon_energy+12,0
	mov	wepon_energy+16,0
	mov	cops_wepon,0
	mov	score,0

	jmp     @@menu

;------------------------------
;------------------end of game:
@@eog:
	call    keyint_off
	call    save_cfg

	mov     ax,03h                  ;text mode
	int     10h

;;	call    print_fps

	pop     ebp
	pop     edi
	pop     esi
	pop     edx
	pop     ecx
	pop     ebx
	pop     eax
	pop     es
	pop     ds

	ret

start_  endp

_TEXT   ends

	END

