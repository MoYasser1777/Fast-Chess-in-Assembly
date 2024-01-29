.286

.MODEL SMALL
.STACK 64
.DATA
    x         DB 0
    y         DB 12
    x1        DB 3
    y1        DB 0
    x2        DB 4
    y2        DB 12
    memsg     DB "ME:$"
    youmsg    DB "YOU:$"
    SENDVALUE DB ?
    VALUE     DB ?
.CODE
Initalize PROC FAR
               mov   dx,3fbh             ; Line Control Register
               mov   al,10000000b        ;Set Divisor Latch Access Bit
               out   dx,al               ;Out it

               mov   dx,3f8h
               mov   al,0ch
               out   dx,al


               mov   dx,3f9h
               mov   al,00h
               out   dx,al


               mov   dx,3fbh
               mov   al,00011011b
    ;0:Access to Receiver buffer, Transmitter buffer
    ;0:Set Break disabled
    ;011:Even Parity
    ;0:One Stop Bit
    ;11:8bits
               out   dx,al

Initalize ENDP


movecursor PROC far
               pusha
               mov   dl,x
               mov   dh,y
               mov   bh,0
               mov   ah,2
               int   10h
               popa
               ret
               endp


printmsg proc FAR                        ;offset has to be in dx before calling
               pusha
               mov   ah,9
               int   21h
               popa
               ret
printmsg endp



MAIN PROC FAR
    
               MOV   AX,@DATA
               MOV   DS,AX

               MOV   AX,03H
               INT   10H

               CALL  Initalize


               MOV   x,0
               MOV   y,0
               CALL  movecursor

               MOV   DX,OFFSET memsg
               CALL  printmsg
                      
               MOV   x,0
               MOV   y,12
               CALL  movecursor

               MOV   DX,OFFSET youmsg
               CALL  printmsg


               MOV   x,3
               MOV   y,0
               CALL  movecursor


    RECIEVING: mov   dx , 3FDH           ; Line Status Register
               in    al , dx
               AND   al , 1
               JZ    SENDING

               mov   dx , 03F8H
               in    al , dx
               mov   VALUE , al

               CMP   VALUE,13
               JZ    ENTERLINE1
               JMP   LL1

    ENTERLINE1:INC   y2
               MOV   x2,-1
                      

    LL1:       MOV   AL,x2
               MOV   AH,y2
               MOV   x,AL
               MOV   y,AH
               CALL  movecursor
               INC   X2

               mov   ah,2
               mov   dl,VALUE
               int   21h





    SENDING:   mov   dx , 3FDH           ; Line Status Register
               In    al , dx             ;Read Line Status
               AND   al , 00100000b
               JZ    RECIEVING
               
               mov   ah,1
               int   16h
               JZ    RECIEVING
               MOV   SENDVALUE,AL
               MOV   AH,0Ch
               INT   21h

               CMP   SENDVALUE,13
               JZ    ENTERLINE
               JMP   LL

    ENTERLINE: INC   y1
               MOV   x1,0

    LL:        mov   ah,2
               mov   dl,SENDVALUE
               int   21h

               mov   dx , 3F8H           ; Transmit data register
               mov   al, SENDVALUE
               out   dx , al


               MOV   AL,x1
               MOV   AH,y1
               MOV   x,AL
               MOV   y,AH
               CALL  movecursor
               INC   X1

               mov   ah,2
               mov   dl,SENDVALUE
               int   21h

               JMP   RECIEVING


MAIN ENDP
END MAIN 