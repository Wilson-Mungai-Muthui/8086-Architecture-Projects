ORG 0000H

.MODEL SMALL
.STACK 100


DATA SEGMENT
      
CONT1  EQU 0010H        ;8259:A0=0
CONT2  EQU 0012H        ;8259:A0=1
ICW1   EQU 00010111B    ;INITIALIZATION CONTROL WORD 1 
ICW2   EQU 40H          ;INITIALIZATION CONTROL WORD 2
ICW4   EQU 00000011B    ;INITIALIZATION CONTROL WORD 4
OCW1   EQU 00000000B    ;OPERATION CONTROL WORD 1
TCWR3  EQU 01110110B    ;8253 MODE 3 OPERATION
TCWR0  EQU 01110000B    ;8253 MODE 0 OPERATION

;PORT ADDRESSES
;1ST 8255
PORTA1 EQU 0030H
PORTB1 EQU 0032H
PORTC1 EQU 0034H
PCW1   EQU 0036H

;2ND 8255
PORTA2 EQU 0050H
PORTB2 EQU 0052H
PORTC2 EQU 0054H
PCW2   EQU 0056H

;8253
TM0    EQU 0070H
TM1    EQU 0072H
TM2    EQU 0074H
TMCTR  EQU 0076H

;DATA STRINGS
WELCOME     DB  "WELCOME TO SERVO MOTOR CONTROL$"
CTRL        DB  "PRESS INPUT FOR CONFIGURATION$"
STR_ONE     DB  "PRESS 1 FOR -90 DEGREES$"
STR_TWO     DB  "PRESS 2 FOR -45 DEGREES$"
STR_THREE   DB  "PRESS 3 FOR   0 DEGREES$"
STR_FOUR    DB  "PRESS 4 FOR +45 DEGREES$"
STR_FIVE    DB  "PRESS 5 FOR +90 DEGREES$"
NORMAL      DB  "WAITING FOR KEY PRESS$" 
INTERRUPT   DB  "SERVO MOTOR CONTROL COMPLETE$"
STR         DB  "BY EEE2412 EEE LC GROUP 3$"

;UNDEFINED VARIABLE
KEY         DB   ?

;DATA STRINGS
OPTION_ONE     DB  "+90.0 DEGREES OUTPUT$"
OPTION_TWO     DB  "+45.0 DEGREES OUTPUT$"
OPTION_THREE   DB  "  0.0 DEGREES OUTPUT$"
OPTION_FOUR    DB  "-45.0 DEGREES OUTPUT$"
OPTION_FIVE    DB  "-90.0 DEGREES OUTPUT$"

DATA ENDS

CODE SEGMENT
    
MAIN:

;INITIALIZATION OF SEGMENTS
MOV AX, @DATA
MOV DS, AX 
MOV ES, AX

;--------------------------------------------------;
;                                                  ;
;              INTERRUPT SETUP                     ;                    
;                                                  ;
;--------------------------------------------------;

CLI

MOV DX, CONT1
MOV AL, ICW1
OUT DX, AL
MOV DX, CONT2
MOV AL, ICW2
OUT DX, AL
MOV AL, ICW4
OUT DX, AL

;UNMASK INTERRUPTS
MOV AL, OCW1
OUT DX, AL

;INTERRUPT VECTOR ADDRESS SETUP
XOR AX, AX
MOV ES, AX
MOV AL ,40H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET STOP
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG STOP
MOV WORD PTR ES:[BX], AX
XOR AX, AX


XOR AX, AX
MOV ES, AX
MOV AL ,41H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET INPUT
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG INPUT
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,42H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET START
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG START
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,43H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET ONE_MS
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG ONE_MS
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,44H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET TWO_MS
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG TWO_MS
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,45H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET THREE_MS
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG THREE_MS
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,46H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET FOUR_MS
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG FOUR_MS
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,47H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET FIVE_MS
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG FIVE_MS
MOV WORD PTR ES:[BX], AX
XOR AX, AX
    
STI   


;-----------------------------------------------;
;                                               ;
;            DEFAULT OPERATION                  ;
;                                               ;
;-----------------------------------------------;
MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 80H
MOV DX, PCW2
OUT DX, AX

CALL LCDinit
LEA SI, WELCOME
CALL printString


HERE:
JMP HERE       ;WAITING FOR INPUT



;-----------------------------------------------;
;                                               ;
;              INTERRUPT REQUESTS               ;
;                                               ;
;-----------------------------------------------;

DISPLAY PROC NEAR
    MOV AX, 89H
    MOV DX, PCW2
    OUT DX, AX
    
    
    IR0:
    CMP BX, '1'
    JNE IR1
    MOV AX, 00000001B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY


    IR1:
    CMP BX, '2'
    JNE IR2
    MOV AX, 00000010B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY

    IR2:
    CMP BX, '3'
    JNE IR3
    MOV AX, 00000100B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY
    
    IR3:
    CMP BX, '4'
    JNE IR4
    MOV AX, 00001000B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY


    IR4:
    CMP BX, '5'
    JNE IR5
    MOV AX, 00010000B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY


    IR5:
    CMP BX, '6'
    JNE END_DISPLAY
    MOV AX, 00100000B
    MOV DX, PORTA2
    OUT DX, AX
    MOV CX, 00FFH
    CALL DELAY
    JMP END_DISPLAY


 

END_DISPLAY:
    
RET

DISPLAY ENDP


;-----------------------------------------------;
;                                               ;
;              KEYPAD MODULE                    ;
;                                               ;
;-----------------------------------------------;

KEYPAD PROC NEAR
   
PUSH AX
PUSH BX
PUSH CX
    
MOV AX, 89H
MOV DX, PCW2
OUT DX, AX

GOE:
CALL DISPLAY
    
COLUMN0:
MOV AL, 00000001B        
MOV DX,PORTB2            
OUT DX,AL
IN AL, PORTC2
JMP ROW00
 

ROW00:
MOV KEY, AL
CMP KEY, 00000001B
JNE ROW10
MOV BX, '3'
JMP GOE


ROW10:
CMP KEY, 00000010B
JNE ROW20
MOV BX, '6'
JMP GOE


ROW20:
CMP KEY, 00000100B
JNE ROW30
MOV BX, '9'
JMP GOE
             


ROW30:
CMP KEY, 00001000B
JNE COLUMN1
MOV BX, '#'
JMP GOE

    
COLUMN1:
MOV AL, 00000010B        
MOV DX,PORTB2            
OUT DX,AL
IN AL, PORTC2
JMP ROW01
 

ROW01:
MOV KEY, AL
CMP KEY, 00000001B
JNE ROW11
MOV BX, '2'
JMP GOE


ROW11:
CMP KEY, 00000010B
JNE ROW21
MOV BX, '5'
JMP GOE


ROW21:
CMP KEY, 00000100B
JNE ROW31
MOV BX, '8'
JMP GOE             


ROW31:
CMP KEY, 00001000B
JNE COLUMN2
MOV BX, '0'
JMP GOE

    
COLUMN2:
MOV AL, 00000100B        
MOV DX,PORTB2            
OUT DX,AL
IN AL, PORTC2
JMP ROW02
 

ROW02:
MOV KEY, AL
CMP KEY, 00000001B
JNE ROW12
MOV BX, '1'
JMP GOE


ROW12:
CMP KEY, 00000010B
JNE ROW22
MOV BX, '4'
JMP GOE


ROW22:
CMP KEY, 00000100B
JNE ROW32
MOV BX, '7'
JMP GOE              


ROW32:
CMP KEY, 00001000B
JNE COLUMN0
MOV BX, '*'
JMP GOE


POP CX   
POP BX
POP AX
   
RET    
KEYPAD ENDP


;--------------------------------------------------;
;                                                  ;
;              TIMER MODULES                       ;                    
;                                                  ;
;--------------------------------------------------;
TIMER_SETUP_0 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 0E9H
    OUT TM1, AL
    MOV AL, 47H
    OUT TM1, AL
    RET
    
TIMER_SETUP_0 ENDP

TIMER_SETUP_1 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 38H
    OUT TM1, AL
    MOV AL, 4AH
    OUT TM1, AL
    RET
    
TIMER_SETUP_1 ENDP


TIMER_SETUP_2 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 0E3H
    OUT TM1, AL
    MOV AL, 48H
    OUT TM1, AL
    RET
    
TIMER_SETUP_2 ENDP



TIMER_SETUP_3 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 0E9H
    OUT TM1, AL
    MOV AL, 47H
    OUT TM1, AL
    RET
    
TIMER_SETUP_3 ENDP


TIMER_SETUP_4 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 0EFH
    OUT TM1, AL
    MOV AL, 46H
    OUT TM1, AL
    RET
    
TIMER_SETUP_4 ENDP 


TIMER_SETUP_5 PROC NEAR
    
    MOV AL, TCWR0
    OUT TMCTR, AL
    MOV AL, 68H
    OUT TM1, AL
    MOV AL, 42H
    OUT TM1, AL
    RET
    
TIMER_SETUP_5 ENDP



;--------------------------------------------------;
;                                                  ;
;            SERVO INTERRUPT ROUTINES              ;                    
;                                                  ;
;--------------------------------------------------;

ONE_MS:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, OPTION_ONE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, CTRL
CALL LCDinit
CALL printString
        
LOOP_ONE:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_1
JMP LOOP_ONE
        
IRET
;------------------------------------------------
TWO_MS:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, OPTION_TWO
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, CTRL
CALL LCDinit
CALL printString
        
LOOP_TWO:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_2
JMP LOOP_TWO
        
IRET
;------------------------------------------------
THREE_MS:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, OPTION_THREE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, CTRL
CALL LCDinit
CALL printString
        
LOOP_THREE:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_3
JMP LOOP_THREE
        
IRET
;-----------------------------------------------------
FOUR_MS:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, OPTION_FOUR
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, CTRL
CALL LCDinit
CALL printString
        
LOOP_FOUR:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_4
JMP LOOP_FOUR
        
IRET    
;-----------------------------------------------------

FIVE_MS:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, OPTION_FIVE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, CTRL
CALL LCDinit
CALL printString
        
LOOP_FIVE:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_5
JMP LOOP_FIVE
        
IRET

;---------------------------------------------------------

START:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, CTRL
CALL LCDinit
CALL printString


IRET    
;----------------------------------------------------- 

INPUT:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

LEA SI, STR_ONE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, STR_TWO
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, STR_THREE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, STR_FOUR
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, STR_FIVE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, NORMAL
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

INP:
CALL KEYPAD
JMP INP
        
IRET    
;-----------------------------------------------------
STOP:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX
        
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, INTERRUPT
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

LEA SI, STR
CALL LCDinit
CALL printString

STP:
XOR CX, CX
MOV CX, 1100
CALL DELAY
CALL TIMER_SETUP_0
JMP STP
        
IRET


;-----------------------------------------------;
;                                               ;
;        LCD LIBRARY FUNCTIONS                  ;
;                                               ;
;-----------------------------------------------;

;LCD INITIALIZATION PROCEDURE
  
LCDinit PROC NEAR                                       
    PUSH AX                                              
    PUSH DX                                              
    PUSH CX                                              
                                                         
    MOV  DX, PORTB1                                      
    MOV  AL, 00H                                         
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                           
                                                         
    MOV  DX, PORTA1                                      
    MOV  AL, 01H      ;CLEAR SCREEN COMMAND                                   
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY
                                                                                                        
    MOV  DX, PORTB1                                      
    MOV  AL, 02H                                         
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                      
    CALL DELAY                                               
                                                         
;-------------------------------------------------       
                                                         
    MOV  DX, PORTB1                                      
    MOV  AL, 00H                                         
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                           
                                                         
                                                         
    MOV  DX, PORTA1                                      
    MOV  AL, 0EH      ;DISPLAY ON, CURSOR ON COMMAND                                   
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                           
                                                         
    MOV  DX, PORTB1                                      
    MOV  AL, 02H                                         
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY    
                                                          
    POP  CX                                              
    POP  DX                                              
    POP  AX                                              
    RET                                                  
LCDinit ENDP                                            
;--------------------------------------------------------  
   

;PRINT CHARACTER PROCEDURE 
                
printChar PROC NEAR                                      
    PUSH AX                                              
    PUSH DX
    PUSH CX                                              
                                                         
    MOV  DX, PORTB1                                      
    MOV  AL, 00H                                         
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                           
                                                         
    MOV  DX, PORTA1                                      
    MOV  AL, BL                                     
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                          
                                                         
    MOV  DX, PORTB1                                      
    MOV  AL, 00000010B                                   
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                       
    CALL DELAY                                           
                                                         
    MOV  DL, PORTB1                                      
    MOV  AL, 00000001B                                   
    OUT  DX, AX                                          
    MOV  CX, 00FFH                                      
    CALL DELAY                                           
                                                         
    POP  DX                                              
    POP  AX                                              
    POP  CX
    RET                                                  
printChar ENDP                                           

;--------------------------------------------------------                                                            
       
                                                            
;PRINT STRING ON LCD SCREEN

printString PROC NEAR                                    
                                                         
 printStr:                                               
    MOV  BL, [SI]                                         
    CMP  BL, '$'                                          
    JE   endPrint                                         
    CALL printChar                                      
    INC  SI                                               
    JMP  printStr                                         
  endPrint:                                               
                                                         
  RET                                                    
printString ENDP                                         
;--------------------------------------------------------

;--------------------------------------------------;
;                                                  ;
;          KEYPAD DELAY MODULE                     ;                    
;                                                  ;
;--------------------------------------------------; 

DELAY PROC NEAR
    LOOP $         ;LOOP AT THIS STATEMENT UNTIL CX IS 0
    RET
DELAY ENDP  

CODE ENDS
END       