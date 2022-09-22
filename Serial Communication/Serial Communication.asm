ORG 0000H

.MODEL SMALL
.STACK 100


DATA SEGMENT
      
CONT1  EQU 0010H           ;8259:A0=0
CONT2  EQU 0012H           ;8259:A0=1
ICW1   EQU 00010111B       ;INITIALIZATION COMMAND WORD 1
ICW2   EQU 40H             ;INITIALIZATION COMMAND WORD 2
ICW4   EQU 00000011B       ;INITIALIZATION COMMAND WORD 4
OCW1   EQU 00000000B       ;OPERATION COMMAND WORD 1


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

;8251
SRD    EQU 0090H
SRC    EQU 0092H

;DATA STRINGS
WELCOME     DB  "WELCOME TO SERIAL COMMS MODULE$"
CTRL        DB  "CHECK BUTTONS FOR OPERATION$"
TRANSMIT    DB  "SOUND TRANSMITTED FROM 8086$" 
RECEIVE     DB  "SOUND RECEIVED FROM CLOCK$"
TRANSCEIVE  DB  "SOUND RECEIVED FRM CLK AND TRANSMITTED$"
LEAVE       DB  "SERIAL COMMS COMPLETE$"
STR         DB  "BY EEE2412 EEE LC GROUP 3$"


DATA ENDS

CODE SEGMENT
    
MAIN:

;INITIALIZATION OF DATA AND EXTRA SEGMENTS
MOV AX, @DATA
MOV DS, AX 
MOV ES, AX

;--------------------------------------------------;
;                                                  ;
;                   8251 SETUP                     ;                    
;                                                  ;
;--------------------------------------------------;

;GARBAGE
MOV AL, 0EEH
MOV DX, SRC
OUT DX, AL

;RESET
MOV AL, 40H
OUT DX, AL

;MODE
MOV AL, 4DH
OUT DX, AL

;CONTROL
MOV AL, 15H
OUT DX, AL




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
MOV AX, OFFSET START
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG START
MOV WORD PTR ES:[BX], AX
XOR AX, AX


XOR AX, AX
MOV ES, AX
MOV AL ,41H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET TRANSMIT_SOUND
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG TRANSMIT_SOUND
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,42H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET RECEIVE_SOUND
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG RECEIVE_SOUND
MOV WORD PTR ES:[BX], AX
XOR AX, AX

XOR AX, AX
MOV ES, AX
MOV AL ,43H
MOV AH, 4
MUL AH
MOV BX, AX
MOV AX, OFFSET TRANSCEIVE_SOUND
MOV WORD PTR ES:[BX], AX
INC BX
INC BX
MOV AX, SEG TRANSCEIVE_SOUND
MOV WORD PTR ES:[BX], AX
XOR AX, AX


XOR AX, AX
MOV ES, AX
MOV AL ,44H
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
    
STI   


;-----------------------------------------------;
;                                               ;
;            DEFAULT OPERATION                  ;
;                                               ;
;-----------------------------------------------;
MOV AX, 80H
MOV DX, PCW1
OUT DX, AX


CALL LCDinit
LEA SI, WELCOME
CALL printString


HERE:
JMP HERE        ;WAITING FOR INPUT



;-----------------------------------------------;
;                                               ;
;              INTERRUPT ROUTINES               ;
;                                               ;
;-----------------------------------------------;

START:

STI

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX
        
MOV AX, 0FFH
MOV DX, PORTC1
OUT DX, AX

LEA SI, CTRL
CALL LCDinit
CALL printString


IRET
;------------------------------------------------
TRANSMIT_SOUND:

STI

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX
        
MOV AX, 0F0H
MOV DX, PORTC1
OUT DX, AX

LEA SI, TRANSMIT
CALL LCDinit
CALL printString

LP0:

MOV CX, 50000

TS0:
MOV AL, 00H
CALL CHECK_TxRDY
CALL SEND_CHARACTER
LOOP TS0


MOV CX, 5000

TS1:
MOV AL, 0FFH
CALL CHECK_TxRDY
CALL SEND_CHARACTER
LOOP TS1

JMP LP0

IRET
;---------------------------------------------------

RECEIVE_SOUND:

STI


MOV AX, 80H
MOV DX, PCW1
OUT DX, AX
        
MOV AX, 0FH
MOV DX, PORTC1
OUT DX, AX

LEA SI, RECEIVE
CALL LCDinit
CALL printString

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX

RP:

CALL CHECK_RxRDY

MOV DX, SRD
IN AX, DX
SHR AL,1
MOV DX, PORTA2
OUT DX, AX

JMP RP

IRET
;---------------------------------------------------

TRANSCEIVE_SOUND:

STI

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX
        
MOV AX, 55H
MOV DX, PORTC1
OUT DX, AX

LEA SI, TRANSCEIVE
CALL LCDinit
CALL printString

LP1:

CALL CHECK_RxRDY

MOV DX, SRD
IN AX, DX
MOV DX, PORTA2
OUT DX, AX


CALL CHECK_TxRDY

MOV DX, SRD
OUT DX, AL 

MOV CX, 1100
CALL DELAY

JMP LP1

IRET
;---------------------------------------------------

STOP:

STI   

MOV AX, 89H
MOV DX, PCW2
OUT DX, AX

MOV AX, 80H
MOV DX, PCW1
OUT DX, AX

MOV AX, 00H
MOV DX, PORTC2
OUT DX, AX

LEA SI, LEAVE
CALL LCDinit
CALL printString

MOV CX, 64256
CALL DELAY

LEA SI, STR
CALL LCDinit
CALL printString

IRET



;--------------------------------------------------;
;                                                  ;
;              SERIAL MODULES                      ;                    
;                                                  ;
;--------------------------------------------------;

CHECK_TxRDY PROC NEAR
PUSH AX
PUSH DX
			
MOV DX, SRC
			
L-1:
IN AL, DX
TEST AL, 01H
JZ L-1
			
POP DX
POP AX			
RET
CHECK_TxRDY ENDP

CHECK_RxRDY PROC NEAR
PUSH AX
PUSH DX
			
MOV DX, SRC
			
L_1:
IN AL, DX
TEST AL, 02H
JZ L_1
			
POP DX
POP AX			
RET
CHECK_RxRDY ENDP

SEND_CHARACTER PROC NEAR
PUSH DX
			   
MOV DX, SRD
OUT DX, AL
			   	
POP DX
RET
SEND_CHARACTER ENDP

RECEIVE_CHARACTER PROC NEAR
PUSH DX
			      
MOV DX, SRD
IN AX, DX
SHR AL,1
MOV CX, 0FFH
CALL DELAY
					
POP DX
RET
RECEIVE_CHARACTER ENDP


WAIT_A_LITTLE PROC NEAR
PUSH CX
MOV CX, 0200H
LOOP1: 
NOP
LOOP LOOP1
POP CX
RET
WAIT_A_LITTLE ENDP
	
DELAY_S PROC NEAR
PUSH CX
MOV CX, 10
LOOP_1:
PUSH CX
				
MOV CX, 0FFFFH
LOOP_2: 
NOP
LOOP LOOP_2
				
POP CX
LOOP LOOP_1
POP CX
RET
DELAY_S ENDP  


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