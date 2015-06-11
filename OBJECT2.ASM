;-------------------------------------------------------        
;  object course data for IZMIR 
;  stage 2
;-------------------------------------------------------
	.386

_GOTO                   equ     230

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
	sco             dw      ?       ;

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


_data   segment public use32 'DATA'

extrn   s2tan_spr_data1: dword
extrn   s2tan_spr_data2: dword
extrn   s2tan_spr_data3: dword
extrn   s2tan_spr_data4: dword
extrn   s2tan_spr_data5: dword
extrn   s2tan_spr_data6: dword
extrn   s2tan_spr_data7: dword
extrn   rock01_spr_data: dword
extrn   rock02_spr_data: dword
extrn   s2boss1_spr_data: dword

	ORG 0
OBJ_DATA        label
enemy_type      label   word
object  <1, 0, -100, 2500,,,,,,, 1, 2500, 30,  2, 0, 0, offset s2tan_spr_data1, offset tan_course1, 0, 1,0,0>
; robot in air
object  <2, 0, -100, 2500,,,,,,, 1, 2500, 40,  2, 0, 128, offset s2tan_spr_data2, offset tan_course2, 0, 1,0,0>
; ball in air
object  <3, 0,    0, 2500,,,,,,, 1, 2500, 40,  2, 0, 128, offset s2tan_spr_data3, offset tan_course3, 0, 0,0,0>
; ball on water
object  <4, 0, -200, 150,,,,,,,  1, 2500, 30,  2, 0, 0, offset s2tan_spr_data4, offset tan_course4, 0, 1,0,0>
; UFO
object  <5, 0,    0, 2500,,,,,,, 1, 2500, 30,  2, 0, 0, offset s2tan_spr_data5, offset tan_course5, 0, 0,0,0>
; ship
object  <6, 0,    0, 2500,,,,,,, 1, 2500, 20,  2, 0, 0, offset s2tan_spr_data6, offset tan_course6, 0, 0,0,0>
; ship with wheel
object  <7, 0,    0, 2500,,,,,,, 0, 2500,  0,  7, 0, 128, offset s2tan_spr_data7, offset tan_course7, 0, 0,0,0>
; beam on water

object  <8, 0,    0, 2500,,,,,,, 0, 2500,  0,  2, 0, 0, offset rock01_spr_data, offset rock_course, 0, 0,0,0>
; rock 1
object  <9, 0,    0, 2500,,,,,,, 0, 2500,  0,  2, 0, 0, offset rock02_spr_data, offset rock_course, 0, 0,0,0>
; rock 2

object  <10, 0,   0, 2500,,,,,,, 1, 2500, 500, 5000, 0, 128, offset s2boss1_spr_data, offset boss_course, 0, 0,0,0>
; boss


;---------------------------------------------------------------------

tan_course1     label   word  ;   robot in air
	dw 0,0,0,-25, 1,0,0,-25, 2,0,0,-25
	dw 232,500
	dd conti1,conti1,tan_course1
conti1:
	dw 3,0,0,-5, 3,0,0,-5, 4,0,0,0
	dw 4,0,0,0, 5,0,0,5, 5,0,0,10
	dw 201,1,0,0
	dw 6,0,0,15, 7,0,0,15, 8,0,0,15, 9,0,0,10
	dw 201,1,0,0
cruse:  dw 9,0,0,-5
	dw 233,1
	dd conti2,conti2,cruse
conti2:
	dw 1,0,0,-25, 2,0,0,-25, -1

tan_course2     label   word  ;   ball in air
	dw 0,0,0,-5, 1,0,5,-5, 2,0,10,-5
	dw 3,0,15,-5, 4,0,20,-5

	dw 0,0,25,-5, 1,0,20,-5, 2,0,15,-5
	dw 3,0,10,-5, 4,0,5,-5

	dw 0,0,0,-5, 1,0,-5,-5, 2,0,-10,-5
	dw 3,0,-15,-5, 4,0,-20,-5

	dw 0,0,-25,-5, 1,0,-20,-5, 2,0,-15,-5
	dw 3,0,-10,-5, 4,0,-5,-5

	dw _GOTO
	dd tan_course2

tan_course3     label   word  ;   ball on the water
	dw 0,0,0,-5, 1,5,0,-5, 2,10,0,-5
	dw 0,15,0,-5, 1,20,0,-5, 2,25,0,-5
	dw 0,20,0,-5, 1,15,0,-5, 2,10,0,-5
	dw 0,5,0,-5, 1,0,0,-5, 2,-5,0,-5
	dw 0,-10,0,-5, 1,-15,0,-5, 2,-20,0,-5
	dw 0,-25,0,-5, 1,-20,0,-5, 2,-15,0,-5
	dw 0,-10,0,-5, 1,-5,0,-5
	dw _GOTO
	dd tan_course3

tan_course4     label   word  ;   UFO   right to left
	dw 0,0,10,50, 1,0,10,50, 2,0,10,50
	dw 4,0,5,50, 5,0,5,50, 6,0,5,50
	dw 7,0,0,60, 8,0,0,60, 9,0,0,60
	dw 10,0,0,50, 11,0,0,50, 12,0,0,50
	dw 234,10
	dd conti400,conti400,conti401
conti400:
	dw 13,-5,0,50, 14,-5,0,40, 15,-10,0,30
	dw 201,1,0,0
	dw 16,-20,0,20, 201,1,0,0, 17,-30,0,0, -1
conti401:
	dw 13+256,5,0,50, 14+256,5,0,40, 15+256,10,0,30
	dw 201,1,0,0
	dw 16+256,20,0,20, 201,1,0,0, 17+256,30,0,0, -1

tan_course5     label   word  ;   ship
	dw 0,0,0,-5, 1,0,0,-5, 2,0,0,-5
	dw 3,0,0,-5, 4,0,0,-5, 5,0,0,-5
	dw 204,-1
	dw 6,0,0,-5
	dw 201,1,0,0
	dw 7,0,0,-5, 8,0,0,-5, 9,0,0,-5, 9,0,0,-5
	dw 8,0,0,-5, 7,0,0,-5, 6,0,0,-5, 5,0,0,-5
	dw 204,1
	dw 4,0,0,-5, 3,0,0,-5
	dw 0,0,0,-5, 1,0,0,-5, 2,0,0,-5
	dw _GOTO
	dd tan_course5

tan_course6     label   word  ;   ship with wheel
	dw 0,0,0,-5, 1,0,0,-5, 2,0,0,-5
	dw 3,0,0,-5, 4,0,0,-5, 5,0,0,-5
	dw 204,-1
	dw 6,0,0,-5
	dw 201,1,0,0
	dw 7,0,0,-5, 8,0,0,-5, 9,0,0,-5, 9,0,0,-5
	dw 8,0,0,-5, 7,0,0,-5, 6,0,0,-5, 5,0,0,-5
	dw 204,1
	dw 4,0,0,-5, 3,0,0,-5
	dw 0,0,0,-5, 1,0,0,-5, 2,0,0,-5
	dw _GOTO
	dd tan_course6


tan_course7     label   word  ;   high beam
	dw 0,0,0,0, 1,0,0,0, 2,0,0,0
	dw 3,0,0,0, 4,0,0,0
	dw _GOTO
	dd tan_course7

rock_course     label   word  ;
	dw 0,0,0,0, 1,0,0,0, 2,0,0,0
	dw _GOTO
	dd rock_course

boss_course     label   word ;
	dw 0,0,0,-5
	dw 232,800
	dd contib1,contib1,boss_course
contib1:
	dw 1,0,0,0, 2,0,0,0
	dw 202,3, 202,4, 202,5
	dw 202,6, 202,7, 202,8, 202,9
	dw 202,10, 202,11, 202,12
contib2:
	dw 234,30
	dd left00,conti00,right00
conti00:
	dw 201,1,0,-100
	dw 233,5000-400
	dd bosskill,bosskill,conti01
conti01:
	dw 13,0,0,0
	dw 232,200
	dd backmove,contib2,contib2
backmove:
	dw 201,0,0,-100
	dw 13,0,0,20, 12,0,0,25, 11,0,0,30
	dw 12,0,0,40, 13,0,0,40
	dw 232,500
	dd backmove,contib2,contib2

left00:
	dw 13,-20,0,20
	dw _GOTO
	dd conti00
right00:
	dw 13,20,0,20
	dw _GOTO
	dd conti00

bosskill:
	dw 12,0,0,20, 202,11
	dw 205,1,0,-10
	dw 202,10, 202,9, 202,8
	dw 205,1,0,0
	dw 202,7, 202,6, 202,5, 202,4
	dw 205,1,-20,0
	dw 205,1,20,0
	dw 202,3, 202,2, 202,1
	dw 205,1,-40,0
	dw 202,0
	dw 209
_data   ends
	END
