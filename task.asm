section .text
	global _start

_start:                   ;entry point
  ;; generate the name
  call generate_name

  ;; output the name
  mov eax, 4              ;sys_write
	mov edx, lenname        ;string length
	mov ecx, name           ;string
	mov ebx, 1              ;stdout
	int 0x80                ;syscall

  ;; exit program
	mov eax, 1              ;interupt code
	mov ebx, 0              ;sys_exit
	int 0x80                ;syscall

generate_name:
  mov ebx, 0              ;holds the number of the current syllable
  mov ecx, name           ;holds the address of the current point in the string

_loop_start:
  ;; add a syllable to the string
  call do_rand            ;generate a new random number
	mov eax, dword [rand]

  push ebx                ;push the value of ebx on the stack
  xor edx, edx            ;no lower bits
  mov ebx, lenconsonants  ;divide by sizeof consonants
  div ebx                 ;divide eax by ebx, remainder in edx
  pop ebx                 ;restore old ebx from the stack

  ;; if we should add the "th"
  push eax  	            ;push the value of ebx on the stack
  mov eax, lenconsonants  ;store the consonant count in eax
  dec eax                 ;subtract 1 for imaginary 'th' index
  cmp edx, eax            ;if the current random index is the 'th' one
  pop eax                 ;pop old value back into eax
  jne _skip_th

  mov [ecx], dword 'th'   ;add the characters
  add ecx, 2              ;add 2 to the string pointer
  jmp _skip_add_c

_skip_th:
  mov eax, consonants     ;move the address of consonants into eax
  add eax, edx            ;add the index of the random character
  mov eax, [eax]          ;dereference the value
  mov [ecx], al           ;move the lower bits of eax into the current address of the name string

  inc ecx                 ;increment the string pointer

  ;; if the current random character isn't an 's'
  cmp edx, 2
  jb _skip_add_c          ;jump if below

  call do_rand            ;generate a new random number to decide weather to double s
  mov eax, dword [rand]   ;store in eax

  push ebx                ;push the value of ebx on the stack
  xor edx, edx            ;no lower bits
  mov ebx, 11             ;divide by 11: we want values between 0 and 10
  div ebx                 ;divide eax by ebx, remainder in edx
  pop ebx                 ;pop old value back into ebx

  cmp ebx, 5              ;50 percent chance
  jb _skip_add_c          ;jump if below

  mov [ecx], dword 'ss'    ;add an extra 's'
  inc ecx
  inc ecx

_skip_add_c:
  push ebx                ;push the value of ebx on the stack
  xor edx, edx            ;no lower bits
  mov ebx, lenvowels      ;divide by sizeof vowels
  div ebx                 ;divide eax by ebx, remainder in edx
  pop ebx                 ;restore old ebx from the stack

  mov eax, vowels         ;move the address of vowels into eax
  add eax, edx            ;add the index of the random character
  mov eax, [eax]          ;dereference the value
  mov [ecx], al           ;move the lower bits of eax into the current address of the name string

  inc ecx                 ;increment the string pointer

  ;; decide weather to do another syllable
  inc ebx

  ;; go back to loop start if ebx == 1: at least two syllables
  cmp ebx, 1
  je _loop_start

  call do_rand            ;generate a new random number
  mov eax, dword [rand]   ;store in eax

  push ebx                ;push the value of ebx on the stack
  xor edx, edx            ;no lower bits
  mov ebx, 11             ;divide by 11: we want values between 0 and 10
  div ebx                 ;divide eax by ebx, remainder in edx
  pop ebx                 ;pop old value back into ebx

  ;; if i == 2, chance is 60%
  cmp ebx, 2
  jne _after_two

  cmp edx, 6              ;60 percent chance
  jb _loop_start          ;jump if below

_after_two:
  cmp edx, 5              ;60 percent chance
	jb _loop_start          ;jump if below

  ret

;; pseudo rand function (not really but hey lol)
do_rand:
  push ebx
  push eax

  rdtsc
  add ebx, eax
  mov [rand], dword ebx

  pop eax
  pop ebx

  ret


section .data
  name db '                                              ', 0x0a
  lenname equ $ - name

section .rdata                  ;const data
	randprompt db 'enter a character to seed random', 0x0a
	lenrandprompt equ $ - randprompt

  ;; list of consonants
  global consonants
consonants:
  db 's'
  db 's'
  db 'b'
  db 'd'
  db 'g'
  db 'l'
  db 'm'
  db 'n'
  db 'p'
  db 't'
  db 't'
  db 'v'
  db 'z'
  db 'z'
  lenconsonants equ $ - consonants + 1

  ;; list of vowels
  global vowels
vowels:
  db 'a'
  db 'e'
  db 'i'
  db 'o'
  db 'u'
  lenvowels equ $ - vowels

section .bss                    ;uninitialized data
	rand resd 1                   ;4 byte value for random result
