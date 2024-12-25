
SECTION .text

global go_0kos.Sleep
global go_0kos.Event
global go_0kos.GetButtonID
global go_0kos.CreateButton
global go_0kos.Exit
global go_0kos.Redraw
global go_0kos.Window
global go_0kos.WriteText
global go_0kos.GetTime
global go_0kos.DrawLine
global go_0kos.DrawBar
global go_0kos.DebugOutHex
global go_0kos.DebugOutChar
global go_0kos.DebugOutStr
global go_0kos.WriteText2

SECTION .text

; Сравнение 32-битных блоков памяти
global runtime.memequal32..f
runtime.memequal32..f:
    push ebp
    mov ebp, esp
    
    ; Получаем указатели на два блока памяти
    mov esi, [ebp+8]      ; Указатель на первый блок
    mov edi, [ebp+12]     ; Указатель на второй блок
    mov ecx, [ebp+16]     ; Размер блока (в байтах)
    
    ; Важно: Сравниваем блоки по 4 байта (32-бит)
    cld                     ; Очищаем флаг направления для побайтовых операций
    repe cmpsd              ; Сравниваем 4 байта за раз (по 32 бита)
    
    ; Если все байты одинаковы, возвращаем 0 (равны)
    setz al
    movzx eax, al           ; Возвращаем 0 или 1 в eax (0 — блоки равны)
    
    ; Возвращаем результат
    mov esp, ebp
    pop ebp
    ret

; Сравнение 8-битных блоков памяти
global runtime.memequal8..f
runtime.memequal8..f:
    push ebp
    mov ebp, esp
    
    ; Получаем указатели на два блока памяти
    mov esi, [ebp+8]      ; Указатель на первый блок
    mov edi, [ebp+12]     ; Указатель на второй блок
    mov ecx, [ebp+16]     ; Размер блока (в байтах)
    
    ; Сравниваем блоки по 1 байту (8-бит)
    cld                     ; Очищаем флаг направления для побайтовых операций
    repe cmpsb              ; Сравниваем 1 байт за раз (по 8 бит)
    
    ; Если все байты одинаковы, возвращаем 0 (равны)
    setz al
    movzx eax, al           ; Возвращаем 0 или 1 в eax (0 — блоки равны)
    
    ; Возвращаем результат
    mov esp, ebp
    pop ebp
    ret

; Универсальное сравнение памяти (для любых блоков)
global runtime.memequal
runtime.memequal:
    push ebp
    mov ebp, esp
    
    ; Получаем указатели на два блока памяти
    mov esi, [ebp+8]      ; Указатель на первый блок
    mov edi, [ebp+12]     ; Указатель на второй блок
    mov ecx, [ebp+16]     ; Размер блока (в байтах)
    
    ; В случае меньших блоков (меньше 4 байт) будем сравнивать побайтово
    cmp ecx, 4
    jl compare_byte
    
    ; Сравнение блоков по 4 байта (32-бит) если размер >= 4
    cld                     ; Очищаем флаг направления для побайтовых операций
    repe cmpsd              ; Сравниваем 4 байта за раз (по 32 бита)
    
    ; Если все блоки одинаковы, возвращаем 0 (равны)
    setz al
    movzx eax, al           ; Возвращаем 0 или 1 в eax (0 — блоки равны)
    jmp end_memequal

compare_byte:
    ; Сравнение блоков по 1 байту (8-бит)
    cld                     ; Очищаем флаг направления для побайтовых операций
    repe cmpsb              ; Сравниваем 1 байт за раз (по 8 бит)
    
    ; Если все байты одинаковы, возвращаем 0 (равны)
    setz al
    movzx eax, al           ; Возвращаем 0 или 1 в eax (0 — блоки равны)
    
end_memequal:
    ; Возвращаем результат
    mov esp, ebp
    pop ebp
    ret


global go_0kos.SetByteString
go_0kos.SetByteString:
  push ebp
  mov ebp, esp
  mov eax, [ebp+8]
  mov ebx, [ebp+12]
  mov ecx, [ebp+16]
  mov dh, [ebp+20]
  mov byte[eax+ecx], dh
  mov esp, ebp
  pop ebp
  ret

global __go_runtime_error
global __go_register_gc_roots
global __unsafe_get_addr

__unsafe_get_addr:
  push ebp
  mov ebp, esp
  mov eax, [ebp+8]
  mov esp, ebp
  pop ebp
  ret

__go_register_gc_roots:
__go_runtime_error:
  ret

global runtime.concatstrings
runtime.concatstrings:
    ; Считаем общую длину обеих строк
    add esi, ecx           ; Общая длина = длина первой строки + длина второй
    mov ebx, esi           ; Запоминаем общую длину в ebx

    ; Выделим память для результата
    ; (Будет использоваться системный вызов для выделения памяти в KolibriOS)
    mov eax, 68            ; Номер функции для выделения памяти
    mov ecx, ebx           ; Требуемый размер памяти в байтах
	mov ebx, 12            ; Номер подфункции
    int 0x40               ; Вызов системного вызова
    mov ebx, eax           ; Сохраняем указатель на выделенную память (ebx — 32-битная версия)

    ; Копируем первую строку в результат
    mov edi, ebx           ; Указатель на результат
    mov esi, [esp+4]       ; Указатель на первую строку
    mov ecx, [esp+8]       ; Длина первой строки
copy_str1:
    mov al, [esi]          ; Загружаем байт из первой строки
    test al, al            ; Проверяем конец строки
    jz done_copy_str1
    mov [edi], al          ; Записываем байт в результат
    inc esi                ; Переходим к следующему символу
    inc edi                ; Переходим к следующей ячейке результата
    loop copy_str1

done_copy_str1:

    ; Копируем вторую строку в результат
    mov edi, ebx           ; Указатель на результат
    add edi, ebx           ; Переходим к концу первой строки
    mov esi, [esp+12]      ; Указатель на вторую строку
    mov ecx, [esp+16]      ; Длина второй строки
copy_str2:
    mov al, [esi]          ; Загружаем байт из второй строки
    test al, al            ; Проверяем конец строки
    jz done_copy_str2
    mov [edi], al          ; Записываем байт в результат
    inc esi                ; Переходим к следующему символу
    inc edi                ; Переходим к следующей ячейке результата
    loop copy_str2

done_copy_str2:

    ; Завершаем строку нулевым байтом
    mov byte [edi], 0

    ; Возвращаем указатель на результат
    mov eax, ebx           ; Указатель на объединённую строку
    ret


global runtime.writeBarrier
global runtime.gcWriteBarrier
runtime.writeBarrier:
    mov eax, [esp+8]
    mov ebx, [esp+12]
    mov dword[eax], ebx
    ret

global runtime.strequal..f
runtime.strequal..f:
    mov eax, [esp+8]      ; Первый указатель
    mov ebx, [esp+16]     ; Второй указатель
    mov ecx, 0            ; Индекс для прохода по строкам
strcmp_loop:
    mov byte dl, [eax+ecx]
    mov byte dh, [ebx+ecx]
    inc ecx
    cmp dl, 0
    je strcmp_end_0       ; Окончание строки
    cmp byte dl, dh
    je strcmp_loop        ; Сравнение продолжается
    jl strcmp_end_1       ; Если строки разные
    jg strcmp_end_2
strcmp_end_0:
    cmp dh, 0
    jne strcmp_end_1
    xor ecx, ecx          ; Строки равны
    ret
strcmp_end_1:
    mov ecx, 1            ; Строки не равны
    ret
strcmp_end_2:
    mov ecx, -1           ; Строки различны
    ret

runtime.gcWriteBarrier:
    mov eax, [esp+8]
    mov ebx, [esp+12]
    mov dword[eax], ebx
    ret

global runtime.goPanicIndex
runtime.goPanicIndex:
    ret

global runtime.registerGCRoots
runtime.registerGCRoots:
    ret

global memcmp
memcmp:
    push ebp
    mov ebp,esp
    mov     esi, [ebp+8]    ; Move first pointer to esi
    mov     edi, [ebp+12]    ; Move second pointer to edi
    mov     ecx, [ebp+16]    ; Move length to ecx

    cld                         ; Clear DF, the direction flag, so comparisons happen
                                ; at increasing addresses
    cmp     ecx, ecx            ; Special case: If length parameter to memcmp is
                                ; zero, don't compare any bytes.
    repe cmpsb                  ; Compare bytes at DS:ESI and ES:EDI, setting flags
                                ; Repeat this while equal ZF is set
    setz    al
    mov esp,ebp
    pop ebp
    ret


go_0kos.Sleep:
    push ebp
    mov ebp, esp
    mov eax, 5            ; ID вызова
    mov ebx, [ebp+8]      ; Параметр (например, время задержки)
    int 0x40              ; Системный вызов (пример для Linux/x86)
    mov esp, ebp
    pop ebp
    ret


go_0kos.Event:
    mov eax, 10           ; ID вызова
    int 0x40              ; Системный вызов
    ret

go_0kos.GetButtonID:
  mov   eax,17
  int   0x40
  test  al,al
  jnz   .no_button
  shr   eax,8
  ret
.no_button:
  xor   eax,eax
  dec   eax
  ret

go_0kos.Exit:
	mov eax, -1
	int 0x40
    ret

go_0kos.Redraw:
    push ebp
    mov ebp,esp
	mov eax, 12
	mov ebx, [ebp+8]
	int 0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.Window:
    push ebp
    mov ebp,esp
	mov ebx, [ebp+8]
	shl ebx, 16
	or ebx, [ebp+16]
	mov ecx, [ebp+12]
	shl ecx, 16
	or ecx, [ebp+20]
	mov edx, 0x14
	shl edx, 24
	or edx, 0xFFFFFF
	mov esi, 0x808899ff
	mov edi, [ebp+24]
	xor eax, eax
	int 0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.WriteText:
    push ebp
    mov ebp,esp
    mov eax,4
    mov ebx,[ebp+8]
    shl ebx,16
    mov bx,[ebp+12]
    mov ecx,[ebp+16]
    mov edx,[ebp+20]
    mov esi,[ebp+24]
    int 0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.WriteText2:
    push ebp
    mov ebp,esp
    mov eax,47
    mov ebx,[ebp+8]
    shl ebx,16
    mov ecx,[ebp+12]
    mov edx,[ebp+20]
    shl edx,16
    add edx, [ebp+24]
    mov esi,[ebp+28]
    int 0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.DrawLine:
    push ebp
    mov ebp,esp
    mov ebx,[ebp+8]
    shl ebx,16
    mov bx,[ebp+16]
    mov ecx,[ebp+12]
    shl ecx,16
    mov cx,[ebp+20]
    mov edx,[ebp+24]
    mov eax,38
    int 0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.DrawBar:
    push ebp
    mov ebp,esp
    mov   eax,13
    mov   ebx,[ebp+8]
    shl   ebx,16
    mov   bx,[ebp+16]
    mov   ecx,[ebp+12]
    shl   ecx,16
    mov   cx,[ebp+20]
    mov   edx,[ebp+24]
    int   0x40
    mov esp,ebp
    pop ebp
    ret

go_0kos.GetTime:
    mov eax, 3
    int 0x40
    ret

go_0kos.DebugOutHex:
    mov eax, [esp+4]
    mov   edx, 8
    .new_char:
    rol   eax, 4
    movzx ecx, al
    and   cl,  0x0f
    mov   cl,  [__hexdigits + ecx]
    pushad
    mov eax, 63
    mov ebx, 1
    int 0x40
    popad
    dec   edx
    jnz   .new_char
    ret

go_0kos.DebugOutChar:
   mov al, [esp+4]
   pushf
   pushad
   mov  cl,al
   mov  eax,63
   mov  ebx,1
   int  0x40
   popad
   popf
   ret

go_0kos.DebugOutStr:
   mov  edx,[esp+4]
   mov  eax,63
   mov  ebx,1
 m2:
   mov  cl, [edx]
   test cl,cl
   jz   m1
   int  40h
   inc  edx
   jmp  m2
 m1:
   ret

go_0kos.CreateButton:
  push  ebp
  mov   ebp,esp
  mov   eax, 8
  mov ebx, [ebp+8]
  shl ebx, 16
  mov bx, [ebp+16]
  mov ecx, [ebp+12]
  shl ecx, 16
  mov cx, [ebp+20]
  mov edx, [ebp+24]
  mov esi, [ebp+28]
  int   0x40
  mov   esp,ebp
  pop   ebp
  ret

; Описание данных
SECTION .data
__hexdigits:
    db '0123456789ABCDEF' ; Символы для отображения в шестнадцатеричном формате

; Пример использования данных
__test:
    dd __hexdigits        ; Пример ссылки на данные
    dd 15                 ; Пример значения