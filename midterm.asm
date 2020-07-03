data segment
    charNumber db 0
    firstDigit db '0'
    secondDigit db '0'
    number1 db 0
    number2 db 0
    numberDegree db 1
    firstNumberMessage db "Please, enter the first number(0-99):$"
    secondNumberMessage db "Please, enter the second number(0-99):$"
    newLine db 10,13,"$"  
    processMessage db "Grid drawing will start. Please wait until the drawing is completed.$" 
    processMessage2 db "Please press any key to start the drawing operation! .$"  
    errorMessage db "(0,0) grid cannot be created .$"
    distanceX dw ?
    distanceY dw ?  
ends   

stack segment
    dw 128 dup(0)
ends

code segment
numberConversion macro calculateNumber
     local oneDigitNumber, twoDigitNumber, finish
     cmp charNumber,1
     je oneDigitNumber
     jmp twoDigitNumber
    
    oneDigitNumber:
     sub [firstDigit],30h ; Number can be 0-9
     mov al,[firstDigit]
     mov [calculateNumber],al
     jmp finish
     
    twoDigitNumber: 
     ;First digit is tens digit
     sub [firstDigit],30h ;
     mov al,10
     mul [firstDigit]
     mov [calculateNumber],al
     ;Second digit is units digit
     sub [secondDigit],30h ; can be 0-9
     mov al,[secondDigit]
     ;number = firstDigit+secondDigit
     add [calculateNumber],al
     jmp finish
     
    finish:
     mov [charNumber],0
     mov [firstDigit],'0'
     mov [secondDigit],'0'
     inc numberDegree
endm   


start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    mov dx,offset firstNumberMessage
    call printMessage    
    
    
read:
    call readChar
    cmp al,08h ; is backspace? 
    je backspace
    cmp al,0Dh ; is enter?
    je enter
    cmp al,30h ;ASCII code 30h-39h(0-99)
    jb read ;
    cmp al,39h
    ja read ;
    jmp enteredNumber  
    
    
backspace:
    cmp [charNumber],0
    je read ; if zero, read char again
    dec [charNumber]
    call clearChar
    cmp charNumber,1
    je clearSecondDigit
    cmp charNumber,0
    je clearFirstDigit
    
  clearFirstDigit:  
    mov firstDigit,'0'
  clearSecondDigit:
    mov secondDigit,'0'
  
    jmp read

enter:
    cmp [charNumber],0
    je read
    lea dx,newLine
    call printMessage
    jmp convertNumber

enteredNumber:
    cmp [charNumber],0 
    je oneDigit 
    cmp [charNumber],1 
    je twoDigit 
    jmp read
    
oneDigit:
    mov [firstDigit],al
    inc [charNumber]
    call printCharacter
    jmp read

twoDigit:
    mov [secondDigit],al
    inc [charNumber]
    call printCharacter
    jmp read  

convertNumber:
    cmp [numberDegree],1
    je firstNumber
    jmp secondNumber
  firstNumber:
    numberConversion number1
    lea dx,secondNumberMessage
    call printMessage
    jmp read
  secondNumber:
    numberConversion number2
    jmp numberControlZero ; zero-zero control
  interface1: 
    lea dx,processMessage
    call printMessage 
    lea dx,newLine
    call printMessage
    lea dx,processMessage2
    call printMessage
    push    cx
    push    ax
    push    dx
    push    bx
               
    pop     bx
    pop     ax
    pop     dx
    pop     cx
    mov     ah, 08h
    int     21h
    jmp number1Control0 ; number1 Control(0,1,2)
  interface2:
    jmp number2Control0 ; number2 Control(0,1,2)
  interface: 
    cmp number1,2
    jle drawGridY
    jne drawGridX
    
  number1Control0:
    cmp number1,0
    je interface2
    jne number1Control1 
    
  number1Control1:
    cmp number1,1
    je drawXLine1
    jne number1Control2 
    
  number1Control2:
    cmp number1,2
    je drawXLine2
    jne interface 
    
  number2Control0:
    cmp number2,0
    je finishOS
    jne number2Control1 
    
  number2Control1:
    cmp number2,1
    je number1ControlForNumber2_0
    jne number2Control2
    
  number1ControlForNumber2_0: 
    cmp number1,0
    je drawYLine1_0
    jne drawYLine1_1
  
  number2Control2:
    cmp number2,2
    je number1ControlForNumber2_1
    jne drawGridY      
    
  number1ControlForNumber2_1:
    cmp number1,0
    je drawYLine2_0
    jne drawYLine2_1
    
  drawXLine1: ;if input=1
    mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h
    mov ah,00
    mov al,12h
    int 10h
    mov cx,100
    mov dx,50 
    back3:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc cx
        cmp cx,540
        jne back3
    je interface2 
    
  drawXLine2: ; if number=2
    mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h
    mov ah,00
    mov al,12h
    int 10h
    mov cx,100
    mov dx,50 
    back2:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc cx
        cmp cx,540
        jne back2 
    mov cx,100
    add dx,380
    cmp dx,430
    jle back2
    jg interface2
  
  
 drawYLine1_0: ;if number1=0 and number2=1 640x480 created 
    mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h
    mov ah,00
    mov al,12h
    int 10h 
    mov cx,100
    mov dx,50 
    back5:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc dx
        cmp dx,430
        jne back5 
        je finishOS 
        
  drawYLine1_1: ;if number1=!0 and number2=!0 640x480 already created
    
    mov cx,100   ;so 640x480 did not create
    mov dx,50 
    back6:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc dx
        cmp dx,430
        jne back6 
        je finishOS
         
  drawYLine2_0: ;if number1=0 and number2=!0 640x480 created
     mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h
    mov ah,00
    mov al,12h
    int 10h
    mov cx,100
    mov dx,50 
    back4:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc dx
        cmp dx,430
        jne back4 
        
        mov dx,50
        add cx,440 
        cmp cx,540
        jle back4
        jg finishOS
         
   drawYLine2_1: ;if number1=!0 and number2=!0 640x480 already created
    mov cx,100
    mov dx,50   ;so 640x480 did not create
    back7:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc dx
        cmp dx,430
        jne back7 
        
        mov dx,50
        add cx,440
        cmp cx,540
        jle back7
        jg finishOS
    
     
numberControlZero:
    cmp number1,0
    je numberControlZero3
    jg interface1
    
numberControlZero3: 
    cmp number2,0
    je  printErrorMessage
    jg interface1
       
     
printErrorMessage:
       lea dx,errorMessage
     call printMessage 
     lea dx,newLine
     call printMessage 
     jmp finishOS

drawGridX:  
    mov ax,0600h
    mov bh,07
    mov cx,0000
    mov dx,184Fh
    int 10h
    mov ah,00
    mov al,12h
    int 10h
    
    call findDistanceY
    
    mov cx,100
    mov dx,50 
    mov bl,[number1]
    back:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc cx
        cmp cx,540
        jne back 
        
        mov cx,100
        add dx,distanceY
        sub bx,01
        jg back
        je interface2  
        
drawGridY: 
    
   
    
    call findDistanceX
    
    mov cx,100
    mov dx,50 
    mov bl,[number2]
    back1:
        mov ah,0Ch
        mov al,01h
        int 10h
        inc dx
        cmp dx,430
        jne back1 
        
        mov dx,50
        add cx,distanceX
        sub bx,01
        jg back1
        je finishOS


    
finishOS:
    
    mov ax, 4c00h ; exit to operating system.
    int 21h

proc printMessage
    ;dx de dizi adresi olmali
    mov ah,09h
    int 21h
    ret
endp
    
proc readChar
    mov ah,07h
    int 21h ;AL=karakter   
    ret
endp

proc printCharacter
    mov dl,al
    mov ah,02h
    int 21h
    ret
endp

proc clearChar
    ;backspace karakteri ile bir karakter geri gel
    mov dl,08h
    mov ah,02h
    int 21h
    ;bosluk karakteri ile silinmiþ görüntüsü oluþtur
    mov dl,' '
    mov ah,02h
    int 21h
    ;backspace karakteri ile bir karakter geri gel
    mov dl,08h
    mov ah,02h
    int 21h
    
    ret    
endp  

proc findDistanceX
    mov ax,0000h 
    mov ax,440 
    mov bx,0000h
    mov bl,[number2]
    sub bl,01
    div bl;al=440/number1-1 
    mov ah,00
    mov [distanceX],ax 
    ret
endp

proc findDistanceY
    mov ax,0000h 
    mov ax,380
    mov bx,0000h
    mov bl,[number1]
    sub bl,01
    div bl;al=380/number1-1 
    mov ah,00
    mov [distanceY],ax 
    ret
endp 
        
ends       
   


end start ; set entry point and stop the assembler.
     
       
    