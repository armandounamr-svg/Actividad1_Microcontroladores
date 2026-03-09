; Actividad 1.asm
; Generar 100 números pseudoaleatorios (LCG)
; ATmega328P

.include "m328pdef.inc"

;------------- REGISTROS ----------------
.def rand  = r16
.def count = r17
.def temp  = r18

;------------- MEMORIA SRAM -------------
.dseg
.org SRAM_START ; Aseguramos que empiece en el inicio de la RAM de datos
table_of_unsorted_numbers:
.byte 100

;------------- CODIGO -------------------
.cseg
.org 0x0000
rjmp RESET

RESET:
    ; 1. Inicializar Puntero de Pila (Stack Pointer)
    ldi temp, low(RAMEND)
    out SPL, temp
    ldi temp, high(RAMEND)
    out SPH, temp

    ; 2. Inicializar puntero Z para apuntar a la SRAM
    ldi ZL, low(table_of_unsorted_numbers)
    ldi ZH, high(table_of_unsorted_numbers)

    ; 3. Configuración inicial
    ldi count, 100
    ldi rand, 37      ; Semilla inicial

GENERATE:
    ;--- Algoritmo: rand = (rand * 5) + 1 ---
    mov temp, rand    ; Copia el valor actual
    lsl rand          ; rand = rand * 2
    lsl rand          ; rand = rand * 4
    add rand, temp    ; rand = (rand * 4) + original = * 5
    inc rand          ; rand = (rand * 5) + 1

    ;--- Guardar en memoria ---
    st Z+, rand       ; Guarda el resultado y avanza el puntero Z

    ;--- Control de bucle ---
    dec count
    brne GENERATE

END:
    rjmp END          ; Fin del programa