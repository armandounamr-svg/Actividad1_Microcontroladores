; Actividad 1.asm
; Generar 100 números pseudoaleatorios (LCG)
; ATmega328P

;------------- REGISTROS ----------------
.def rand    = r16
.def count   = r17
.def temp    = r18


;------------- MEMORIA SRAM -------------
.dseg
.org 0x0100
table_of_unsorted_numbers:    .byte 100
table_of_sorted_numbers_alg1:  .byte 100
table_of_sorted_numbers_alg2:  .byte 100

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
    ldi count, 100
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
    ldi count, 100
COPY_L:
    ld temp, Z+
    st X+, temp
    dec count
    brne COPY_L
    ret

;--- BUBBLE SORT (Algoritmo 1) ---
ldi r20, 99              ; contador exterior

BUBBLE_SORT:

    ldi ZL, low(table_of_sorted_numbers_alg1)
    ldi ZH, high(table_of_sorted_numbers_alg1)

    ldi r21, 99          ; contador interior

BUBBLE_INNER:

    ld r22, Z            ; numero actual
    ldd r23, Z+1         ; siguiente numero

    cp r22, r23
    brsh Cambio            ; si r22 >= r23 intercambiar
    rjmp NEXT

Cambio:
    st Z, r23
    std Z+1, r22

NEXT:
    adiw ZL,1            ; avanzar posición

    dec r21
    brne BUBBLE_INNER

dec r20
brne BUBBLE_SORT
DONE_B:
    ret

;--- SELECTION SORT (Algoritmo 2) ---

SELECTION_SORT:
ldi XL, low(table_of_sorted_numbers_alg2)
ldi XH, high(table_of_sorted_numbers_alg2)

ldi r18, 99            ; contador exterior (N-1)

OUTER:

    mov ZL, XL
    mov ZH, XH         ; Z = posición actual

    ld r20, Z         

    mov r22, ZL
    mov r23, ZH        ; guardar dirección del mínimo

    mov r19, r18       ; contador interior

INNER:

    adiw ZL,1          ; siguiente elemento
    ld r21, Z          ; valor a comparar

    cp r21, r20
    brsh SKIP          ; si >= no cambia

    mov r20, r21       ; nuevo mínimo
    mov r22, ZL
    mov r23, ZH
SKIP:
    dec r19
    brne INNER

; intercambio
    ld r21, X          ; valor original
    st X, r20          ; poner mínimo

    mov ZL, r22
    mov ZH, r23
    st Z, r21          ; guardar el viejo valor

    adiw XL,1          ; avanzar posición

    dec r18
    brne OUTER