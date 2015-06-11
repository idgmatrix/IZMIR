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

extrn   name001: dword
extrn   name002: dword
extrn   name003: dword
extrn   name004: dword
extrn   name005: dword
extrn   name006: dword
extrn   name007: dword
extrn   name008: dword
extrn   name009: dword
extrn   name010: dword

	ORG 0
OBJ_DATA        label
enemy_type      label   word
object  < 1, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name001, offset name_course, 0, 1,0,0>
object  < 2, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name002, offset name_course, 0, 1,0,0>
object  < 3, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name003, offset name_course, 0, 1,0,0>
object  < 4, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name004, offset name_course, 0, 1,0,0>
object  < 5, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name005, offset name_course, 0, 1,0,0>
object  < 6, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name006, offset name_course, 0, 1,0,0>
object  < 7, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name007, offset name_course, 0, 1,0,0>
object  < 8, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name008, offset name_course, 0, 1,0,0>
object  < 9, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name009, offset name_course, 0, 1,0,0>
object  <10, 0, -200, 150,,,,,,, 0, 2500, 20,  2, 0, 128, offset name010, offset name_course, 0, 1,0,0>

name_course     label   
	dw 0,0,10,20
	dw 0,0,10,20
	dw 0,0,10,20
	dw 0,0,10,20
	dw 0,0,10,25
	dw 0,0,10,25
	dw 0,0,10,25
	dw 0,0,5,30
	dw 0,0,0,30,-1

_data   ends
	END
