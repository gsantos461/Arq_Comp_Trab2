# ordenacoes.asm
# Executa Bubble e Insertion sobre O MESMO vetor (n=5,10,20)


        .data
prompt_original:  .asciiz "\n--- Vetor original ---\n"
prompt_after:     .asciiz "\nResultado:\n"
nl:               .asciiz "\n"
sep:              .asciiz "\n-------------------------------\n"

str_bubble:       .asciiz "Bubble Sort - comps: "
str_swaps:        .asciiz " , swaps: "
str_insertion:    .asciiz "Insertion Sort - comps: "
str_in_swaps:     .asciiz " , moves: "

label_bubble:     .asciiz "Bubble"
label_insertion:  .asciiz "Insertion"

# --- vetores originais ---
vec5_orig:    .word 15, 3, 9, 1, 7
n5:           .word 5
vec5_bub:     .space 20
vec5_ins:     .space 20

vec10_orig:   .word 12, 5, 18, 1, 3, 9, 2, 20, 11, 4
n10:          .word 10
vec10_bub:    .space 40
vec10_ins:    .space 40

vec20_orig:   .word 20,19,1,4,15,7,3,14,9,2,10,16,13,12,11,6,5,8,17,18
n20:          .word 20
vec20_bub:    .space 80
vec20_ins:    .space 80

# contadores globais (cada rotina também zera internamente)
bubble_comps:     .word 0
bubble_swaps:     .word 0
insertion_comps:  .word 0
insertion_moves:  .word 0

        .text
        # bootstrap
        j main
        nop

        .globl main

# -------------------------
# copy_array: copies n words from src($a0) to dst($a1), n in $a2
# Preserves $ra, $s0
# -------------------------
copy_array:
        addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $s0, 0($sp)

        move $s0, $a2      # counter in s0

copy_loop:
        beq  $s0, $zero, copy_done
        lw   $t0, 0($a0)
        sw   $t0, 0($a1)
        addi $a0, $a0, 4
        addi $a1, $a1, 4
        addi $s0, $s0, -1
        j    copy_loop

copy_done:
        lw   $s0, 0($sp)
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra

# -------------------------
# print_array: prints n ints from base $a0, n in $a1
# Preserves $ra, $s0
# -------------------------
print_array:
        addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $s0, 0($sp)

        move $s0, $a0
        move $t0, $a1
        li   $t1, 0

print_array_loop:
        beq  $t1, $t0, print_array_end
        sll  $t2, $t1, 2
        add  $t3, $s0, $t2
        lw   $a0, 0($t3)
        li   $v0, 1
        syscall

        # print a space
        li   $a0, 32
        li   $v0, 11
        syscall

        addi $t1, $t1, 1
        j    print_array_loop

print_array_end:
        # newline after array
        la   $a0, nl
        li   $v0, 4
        syscall

        lw   $s0, 0($sp)
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra

# -------------------------
# bubble_sort (in-place)
# args: $a0 = base, $a1 = n
# zera bubble_comps e bubble_swaps internamente
# -------------------------
bubble_sort:
        addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $s0, 0($sp)

        move $s0, $a0
        move $t0, $a1

        # zero counters
        la   $t6, bubble_comps
        sw   $zero, 0($t6)
        la   $t6, bubble_swaps
        sw   $zero, 0($t6)

        li   $t1, 1
        ble  $t0, $t1, b_end

        addi $t2, $t0, -1
        li   $t3, 0

b_outer:
        beq  $t3, $t2, b_outer_done
        sub  $t4, $t2, $t3
        li   $t5, 0

b_inner:
        beq  $t5, $t4, b_inner_done

        sll  $a2, $t5, 2
        add  $a2, $s0, $a2
        lw   $t7, 0($a2)

        addi $a3, $a2, 4
        lw   $t8, 0($a3)

        la   $t9, bubble_comps
        lw   $t1, 0($t9)
        addi $t1, $t1, 1
        sw   $t1, 0($t9)

        ble  $t7, $t8, b_no_swap
        sw   $t8, 0($a2)
        sw   $t7, 0($a3)

        la   $t9, bubble_swaps
        lw   $t1, 0($t9)
        addi $t1, $t1, 1
        sw   $t1, 0($t9)

b_no_swap:
        addi $t5, $t5, 1
        j    b_inner

b_inner_done:
        addi $t3, $t3, 1
        j    b_outer

b_outer_done:
b_end:
        lw   $s0, 0($sp)
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra

# -------------------------
# insertion_sort (in-place)
# args: $a0 = base, $a1 = n
# zera insertion_comps e insertion_moves internamente
# -------------------------
insertion_sort:
        addi $sp, $sp, -8
        sw   $ra, 4($sp)
        sw   $s0, 0($sp)

        move $s0, $a0
        move $t0, $a1

        # zero counters
        la   $t6, insertion_comps
        sw   $zero, 0($t6)
        la   $t6, insertion_moves
        sw   $zero, 0($t6)

        li   $t1, 1
        ble  $t0, $t1, i_end

        li   $t2, 1

i_outer:
        beq  $t2, $t0, i_done

        sll  $t3, $t2, 2
        add  $t3, $s0, $t3
        lw   $t4, 0($t3)   # key

        addi $t5, $t2, -1

i_inner:
        blt  $t5, $zero, i_place

        sll  $t6, $t5, 2
        add  $t6, $s0, $t6
        lw   $t7, 0($t6)

        la   $t8, insertion_comps
        lw   $t9, 0($t8)
        addi $t9, $t9, 1
        sw   $t9, 0($t8)

        ble  $t7, $t4, i_place
        addi $t6, $t6, 4
        sw   $t7, 0($t6)

        la   $t8, insertion_moves
        lw   $t9, 0($t8)
        addi $t9, $t9, 1
        sw   $t9, 0($t8)

        addi $t5, $t5, -1
        j    i_inner

i_place:
        addi $t5, $t5, 1
        sll  $t6, $t5, 2
        add  $t6, $s0, $t6
        sw   $t4, 0($t6)

        la   $t8, insertion_moves
        lw   $t9, 0($t8)
        addi $t9, $t9, 1
        sw   $t9, 0($t8)

        addi $t2, $t2, 1
        j    i_outer

i_done:
i_end:
        lw   $s0, 0($sp)
        lw   $ra, 4($sp)
        addi $sp, $sp, 8
        jr   $ra

# -------------------------
# helper print_str (expects $a0 = addr)
# -------------------------
print_str:
        li   $v0, 4
        syscall
        jr   $ra

# -------------------------
# main: para cada n: copia orig->bub e orig->ins; zera contadores; roda ambos; imprime resultados
# -------------------------
main:
        # ---- TEST n=5 ----
        la   $a0, prompt_original
        li   $v0, 4
        syscall

        la   $a0, vec5_orig
        lw   $a1, n5
        jal  print_array

        # copia original -> cópias
        la   $a0, vec5_orig
        la   $a1, vec5_bub
        lw   $a2, n5
        jal  copy_array
        la   $a0, vec5_orig
        la   $a1, vec5_ins
        lw   $a2, n5
        jal  copy_array

        # ---- Bubble (n=5) ----
        # zero counters (extra segurança)
        la   $t0, bubble_comps
        sw   $zero, 0($t0)
        la   $t0, bubble_swaps
        sw   $zero, 0($t0)

        la   $a0, vec5_bub
        lw   $a1, n5
        jal  bubble_sort

        # print Bubble result
        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_bubble
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec5_bub
        lw   $a1, n5
        jal  print_array

        # print bubble counters
        la   $a0, str_bubble
        li   $v0, 4
        syscall
        la   $t0, bubble_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_swaps
        li   $v0, 4
        syscall
        la   $t0, bubble_swaps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        la   $a0, nl
        li   $v0, 4
        syscall

        # ---- Insertion (n=5) ----
        la   $t0, insertion_comps
        sw   $zero, 0($t0)
        la   $t0, insertion_moves
        sw   $zero, 0($t0)

        la   $a0, vec5_ins
        lw   $a1, n5
        jal  insertion_sort

        # print Insertion result
        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_insertion
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec5_ins
        lw   $a1, n5
        jal  print_array

        # print insertion counters
        la   $a0, str_insertion
        li   $v0, 4
        syscall
        la   $t0, insertion_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_in_swaps
        li   $v0, 4
        syscall
        la   $t0, insertion_moves
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        # separator
        la   $a0, sep
        li   $v0, 4
        syscall

        # ---- TEST n=10 ----
        la   $a0, prompt_original
        li   $v0, 4
        syscall

        la   $a0, vec10_orig
        lw   $a1, n10
        jal  print_array

        # copia
        la   $a0, vec10_orig
        la   $a1, vec10_bub
        lw   $a2, n10
        jal  copy_array
        la   $a0, vec10_orig
        la   $a1, vec10_ins
        lw   $a2, n10
        jal  copy_array

        # Bubble (n=10)
        la   $t0, bubble_comps
        sw   $zero, 0($t0)
        la   $t0, bubble_swaps
        sw   $zero, 0($t0)

        la   $a0, vec10_bub
        lw   $a1, n10
        jal  bubble_sort

        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_bubble
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec10_bub
        lw   $a1, n10
        jal  print_array

        la   $a0, str_bubble
        li   $v0, 4
        syscall
        la   $t0, bubble_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_swaps
        li   $v0, 4
        syscall
        la   $t0, bubble_swaps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        la   $a0, nl
        li   $v0, 4
        syscall

        # Insertion (n=10)
        la   $t0, insertion_comps
        sw   $zero, 0($t0)
        la   $t0, insertion_moves
        sw   $zero, 0($t0)

        la   $a0, vec10_ins
        lw   $a1, n10
        jal  insertion_sort

        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_insertion
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec10_ins
        lw   $a1, n10
        jal  print_array

        la   $a0, str_insertion
        li   $v0, 4
        syscall
        la   $t0, insertion_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_in_swaps
        li   $v0, 4
        syscall
        la   $t0, insertion_moves
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        la   $a0, sep
        li   $v0, 4
        syscall

        # ---- TEST n=20 ----
        la   $a0, prompt_original
        li   $v0, 4
        syscall

        la   $a0, vec20_orig
        lw   $a1, n20
        jal  print_array

        # copia
        la   $a0, vec20_orig
        la   $a1, vec20_bub
        lw   $a2, n20
        jal  copy_array
        la   $a0, vec20_orig
        la   $a1, vec20_ins
        lw   $a2, n20
        jal  copy_array

        # Bubble (n=20)
        la   $t0, bubble_comps
        sw   $zero, 0($t0)
        la   $t0, bubble_swaps
        sw   $zero, 0($t0)

        la   $a0, vec20_bub
        lw   $a1, n20
        jal  bubble_sort

        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_bubble
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec20_bub
        lw   $a1, n20
        jal  print_array

        la   $a0, str_bubble
        li   $v0, 4
        syscall
        la   $t0, bubble_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_swaps
        li   $v0, 4
        syscall
        la   $t0, bubble_swaps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        la   $a0, nl
        li   $v0, 4
        syscall

        # Insertion (n=20)
        la   $t0, insertion_comps
        sw   $zero, 0($t0)
        la   $t0, insertion_moves
        sw   $zero, 0($t0)

        la   $a0, vec20_ins
        lw   $a1, n20
        jal  insertion_sort

        la   $a0, prompt_after
        li   $v0, 4
        syscall
        la   $a0, label_insertion
        li   $v0, 4
        syscall
        la   $a0, nl
        li   $v0, 4
        syscall
        la   $a0, vec20_ins
        lw   $a1, n20
        jal  print_array

        la   $a0, str_insertion
        li   $v0, 4
        syscall
        la   $t0, insertion_comps
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall
        la   $a0, str_in_swaps
        li   $v0, 4
        syscall
        la   $t0, insertion_moves
        lw   $a0, 0($t0)
        li   $v0, 1
        syscall

        la   $a0, sep
        li   $v0, 4
        syscall

        # exit
        li   $v0, 10
        syscall
