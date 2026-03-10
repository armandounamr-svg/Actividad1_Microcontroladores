;
; BIG ONE PRUEBA 150.asm
;
; Created: 10/03/2026 12:47:23 a. m.
; Author : jflh0
;

; Actividad 1.asm
; Generar 100 números pseudoaleatorios (LCG)
; ATmega328P

.include "m328pdef.inc"

;------------- REGISTROS ----------------
.def rand    = r16
.def count   = r17
.def temp    = r18
.def aux1    = r19
.def aux2    = r20
.def min_val = r21

;------------- MEMORIA SRAM -------------
.dseg
.org 0x0100
table_of_unsorted_numbers:    .byte 200
table_of_sorted_numbers_alg1:  .byte 200
table_of_sorted_numbers_alg2:  .byte 200

;------------- CODIGO -------------------
.cseg
.org 0x0000
rjmp RESET

RESET:
    ldi temp, low(RAMEND)
    out SPL, temp
    ldi temp, high(RAMEND)
    out SPH, temp

    rcall GENERATE_NUMBERS

    ; Algoritmo 1: Burbuja
    ldi ZL, low(table_of_unsorted_numbers)
    ldi ZH, high(table_of_unsorted_numbers)
    ldi XL, low(table_of_sorted_numbers_alg1)
    ldi XH, high(table_of_sorted_numbers_alg1)
    rcall COPY_TABLE
    rcall BUBBLE_SORT

    ; Algoritmo 2: Selección
    ldi ZL, low(table_of_unsorted_numbers)
    ldi ZH, high(table_of_unsorted_numbers)
    ldi XL, low(table_of_sorted_numbers_alg2)
    ldi XH, high(table_of_sorted_numbers_alg2)
    rcall COPY_TABLE
    rcall SELECTION_SORT

END_LOOP:
    rjmp END_LOOP

;--- GENERAR NÚMEROS ---
GENERATE_NUMBERS:
    ldi ZL, low(table_of_unsorted_numbers)
    ldi ZH, high(table_of_unsorted_numbers)
    ldi count, 150
    ldi rand, 37
GEN_L:
    mov temp, rand
    lsl rand
    lsl rand
    add rand, temp
    inc rand
    st Z+, rand
    dec count
    brne GEN_L
    ret

;--- COPIAR TABLA ---
COPY_TABLE:
    ldi count, 150
COPY_L:
    ld temp, Z+
    st X+, temp
    dec count
    brne COPY_L
    ret

;--- BUBBLE SORT (Algoritmo 1) ---
BUBBLE_SORT:
    ldi aux1, 150    ; Límite exterior
OUTER_B:
    ldi ZL, low(table_of_sorted_numbers_alg1)
    ldi ZH, high(table_of_sorted_numbers_alg1)
    mov aux2, aux1
    dec aux2
    breq DONE_B          ; Si terminamos las pasadas
INNER_B:
    ld r0, Z             ; Carga el elemento actual (i)
    ldd r1, Z+1          ; Carga el elemento siguiente (i+1) SIN mover el puntero Z
    
    cp r1, r0            ; Compara (i+1) con (i)
    brsh NO_SWAP_B       ; Si (i+1) >= (i), no intercambiar

    ; --- Intercambio (Swap) ---
    st Z, r1             ; Guarda el menor en la posición (i)
    std Z+1, r0          ; Guarda el mayor en la posición (i+1)

NO_SWAP_B:
    adiw ZL, 1           ; Avanza el puntero Z a la siguiente posición
    dec aux2
    brne INNER_B
    
    dec aux1
    brne OUTER_B
DONE_B:
    ret

;--- SELECTION SORT (Algoritmo 2) ---
SELECTION_SORT:
    ldi XL, low(table_of_sorted_numbers_alg2)
    ldi XH, high(table_of_sorted_numbers_alg2)
    ldi aux1, 149  ; N-1 pasadas
OUTER_S:
    mov ZL, XL      ; Puntero de búsqueda empieza en la posición actual de X
    mov ZH, XH
    ld min_val, Z+  ; El primer valor es el mínimo inicial
    mov r24, XL     ; Guardar dirección del mínimo actual
    mov r25, XH
    
    mov aux2, aux1
INNER_S:
    ld temp, Z      ; Cargar siguiente para comparar
    cp temp, min_val
    brsh NEXT_S
    mov min_val, temp ; Actualizar valor mínimo
    mov r24, ZL       ; Guardar dirección del nuevo mínimo
    mov r25, ZH
NEXT_S:
    adiw ZL, 1      ; Avanzar puntero de búsqueda
    dec aux2
    brne INNER_S

    ; Intercambio final entre X y la dirección del mínimo (R25:R24)
    ld temp, X
    st X, min_val
    mov ZL, r24
    mov ZH, r25
    st Z, temp

    adiw XL, 1      ; Avanzar la frontera de la tabla ordenada
    dec aux1
    brne OUTER_S
    ret
