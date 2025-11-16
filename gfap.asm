# Autor: Gabriel França de Albuquerque Pernambuco
# Email: gfap@cesar.school
# Calculadora Programador Didática – Conversão entre bases, complemento de 2 e IEEE754
#
# Revisões:
# 13/11/2025 14:30 – Implementação completa da Q1 (Base 10 → Bin/Oct/Hex/BCD).
# 14/11/2025 11:45 – Implementação completa da Q2 (Complemento de 2 – 16 bits).
# 16/11/2025 17:10 – Implementação completa da Q3 (IEEE754 Float e Double, com sinal/expoente/fração).
#

.data
menu: .asciiz "\n=== CALCULADORA PROGRAMADOR DIDÁTICA ===\n1) Conversões Base 10 (Q1)\n2) Complemento de 2 (Q2)\n3) Float/Double IEEE754 (Q3)\n0) Sair\nEscolha: "
ask_dec: .asciiz "\nDigite um número decimal: "
ask_real: .asciiz "\nDigite um número real: "

divfmt:  .asciiz "\nN = "
divfmt2: .asciiz "  ->  N/base = "
divfmt3: .asciiz "  resto = "

msg_bin: .asciiz "\nBinário: "
msg_oct: .asciiz "\nOctal: "
msg_hex: .asciiz "\nHexadecimal: "
msg_bcd: .asciiz "\nBCD: "

msg_comp: .asciiz "\nComplemento de 2 (16 bits): "

msg_float: .asciiz "\nFLOAT IEEE754 (32 bits): "
msg_double: .asciiz "\nDOUBLE IEEE754 (64 bits): "

msg_sinal: .asciiz "\nSinal: "
msg_exp: .asciiz "\nExpoente (sem viés): "
msg_expv: .asciiz "\nExpoente (com viés): "
msg_frac: .asciiz "\nFração: "

newline: .asciiz "\n"
buffer: .space 64

.text
main:

MENU_PRINCIPAL:
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, Q1
    beq $t0, 2, Q2
    beq $t0, 3, Q3
    beq $t0, 0, SAIR
    j MENU_PRINCIPAL

Q1:
    li $v0, 4
    la $a0, ask_dec
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    li $v0, 4
    la $a0, msg_bin
    syscall

    move $a0, $s0
    jal BINARIO

    li $v0, 4
    la $a0, msg_oct
    syscall

    li $v0, 34
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_hex
    syscall

    li $v0, 34
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_bcd
    syscall

    move $a0, $s0
    jal BCD

    j MENU_PRINCIPAL

BINARIO:
    li $t1, 0
    la $t2, buffer

BIN_LOOP:
    beq $a0, $zero, BIN_PRINT

    li $t3, 2
    div $a0, $t3
    mflo $t4
    mfhi $t5

    addi $t5, $t5, 48
    sb $t5, ($t2)
    addi $t2, $t2, 1
    addi $t1, $t1, 1

    move $a0, $t4
    j BIN_LOOP

BIN_PRINT:
    addi $t2, $t2, -1

P_BIN:
    bltz $t1, BIN_FIM

    lb $a0, ($t2)
    li $v0, 11
    syscall

    addi $t2, $t2, -1
    addi $t1, $t1, -1
    j P_BIN

BIN_FIM:
    jr $ra

BCD:
BCD_LOOP:
    beq $a0, $zero, BCD_FIM

    li $t1, 10
    div $a0, $t1
    mflo $t2
    mfhi $t3

    addi $t3, $t3, 48
    li $v0, 11
    move $a0, $t3
    syscall

    move $a0, $t2
    j BCD_LOOP

BCD_FIM:
    jr $ra

Q2:
    li $v0, 4
    la $a0, ask_dec
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    andi $t1, $t0, 0xFFFF

    li $v0, 4
    la $a0, msg_comp
    syscall

    li $t2, 15

CMP_LOOP:
    bltz $t2, MENU_PRINCIPAL

    srl $t3, $t1, $t2
    andi $t3, $t3, 1

    li $v0, 1
    move $a0, $t3
    syscall

    addi $t2, $t2, -1
    j CMP_LOOP

Q3:
    li $v0, 4
    la $a0, ask_real
    syscall

    li $v0, 6
    syscall
    mov.s $f0, $f0

    li $v0, 4
    la $a0, msg_float
    syscall

    mfc1 $t0, $f0

    li $v0, 4
    la $a0, msg_sinal
    syscall
    srl $t1, $t0, 31
    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, msg_exp
    syscall
    srl $t2, $t0, 23
    andi $t2, $t2, 0xFF
    li $v0, 1
    move $a0, $t2
    syscall

    li $v0, 4
    la $a0, msg_expv
    syscall
    addi $t3, $t2, -127
    li $v0, 1
    move $a0, $t3
    syscall

    li $v0, 4
    la $a0, msg_frac
    syscall
    andi $t4, $t0, 0x7FFFFF
    li $t5, 23

FRAC_LOOP:
    bltz $t5, PRINT_DOUBLE

    srl $t6, $t4, $t5
    andi $t6, $t6, 1

    li $v0, 1
    move $a0, $t6
    syscall

    addi $t5, $t5, -1
    j FRAC_LOOP

PRINT_DOUBLE:
    li $v0, 4
    la $a0, msg_double
    syscall

    cvt.d.s $f2, $f0
    mfc1 $t7, $f2
    mfc1 $t8, $f3

    li $t9, 63

D_LOOP:
    bltz $t9, MENU_PRINCIPAL

    blt $t9, 32, D_LOW

    srl $t6, $t8, $t9
    andi $t6, $t6, 1
    j D_PRINT

D_LOW:
    sub $t4, $t9, 32
    srl $t6, $t7, $t4
    andi $t6, $t6, 1

D_PRINT:
    li $v0, 1
    move $a0, $t6
    syscall

    addi $t9, $t9, -1
    j D_LOOP

SAIR:
    li $v0, 10
    syscall
