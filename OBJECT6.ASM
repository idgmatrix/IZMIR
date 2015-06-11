;-------------------------------------------------------
;  object course data for IZMIR 
;  stage 6
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

extrn   s6tan_spr_data1: dword
extrn   s6tan_spr_data2: dword
extrn   s6tan_spr_data3: dword
extrn   s6tan_spr_data4: dword
extrn   s6tan_spr_data5: dword
extrn   s6tan_spr_data6: dword
extrn   s6boss1_spr_data: dword

	ORG 0
OBJ_DATA        label
enemy_type      label   word
object  <1, 0, -150, 2500,,,,,,, 1, 2500, 20,  2, 0, 0, offset s6tan_spr_data1, offset tan_course1, 0, 1,0,0>
; plane 6 (big)
object  <2, 0, -150, 2500,,,,,,, 0, 2500, 0,  10, 0, 0, offset s6tan_spr_data2, offset tan_course2, 0, 1,0,0>
; horiz beam
object  <3, 0, -100, 2500,,,,,,, 1, 2500, 30,  2, 0, 128, offset s6tan_spr_data3, offset tan_course3, 0, 1,0,0>
; UFO
object  <4, 0, -250, 2500,,,,,,, 1, 2500, 30,  2, 0, 0, offset s6tan_spr_data4, offset tan_course4, 0, 1,0,0>
; plane
object  <5, 0, -200,  150,,,,,,, 1, 2500, 30,  2, 0, 0, offset s6tan_spr_data5, offset tan_course5, 0, 1,0,0>
; UFO
object  <6, 0, -250,  150,,,,,,, 1, 2500, 30,  2, 0, 128, offset s6tan_spr_data6, offset tan_course6, 0, 1,0,0>
; palne

object  <7, 0, -100, 2500,,,,,,, 1, 2500, 500, 5000, 0, 128, offset s6boss1_spr_data, offset boss_course, 0, 1,0,0>
; BOSS


;---------------------------------------------------------------------
tan_course1     label   word
	dw 0,0,0,-10, 202,1, 202,2, 202,3, 202,2
	dw 202,1, 202,0, 202,4, 202,5, 202,6
	dw 201,1,0,0
	dw 202,5, 202,4, _GOTO
	dd tan_course1

tan_course2     label   word
	dw 0,0,0,-5, 1,0,5,-5, 2,0,10,-5
	dw 0,0,15,-5, 1,0,20,-5

	dw 0,0,25,-5, 1,0,20,-5, 2,0,15,-5
	dw 0,0,10,-5, 1,0,5,-5

	dw 0,0,0,-5, 1,0,-5,-5, 2,0,-10,-5
	dw 0,0,-15,-5, 1,0,-20,-5

	dw 0,0,-25,-5, 1,0,-20,-5, 2,0,-15,-5
	dw 0,0,-10,-5, 1,0,-5,-5
	dw _GOTO
	dd tan_course2

tan_course3     label   word  ;  UFO
	dw 0,0,0,-4,    1,0,2,-4,  2,0,5,-4,  3,0,7,-4,  4,0,10,-4
	dw 200,10, 201,1,0,0
	dw 0,0,10,-4, 1,0,7,-4, 2,0,5,-4, 3,0,2,-4, 4,0,0,-4
	dw 0,0,0,-4, 1,0,-2,-4, 2,-0,-5,-4, 3,0,-7,-4, 4,0,-10,-4
	dw 0,0,-10,-4, 1,0,-7,-4, 2,0,-5,-4, 3,0,-2,-4, 4,0,0,-4
	dw _GOTO
	dd tan_course3

tan_course4     label   word  ; plane 5
	dw 4,0,0,-10, 5,0,0,-10, 6,0,0,-10, 7,0,0,-10
	dw 232,700
	dd conti222,tan_course4,tan_course4
conti222:
	dw 201,1,0,0
	dw 3,0,10,0, 2,0,10,0, 1,0,10,0, 0,0,10,0
	dw 1,0,10,0, 2,0,10,0, 3,0,10,0
	dw 201,1,0,0
loop222:
	dw 4,0,0,-10, 5,0,0,-10, 6,0,0,-10, 7,0,0,-10
	dw _GOTO
	dd loop222

tan_course5     label   word  ;   UFO
	dw 0,0,10,50, 1,0,10,50, 2,0,10,50
	dw 4,0,5,50, 5,0,5,50, 6,0,5,50
	dw 7,0,0,60, 8,0,0,60, 9,0,0,60
	dw 10,0,0,50, 11,0,0,50
	dw 201,1,0,0
	dw _GOTO
	dd tan_course5

tan_course6     label   word  ; plane
	dw 0,0,2,80, 200,5, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80
	dw 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80
	dw 0,0,3,60, 0,0,3,60, 0,0,3,60, 0,0,3,40, 0,0,3,40, 0,0,3,40
	dw 0,0,3,40, 0,0,3,40, 0,0,3,30, 0,0,3,20, 0,0,3,10, 0,0,3,10
	dw 234,5
	dd course602,conti600,conti600
conti600:
	dw 1,10,3,10, 1,10,3,10, 1,10,3,10, 1,10,3,10
	dw 2,20,3,10, 2,20,3,10, 2,20,3,10
	dw 2,20,3,10, 2,20,3,10
	dw 3,30,3,0, 3,30,3,0
	dw 3,30,3,0, 3,30,3,0, 201,0,0,0
	dw 4,20,2,-10, 4,20,2,-10, 200,10,  201,0,0,0
	dw 4,20,2,-10, 4,20,2,-10, 4,20,2,-10
	dw 5,10,2,-10, 5,10,2,-10, 5,5,3,-15, 5,5,4,-15, 201,0,0,0
	dw _GOTO
	dd conti601
course602:
	dw 1+256,-10,3,10, 1+256,-10,3,10, 1+256,-10,3,10, 1+256,-10,3,10
	dw 2+256,-20,3,10, 2+256,-20,3,10, 2+256,-20,3,10
	dw 2+256,-20,3,10, 2+256,-20,3,10
	dw 3+256,-30,3,0, 3+256,-30,3,0
	dw 3+256,-30,3,0, 3+256,-30,3,0, 201,0,0,0
	dw 4+256,-20,2,-10, 4+256,-20,2,-10, 200,10,  201,0,0,0
	dw 4+256,-20,2,-10, 4+256,-20,2,-10, 4+256,-20,2,-10
	dw 5+256,-10,2,-10, 5+256,-10,2,-10, 5+256,-5,3,-15, 5+256,-5,4,-15, 201,0,0,0
conti601:
	dw 6,0,5,-20, 6,0,0,-30, -1

;;;;;;BOSS;;;;;;;
boss_course     label   word  ;
	dw 0,0,0,-15, 1,0,0,-15, 2,0,0,-15, 3,0,0,-15
	dw 201,1,-55,-70
	dw 4,0,0,-15, 5,0,0,-15, 6,0,0,-15, 7,0,0,-15
	dw 8,0,0,-15, 9,0,0,-15
	dw 232,800
	dd contib1,contib1,boss_course
contib1:
	dw 0,0,0,10
	dw 1,0,0,10
	dw 2,0,0,10
	dw 201,1,-55,-70
	dw 3,0,0,10
	dw 201,1,-55,-70
	dw 4,0,0,10
	dw 201,1,-55,-70
	dw 5,0,0,10
check00:dw 232,200
	dd backmove0,backmove0,contib2
contib2:
	dw 6,0,0,10
	dw 7,0,0,10
	dw 8,0,0,10
	dw 234,50
	dd left00,nextl,right00
nextl:
	dw 9,0,0,20
	dw 233,5000-400
	dd chkd0,chkd0,contib3
contib3:
	dw 6,0,0,20
	dw 7,0,0,20
check01:dw 232,200
	dd backmove0,backmove0,contib1
backmove0:
	dw 0,0,0,30, 1,0,0,30, 2,0,0,30, 3,0,0,30
	dw 201,1,-55,-70
	dw 4,0,0,30, 5,0,0,30, 6,0,0,30, 7,0,0,30
	dw 8,0,0,30, 9,0,0,30
	dw 201,1,-55,-70
	dw _GOTO
	dd check00

left00: dw 210,-25,0,20
	dw _GOTO
	dd check00

right00:dw 210,25,0,20
	dw _GOTO
	dd check00

bossdown:
	dw 10,0,0,0
	dw 11,0,0,0, 12,0,0,0, 13,0,0,0, 14,0,0,0
	dw 201,1,-55,-70
	dw 15,0,0,0, 16,0,0,0, 17,0,0,0, 18,0,0,0
	dw 19,0,0,0
	dw _GOTO
	dd chkboss000
chkd0:
	dw 10,0,5,10
	dw 11,0,5,0
	dw 205,1,10,-70
	dw 205,1,0,-75
	dw 205,1,-10,-60
chkboss000:
	dw 232,1000
	dd contid1,contid1,bossdown
contid1:
	dw 12,0,0,10
	dw 201,1,-55,-70
	dw 13,0,0,20
	dw 14,0,0,10
	dw 201,1,-55,-70
	dw 232,200
	dd backmove1,backmove1,contid2
contid2:
	dw 15,0,0,10, 16,0,0,20
	dw 17,0,0,10, 18,0,0,10
	dw 233,5000-500
	dd bosskill,bosskill,contid3
contid3:
	dw 19,0,0,10
check001:dw 232,200
	dd backmove1,backmove1,contid1
backmove1:
	dw 201,1,-55,-70
	dw 11,0,0,40, 12,0,0,40, 13,0,0,40, 14,0,0,40, 15,0,0,40
	dw 16,0,0,40, 17,0,0,40, 18,0,0,40, 19,0,0,40
	dw 201,1,-55,-70
	dw 234,50
	dd left01,check001,right01

left01: dw 210,-20,0,20
	dw _GOTO
	dd check001

right01:dw 210,20,0,20
	dw _GOTO
	dd check001


bosskill:
	dw 205,1,0,-50
	dw 205,1,30,-20
	dw 11,0,0,10, 11,0,0,10
	dw 205,1,20,-80
	dw 12,0,0,20, 12,0,0,20
	dw 13,0,0,20, 13,0,0,20
	dw 14,0,0,20, 14,0,0,20
	dw 15,0,0,20, 15,0,0,20
	dw 205,1,-20,-30
	dw 15,0,0,20
	dw 205,1,30,-70
	dw 16,0,0,20
	dw 205,1,-30,-20
	dw 16,0,0,20
	dw 205,1,0,-40
	dw 17,0,0,20
	dw 205,1,-20,-90
	dw 18,0,0,20
	dw 205,1,40,-80
	dw 19,0,0,20
	dw 205,1,-40,-30
	dw 19,0,0,20
	dw 205,1,-30,-40
	dw 205,1,20,-40
	dw 19,0,0,20
	dw 205,1,0,-20
	dw 205,1,0,-40
	dw 205,1,-30,-30
	dw 19,0,0,20
	dw 205,1,20,-50
	dw 205,1,30,0
	dw 19,0,0,20
	dw 205,1,-30,-70
	dw 205,1,0,-70

	dw 209


_data   ends
	END
