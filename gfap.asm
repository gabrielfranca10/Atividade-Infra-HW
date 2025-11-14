# Autor: Gabriel França de Albuquerque Pernambuco
# Email: gfap@cesar.school
# Calcuadora Programador Didática
# Revisão: 14/11/2025 11:45
 
.data
menu1: .asciiz "\n[Q1] Conversões a partir de base 10:\n1) Binário\n2) Octal\n3) Hexadecimal\n4) BCD\nEscolha: "
ask:   .asciiz "\nDigite um número decimal: "
divfmt:  .asciiz "\nN = "
divfmt2: .asciiz "  -> N/base = "
divfmt3: .asciiz "  resto = "
resbin: .asciiz "\nResultado: "

newline: .asciiz "\n"
buffer: .space 64

.text
main:
    li $v0, 4
    la $a0, menu1
    syscall

    li $v0, 5
    syscall
    move $t0, $v0       

    li $v0, 4
    la $a0, ask
    syscall

    li $v0, 5
    syscall
    move $a0, $v0     

    beq $t0, 1, binario
    beq $t0, 2, octal
    beq $t0, 3, hexa
    beq $t0, 4, bcd
    j fim

binario:
    li $t1, 0       
    la $t2, buffer 

bin_loop:
    beq $a0, $zero, mostra_bin

    li $v0, 4
    la $a0, divfmt
    syscall

    move $a0, $v0
    syscall

    li $t3, 2
    div $a0, $t3
    mflo $t4          
    mfhi $t5         

    # exibir passo
    li $v0, 1
    move $a0, $a0
    syscall

    li $v0, 4
    la $a0, divfmt2
    syscall

    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 4
    la $a0, divfmt3
    syscall

    li $v0, 1
    move $a0, $t5
    syscall

    # salva no buffer (invertido)
    addi $t5, $t5, 48
    sb $t5, ($t2)
    addi $t2, $t2, 1
    addi $t1, $t1, 1

    move $a0, $t4
    j bin_loop

mostra_bin:
    li $v0, 4
    la $a0, resbin
    syscall

    addi $t2, $t2, -1

bin_print:
    bltz $t1, fim
    lb $a0, ($t2)
    li $v0, 11
    syscall

    addi $t2, $t2, -1
    addi $t1, $t1, -1
    j bin_print

octal:
    li $v0, 34
    move $a0, $a0
    syscall
    j fim

hexa:
    li $v0, 34
    move $a0, $a0
    syscall
    j fim

bcd:
    li $t0, 0
    li $v0, 4
    la $a0, resbin
    syscall

bcd_loop:
    beq $a0, $zero, fim

    li $t1, 10
    div $a0, $t1
    mflo $t2
    mfhi $t3     # dígito

    addi $t3, $t3, 48
    li $v0, 11
    move $a0, $t3
    syscall

    move $a0, $t2
    j bcd_loop

fim:
    li $v0, 10
    syscall

# Complemento de 2 — 16 bits

.data
ask: .asciiz "\nDigite um valor decimal (signed): "
msgbin: .asciiz "\nBinário puro: "
msgcomp: .asciiz "\nComplemento de 2 (16 bits): "
newline: .asciiz "\n"

.text
main:
    li $v0, 4
    la $a0, ask
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    # pega 16 bits
    andi $t1, $t0, 0xFFFF

    li $v0, 4
    la $a0, msgcomp
    syscall

    li $t2, 15

loop_bits:
    bltz $t2, fim

    srl $t3, $t1, $t2
    andi $t3, $t3, 1

    li $v0, 1
    move $a0, $t3
    syscall

    addi $t2, $t2, -1
    j loop_bits

fim:
    li $v0, 10
    syscall
