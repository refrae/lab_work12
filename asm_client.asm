section .data
    ; Структура sockaddr_in для подключения к 127.0.0.1:8080
    sock_addr:
        dw 2          ; AF_INET (2 байта) -> 02 00 (Little-Endian)
        dw 0x901F     ; Порт 8080 в формате Big-Endian (0x1F90 перевернут)
        dd 0x0100007F ; IP 127.0.0.1 в формате Big-Endian (0x7F000001 перевернут)
        dq 0          ; 8 байт нулей (заглушка)
    
    sock_addr_len equ $ - sock_addr

    msg db "Hello from clean NASM assembly code!"
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; 1. СИСТЕМНЫЙ ВЫЗОВ: sys_socket (Создание структуры сокета в ядре)
    mov rax, 41       ; RAX = 41 (номер sys_socket)
    mov rdi, 2        ; RDI = 2 (AF_INET)
    mov rsi, 1        ; RSI = 1 (SOCK_STREAM)
    mov rdx, 0        ; RDX = 0 (протокол по умолчанию)
    syscall           ; Вызов ядра. Дескриптор сокета вернется в RAX.

    ; Сохраняем полученный дескриптор сокета
    mov r12, rax

    ; 2. СИСТЕМНЫЙ ВЫЗОВ: sys_connect
    mov rax, 42            ; RAX = 42 (номер sys_connect)
    mov rdi, r12           ; RDI = наш сохраненный дескриптор сокета
    mov rsi, sock_addr     ; RSI = указатель на структуру sockaddr
    mov rdx, sock_addr_len ; RDX = размер структуры (16 байт)
    syscall                ; Вызов ядра

    ; 3. СИСТЕМНЫЙ ВЫЗОВ: sys_write (Отправка данных)
    mov rax, 1       ; RAX = 1 (номер sys_write)
    mov rdi, r12     ; RDI = дескриптор сокета
    mov rsi, msg     ; RSI = адрес нашей строки
    mov rdx, msg_len ; RDX = длина строки
    syscall          ; Вызов ядра

    ; 4. СИСТЕМНЫЙ ВЫЗОВ: sys_exit (Корректный выход)
    mov rax, 60      ; RAX = 60 (номер sys_exit)
    xor rdi, rdi     ; RDI = 0 (код возврата)
    syscall
