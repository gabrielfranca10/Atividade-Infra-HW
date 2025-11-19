# Autor: Gabriel França de Albuquerque Pernambuco
# Email: gfap@cesar.school
# Calculadora Programador Didática – Conversão entre bases, complemento de 2 e IEEE754
#
# Revisões:
# 13/11/2025 14:30 – Implementação completa da Q1 (Base 10 → Bin/Oct/Hex/BCD).
# 14/11/2025 11:45 – Implementação completa da Q2 (Complemento de 2 – 16 bits).
# 16/11/2025 17:10 – Implementação completa da Q3 (IEEE754 Float e Double, com sinal/expoente/fração).
# 19/11/2025 16:50 – Revisando erro na Q1 (Base 10 → Bin/Oct/Hex/BCD)

.data
menu: .asciiz "\n=== CALCULADORA PROGRAMADOR DIDATICA ===\n1) Q1 – Conversoes Base 10\n2) Q2 – Complemento de 2\n3) Q3 – IEEE754 Float/Double\n0) Sair\nEscolha: "

ask_dec: .asciiz "\nDigite um numero decimal: "
ask_real: .asciiz "\nDigite um numero real: "

msg_bin: .asciiz "\nBINARIO – Passo a passo:\n"
msg_oct: .asciiz "\nOCTAL – Passo a passo:\n"
msg_hex: .asciiz "\nHEXADECIMAL – Passo a passo:\n"
msg_bcd: .asciiz "\nBCD – 4 bits por digito:\n"

div1: .asciiz "N = "
div2: .asciiz " / base = "
div3: .asciiz "  resto = "
nl:   .asciiz "\n"

msg_comp: .asciiz "\nComplemento de 2 (16 bits):\n"
msg_neg: .asciiz "\nNumero negativo detectado:\nInvertendo bits...\nSomando 1...\nResultado final:\n"

msg_float: .asciiz "\nFLOAT IEEE754 (32 bits):\n"
msg_double: .asciiz "\nDOUBLE IEEE754 (64 bits):\n"

msg_sinal: .asciiz "Sinal: "
msg_exp:   .asciiz "Expoente: "
msg_expv:  .asciiz "Expoente sem vies: "
msg_frac:  .asciiz "Fracao: "

buffer: .space 128

.text
main:

MENU:
    li $v0,4
    la $a0,menu
    syscall
    li $v0,5
    syscall
    move $t0,$v0
    beq $t0,1,Q1
    beq $t0,2,Q2
    beq $t0,3,Q3
    beq $t0,0,EXIT
    j MENU

###########################################################
# Q1 – BINÁRIO, OCTAL, HEXA, BCD
###########################################################
Q1:
    li $v0,4
    la $a0,ask_dec
    syscall
    li $v0,5
    syscall
    move $s0,$v0

    li $v0,4
    la $a0,msg_bin
    syscall
    move $a0,$s0
    li $a1,2
    jal CONV

    li $v0,4
    la $a0,msg_oct
    syscall
    move $a0,$s0
    li $a1,8
    jal CONV

    li $v0,4
    la $a0,msg_hex
    syscall
    move $a0,$s0
    li $a1,16
    jal CONV

    li $v0,4
    la $a0,msg_bcd
    syscall
    move $a0,$s0
    jal BCD
    j MENU

###########################################################
# Q2 – COMPLEMENTO DE 2 (16 BITS)
###########################################################
Q2:
    li $v0,4
    la $a0,ask_dec
    syscall
    li $v0,5
    syscall
    move $t0,$v0

    bgez $t0,C2_POS

    li $v0,4
    la $a0,msg_neg
    syscall

    nor $t1,$t0,$zero
    addi $t1,$t1,1
    move $t0,$t1

C2_POS:
    li $v0,4
    la $a0,msg_comp
    syscall

    li $t2,15
C2_LOOP:
    bltz $t2, MENU
    srl $t3,$t0,$t2
    andi $t3,$t3,1
    li $v0,1
    move $a0,$t3
    syscall
    addi $t2,$t2,-1
    j C2_LOOP

###########################################################
# Q3 – IEEE754 FLOAT E DOUBLE
###########################################################
Q3:
    li $v0,4
    la $a0,ask_real
    syscall
    li $v0,6
    syscall
    mov.s $f0,$f0

    li $v0,4
    la $a0,msg_float
    syscall

    mfc1 $t0,$f0

    li $v0,4
    la $a0,msg_sinal
    syscall
    srl $t1,$t0,31
    li $v0,1
    move $a0,$t1
    syscall
    li $v0,4
    la $a0,nl
    syscall

    li $v0,4
    la $a0,msg_exp
    syscall
    srl $t2,$t0,23
    andi $t2,$t2,0xFF
    li $v0,1
    move $a0,$t2
    syscall
    li $v0,4
    la $a0,nl
    syscall

    li $v0,4
    la $a0,msg_expv
    syscall
    addi $t3,$t2,-127
    li $v0,1
    move $a0,$t3
    syscall
    li $v0,4
    la $a0,nl
    syscall

    li $v0,4
    la $a0,msg_frac
    syscall
    andi $t4,$t0,0x7FFFFF
    li $t5,22
Q3_FRAC:
    bltz $t5,Q3_DOUBLE
    srl $t6,$t4,$t5
    andi $t6,$t6,1
    li $v0,1
    move $a0,$t6
    syscall
    addi $t5,$t5,-1
    j Q3_FRAC

Q3_DOUBLE:
    li $v0,4
    la $a0,msg_double
    syscall

    cvt.d.s $f2,$f0
    mfc1 $t7,$f2
    mfc1 $t8,$f3
    li $t9,63

QD_LOOP:
    bltz $t9, MENU

    bge $t9,32,HI32
    sub $t1,$t9,32
    srl $t0,$t8,$t1
    andi $t0,$t0,1
    li $v0,1
    move $a0,$t0
    syscall
    addi $t9,$t9,-1
    j QD_LOOP

HI32:
    srl $t0,$t7,$t9
    andi $t0,$t0,1
    li $v0,1
    move $a0,$t0
    syscall
    addi $t9,$t9,-1
    j QD_LOOP

###########################################################

BCD:
    move $t0,$a0
BCD_LOOP:
    beq $t0,$zero, MENU
    li $t1,10
    div $t0,$t1
    mflo $t2
    mfhi $t3

    li $v0,1
    move $a0,$t3
    syscall
    li $v0,4
    la $a0,nl
    syscall

    move $t0,$t2
    j BCD_LOOP


CONV:
    move $s1,$a0
    la $t0,buffer
    li $t1,0

C_LOOP:
    beq $s1,$zero,PRINT

    li $v0,4
    la $a0,div1
    syscall

    li $v0,1
    move $a0,$s1
    syscall

    li $v0,4
    la $a0,div2
    syscall

    div $s1,$a1
    mflo $t2
    mfhi $t3

    li $v0,1
    move $a0,$t2
    syscall

    li $v0,4
    la $a0,div3
    syscall

    li $v0,1
    move $a0,$t3
    syscall

    li $v0,4
    la $a0,nl
    syscall

    move $t4,$t3
    blt $t4,10,DIG
    addi $t4,$t4,55
    sb $t4,0($t0)
    addi $t0,$t0,1
    addi $t1,$t1,1
    move $s1,$t2
    j C_LOOP

DIG:
    addi $t4,$t4,48
    sb $t4,0($t0)
    addi $t0,$t0,1
    addi $t1,$t1,1
    move $s1,$t2
    j C_LOOP

PRINT:
    add $t6,$zero,$t1
    addi $t0,$t0,-1
P_LOOP:
    bltz $t6, MENU
    lb $a0,0($t0)
    li $v0,11
    syscall
    addi $t0,$t0,-1
    addi $t6,$t6,-1
    j P_LOOP

EXIT:
    li $v0,10
    syscall

