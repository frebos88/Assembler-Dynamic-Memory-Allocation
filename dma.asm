.486
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib

FreeWpMemory    PROTO
LoadWpt         PROTO :DWORD
AddStruct       PROTO

.const
szfopenMode db "r",0
szfopenFile db "Waypoints.txt",0

.data?
wp dd ?
LoadedWps dd ?

.code
    start:
        mov LoadedWps,0
        push offset szfopenFile
        call LoadWpt
        call FreeWpMemory
        push 0
        call ExitProcess

        FreeWpMemory proc
            xor ecx,ecx
            @ResetEDX:
                xor edx,edx
                cmp ecx,LoadedWps
                jae @Next1
                @@:
                    cmp edx,4
                    jae @f
                    push ecx
                    push edx
                    mov ebx,wp
                    mov ebx,[ebx+ecx*4]
                    mov ebx,[ebx+edx*4]
                    push ebx
                    call crt_free
                    add esp,4
                    pop edx
                    pop ecx
                    add edx,1
                    jmp @b
                @@:
                    add ecx,1
                    jmp @ResetEDX
            @Next1:
                xor ecx,ecx
                xor edx,edx
                @@:
                    cmp edx,LoadedWps
                    jae @f
                    push ecx
                    push edx
                    mov ebx,wp
                    mov ebx,[ebx+edx*4]
                    push ebx
                    call crt_free
                    add esp,4
                    pop edx
                    pop ecx
                    add edx,1
                    jmp @b
            @@:
                push wp
                call crt_free
                add esp,4
                mov LoadedWps,0
                ret
        FreeWpMemory endp

        LoadWpt proc szFilename:DWORD
            LOCAL lpfopen           :DWORD
            LOCAL NewPointer        :DWORD

            push offset szfopenMode
            push szFilename
            call crt_fopen
            mov lpfopen,eax

            push 4
            call crt_malloc
            mov wp,eax
            call AddStruct
            mov NewPointer,eax
            xor edx,edx
            xor ecx,ecx
            jmp @f
            @ResetEDX:
                xor edx,edx
                add ecx,1
                call AddStruct
                mov NewPointer,eax
            @@:
                cmp edx,4
                jae @ResetEDX
                push edx
                push ecx
                push 7
                call crt_malloc
                add esp,4
                push eax

                push lpfopen
                push 7
                push eax
                call crt_fgets
                add esp,12
                cmp eax,0
                je @f
                
                pop eax
                pop ecx
                pop edx
                mov ebx,NewPointer
                mov [ebx+edx*4],eax
                add edx,1
                jmp @b
            @@:
                sub LoadedWps,1
                pop eax
                push eax
                call crt_free
                push NewPointer
                call crt_free
                push lpfopen
                call crt_fclose
            ret
        LoadWpt endp

        AddStruct proc uses ebx ecx edx
            push 16
            call crt_malloc
            add esp,4
            push eax
            mov eax,LoadedWps
            add eax,1
            mov ecx,4
            mul ecx
            push eax
            push wp
            call crt_realloc
            add esp,8
            mov wp,eax
            mov ebx,wp
            mov eax,LoadedWps
            mov ecx,4
            mul ecx
            mov edx,eax
            pop eax
            mov [ebx+edx],eax
            add LoadedWps,1
            ret
        AddStruct endp
            

    end start
