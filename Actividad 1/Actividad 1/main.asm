;
; Actividad 1.asm
;
; Created: 06/03/2026 09:32:30 p. m.
; Author : jflh0
;

;================================================
; Generar 100 números pseudoaleatorios
; ATmega328P - AVR Assembly
; Microchip Studio

;========================================


.include "m328pdef.inc"

;------------- REGISTROS ----------------
.def rand = r16
.def count = r17

;------------- MEMORIA SRAM -------------
.dseg
table_of_unsorted_numbers:
.byte 100

;------------- CODIGO -------------------
.cseg
.org 0x0000
rjmp RESET


RESET:

; inicializar puntero Z
ldi r30, low(table_of_unsorted_numbers)
ldi r31, high(table_of_unsorted_numbers)

; contador de 100 numeros
ldi count, 100

; semilla inicial
ldi rand, 37

GENERATE:

; algoritmo simple pseudoaleatorio
; rand = rand*5 + 1

mov r18, rand
lsl rand
lsl rand
add rand, r18
inc rand

; guardar en memoria
st Z+, rand

; disminuir contador
dec count
brne GENERATE

END:
rjmp END