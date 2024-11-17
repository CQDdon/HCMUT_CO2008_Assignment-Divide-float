# Chuong trinh: Doc du lieu tu file 
#----------------------------------- 
.include "macro.mac" 
# Data segment 
 .data 
# Cac dinh nghia bien 
dulieu1: .space 4 
dulieu2: .space 4 
tenfile: .asciiz "DULIEU.BIN" 
fdescr: .word 0 
# Cac cau nhac nhap/xuat du lieu 
str_dl1: .asciiz "Du lieu 1 = " 
str_dl2: .asciiz "Du lieu 2 = " 
str_loi: .asciiz "Mo file bi loi." 
#----------------------------------- 
# Code segment 
 .text 
#----------------------------------- 
# Chuong trinh chinh 
#----------------------------------- 
main: 
# Nhap (syscall) 
# Xu ly 
 # mo file doc 
 la $a0,tenfile 
 addi $a1,$zero,0 #a1=0 (read only)
 addi $v0,$zero,13 
 syscall 
 bgez $v0,tiep 
baoloi: #puts str_loi #mo file bi loi 
addi $v0,$zero,4 # puts str_loi 
la $a0, str_loi
syscall
 j Kthuc 
tiep: sw $v0,fdescr #luu file descriptor 
 # doc file 
 # 4 byte dau (kieu word) 
 lw $a0,fdescr 
 la $a1,dulieu1 
 addi $a2,$zero,4 
 addi $v0,$zero,14 
 syscall 
 # 4 byte sau (kieu float) 
 la $a1,dulieu2 
 addi $a2,$zero,4 
 addi $v0,$zero,14 
 syscall 
 # dong file 
 lw $a0,fdescr 
 addi $v0,$zero,16 
 syscall 
# Xuat ket qua (syscall) 
 # in du lieu 1 
 putf_p str_dl1,dulieu1 
 linefeed 
 # in du lieu 2 
 putf_p str_dl2,dulieu2 
# Ket thuc chuong trinh (syscall) 
Kthuc: addiu $v0,$zero,10 
 syscall 
#-----------------------------------
