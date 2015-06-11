;-------------------------------------------------------
;  object course data for IZMIR
;  stage 3
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

extrn   s3tan_spr_data1: dword
extrn   s3tan_spr_data2: dword
extrn   s3tan_spr_data3: dword
extrn   s3tan_spr_data4: dword
extrn   s3tan_spr_data5: dword
extrn   s3tan_spr_data6: dword
extrn   s3tan_spr_data7: dword
extrn   s3tan_spr_data8: dword
extrn   s3boss1_spr_data: dword

	ORG 0
OBJ_DATA        label
enemy_type      label   word
object  <1, 0,    0, 2500,,,,,,, 1, 2500, 40,  2, 0, 0, offset s3tan_spr_data1, offset tan_course1, 0, 0,0,0>
; robot on
object  <2, 0, -100, 2500,,,,,,, 1, 2500, 40,  2, 0, 128, offset s3tan_spr_data2, offset tan_course2, 0, 1,0,0>
; ball in air
object  <3, 0, -100, 2000,,,,,,, 1, 2500, 30,  2, 0, 128, offset s3tan_spr_data3, offset tan_course3, 0, 1,0,0>
; robot in air
object  <4, 0,    0, 2500,,,,,,, 1, 2500, 10,  2, 0, 0, offset s3tan_spr_data4, offset tan_course4, 0, 0,0,0>
; tank
object  <5, 0, -250,  150,,,,,,, 1, 2500, 20,  2, 0, 128, offset s3tan_spr_data5, offset tan_course5, 0, 1,0,0>
; plane
object  <6, 0, -250,  150,,,,,,, 1, 2500, 30,  2, 0, 0, offset s3tan_spr_data6, offset tan_course6, 0, 1,0,0>
; UFO
object  <7, 0,    0, 2500,,,,,,, 0, 2500, 0,  7, 0, 128, offset s3tan_spr_data7, offset tan_course7, 0, 0,0,0>
; beam
object  <8, 0, -250,  150,,,,,,, 1, 2500, 30,  2, 0, 128, offset s3tan_spr_data8, offset tan_course8, 0, 1,0,0>
; plane (kaori)

object  <9, 0,    0, 2500,,,,,,, 1, 2500, 500, 5000, 0, 128, offset s3boss1_spr_data, offset boss_course, 0, 0,0,0>
; BOSS


;---------------------------------------------------------------------
tan_course1     label   word  ; robot on earth
	dw 0,0,0,-5
	dw 201,0,-10,-60
	dw 1,0,0,-5
	dw 2,0,0,-5
	dw 3,0,0,-5
	dw 4,0,0,-5
	dw 5,0,0,-5
	dw _GOTO
	dd tan_course1

tan_course2     label   word  ; ball in air
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


tan_course3     label   word  ;   robot in air

	dw 234,30
	dd course301,loop300,course303

course301:
	dw 0,-20,0,0
	dw 234,30
	dd course301,conti300,conti300
conti300:
	dw 1,-5,0,0, 2,0,0,-5, 202,3
	dw 4,0,0,-10, 5,0,0,-15, 6,0,0,-20

loop300:
	dw 7,0,0,-25
	dw 232,1000
	dd conti301,conti301,loop300
conti301:
	dw 6,0,0,-20, 5,0,0,-15, 4,0,0,-10
	dw 201,1,0,0
	dw 202,4, 202,4, 202,4
	dw 201,1,0,0
	dw 4,0,0,-5, 5,0,0,-10, 6,0,0,-15
loop301:
	dw 7,0,0,-15
	dw 232,500
	dd conti302,conti302,loop301
conti302:
	dw 6,0,0,-10, 5,0,0,0, 4,0,0,10
	dw 201,1,0,0
	dw 4,0,0,20, 202,4
	dw 201,1,0,0
	dw 202,4, 202,4
	dw 201,1,0,0
	dw 4,0,0,-5, 5,0,0,-10, 6,0,0,-15
	dw 7,0,0,-15, -1
;;
course303:
	dw 0+256,20,0,0
	dw 234,30
	dd conti303,conti303,course303
conti303:
	dw 1+256,-5,0,0, 2+256,0,0,-5, 202,3+256
	dw 4,0,0,-10, 5,0,0,-15, 6,0,0,-20
	dw _GOTO
	dd loop300


tan_course4     label   word  ;   tank
	dw 0,5,0,-5,  1,5,0,-5,  2,0,0,-5,  3,5,0,-5,  4,5,0,-5
	dw 0,5,0,-10,  1,5,0,-10,  2,0,0,-10,  3,5,0,-10,  4,5,0,-10
	dw 200,10, 201,1,-5,-20
	dw 0,5,0,-5,  1,5,0,-5,  2,0,0,-5,  3,5,0,-5,  4,5,0,-5
	dw 201,1,-5,-20, 0,-5,0,-5, 1,-5,0,-5,  2,0,0,-5,  3,-5,0,-5,  4,-5,0,-5
	dw 201,1,-5,-20, 0,-5,0,-10, 1,-5,0,-10,  2,0,0,-10,  3,-5,0,-10,  4,-5,0,-10
	dw 0,-5,0,-5, 1,-5,0,-5,  2,0,0,-5,  3,-5,0,-5,  4,-5,0,-5
	dw _GOTO
	dd tan_course4

tan_course5     label   word  ; plane
	dw 0,0,2,80, 200,5, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80
	dw 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80, 0,0,2,80
	dw 0,0,3,60, 0,0,3,60, 0,0,3,60, 0,0,3,40, 0,0,3,40, 0,0,3,40
	dw 0,0,3,40, 0,0,3,40, 0,0,3,30, 0,0,3,20, 0,0,3,10, 0,0,3,10
	dw 234,5
	dd course502,conti500,conti500
conti500:
	dw 1,10,3,10, 1,10,3,10, 1,10,3,10, 1,10,3,10
	dw 2,20,3,10, 2,20,3,10, 2,20,3,10
	dw 2,20,3,10, 2,20,3,10
	dw 3,30,3,0, 3,30,3,0
	dw 3,30,3,0, 3,30,3,0, 201,0,0,0
	dw 4,20,2,-10, 4,20,2,-10, 200,10,  201,0,0,0
	dw 4,20,2,-10, 4,20,2,-10, 4,20,2,-10
	dw 5,10,2,-10, 5,10,2,-10, 5,5,3,-15, 5,5,4,-15, 201,0,0,0
	dw _GOTO
	dd conti501
course502:
	dw 1+256,-10,3,10, 1+256,-10,3,10, 1+256,-10,3,10, 1+256,-10,3,10
	dw 2+256,-20,3,10, 2+256,-20,3,10, 2+256,-20,3,10
	dw 2+256,-20,3,10, 2+256,-20,3,10
	dw 3+256,-30,3,0, 3+256,-30,3,0
	dw 3+256,-30,3,0, 3+256,-30,3,0, 201,0,0,0
	dw 4+256,-20,2,-10, 4+256,-20,2,-10, 200,10,  201,0,0,0
	dw 4+256,-20,2,-10, 4+256,-20,2,-10, 4+256,-20,2,-10
	dw 5+256,-10,2,-10, 5+256,-10,2,-10, 5+256,-5,3,-15, 5+256,-5,4,-15, 201,0,0,0
conti501:
	dw 6,0,5,-20, 6,0,0,-30, -1

tan_course6     label   word  ;   UFO
	dw 0,0,10,50, 1,0,10,50, 2,0,10,50
	dw 4,0,5,50, 5,0,5,50, 6,0,5,50
	dw 7,0,0,60, 8,0,0,60, 9,0,0,60
	dw 10,0,0,50, 11,0,0,50
	dw 201,1,0,0
	dw _GOTO
	dd tan_course6

tan_course7     label   word  ;   high beam
	dw 0,0,0,0, 1,0,0,0, 2,0,0,0
	dw 3,0,0,0, 4,0,0,0
	dw _GOTO
	dd tan_course7

tan_course8     label   word  ;   plane(kaori)
	dw 0,0,0,50
	dw 232,800
	dd tan_course8,tan_course8,conti800
conti800:
	dw 234,10
	dd cos800,cos800,cos801
cos800:
	dw 1+256,0,-5,40, 2+256,0,-10,35, 3+256,0,-5,25
	dw 4+256,0,0,20, 5+256,0,5,15
	dw 6+256,-10,15,15, 7+256,-20,15,15, 8+256,-30,15,15, 9+256,-40,15,15
	dw 10+256,-30,20,10, 11+256,-20,15,10, 12+256,-10,10,5, 13+256,-5,5,0
	dw 201,1,0,0
	dw 14+256,-5,0,0
	dw _GOTO
	dd loop800
cos801:
	dw 1,0,-5,40, 2,0,-10,35, 3,0,-5,25
	dw 4,0,0,20, 5,0,5,15
	dw 6,10,15,15, 7,20,15,15, 8,30,15,15, 9,40,15,15
	dw 10,30,20,10, 11,20,15,10, 12,10,10,5, 13,5,5,0
	dw 201,1,0,0
	dw 14,5,0,-5
loop800:
	dw 15,0,0,-10
	dw 15,0,0,-15
	dw 201,1,0,0
	dw 15,0,0,-20
	dw 15,0,0,-20
	dw _GOTO
	dd loop800


;;BOSS;;
boss_course     label   word  ;
	dw 0,0,0,-15, 1,0,0,-15, 2,0,0,-15, 3,0,0,-15
	dw 201,1,-60,-60
	dw 201,1, 60,-60
	dw 4,0,0,-15, 5,0,0,-15, 6,0,0,-15, 7,0,0,-15
	dw 8,0,0,-15, 9,0,0,-15, 10,0,0,-15
	dw 232,1000
	dd contib1,contib1,boss_course
contib1:
	dw 0,0,0,10
	dw 1,0,0,10
	dw 2,0,0,10
	dw 201,1,-50,-60
	dw 201,1, 50,-60
	dw 3,0,0,10
	dw 4,0,0,10
	dw 5,0,0,10
check00:dw 232,200
	dd backmove,backmove,contib2
contib2:
	dw 6,0,0,20
	dw 7,0,0,20
	dw 8,0,0,20
	dw 201,1,-50,-60
	dw 201,1, 50,-60
	dw 9,0,0,20
	dw 10,0,0,20
	dw 233,5000-400
	dd chkd0,chkd0,contib3
contib3:
	dw 6,0,0,20
	dw 7,0,0,20
check01:dw 232,200
	dd backmove,backmove,contib1
backmove:
	dw 0,0,0,40, 1,0,0,40, 2,0,0,40, 3,0,0,40
	dw 201,0,0,-60
	dw 4,0,0,40, 5,0,0,45, 6,0,0,40, 7,0,0,40
	dw 8,0,0,40, 9,0,0,40, 10,0,0,40
	dw 201,0,0,-60
	dw 234,50
	dd left00,check01,right00

left00: dw 210,-25,0,25
	dw _GOTO
	dd check01

right00:dw 210,25,0,25
	dw _GOTO
	dd check01

bossdown:
	dw 11,0,0,-15, 12,0,0,-15, 13,0,0,-15, 14,0,0,-15
	dw 201,1,-60,-60
	dw 201,1, 60,-60
	dw 15,0,0,-15, 16,0,0,-15, 17,0,0,-15, 18,0,0,-15
	dw 19,0,0,-15, 20,0,0,-15, 21,0,0,-15
	dw _GOTO
	dd chkd001
chkd0:
	dw 11,0,0,0
	dw 205,1,50,-100
	dw 205,1,0,-90
	dw 205,1,-50,-80
	dw 205,1,70,-70
	dw 205,1,-40,-110
chkd001:
	dw 232,1000
	dd contid1,contid1,bossdown
contid1:
	dw 11,0,0,10
	dw 12,0,0,10
	dw 13,0,0,10
	dw 14,0,0,10
	dw 201,1,10,-60
	dw 201,1,-10,-60
	dw 232,200
	dd backmove1,backmove1,contid2
contid2:
	dw 15,0,0,20, 16,0,0,20
	dw 201,1,-60,-60
	dw 201,1, 60,-60
	dw 17,0,0,20, 18,0,0,20
	dw 233,5000-600
	dd bosskill,bosskill,contid3
contid3:
	dw 19,0,0,20, 20,0,0,20
	dw 21,0,0,20
check001:dw 232,200
	dd backmove1,backmove1,contid1
backmove1:
	dw 201,0,0,-60
	dw 205,1,0,0
	dw 11,0,0,40, 12,0,-5,40, 13,0,-10,40, 14,0,-15,40, 15,0,-15,40
	dw 201,0,0,-60
	dw 16,0,0,40, 17,0, 5,40, 18,0, 10,40, 19,0, 15,40, 20,0,15,40
	dw 21,0,10,40
	dw 201,0,0,-60
	dw 234,50
	dd left01,check001,right01

left01: dw 210,-25,0,25
	dw _GOTO
	dd check001

right01:dw 210,25,0,25
	dw _GOTO
	dd check001


bosskill:
	dw 205,1,0,0
	dw 205,1,30,20
	dw 11,0,0,25, 11,0,0,25
	dw 205,1,0,20
	dw 12,0,0,20, 12,0,0,20
	dw 13,0,0,20, 13,0,0,20
	dw 14,0,0,20, 14,0,0,20
	dw 15,0,0,20, 15,0,0,20
	dw 205,1,-20,-20
	dw 15,0,0,20
	dw 205,1,60,-20
	dw 16,0,0,20
	dw 205,1,-60,-40
	dw 16,0,0,20
	dw 205,1,-60,-30
	dw 17,0,0,20
	dw 205,1,-40,-20
	dw 18,0,0,20
	dw 205,1,40,-20
	dw 19,0,0,20
	dw 205,1,-40,-20
	dw 20,0,0,20
	dw 205,1,-60,-80
	dw 205,1,40,-40
	dw 21,0,0,20
	dw 205,1,30,-10
	dw 205,1,-30,-20
	dw 205,1,-30,-30
	dw 21,0,0,20
	dw 205,1,20,-50
	dw 205,1,30,0
	dw 21,0,0,20
	dw 205,1,-30,-20
	dw 205,1,0,0

	dw 209

_data   ends
	END
