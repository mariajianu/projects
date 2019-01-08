;JIANU Maria 321CB
%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
		mov ebp, esp; for correct debugging
		push ebp
		mov ebp, esp

	GET_STRING expr, MAX_INPUT_SIZE
        
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        
        mov esi, expr ;use esi to parse the string
        ;this big loop will parse through the input         
parse_string:
        cmp byte[esi], ' '
        je space
        cmp byte [esi], '-'
        je ch_neg ;check if negative number or minus
        cmp byte[esi],'+' ;check if the current character is operand or operator 
        je plus
        cmp byte[esi],'/'
        je divide  
        cmp byte[esi],'*'
        je multiply
        jmp string_to_int ;if it is an operand, convert it to int
space: 
      inc esi ;if its the space between the numbers, go to next character
      jmp parse_string
      
ch_neg:
        inc esi
        cmp byte[esi],0x00
        je minus ;if next character is end of input line, it was a minus
        cmp byte[esi],' '
        je minus ;if next character is space, it was a minus
        jmp string_to_int_neg ;if next character is a digit, it is a negative number
plus:
        pop eax ;pop the number so we can add them
        pop ebx
        add eax, ebx ;add them
        push eax ;push the sum back on to the stack
        inc esi
        cmp byte[esi], 0x00 ;check if end of line
        jne parse_string
        jmp finish
minus:
        pop eax ;pop the numbers so we can substract them
        mov ebx, eax ;swap them to respect the order of operations
        pop eax
        sub eax, ebx
        push eax ;push the result back on to the stack
        inc esi
        cmp byte[esi], 0x00
        jne parse_string
        jmp finish
divide:
        xor eax, eax
        mov edx, 0
        pop eax ;pop and swap the numbers 
        mov ebx, eax
        pop eax
        cdq ;set cdq for the negative numbers
        idiv ebx
        push eax ;the quotient is pushed back on to the stack
        inc esi
        cmp byte[esi], 0x00
        jne parse_string
        jmp finish
multiply:
        xor eax, eax
        mov edx, 0
        pop eax ;pop and multiply the numbers
        pop ebx
        imul ebx
        push eax ;push the result on the stack
        inc esi
        cmp byte[esi], 0x00
        jne parse_string
        jmp finish
        
string_to_int_neg: ;convert to int the negative numbers
        mov edx, esi ;move the string
        xor eax, eax
    convert_neg:
        movzx ebx, byte[edx] ;take it byte by byte
        inc edx
        cmp ebx ,'0' ;if below 0 it is not a digit
        jb done_neg
        cmp ebx ,'9' ;if over 0 it is not a digit
        ja done_neg
        sub ebx, 48 ;substract '0' in ASCII
        imul eax, 10 ;multiply it by ten
        add eax, ebx ;add it to the result 
        jmp convert_neg

done_neg:
        not eax ;2's complement to make it negative
        add eax, 1
        push eax
        cmp eax, -99
        jl three_digit_nr 
        cmp eax, -9
        jl two_digit_nr       
        inc esi
        jmp parse_string
     
string_to_int: ;convert to int the pozitive numbers
        mov edx, esi
        xor eax, eax
    convert:
        movzx ebx, byte[edx]
        inc edx
        cmp ebx ,'0'
        jb done
        cmp ebx ,'9'
        ja done
        sub ebx, 48
        imul eax, 10
        add eax, ebx
        jmp convert

done:
        push eax
        cmp eax, 99
        jg three_digit_nr
        cmp eax, 9
        jg two_digit_nr
        inc esi
        jmp parse_string 
         
two_digit_nr:
        inc esi ;'jump' over the next 2 digits because esi will point to the first one
        inc esi
        jmp parse_string
    
three_digit_nr:
        inc esi ; 'jump' over the next 3 digits
        inc esi
        inc esi
        jmp parse_string

finish:
        pop eax
        PRINT_DEC 4, eax
        xor eax, eax
        mov esp, ebp
        
        leave
        ret
