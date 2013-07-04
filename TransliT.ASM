.686
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.data
DlgName db "MyDialog",0
AppName db "TransliT",0
TestString db "Wow! I'm in an edit box now",0
trans1  db  "abvgdeiklmnoprtfhx#y'wu"
trans2  db  "àáâãäåèêëìíîïðòôõõúûüùó"
trans1_c  db  "ABVGDEIKLMNOPRTFHX#Y'WU" 
trans2_c  db  "ÀÁÂÃÄÅÈÊËÌÍÎÏÐÒÔÕÕÚÛÜÙÓ"
trans1_com_c    db  "JoYoZhChShJaYaJeYeJuYu"
trans2_com_c    db  "¨¨Æ×ØßßÝÝÞÞ"
trans1_com  db  "joyozhchshjayajeyejuyu"
trans2_com  db  "¸¸æ÷øÿÿýýþþ"
trans1_com_s    db  "jsycz"
trans2_com_s    db  "éñûöç"
trans1_com_s_c  db  "JSYCZ"
trans2_com_s_c  db  "ÉÑÛÖÇ"


.data?
hInstance HINSTANCE ?
hMem    dd  ?
CommandLine LPSTR ?
buffer_i db 305 dup(?)
buffer_o db 305 dup(?)
CAPITAL  db ?
COMPLEX_CAPITAL db ?
strlen  dw  ?
strl    dd  ?

.const
IDC_EDIT        equ 3000
IDC_BUTTON      equ 3001
IDC_EXIT        equ 3002
IDC_EDIT1       equ 3003

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke DialogBoxParam, hInstance, ADDR DlgName,NULL,addr DlgProc,NULL
	invoke ExitProcess,eax

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.IF uMsg==WM_INITDIALOG
		invoke GetDlgItem, hWnd,IDC_EDIT
		invoke SetFocus,eax
	.ELSEIF uMsg==WM_CLOSE
		invoke EndDialog, hWnd,NULL
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF lParam==0
			;.IF ax==IDM_GETTEXT
			;	invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
			;	invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK
			;.ELSEIF ax==IDM_CLEAR
			;	invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
			;.ELSEIF ax==IDM_EXIT
			;	invoke EndDialog, hWnd,NULL
			;.ENDIF
		.ELSE
			mov edx,wParam
			shr edx,16
			.if dx==BN_CLICKED
				.IF ax==IDC_BUTTON
                              invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer_i,303
                              mov   strl, eax
                              call  translate
                              invoke SetDlgItemText,hWnd,IDC_EDIT1,ADDR buffer_o
                              ;invoke SendDlgItemMessage,hWnd,IDC_EDIT1,WM_SETTEXT,0,addr buffer_o
                        .ELSEIF ax==IDC_EXIT
					invoke EndDialog, hWnd,NULL
				.ENDIF
			.ENDIF
		.ENDIF
      .ELSEIF uMsg==WM_COPY
        invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_DDESHARE, strl
        mov hMem, eax
        cmp eax, 0
        je FAIL
        invoke OpenClipboard, hWnd
        cmp eax,0
        je FAIL
        invoke  EmptyClipboard
        cmp eax,0
        je FAIL
        lea esi, buffer_o
        mov edi, hMem
        mov ecx, strl
        cplp:
            mov al, byte ptr [esi+ecx]
            mov byte ptr [edi+ecx], al
            loop cplp
        invoke  SetClipboardData, CF_UNICODETEXT, hMem
        invoke  CloseClipboard
      FAIL:
 	.ELSE
		mov eax,FALSE
		ret
	.ENDIF
	mov eax,TRUE
	ret
DlgProc endp

translate   proc
 xor ebx, ebx
 xor eax, eax
 xor edx, edx
 lea edi, buffer_i
 lea esi, buffer_o
 mov ebx, edi
 mov ecx, 350d
 repne   scasb
 sub edi, ebx
 dec    edi
 mov strlen, di
 cmp    edi, strl
 je @1
 invoke MessageBox,NULL,ADDR TestString,ADDR AppName,MB_OK 
 @1:
xor ecx,ecx
begin:
    push    edx
    xor ebx, ebx
    xor eax, eax
    lea edi, buffer_i
    lea esi, buffer_o
    mov al, byte ptr [edi+ecx]
    cmp al, "A"
    jge  @2
    cmp al, "'"
    je  cont
    jmp done
@2:
    cmp al, "Z"
    jg  check
    mov edx, 1
    mov CAPITAL, dl
    mov COMPLEX_CAPITAL, dl
    jmp cont
 
check:
    xor edx, edx
    mov CAPITAL, dl
    mov COMPLEX_CAPITAL, dl
    cmp al, "a"
    jl  done
    cmp al, "z"
    jg  done
cont:
    test edx, edx
    jnz  capit1
    cmp al, "j"
    je  complex
    cmp al, "s"
    je  complex
    cmp al, "y"
    je  complex
    cmp al, "c"
    je  complex
    cmp al, "z"
    je  complex
    jmp m3
capit1:
    cmp al, "J"
    je  complex
    cmp al, "S"
    je  complex
    cmp al, "Y"
    je  complex
    cmp al, "C"
    je  complex
    cmp al, "Z"
    je  complex
m3:
    xor edx, edx
    mov dl, CAPITAL
    test edx, edx
    jnz capit2   

    
    lea edi, trans1
    mov ebx, edi
    push    ecx
    mov ecx, 50
    repne scasb
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi
    lea edi, trans2
    mov al, byte ptr [edi+ebx]
    jmp done

capit2:
    lea edi, trans1_c
    mov ebx, edi
    push    ecx
    mov ecx, 50
    repne scasb
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi
    lea edi, trans2_c
    mov al, byte ptr [edi+ebx]
    jmp done

    

complex:
    lea edi, buffer_i
    mov edx, ecx
    inc dx
    cmp DX, strlen
    je  notcomp
    inc ecx
    mov ah, byte ptr [edi+ecx]
    mov dl, COMPLEX_CAPITAL
    test dl,dl
    jz smal1
    cmp ah, 60h
    jg  sk1
    add ah, 20h
sk1:
    lea edi, trans1_com_c
    mov ebx, edi
    push    ecx
    mov ecx, 15
    repne scasw
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi                ;Ù!!!
    cmp ebx, 24
    jg  smp_c
    shr ebx, 1
    cmp ebx, 4
    jne n2
    lea edi, buffer_i
    mov dl, [edi+ecx+1]
    cmp dl, "h"
    je n3
    jmp n2
    cmp dl, "H"
    jne n2
n3:
    inc ecx
    mov al, "Ù"
    jmp done
n2:
    lea edi, trans2_com_c
    mov al, byte ptr [edi+ebx]
    jmp done

smp_c:
    dec ecx
smp_c_1:
    lea edi, trans1_com_s_c
    mov ebx, edi
    push    ecx
    mov ecx, 15
    repne scasb
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi
    lea edi, trans2_com_s_c
    mov al, byte ptr [edi+ebx]
    jmp done

smal1:
    lea edi, trans1_com
    mov ebx, edi
    push    ecx
    mov ecx, 15
    repne scasw
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi                ;Ù!!!
    cmp ebx, 24
    jg  smp
    shr ebx, 1
    cmp ebx, 4
    jne n1
    lea edi, buffer_i
    mov dl, [edi+ecx+1]
    cmp dl, "h"
    jne n1
    inc ecx
    mov al, "ù"
    jmp done
n1:
    lea edi, trans2_com
    mov al, byte ptr [edi+ebx]
    jmp done
    
smp:
    dec ecx
smp_1:
    lea edi, trans1_com_s
    mov ebx, edi
    push    ecx
    mov ecx, 12
    repne scasb
    pop ecx
    sub edi, ebx
    dec edi
    mov ebx, edi
    lea edi, trans2_com_s
    mov al, byte ptr [edi+ebx]
    jmp done

notcomp:
    mov dl, COMPLEX_CAPITAL
    test    dl,dl
    jz  smp_1
    jmp smp_c_1
    ret
done:
    pop edx
    mov [esi+edx], al
    inc ecx
    push    edx
    xor edx, edx
    mov CAPITAL, dl
    mov COMPLEX_CAPITAL, dl
    pop edx
    inc edx
    cmp cx, strlen
    jne begin
    xor eax, eax
    mov [esi+edx], eax
    ret
translate   endp

end start

