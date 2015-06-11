	;======================================
	;  IZ_DEMO.ASM (IZMIR DEMO)
	;  DOS/4GW 386 DOS extender
	;         1995. 4. 30
	;  coded by JEONG, JAE-SEONG
	;
	;  Movie Flic File Player 
	;  BGM Player
	;
	;  (c) Mirinae Software, Inc.
	;  License : Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	;======================================

	.386

	LOCALS

_DATA   SEGMENT DWORD USE32 PUBLIC 'DATA'

	;
PUBLIC  SAVE_CONT
_INT0F0H        EQU     0F0H
	;
INST_LOAD:
MUSIC_MODEL:    DB      04      ;0
SPEED:          DB      00
JOSTICK0:       DB      00
JOSTICK1:       DB      00
	;
JOYX0:          DW      1400,850,000
JOYY0:          DW      1400,850,000
JOYX1:          DW      1400,850,000
JOYY1:          DW      1400,850,000
		DW      00,00,00
		DW      00,00,00
INSTALL:        DB      'CONFIG.DAT',00
		;
		;
		;
SAVE_CONT:      DD      00
VOLUME:         DB      00
STACK_OFF:      DD      00
STACK_SEG:      DW      00
FILE_FLI:       DD      00
CBUF:           DD      00
SAVEINT:        DD      00
ERRDAT:         DB      00
HANDLE:         DW      00
LENTH:          DD      00
BUFFER0:        DD      00
BUFFER1:        DD      00
BUFFER2:        DD      00
;       KEYDAT0:        DB      00
ALTKEY:         DB      01
ALT_JMP:        DD      00
ALT_JMP1:       DD      00
TIME0:          DD      00
BL_PLAY:        DB      00
VOC_ADD:        DD      00
LENTH_ADD:      DD      00
MUSIC_LOOP:     DB      00
		;
SEG_MEM:        DW      00

REG_BLK         STRUC
		_EDI    DD      00000H  ;EDI
		_ESI    DD      00000H  ;ESI
		_EBP    DD      00000H  ;EBP
		_000    DD      00000H  ;000
		_EBX    DD      00000H  ;EBX
		_EDX    DD      00000H  ;EDX
		_ECX    DD      00300H  ;ECX
		_EAX    DD      00001H  ;EAX
		_FLAGS  DW      00000H  ;FLAGS
		_ES     DW      0A000H  ;ES
		_DS     DW      06000H  ;DS
		_FS     DW      00000H  ;FS
		_GS     DW      00000H  ;GS
		_IP     DW      00000H  ;IP
		_CS     DW      00000H  ;CS
		_SP     DW      00000H  ;SP
		_SS     DW      00000H  ;SS
REG_BLK         ENDS

REG_BLK01       REG_BLK < >

LOG_FILE:
	DB      'MIRE    .GRP',00,72H
MIRINAE_NU      EQU     (MIRINAE1 - MIRINAE)/14
MIRINAE:
;       DB      'B01     .GRP',00,72H
;       DB      'B02     .GRP',00,72H
;       DB      'B03     .GRP',00,72H
;       DB      'B04     .GRP',00,72H
	DB      'A1      .GRP',00,50H
	DB      'A2      .GRP',00,50H
	DB      'C01     .GRP',00,0A0H
;       DB      'C02     .GRP',00,72H
	DB      'A3      .GRP',00,72H
	DB      'A4      .GRP',00,72H
	DB      'A5      .GRP',00,72H
	DB      'A6      .GRP',00,72H
	DB      'A7      .GRP',00,72H
	DB      'A8      .GRP',00,72H
MIRINAE1:

STAGE_FLI:
	DB      'NEW2    .GRP',00,72H
	DB      'NEW3    .GRP',00,72H
	DB      'NEW1    .GRP',00,72H
	DB      'NEW4    .GRP',00,72H
	DB      'NEW5    .GRP',00,72H
	DB      'NEW6    .GRP',00,72H
	DB      'E1      .GRP',00,72H
	;
OVER_FLI:
	DB      'EXIT    .GRP',00,72H
	;
	;

MUS_LEN         EQU     14

OPEN_MUSIC_FILE:
	DB      'A-I-PROL.MUE',00,00
	DB      'A-I-PROL.MUE',00,00
	DB      'A-I-PROL.MUE',00,00
	DB      'S-I-PROL.MUE',00,00
	DB      'S-I-PROL.MUE',00,00
MENU_MUSIC_FILE:
	DB      'A-I-MENU.MUE',00,00
	DB      'A-I-MENU.MUE',00,00
	DB      'A-I-MENU.MUE',00,00
	DB      'S-I-MENU.MUE',00,00
	DB      'S-I-MENU.MUE',00,00
OVER_MUSIC_FILE:
	DB      'A-I-OVER.MUE',00,00
	DB      'A-I-OVER.MUE',00,00
	DB      'A-I-OVER.MUE',00,00
	DB      'S-I-OVER.MUE',00,00
	DB      'S-I-OVER.MUE',00,00
STAGE_MUSIC_FILE:
	;       1
	DB      'A-I-S1  .MUE',00,00
	DB      'A-I-S1  .MUE',00,00
	DB      'A-I-S1  .MUE',00,00
	DB      'S-I-S1  .MUE',00,00
	DB      'S-I-S1  .MUE',00,00
	;       2
	DB      'A-I-S2  .MUE',00,00
	DB      'A-I-S2  .MUE',00,00
	DB      'A-I-S2  .MUE',00,00
	DB      'S-I-S2  .MUE',00,00
	DB      'S-I-S2  .MUE',00,00
	;       3
	DB      'A-I-S3  .MUE',00,00
	DB      'A-I-S3  .MUE',00,00
	DB      'A-I-S3  .MUE',00,00
	DB      'S-I-S3  .MUE',00,00
	DB      'S-I-S3  .MUE',00,00
	;       4
	DB      'A-I-S4  .MUE',00,00
	DB      'A-I-S4  .MUE',00,00
	DB      'A-I-S4  .MUE',00,00
	DB      'S-I-S4  .MUE',00,00
	DB      'S-I-S4  .MUE',00,00
	;       5
	DB      'A-I-S5  .MUE',00,00
	DB      'A-I-S5  .MUE',00,00
	DB      'A-I-S5  .MUE',00,00
	DB      'S-I-S5  .MUE',00,00
	DB      'S-I-S5  .MUE',00,00
	;       6
	DB      'A-I-S6  .MUE',00,00
	DB      'A-I-S6  .MUE',00,00
	DB      'A-I-S6  .MUE',00,00
	DB      'S-I-S6  .MUE',00,00
	DB      'S-I-S6  .MUE',00,00
	;       7
	DB      'A-I-STAF.MUE',00,00
	DB      'A-I-STAF.MUE',00,00
	DB      'A-I-STAF.MUE',00,00
	DB      'S-I-STAF.MUE',00,00
	DB      'S-I-STAF.MUE',00,00
	;
	;
END_MUSIC_FILE:
	DB      'A-I-END .MUE',00,00
	DB      'A-I-END .MUE',00,00
	DB      'A-I-END .MUE',00,00
	DB      'S-I-END .MUE',00,00
	DB      'S-I-END .MUE',00,00

GS_SYN1:        DB      'GS-RESET.SYX',00,00
GS_SYN2:        DB      'GS-HALL1.SYX',00,00
MT_SYN1:        DB      'MT-RESET.SYX',00,00
MT_SYN2:        DB      'MT-GM1  .SYX',00,00
MT_SYN3:        DB      'MT-GM2  .SYX',00,00

_DATA   ENDS

_BSS    SEGMENT DWORD USE32 PUBLIC 'BSS'

EXTRN   keyboard
KEYDAT0 equ     keyboard+39h
EXTRN pcx_buffer0
LOAD_MEMORY     EQU     pcx_buffer0

_BSS    ENDS



DGROUP  GROUP   _DATA,_BSS      ;,_STACK

_TEXT   SEGMENT DWORD USE32 PUBLIC 'CODE'
	ASSUME  CS:_TEXT,DS:DGROUP,ES:DGROUP
extrn   xmode:near
PUBLIC  SET_SYX
PUBLIC  STAGE_MUSIC
PUBLIC  MENU_MUSIC
PUBLIC  OVER_MUSIC
PUBLIC  END_MUSIC
PUBLIC  OPENING
PUBLIC  PLAY_MUSIC
PUBLIC  STOP_MUSIC
PUBLIC  SETTIME
PUBLIC  INTTIME
PUBLIC  INTERVIZ
	;
	;
	;
	;
	;
SET_SYX:
	MOV     EBX,1000H               ;SEG 1000H = ADDRESS 10000H
	CALL    REAL_MEM_PRG            ;REAL MEMORY ALLOCATION
	MOV     EDX,OFFSET INSTALL
	MOV     ESI,OFFSET INST_LOAD
	CALL    DKREAD
	CALL    DELAY_TIME
	;
	CALL    RESET_MUSIC
	XOR     EAX,EAX
	MOV     AL,BYTE PTR MUSIC_MODEL
	SHL     EAX,2
	MOV     EBP,OFFSET SET_SYX000
	ADD     EBP,EAX
	CALL    CS:[EBP]
	RET

SET_SYX000:
	DD      NON_000
	DD      ADLIB_000
	DD      ADLIB_000
	DD      MT_000
	DD      GS_000
	;
	;

NON_000:
ADLIB_000:
	RET

MT_000:
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	MOV     EDX,OFFSET MT_SYN1
	CALL    DKREAD
	MOV     ECX,DWORD PTR LENTH
	CALL    SEND_EX
	;
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	MOV     EDX,OFFSET MT_SYN2
	CALL    DKREAD
	MOV     ECX,DWORD PTR LENTH
	CALL    SEND_EX
	;
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	MOV     EDX,OFFSET MT_SYN3
	CALL    DKREAD
	MOV     ECX,DWORD PTR LENTH
	CALL    SEND_EX
	RET

GS_000:
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	MOV     EDX,OFFSET GS_SYN1
	CALL    DKREAD
	MOV     ECX,DWORD PTR LENTH
	CALL    SEND_EX
	;
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	MOV     EDX,OFFSET GS_SYN2
	CALL    DKREAD
	MOV     ECX,DWORD PTR LENTH
	CALL    SEND_EX
	RET

STAGE_MUSIC: ;; stage music setting
	MOV     AH,14*5
	MUL     AH
	MOV     ECX,EAX
	;
	XOR     EAX,EAX
	MOV     AL,BYTE PTR MUSIC_MODEL
	MOV     AH,14
	MUL     AH
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDX,OFFSET STAGE_MUSIC_FILE
	ADD     EDX,EAX
	ADD     EDX,ECX
	CALL    DKREAD
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDI,OFFSET LOAD_MEMORY+65536
	CALL    LZEXE
	SUB     EDI,OFFSET LOAD_MEMORY+65536
	MOV     ECX,EDI
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	CALL    MOVE_PRO_REAL
	MOV     AL,2            ;2 -> LOOP, 3 -> ONE PLAY
	MOV     BYTE PTR MUSIC_LOOP,AL
	CALL    SET_MUSIC

	RET

INTERVIZ:
	PUSH    EAX
	;
	MOV     ECX,-1
	CALL    SETTIME
	;
	POP     EAX
	MOV     AH,14
	MUL     AH
	MOV     EDX,OFFSET STAGE_FLI
	ADD     EDX,EAX
	XOR     ECX,ECX
	MOV     CL,[EDX+13]     ;072H
	MOV     DWORD PTR TIME0,ECX
	MOV     DWORD PTR FILE_FLI,EDX
	CALL    FLI_FILE_RUN
	CALL    VRAMCLS00
	RET
	;
	;
	;
	;
MENU_MUSIC:
	MOV     AL,BYTE PTR MUSIC_MODEL
	MOV     AH,14
	MUL     AH
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDX,OFFSET MENU_MUSIC_FILE
	ADD     EDX,EAX
	CALL    DKREAD
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDI,OFFSET LOAD_MEMORY+65536
	CALL    LZEXE
	SUB     EDI,OFFSET LOAD_MEMORY+65536
	MOV     ECX,EDI
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	CALL    MOVE_PRO_REAL
	MOV     AL,2            ;2 -> LOOP, 3 -> ONE PLAY
	MOV     BYTE PTR MUSIC_LOOP,AL
	CALL    SET_MUSIC
	RET
	;
	;
	;
	;
OVER_MUSIC:
	MOV     AX,13H
	INT     10H
	;
	CLI
	MOV     AX,SS
	MOV     WORD PTR STACK_SEG,AX
	MOV     EAX,ESP
	MOV     DWORD PTR STACK_OFF,EAX
	STI
	XOR     EAX,EAX
	MOV     AL,BYTE PTR MUSIC_MODEL
	MOV     AH,14
	MUL     AH
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDX,OFFSET OVER_MUSIC_FILE
	ADD     EDX,EAX
	CALL    DKREAD
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDI,OFFSET LOAD_MEMORY+65536
	CALL    LZEXE
	SUB     EDI,OFFSET LOAD_MEMORY+65536
	MOV     ECX,EDI
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	CALL    MOVE_PRO_REAL
	;
	MOV     AL,3            ;2 -> LOOP, 3 -> ONE PLAY
	MOV     BYTE PTR MUSIC_LOOP,AL
	CALL    SET_MUSIC
	MOV     ECX,-1
	CALL    SETTIME
	CALL    PLAY_MUSIC
	;
	MOV     AL,0
	MOV     BYTE PTR ALTKEY,AL
	MOV     EAX,OFFSET OVER_END
	MOV     DWORD PTR ALT_JMP,EAX
	;
	MOV     ECX,5
OVER_MUSIC01:
	PUSH    ECX
	MOV     EDX,OFFSET OVER_FLI
	XOR     ECX,ECX
	MOV     CL,[EDX+13]     ;072H
	MOV     DWORD PTR TIME0,ECX
	MOV     DWORD PTR FILE_FLI,EDX
	CALL    FLI_FILE_RUN
	POP     ECX
	LOOP    OVER_MUSIC01
	;
OVER_END:
	MOV     AL,1
	MOV     BYTE PTR ALTKEY,AL
	CLI
	MOV     AX,WORD PTR STACK_SEG
	MOV     SS,AX
	MOV     EAX,DWORD PTR STACK_OFF
	MOV     ESP,EAX
	STI
	CALL    VRAMCLS00
	CALL    STOP_MUSIC
	CALL    xmode
	RET
	;
	;
	;
	;
END_MUSIC:
	MOV     AL,BYTE PTR MUSIC_MODEL
	MOV     AH,14
	MUL     AH
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDX,OFFSET END_MUSIC_FILE
	ADD     EDX,EAX
	CALL    DKREAD
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDI,OFFSET LOAD_MEMORY+65536
	CALL    LZEXE
	SUB     EDI,OFFSET LOAD_MEMORY+65536
	MOV     ECX,EDI
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	CALL    MOVE_PRO_REAL
	MOV     AL,2            ;2 -> LOOP, 3 -> ONE PLAY
	MOV     BYTE PTR MUSIC_LOOP,AL
	CALL    SET_MUSIC
	RET
	;
	;
	;
	;
	;
OPENING:
	MOV     AX,13H
	INT     10H
	;
	CLI
	MOV     AX,SS
	MOV     WORD PTR STACK_SEG,AX
	MOV     EAX,ESP
	MOV     DWORD PTR STACK_OFF,EAX
	STI
	;
	XOR     EAX,EAX
	MOV     AL,BYTE PTR MUSIC_MODEL
	MOV     AH,14
	MUL     AH
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDX,OFFSET OPEN_MUSIC_FILE
	ADD     EDX,EAX
	CALL    DKREAD
	MOV     ESI,OFFSET LOAD_MEMORY+65536+8000H
	MOV     EDI,OFFSET LOAD_MEMORY+65536
	CALL    LZEXE
	;
	SUB     EDI,OFFSET LOAD_MEMORY+65536
	MOV     ECX,EDI
	MOV     ESI,OFFSET LOAD_MEMORY+65536
	CALL    MOVE_PRO_REAL
	;
	MOV     ECX,-1
	CALL    SETTIME
	MOV     EDX,OFFSET LOG_FILE
	XOR     ECX,ECX
	MOV     CL,[EDX+13]     ;072H
	MOV     DWORD PTR TIME0,ECX
	MOV     DWORD PTR FILE_FLI,EDX
	CALL    FLI_FILE_RUN
	CALL    VRAMCLS00
	;
	;
	;
	MOV     AL,3            ;2 -> LOOP, 3 -> ONE PLAY
	MOV     BYTE PTR MUSIC_LOOP,AL
	CALL    SET_MUSIC
	MOV     ECX,-1
	CALL    SETTIME
	CALL    PLAY_MUSIC
	;
	MOV     AL,0
	MOV     BYTE PTR ALTKEY,AL
	MOV     EAX,OFFSET OPEN_END
	MOV     DWORD PTR ALT_JMP,EAX
	;
	MOV     ECX,MIRINAE_NU
	MOV     EDX,OFFSET MIRINAE
MAIN_000:
	PUSH    ECX
	PUSH    EDX
	XOR     ECX,ECX
	MOV     CL,[EDX+13]     ;072H
	MOV     DWORD PTR TIME0,ECX
	MOV     DWORD PTR FILE_FLI,EDX
	CALL    FLI_FILE_RUN
	POP     EDX
	POP     ECX
	CMP     ECX,1
	JZ      MAIN_001
	PUSH    ECX
	PUSH    EDX
	CALL    VRAMCLS00
	POP     EDX
	POP     ECX
	ADD     EDX,14
	LOOP    MAIN_000
MAIN_001:
	MOV     ECX,1164*2
	CALL    INT_TIME0
MAIN_002:
OPEN_END:
	MOV     AL,1
	MOV     BYTE PTR ALTKEY,AL
	CLI
	MOV     AX,WORD PTR STACK_SEG
	MOV     SS,AX
	MOV     EAX,DWORD PTR STACK_OFF
	MOV     ESP,EAX
	STI
	CALL    VRAMCLS00
	CALL    STOP_MUSIC
	CALL    xmode
	RET
	;
	;
	;
	;
	;
	;
	;
	;
	;
	;
	;
FLI_FILE_RUN:
JSP21:
	MOV     EDX,DWORD PTR FILE_FLI
	CALL    OPENFILE
	;
	CLI
	MOV     EAX,DWORD PTR ALT_JMP
	MOV     DWORD PTR ALT_JMP1,EAX
	MOV     EAX,OFFSET JSP_END
	MOV     DWORD PTR ALT_JMP,EAX
	STI
	;
	MOV     ESI,OFFSET LOAD_MEMORY
	MOV     ECX,128
	CALL    GETFILE
	;
	MOV     EBP,OFFSET LOAD_MEMORY
	MOV     AX,DS:[EBP+4]
	CMP     AX,0AF11H
	JZ      JSK_MAIN
	;
JSP10:  CALL    CLOSEFILE
	CLI
	MOV     EAX,DWORD PTR ALT_JMP1
	MOV     DWORD PTR ALT_JMP,EAX
	STI
	RET
	;
	;
	;
JSP_END:
	MOV     AL,1
	MOV     BYTE PTR ALTKEY,AL
	CLI
	MOV     EAX,DWORD PTR ALT_JMP1
	MOV     DWORD PTR ALT_JMP,EAX
	STI
	CALL    CLOSEFILE
	JMP     DWORD PTR ALT_JMP1
	;
	;
	;               END FILES
	;
	;
JSK_MAIN:
	XOR     ECX,ECX
	MOV     CX,DS:[EBP+6]
JSKMAIN10:
	PUSH    ECX
	MOV     ESI,OFFSET LOAD_MEMORY
	MOV     ECX,16
	CALL    GETFILE
	MOV     EBP,OFFSET LOAD_MEMORY
	MOV     AX,DS:[EBP+4]
	CMP     AX,0F1FAH
	JZ      JSK_MAIN1
	POP     ECX
	JMP     JSP10           ;END
	;
	;
	;
JSK_MAIN1:
	XOR     ECX,ECX
	MOV     CX,DS:[EBP+6]
	CMP     CX,0
	JZ      JSK_MAIN5
	PUSH    ECX
	MOV     ECX,DS:[EBP+0]
	SUB     ECX,16
	MOV     ESI,OFFSET LOAD_MEMORY
	CALL    GETFILE
	POP     ECX
	MOV     EBP,OFFSET LOAD_MEMORY
JSKMAIN11:
	PUSH    ECX
	PUSH    EBP
	MOV     AX,DS:[EBP+4]
	ADD     EBP,6
	SUB     AX,11
JSKMAIN13:
	CMP     AX,6
	JC      JSK_MAIN4
	POP     EBP
	POP     ECX
	POP     ECX
	JMP     JSP10           ;END
	;
	;
	;
JSK_MAIN4:
	MOV     ESI,OFFSET CBUF
	MOV     [ESI],EBP
	SHL     AX,2
	MOV     EDI,OFFSET MIRINAE_0
	ADD     DI,AX
	ADC     EDI,0
	CALL    CS:[EDI]
	POP     EBP
	POP     ECX
	MOV     AX,DS:[EBP]
	ADD     BP,AX
	ADC     EBP,0
	LOOP    JSKMAIN11
	MOV     ECX,DWORD PTR TIME0
	CALL    INT_TIME0
JSK_MAIN5:
	POP     ECX
	LOOP    JSKMAIN_10
	JMP     JSP10
	;
	;
	;
	;
JSKMAIN_10:
	JMP     JSKMAIN10
	;
	;
	;
	;
	;
	;
	;
	;

JS_MAIN:
	XOR     ECX,ECX
	MOV     CX,DS:[EBP+6]
	ADD     EBP,128
JSMAIN10:
	PUSH    ECX
	MOV     AX,DS:[EBP+4]
	CMP     AX,0F1FAH
	JZ      JS_MAIN1
	POP     ECX
	RET             ;END
	;
	;
	;
JS_MAIN1:
	XOR     ECX,ECX
	MOV     CX,DS:[EBP+6]
	ADD     EBP,16
	CMP     CX,0
	JZ      JS_MAIN5
JSMAIN11:
	PUSH    ECX
	PUSH    EBP
	MOV     AX,DS:[EBP+4]
	ADD     EBP,6
	SUB     AX,11
JSMAIN13:
	CMP     AX,6
	JC      JS_MAIN4
	POP     EBP
	POP     ECX
	POP     ECX
	RET                     ;END
	;
	;
	;
JS_MAIN4:
	MOV     ESI,OFFSET CBUF
	MOV     [ESI],EBP
	SHL     AX,2
	MOV     EDI,OFFSET MIRINAE_0
	ADD     DI,AX
	ADC     EDI,0
	CALL    CS:[EDI]
	POP     EBP
	POP     ECX
	MOV     AX,DS:[EBP]
	ADD     BP,AX
	ADC     EBP,0
	LOOP    JSMAIN11
	MOV     ECX,DWORD PTR TIME0
	CALL    INT_TIME0
JS_MAIN5:
	POP     ECX
	LOOP    JSMAIN10
	RET
	;
	;
	;
	;
	;
MIRINAE_0:
	DD      FLI_RGB   ;11      0
	DD      FLI_LC    ;12      1
	DD      FLI_BLK   ;13      2
	DD      FLI_COPY  ;14   X  3
	DD      FLI_RLE   ;15      4
	DD      FLI_COPY  ;16      5
	;----------------------------------------
	;
	;
	;
	;
	;---------------------------------------
FLI_RGB:
	;       RGBSET00:
	MOV     ESI,OFFSET CBUF
	MOV     ESI,[ESI]
	XOR     CH,CH
	XOR     AH,AH
	MOV     CL,[ESI+2]
	MOV     AL,[ESI+3]
	MOV     BX,[ESI+2]
	ADD     ESI,4
	CMP     BX,0
	JNZ     RGBSET02
	MOV     CX,0    ;ECX,0  ;???
	MOV     DI,256
	JMP     RGBSET01
RGBSET02:
	MOV     DI,CX
	ADD     DI,AX
RGBSET01:
	MOV     AL,CL
	MOV     AH,[ESI]
	MOV     BL,[ESI+1]
	MOV     BH,[ESI+2]
	PUSH    ECX
	CALL    COLOR
	POP     ECX
	ADD     ESI,3
	INC     CX
	CMP     CX,DI
	JC      RGBSET01
	RET
	;----------------------------------------
	;
	;
	;
	;
	;----------------------------------------
FLI_COPY:
	CLD
	MOV     ESI,DWORD PTR CBUF
	MOV     EDI,0A0000H     ;0
	MOV     ECX,16000       ;64000/4
	REP     MOVSD
;FLI_COPY01:
;       MOV     EAX,[ESI]
;       MOV     ES:[EDI],EAX
;       ADD     ESI,4
;       ADD     EDI,4
;       LOOP    FLI_COPY01
	RET
	;---------------------------------------
	;
	;
	;
	;
	;---------------------------------------
FLI_BLK:
	CLD
	MOV     EDI,0A0000H     ;0
	MOV     ECX,16000               ;64000/4
	XOR     EAX,EAX
	REP     STOSD
;FLI_BLK01:
;       MOV     ES:[EDI],EAX
;       ADD     EDI,4
;       LOOP    FLI_BLK01
	RET

	;--------------------------------------
	;
	;
	;
	;--------------------------------------
FLI_LC:
	CLD
	MOV     ESI,DWORD PTR CBUF
	MOV     EDI,0A0000H     ;0
	LODSW
	MOV     DX,320
	MUL     DX
	ADD     DI,AX
	LODSW
	MOV     DX,DI
FLI_LC0:
	PUSH    EAX
	XOR     AH,AH
	MOV     DI,DX
	LODSB
	MOV     BL,AL
	TEST    BL,BL
	JZ      FLI_LC4
FLI_LC1:
	LODSB
	ADD     DI,AX
	LODSB
	TEST    AL,AL
	JS      FLI_LC2
	XOR     ECX,ECX
	MOV     CX,AX
	REP     MOVSB
	DEC     BL
	JNZ     FLI_LC1
	JMP     FLI_LC4
FLI_LC2:
	NEG     AL
	XOR     ECX,ECX
	MOV     CX,AX
	LODSB
	REP     STOSB
	DEC     BL
	JNZ     FLI_LC1
FLI_LC4:
	ADD     DX,320
	POP     EAX
	DEC     AX
	JNZ     FLI_LC0
	RET
	;----------------------------------------------
	;
	;
	;
	;
	;----------------------------------------------
FLI_RLE:
	CLD
	MOV     ESI,DWORD PTR CBUF
	MOV     EDI,0A0000H             ;0
	MOV     AX,200
	MOV     DX,DI
FLI_RLE0:
	PUSH    EAX
	XOR     AH,AH
	MOV     DI,DX
	LODSB
	MOV     BL,AL
	TEST    BL,BL
	JZ      FLI_RLE4
FLI_RLE1:
	LODSB
	TEST    AL,AL
	JNS     FLI_RLE2
	NEG     AL
	XOR     ECX,ECX
	MOV     CX,AX
	REP     MOVSB
	DEC     BL
	JNZ     FLI_RLE1
	JMP     FLI_RLE4
FLI_RLE2:
	XOR     ECX,ECX
	MOV     CX,AX
	LODSB
	REP     STOSB
	DEC     BL
	JNZ     FLI_RLE1
FLI_RLE4:
	ADD     DX,320
	POP     EAX
	DEC     AX
	JNZ     FLI_RLE0
	RET

	;---------------------------------------------------
VRAMCLS00:
	CALL    SCROFF
	MOV     ECX,64000/4
	MOV     EDI,0A0000H     ;00
	XOR     EAX,EAX
	REP     STOSD

;VRAMCLS01:
;       MOV     ES:[EDI],AX
;       ADD     EDI,4
;       LOOP    VRAMCLS01

	CALL    SCRON
	RET
	;---------------------------------------------------

INT_TIME0:
	SUB     DWORD PTR SAVEINT,ECX
INT_TIME2:
	;PUSH   ES
	;MOV    AX,34H          ;SELECT = 34H : BASE = 0
	;MOV    ES,AX
INT_TIME1:
	MOV     ECX,DS:[(_INT0F0H+5)*4]
	CMP     ECX,DWORD PTR SAVEINT
	JZ      INT_TIME4
	JC      INT_TIME4
	MOV     AL,BYTE PTR KEYDAT0
	TEST    AL,01H
	JZ      INT_TIME1
	MOV     AL,BYTE PTR ALTKEY
	CMP     AL,1
	JZ      INT_TIME1
	;POP    ES
	JMP     DWORD PTR ALT_JMP
	;
INT_TIME4:
	;POP    ES
	MOV     AL,BYTE PTR KEYDAT0
	TEST    AL,01H
	JZ      INT_TIME6
	MOV     AL,BYTE PTR ALTKEY
	CMP     AL,1
	JZ      INT_TIME6
	JMP     DWORD PTR ALT_JMP
INT_TIME6:
	RET
	;
	;
	;
	;
INT_TIME_NUM:
	SUB     DWORD PTR SAVEINT,ECX
	RET
	;
	;
	;
	;

INT_TIME_CHK:
	;PUSH   ES
	;MOV    AX,34H          ;SELECT = 34H : BASE = 0
	;MOV    ES,AX
	MOV     ECX,DS:[(_INT0F0H+5)*4]
	;POP    ES
	CMP     ECX,DWORD PTR SAVEINT
	JZ      INT_TIME_CHK1
	JC      INT_TIME_CHK1
	MOV     AL,0
	RET
INT_TIME_CHK1:
	MOV     AL,1
	RET
	;-----------------------------------------
	;
	;       CHKE TIME
	;
	;-----------------------------------------
INTTIME:
	SUB     DWORD PTR SAVEINT,ECX
INTTIME2:
INTTIME1:
	MOV     ECX,DS:[(_INT0F0H+5)*4]
	CMP     ECX,DWORD PTR SAVEINT
	JZ      INTTIME4
	JC      INTTIME4
	JMP     INTTIME1
INTTIME4:
	RET


SETTIME:
	;PUSH   ES
	;MOV    AX,34H          ;SELECT = 34H : BASE = 0
	;MOV    ES,AX
	CLI
	MOV     DS:[(_INT0F0H+5)*4],ECX
	MOV     DWORD PTR SAVEINT,ECX
	STI
	;POP    ES
	RET
	;---------------------------------------------------
	;
	;       ADJUST DELAY TIME
	;
	;---------------------------------------------------
DELAY_TIME:
	XOR     EAX,EAX
	MOV     EBP,OFFSET SPEED
	MOV     AL,DS:[EBP]
	CMP     AL,80
	JC      DELAY_TIME01
	MOV     AL,79
DELAY_TIME01:
	MOV     AH,3
	MUL     AH
	MOV     DWORD PTR SAVE_CONT,EAX
	RET

	;---------------------------------------------------
	;
	;
	;
	;
	;
	;
	;---------------------------------------------------
SCROFF: CLI
	MOV     AL,1
	MOV     DX,03C4H
	OUT     DX,AL
	INC     DX
	IN      AL,DX
	OR      AL,20H
	OUT     DX,AL
	STI
	RET
	;
	;
	;
SCRON:  CLI
	MOV     AL,1
	MOV     DX,03C4H
	OUT     DX,AL
	INC     DX
	IN      AL,DX
	AND     AL,0DFH
	OUT     DX,AL
	STI
	RET
	;=============================================================
	;       AL : 칼라 번호
	;       AH : Red 값
	;       BL : Green 값
	;       BH : Blue 값
	;=============================================================
COLOR:
	MOV     DX,3C8H
	OUT     DX,AL
	INC     DX
	PUSH    DX
	MOV     DX,3DAH
COLOR3: IN      AL,DX
	TEST    AL,09H
	JZ      COLOR3
	POP     DX
	MOV     AL,AH
	OUT     DX,AL
	MOV     AL,BL           ;H
	OUT     DX,AL
	MOV     AL,BH           ;L
	OUT     DX,AL
	RET

	;==========================================================
	;
	;       ESI : 로드번지
	;       EDX : 파일이름 번지
	;
	;==========================================================
DKREAD:
	MOV     DWORD PTR BUFFER1,EDX
	MOV     DWORD PTR BUFFER0,ESI
	CALL    DISKREAD
	MOV     EDX,DWORD PTR BUFFER1
	RET
	;----------------------------------------------------
	;
	;
	;----------------------------------------------------
DISKREAD:
	XOR     EAX,EAX
	MOV     DWORD PTR LENTH,EAX
	MOV     EDX,DWORD PTR BUFFER1
	MOV     AL,0
	MOV     AH,3DH
	INT     21H
	JC      ERROR
	MOV     WORD PTR HANDLE,AX
	MOV     BX,WORD PTR HANDLE
	MOV     ECX,0100000H
	MOV     EDX,DWORD PTR BUFFER0   ;DS
	MOV     AH,3FH
	INT     21H
	JC      ERROR
	MOV     DWORD PTR LENTH,EAX
	MOV     BX,WORD PTR HANDLE
	MOV     AH,3EH
	INT     21H
	JC      ERROR
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET

	;---------------------------------------------------------
	;
	;       ESI : 시작 어드레스
	;       EDI : 끝   어드레스
	;       EDX : 파일이름 번지
	;
	;---------------------------------------------------------
DKSAVE:
	MOV     DWORD PTR BUFFER1,EDX
	MOV     ECX,EDI
	SUB     ECX,ESI
	INC     ECX
	MOV     DWORD PTR BUFFER2,ECX
	MOV     DWORD PTR BUFFER0,ESI
	CALL    NEWFIL
	MOV     EDX,DWORD PTR BUFFER1
	RET


NEWFIL:
	MOV     EDX,DWORD PTR BUFFER1
	MOV     AH,3CH
	MOV     ECX,0
	INT     21H
	JC      ERROR
	JMP     DISK100
	RET


DISKSAVE:
	MOV     EDX,DWORD PTR BUFFER1
	MOV     AL,1
	MOV     AH,3DH
	INT     21H
	JC      ERROR
DISK100:
	MOV     WORD PTR HANDLE,AX
	;
	MOV     ECX,DWORD PTR BUFFER2
	MOV     BX,WORD PTR HANDLE
	MOV     EDX,DWORD PTR BUFFER0
	MOV     AH,40H
	INT     21H
	JC      ERROR
	MOV     BX,WORD PTR HANDLE
	MOV     AH,3EH
	INT     21H
	JC      ERROR
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET

ERROR:
	CMP     AL,2
	JZ      ERROR1
	MOV     AL,1
	MOV     BYTE PTR ERRDAT,AL
	RET
ERROR1:
	MOV     AL,2
	MOV     BYTE PTR ERRDAT,AL
	RET
	;-------------------------------------------------
	;
	;
	;
	;
	;
	;
	;--------------------------------------------------
OPENFILE:
	XOR     ECX,ECX
	MOV     DWORD PTR BUFFER1,EDX
	MOV     AL,0
	MOV     AH,3DH
	INT     21H
	JC      ERROR
	MOV     WORD PTR HANDLE,AX
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET
	;------------------------------------------
	;       ECX:NUMBER
	;       ESI:32BIT ADDRESS
	;------------------------------------------
PUTFILE:
	MOV     BX,WORD PTR HANDLE
	MOV     EDX,ESI
	MOV     AH,40H
	INT     21H
	JC      ERROR
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET
	;------------------------------------------
	;       ECX:NUMBER
	;       ESI:32BIT ADDRESS
	;------------------------------------------
GETFILE:
	MOV     BX,WORD PTR HANDLE
	MOV     EDX,ESI
	MOV     AH,3FH
	INT     21H
	JC      ERROR
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET
	;------------------------------------------
CLOSEFILE:
	MOV     BX,WORD PTR HANDLE
	MOV     AH,3EH
	INT     21H
	JC      ERROR
	XOR     AL,AL
	MOV     BYTE PTR ERRDAT,AL
	RET
	;=======================================================
	;
	;       HEXMAL -----> DECMAL [ 16진수를 10 진수로 ]
	;       INPUT  : EAX
	;              : EBP
	;
	;       OUTPUT : [EBP] = DECMALD ( 10 BYTE )
	;
	;========================================================
DECMAL:
	XOR     EDX,EDX
	MOV     EBX,1000000000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP],AL
	;
	MOV     EAX,EDX
	XOR     EDX,EDX
	MOV     EBX,100000000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP+1],AL
	;
	MOV     EAX,EDX
	XOR     EDX,EDX
	MOV     EBX,10000000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP+2],AL
	;
	MOV     EAX,EDX
	XOR     EDX,EDX
	MOV     EBX,1000000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP+3],AL
	;
	MOV     EAX,EDX
	XOR     EDX,EDX
	MOV     EBX,100000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP+4],AL
	;
	MOV     EAX,EDX
	XOR     EDX,EDX
	MOV     EBX,10000
	DIV     EBX
	ADD     AL,30H
	MOV     DS:[EBP+5],AL
	;
	MOV     AX,DX
	XOR     DX,DX
	MOV     BX,1000
	DIV     BX
	ADD     AL,30H
	MOV     DS:[EBP+6],AL
	;
	MOV     AX,DX
	MOV     BL,100
	DIV     BL
	ADD     AL,30H
	MOV     DS:[EBP+7],AL
	;
	MOV     AL,AH
	XOR     AH,AH
	MOV     BL,10
	DIV     BL
	ADD     AL,30H
	MOV     DS:[EBP+8],AL
	;
	ADD     AH,30H
	MOV     DS:[EBP+9],AH
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
RESET_MUSIC:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,0
	JZ      RESET_MUSIC01
	XOR     EAX,EAX
	CLI
	MOV     DS:[((_INT0F0H+5)*4)+2],AX
	MOV     AX,18*36*2
	MOV     DS:[((_INT0F0H+5)*4)],AX
	STI
	MOV     AX,00
	MOV     DS:BYTE PTR ((_INT0F0H+3)*4),AL
RESET_MUSIC01:
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
SET_MUSIC:
	MOV     BX,WORD PTR SEG_MEM
SET_MUSIC01:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,0
	JZ      SET_MUSIC02
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,1
	MOV     [EDI]._EAX,EAX
	MOV     CL,BYTE PTR VOLUME
	MOV     CH,BYTE PTR MUSIC_LOOP
	MOV     [EDI]._ECX,ECX
	MOV     AX,BX
	MOV     [EDI]._DS,AX
	MOV     AX,300H
	MOV     BL,0F2H
	MOV     BH,0
	MOV     CX,0
	INT     31H
SET_MUSIC02:
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
PLAY_MUSIC:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,0
	JZ      PLAY_MUSIC01
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,6
	MOV     [EDI]._EAX,EAX
	MOV     AX,300H
	MOV     BL,0F2H
	MOV     BH,00
	MOV     CX,0
	INT     31H
PLAY_MUSIC01:
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
STOP_MUSIC:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,0
	JZ      STOP_MUSIC01
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,3
	MOV     [EDI]._EAX,EAX
	MOV     AX,300H
	MOV     BL,0F2H
	MOV     BH,0
	MOV     CX,0
	INT     31H
STOP_MUSIC01:
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
MUSIC_CHK:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,0
	JZ      MUSIC_CHK01
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,5
	MOV     [EDI]._EAX,EAX
	MOV     AX,300H
	MOV     BL,0F2H
	MOV     BH,0
	MOV     CX,0
	INT     31H
	MOV     EDI,OFFSET REG_BLK01
	MOV     EBX,[EDI]._EBX
MUSIC_CHK01:
	RET
	;------------------------------------------
	;
	;       ECX   = NUMBER
	;       BP =SEG ,ESI = OFFSET : ADDRESS
	;
	;------------------------------------------
EXCLUCIVE:
	MOV     AL,BYTE PTR MUSIC_MODEL
	CMP     AL,3
	JC      EXCLUCIVE01
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,0
	MOV     [EDI]._EAX,EAX
	MOV     [EDI]._DS,BP
	MOV     [EDI]._ESI,ESI
	MOV     [EDI]._ECX,ECX
	MOV     BH,0
	MOV     BL,0F2H
	MOV     AX,300H
	MOV     CX,0
	INT     31H
EXCLUCIVE01:
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
SEND_EX:
	PUSH    ECX
	XOR     EDI,EDI
	MOV     DI,WORD PTR SEG_MEM
	SHL     EDI,4
MAIN_0003:
	MOV     AL,[ESI]
	MOV     [EDI],AL
	INC     ESI
	INC     EDI
	LOOP    MAIN_0003
	POP     ECX
	MOV     BP,WORD PTR SEG_MEM
	MOV     ESI,0
	CALL    EXCLUCIVE
	RET
	;------------------------------------------
	;
	;
	;
	;
	;------------------------------------------
SOUND:  CMP     BX,0
	JZ      SOUND1
	CMP     BX,54
	JNC     SOUND1
	MOV     EDI,OFFSET REG_BLK01
	MOV     EAX,4
	MOV     [EDI]._EAX,EAX
	MOV     [EDI]._EBX,EBX
	MOV     AX,300H
	MOV     BL,0F2H
	MOV     BH,0
	MOV     CX,0
	INT     31H
SOUND1: RET
	;---------------------------------------------
	;
	;       REAL_MEM
	;       BX = MEMORY SEG
	;
	;---------------------------------------------
REAL_MEM_PRG:
	MOV     AX,100H
	;       MOV     EBX,1000H
	INT     31H
	JC      REAL_MEM_PRG02
	MOV     WORD PTR SEG_MEM,AX
	CMP     DX,0
	JZ      REAL_MEM_PRG01
	INC     WORD PTR SEG_MEM
REAL_MEM_PRG01:
	MOV     AL,0
	RET
REAL_MEM_PRG02:
	;       MEM_ERROR
	MOV     AL,1
	RET
	;---------------------------------------------------
	;
	;       PROTECT_MEMORY --> REAL MEMORY ( MOVE)
	;       INPUT ECX = LENTH
	;             ESI = ADDRESS (SOURCE ADDRESS)
	;       CALL    MOVE_PRO_REAL
	;             EDI =  REAL  ADDRESS
	;---------------------------------------------------
MOVE_PRO_REAL:
	XOR     EDI,EDI
	MOV     DI,WORD PTR SEG_MEM
	SHL     EDI,4
MOVE_PRO_REAL01:
	MOV     AL,[ESI]
	MOV     [EDI],AL
	INC     ESI
	INC     EDI
	LOOP    MOVE_PRO_REAL01
	RET
	;==========================================================
	;
	;       INPUT   LOAD ADDRESS,COMPRESS NUMBER,TARGET ADDRESS
	;                  ESI         EAX               EDI
	;
	;       OUTPUT TARGET ADDRESS
	;
	;==========================================================
LZEXEM: MOV     EBP,ESI
	SHL     EAX,1
	ADD     EBP,EAX
	XOR     EAX,EAX
	MOV     AX,DS:[EBP]
	SHL     EAX,4
	ADD     ESI,EAX
	;==========================================================
	;
	;       INPUT
	;       ESI : 압축한 프로그램 번지
	;       EDI : 압축 풀리는 어드레스 번지
	;
	;       OUTPUT
	;       EDI : 압축이 풀린 끝 번지를 가르킨다.
	;
	;==========================================================
LZEXE:
	PUSH    ES
	MOV     AX,DS
	MOV     ES,AX
	MOV     EBX,-1
	CLD
	LODSW
	MOV     BP,AX
	XOR     ECX,ECX
	MOV     DL,10H
LZ00:   SHR     BP,1
	DEC     DL
	JNZ     LZ01
	LODSW
	MOV     BP,AX
	MOV     DL,10H
LZ01:   JNC     LZ02
	MOVSB
	JMP     SHORT LZ00
LZ02:   SHR     BP,1
	DEC     DL
	JNZ     LZ03
	LODSW
	MOV     BP,AX
	MOV     DL,10H
LZ03:   JC      LZ06
	SHR     BP,1
	DEC     DL
	JNZ     LZ04
	LODSW
	MOV     BP,AX
	MOV     DL,10H
LZ04:   RCL     CX,1
	SHR     BP,1
	DEC     DL
	JNZ     LZ05
	LODSW
	MOV     BP,AX
	MOV     DL,10H
LZ05:   RCL     CX,1
	INC     CX
	INC     CX
	LODSB
	MOV     BH,0FFH
	MOV     BL,AL
	JMP     SHORT LZ07
LZ06:   LODSW
	MOV     BX,AX
	OR      BH,0E0H
	MOV     CL,5
	SHR     AH,CL
	JNZ     LZ08
	LODSB
	AND     AL,AL
	JZ      LZ09
	CMP     AL,1
	JZ      LZ10
	MOV     CL,AL
	INC     CX
	JMP     SHORT LZ07
LZ08:   INC     AH
	INC     AH
	MOV     CL,AH
LZ07:   MOV     AL,[EBX+EDI]
	STOSB
	LOOP    LZ07
	JMP     LZ00
LZ09:   XOR     ECX,ECX
	JMP     LZ00
LZ10:   POP     ES
	RET

	;
	;
	;
	;
	;
	;
_TEXT   ENDS
	END

