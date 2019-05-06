extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8] ;stringul
	mov ebx, [ebp + 12] ;cheia
	mov edx, 0
loop_xor:
	cmp byte[ebx], 0x00 ;verific daca am ajuns la finalul stringului
	je done
	mov dl, byte[ebx]
	xor byte[eax], dl ;fac xor pe cei 2 bytes
	inc ebx
	inc eax
	jmp loop_xor

done:	
	mov ecx, [ebp + 8]
	leave
	ret 

rolling_xor:
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8] 
	mov edx, 0
	mov ebx, 2
	
loop_rol_xor:
	cmp byte[eax], 0x00
	je done_rol
	cmp ebx, 2 
	je first ;primul byte este la fel asa ca il sar
	jmp next
first:
	mov cl, byte[eax]
	mov ebx, 0 ;primul byte e acum in dl
next:
	inc eax
	cmp byte[eax], 0x00 ;verific finalul stringului
	je done_rol
	mov dl, byte[eax]
	xor byte[eax], cl
	mov cl, dl ;retin rezultatul anterior pentru urmatorul xor
	jmp loop_rol_xor

done_rol:
	mov ecx, [ebp + 8]
	leave
	ret

xor_hex_strings:
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8] ;string
	mov ebx, [ebp + 8]
	mov esi, [ebp + 12] ;key

loop_convert:
	mov al, byte[edi] ;convertesc stringul in cate un octet din 2 caract
	cmp al, '9' ;verific daca e carcter hexa-zecimal si il convertesc
	jbe is_digit
	jmp is_letter
is_digit:
	sub al, '0' ;il convertesc din string la valoarea lui numerica
	jmp continue
is_letter:
	sub al, 'a' ;il convertesc din string la valoarea lui numerica
	add al, 10
continue:
	shl al, 4 ;shiftez la stanga cu 4 pentru a putea aduna noul byte
	inc edi
	cmp byte[edi], '9' ;verific daca noul byte e caracter hexa-zecimal
	jbe is_digit_2
	jmp is_letter_2
is_digit_2:
	sub byte[edi], '0' ;il convertesc din string la valoarea lui numerica
	jmp continue_2
is_letter_2:
	sub byte[edi], 'a' ;il convertesc din string la valoarea lui numerica
	add byte[edi], 10
continue_2:
	add al, byte[edi] ;adun noul byte la byte-ul shiftat
	mov byte[ebx], al ;il mut in string
	inc ebx
	inc edi
	cmp byte[edi], 0x00
	je done_convert
	jmp loop_convert	

loop_convert_2:
	mov al, byte[esi] ;procezed identic cu loop_conver
	cmp al, '9'	;dar aici reiau procesul pentru cheie
	jbe is_digit_3
	jmp is_letter_3
is_digit_3:
	sub al, '0'
	jmp continue_3
is_letter_3:
	sub al, 'a'
	add al, 10
continue_3:
	shl al, 4
	inc esi
	cmp byte[esi], '9'
	jbe is_digit_4
	jmp is_letter_4
is_digit_4:
	sub byte[esi], '0'
	jmp continue_4
is_letter_4:
	sub byte[esi], 'a'
	add byte[esi], 10
continue_4:
	add al, byte[esi]
	mov byte[edi], al
	inc edi
	inc esi
	cmp byte[esi], 0x00
	je done_convert_2
	jmp loop_convert_2

done_convert:
	inc ebx
	mov byte[ebx], 0x00 ;adaug caract nul la finalul stringului
	mov edi, edx ;poiner to the key
	jmp loop_convert_2

done_convert_2:
	inc edi
	mov byte[edi], 0x00 ;adaug caract nul la finalul cheii
	
	mov edi, [ebp + 8]
	mov edx, [ebp + 12]
	;mov eax, edi ;inceputul stringului

loop_hex_xor:
	cmp byte[edi], 0x00 ;verific daca am ajuns la finalul stringului
	je done_hex_xor
	mov al, byte[edx]
	xor byte[edi], al ;fac xor pe cei 2 bytes
	inc edi
	inc edx
	jmp loop_hex_xor
done_hex_xor:
	mov ecx, [ebp + 8]
	leave
	ret
base32decode:
	; TODO TASK 4
        push ebp
        mov ebp, esp
        mov eax, [ebp + 8]
        mov esi, eax
        mov ecx, 0
loop_base32:
        cmp byte[eax], '='
        jl is_digit_b32
        cmp byte[eax], '='
        jg is_letter_b32
        mov byte[eax], 0 ; inseamna ca e egal
        mov bl, 0
continue_loop_b32:
        and ecx, 7 ;si intre 7 si orice numar de la 0 la 7 va rezulta numarul, deci cazul
        cmp ecx, 0
        je caz_0
        cmp ecx, 1
        je caz_1
        cmp ecx, 2
        je caz_2
        cmp ecx, 3
        je caz_3
        cmp ecx, 4
        je caz_4
        cmp ecx, 5
        je caz_5
        cmp ecx, 6
        je caz_6  
        cmp ecx, 7
        je caz_7
caz_0:
        mov bl, byte[eax] ;in cele 8 cazuri in bl voi retine bitii pentru urmatorul byte
        mov byte[esi], bl
        shl byte[esi], 3 ;facem loc pentru urmatorii 2 biti
        jmp next_char
caz_1:
        shr bl, 2
        add byte[esi], bl ;adaug bitii ramasi in esi
        inc esi
        mov bl, byte[eax]
        shl bl, 6 ;fac loc pentru urmatorii biti
        mov byte[esi], bl
        jmp next_char
caz_2:
        shl bl, 1
        add byte[esi], bl
        jmp next_char
caz_3:
        shr bl, 4
        add byte[esi], bl
        inc esi ;pointerul doar pt stringul decodat
        mov bl, byte[eax]
        shl bl, 4
        mov byte[esi], bl
        jmp next_char
caz_4:
        shr bl, 1
        add byte[esi], bl
        inc esi
        mov bl, byte[eax]
        shl bl, 7
        mov byte[esi], bl
        jmp next_char
caz_5:
        shl bl, 2
        add byte[esi], bl
        jmp next_char
caz_6:
        shr bl, 3
        add byte[esi], bl
        inc esi
        mov bl, byte[eax]
        shl bl, 5
        mov byte[esi], bl
        jmp next_char
caz_7:
        add byte[esi], bl
        inc esi
        jmp next_char

next_char:
        inc eax ;trec la urmatorul caract din stringul de input
        inc ecx     
        cmp byte[eax], 0x00
        jnz loop_base32
        jmp done_task4
        
is_digit_b32:
        mov bl, byte[eax] ;convertesc din cifra in 27, 28..
        sub bl, '1'
        add bl, 25
        mov byte[eax], bl
        jmp continue_loop_b32
is_letter_b32:
        mov bl, byte[eax] ;convertesc din A,B,C in 0, 1, 2..
        sub bl, 65
        mov byte[eax], bl
        jmp continue_loop_b32
done_task4:
        mov ecx,[ebp + 8]       
        leave
	ret

bruteforce_singlebyte_xor:
	; TODO TASK 5
        push ebp
        mov ebp, esp
        mov esi, [ebp + 8]
        mov edx, 0 ;counter
       
loop_bruteforce:
        mov bl, byte[esi + edx]
        cmp bl, 0x00
        je next_byte ;incrementeaza stringul
        xor bl, al
        ;verific litera cu litera daca "force" se afla in string
check_F:
       cmp bl, 'f'
       jne go_to_next_char
       jmp check_O
check_O:
        mov bl, byte[esi + edx + 1]
        xor bl, al
        cmp bl, 'o'
        jne go_to_next_char
        jmp check_R
check_R:
        mov bl, byte[esi + edx + 2]
        xor bl, al
        cmp bl, 'r'
        jne go_to_next_char
        jmp check_C
check_C:
        mov bl, byte[esi + edx + 3]
        xor bl, al
        cmp bl, 'c'
        jne go_to_next_char
        jmp check_E
check_E:
        mov bl, byte[esi + edx + 4]
        xor bl, al
        cmp bl, 'e'
        jne go_to_next_char
       ;daca am ajuns aici inseamna ca "force" e in string
        mov ebx, 0
        mov edx, 0
        
decode_bruteforce:
        mov bl, byte[esi + edx]
        cmp bl, 0x00
        je done_task5
        xor bl, al ;fac xor byte cu byte
        mov byte[esi + edx], bl
        inc edx
        jmp decode_bruteforce
        
go_to_next_char:
        inc edx
        jmp loop_bruteforce
        
next_byte:
        mov edx, 0
        inc eax
        jmp loop_bruteforce
        
done_task5:
        leave
        ret

decode_vigenere:
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8] ;stringul
	mov ebx, [ebp + 12] ;cheia
	mov esi, ebx ;il retin pentru reluarea cheii

decode_vig_loop:
	mov dl, byte[eax]
	cmp dl, 97 ;verific daca e < 'a'
	jl not_a_letter
	cmp dl, 122 ;verific daca e > 'z'
	jg not_a_letter
	mov cl, byte[ebx]
	cmp cl, 0x00
	je repeat_key ;daca cheia a ajuns la final, mutam pointerul la inceput

add_key:
	sub dl, cl
	add dl, 26
	cmp dl, 26 ;caut off set-ul fata de 'a'
	jge more ;aceste 2 label-uri sunt echivalente cu %26
	jmp less

decode_string:
	mov byte[eax], dl ;mut litera rezultata inapoi in string
	inc eax
	cmp byte[eax], 0x00
	je done_task6
	inc ebx	
	cmp byte[ebx], 0x00
	je repeat_key2
	jmp decode_vig_loop

more:
	sub dl, 26 ;daca %26 > 26
	add dl, 97
	jmp decode_string

less:
	add dl, 97 ;daca %26 < 26
	jmp decode_string
	
repeat_key:
	mov ebx, esi ;reia cheia
	jmp add_key

repeat_key2:
	mov ebx, esi
	jmp decode_vig_loop

not_a_letter:
	inc eax ;daca nu e un caracter de la a-z il sarim
	cmp byte[eax], 0x00
	je done_task6
	jmp decode_vig_loop

done_task6:
	leave
	ret

main:
        mov ebp, esp; for correct debugging
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	mov edx, ecx ;inceputul inputului

loop_string:
	cmp byte[edx], 0x00 ;caut primul 0x00 ca sa vad unde incepe cheia
	je found_string
	inc edx
	jmp loop_string

found_string:
	inc edx ;sar peste 0x00 ca sa ajung la inceputul cheii

	push edx ;key
	push ecx ;string	
	call xor_strings
	add esp, 8
	
	push ecx	
	call puts                   ;print resulting string
	add esp, 4
	
	jmp task_done

task2:
	push ecx ;inceputul stringului
	call rolling_xor
	add esp, 4

	push ecx
	call puts
	add esp, 4

	jmp task_done

task3:
	mov edx, ecx ;inceputul stringului

loop_string_3:
	cmp byte[edx], 0x00 ;caut inceputul cheii
	je found_string_3
	inc edx
	jmp loop_string_3

found_string_3:
	inc edx ;de la edx incepe cheia
	
	push edx
	push ecx
	call xor_hex_strings

	push ecx                 ;print resulting string
	call puts
	add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
        push ecx
        call base32decode 
        add esp, 4
        
	push ecx
	call puts                    ;print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; TODO TASK 5: call the bruteforce_singlebyte_xor function
        push ecx
        call bruteforce_singlebyte_xor
        mov ebx, 0
        mov ebx, eax
        call puts
        pop ecx
        mov eax, ebx
        push eax
        push eax                    ;eax = key value
        push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax	;eax adresa cheii
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
