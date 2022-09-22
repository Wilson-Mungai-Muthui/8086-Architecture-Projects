ORG 0000H

.MODEL SMALL
.STACK 100


DATA SEGMENT
      
CONT1  EQU 0010H          ;8259:A0=0
CONT2  EQU 0012H          ;8259:A0=1
ICW1   EQU 00010111B      ;INITIALIZATION CONTROL WORD 1
ICW2   EQU 40H            ;INITIALIZATION CONTROL WORD 2
ICW4   EQU 00000011B      ;INITIALIZATION CONTROL WORD 4
OCW1   EQU 00000000B      ;OPERATION CONTROL WORD 1


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


;DATA STRINGS
WELCOME     DB  "WELCOME TO DC MOTOR CONTROL$"
NORMAL      DB  "NORMAL MOTOR SPEED$"
INTERRUPT   DB  "DC MOTOR CONTROL COMPLETE$"
STOP        DB  "BY EEE2412 EEE LC GROUP 3$"
INCREASE    DB  "MOTOR SPEED INCREASED$"
DECREASE    DB  "MOTOR SPEED DECREASED$"

DATA ENDS

CODE SEGMENT
    
MAIN:

;INITIALIZATION OF DATA AND EXTRA SEGMENTS
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
MOV AX, OFFSET MTR_NRM
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG MTR_NRM
MOV WORD PTR ES:[BX], AX
XOR AX, AX


XOR AX, AX
MOV ES, AX
MOV AL ,41H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET MTR_INC
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG MTR_INC
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,42H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET MTR_DEC
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG MTR_DEC
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,43H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET STR
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG STR
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
JMP HERE            ;WAITING FOR INPUT



;-----------------------------------------------;
;                                               ;
;            PRINT STRING ON SCREEN             ;
;                                               ;
;-----------------------------------------------;

STR:

STI 

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 80H
MOV DX, PCW2
OUT DX, AX

CALL LCDinit
LEA SI, INTERRUPT
CALL printString

MOV CX, 64256
CALL DELAY

CALL LCDinit
LEA SI, STOP
CALL printString                                                    


MTR_OFF:
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX
MOV CX, 550
CALL DELAY
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX
MOV CX, 550
CALL DELAY
JMP MTR_OFF

IRET

;-----------------------------------------------;
;                                               ;
;           MOTOR SPEED NORMAL ROUTINE          ;
;                                               ;
;-----------------------------------------------;

MTR_NRM:

STI

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 55H                                      
MOV DX, PORTC1
OUT DX, AX

CALL LCDinit
LEA SI, NORMAL
CALL printString


MOV AX, 80H
MOV DX, PCW2
OUT DX, AX

MTR_N:
MOV AX, 0FFH
MOV DX, PORTA2
OUT DX, AX
MOV CX, 550
CALL DELAY
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX
MOV CX, 550
CALL DELAY
JMP MTR_N

IRET

;-----------------------------------------------;
;                                               ;
;      MOTOR SPEED INCREASE ROUTINE             ;
;                                               ;
;-----------------------------------------------;

MTR_INC:

STI

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 0FH                                      
MOV DX, PORTC1
OUT DX, AX

CALL LCDinit
LEA SI, INCREASE
CALL printString

MOV AX, 80H
MOV DX, PCW2
OUT DX, AX

MTR_I:
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX
MOV CX, 200
CALL DELAY
MOV AX, 0FFH
MOV DX, PORTA2
OUT DX, AX
MOV CX, 900
CALL DELAY
JMP MTR_I

IRET

;-----------------------------------------------;
;                                               ;
;       MOTOR SPEED DECREASE ROUTINE            ;
;                                               ;
;-----------------------------------------------;

MTR_DEC:

STI

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 0F0H                                      
MOV DX, PORTC1
OUT DX, AX

CALL LCDinit
LEA SI, DECREASE
CALL printString

MOV AX, 80H
MOV DX, PCW2
OUT DX, AX


MTR_D:
MOV AX, 0FFH
MOV DX, PORTA2
OUT DX, AX
MOV CX, 200
CALL DELAY
MOV AX, 00H
MOV DX, PORTA2
OUT DX, AX
MOV CX, 900
CALL DELAY
JMP MTR_D

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