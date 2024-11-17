# Chuong trinh: Tao file du lieu 
#----------------------------------- 
 .include "macro.mac" 
# Data segment 
 .data 
# Cac dinh nghia bien 
dulieu1: .word 0x41D00000
dulieu2: .word 0xC0A00000 
tenfile: .asciiz "DULIEU.BIN" 
fdescr: .word 0 
# Cac cau nhac nhap/xuat du lieu 
str_tc: .asciiz "Thanh cong." 
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
 la $a0,tenfile 
 addi $a1,$zero,1 # open with a1=1 (write-only) 
 addi $v0,$zero,13 
 syscall 
 bgez $v0,tiep 
 puts str_loi # mo file khong duoc 
 # ghi file 
tiep: sw $v0,fdescr #luu file descriptor 
 # 4 byte dau (du lieu kieu word) 
 lw $a0,fdescr # file descriptor 
 la $a1,dulieu1 
 addi $a2,$zero,4 #ghi 4 byte so nguyen
 addi $v0,$zero,15 
 syscall 
 # 4 byte sau (du lieu kieu float) 
 la $a1,dulieu2 
 addi $a2,$zero,4 #ghi 4 byte so thuc 
 addi $v0,$zero,15 
 syscall 
 # dong file 
 lw $a0,fdescr 
 addi $v0,$zero,16 
 syscall 
# Xuat ket qua (syscall) 
 puts str_tc 
# Ket thuc chuong trinh (syscall) 
Kthuc: addi $v0,$zero,10 
 syscall 
#----------------------------------- 
