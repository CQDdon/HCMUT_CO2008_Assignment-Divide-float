#===================================
# LUU Y KHI SU DUNG GITHUB
# Tao branch rieng de code, khong code tren branch main
# Truoc khi code, phai git pull origin main ve branch cua minh, de khong bi lech lich su commit
# Khong duoc push truc tiep len main, phai push ben branch cua ban than, sau do thong bao cho thanh vien con lai de kiem tra roi moi merge pull request
# Khuyen khich viet description cho pull request 
#===================================

#Chuong trinh: BTL de 4
# Data segment 
.data 
# Cac dinh nghia bien 
mau: .space 4 
tu: .space 4 
tenfile: .asciiz "FLOAT2.BIN" 
fdescr: .word 0 
div_err: .asciiz "Error: Cannot divide.\n" 
result: .word 0

# Cac cau nhac nhap/xuat du lieu 
str_loi: .asciiz "Mo file bi loi." 
div0: .asciiz "Error: Division by zero\n"
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
    # 4 byte dau 
    lw $a0,fdescr 
    la $a1,mau 
    addi $a2,$zero,4 
    addi $v0,$zero,14 
    syscall 
    # 4 byte sau 
    la $a1,tu 
    addi $a2,$zero,4 
    addi $v0,$zero,14 
    syscall 
    # dong file 
    lw $a0,fdescr 
    addi $v0,$zero,16 
    syscall 

    #===================================
    # Dau tien kiem tra xem lieu tu so co bang 0 hay khong
    lw $a0, tu
    bnez $a0, continue
    la $a0, div0 
    addi $v0, $zero, 4 
    syscall 
    jal Kthuc
continue:
    # Dua du lieu tu dang nhi phan ve IEEE 754
    # Tien hanh lay cac bits Sign, Exponent va Mantissa cua tu so
    jal extractSign
    move $s2, $v0
    jal extractExponent
    move $s4, $v0
    jal extractMantissa
    move $s6, $v0
    # Sign, Exponent va Mantissa cua mau so duoc luu vao cac thanh ghi lan luot la $2, $s4, $s6
    
    # Lam tuong tu voi mau so    
    lw $a0, mau 
    bnez $a0, continue2
    move $a0, $zero 
    addi $v0, $zero, 2
    syscall 
    jal Kthuc
continue2:
    jal extractSign
    move $s1, $v0
    jal extractExponent
   	move $s3, $v0
    jal extractMantissa
    move $s5, $v0
    # Sign, Exponent va Mantissa cua mau so duoc luu vao cac thanh ghi lan luot la $1, $s3, $s5
    
    xor	$s0, $s1, $s2 # Sign mau xor Sign tu ta duoc bit Sign cua ket qua la bit MSB
    
	move $a0, $s5
	move $a1, $s6
	# Dua 2 Mantissa vao tham so $a0 va $a1 de tien hanh chia Mantissa
	jal DivisionAlgorithm
	# $v0 la ket qua cua phep chia, $v1 la so Exponent can bu 
	andi $v0, $v0, 0x007fffff # xoa bit an cua Mantissa
	
	# Tinh toan Exponent cho ket qua
	sub $s3, $s3, $s4 # Dau tien, lay Exp mau - Exp tu
    sub $s3, $s3, $v1 # Tru them phan bu    
    addi $s3, $s3, 127 # Cong voi 127 de ra Exponent hoan chinh 
	sll $s3, $s3, 23 # Dich trai Exponent 23 bit roi day vao $s0 
	or $s0, $s0, $s3 
		
	# Them Mantissa vao va in ra ket qua
	or $s0, $s0, $v0
	sw $s0, result
	
	lwc1	$f12,result
  	addi	$v0,$zero,2
  	syscall
	
    #===================================

#ket thuc chuong trinh (syscall)
Kthuc:	
    addi $v0,$zero,10
	syscall
# -------------------------------	
# Cac chuong trinh khac

# Lay bit Sign cua float
# Input  : $a0 -> 32-bit float
# Output: Output : $v0 -> Sign (1 bit)
extractSign:
    andi $v0, $a0, 0x80000000 # Giu lai bit Sign (MSB)
    jr $ra

# Lay 8 bit Exponent cua float
# Input  : $a0 -> 32-bit float
# Output: Output : $v0 -> Exponent (8 bits)
extractExponent:
	srl $v0, $a0, 23  
    andi $v0, $v0, 0xFF
    jr $ra
   
# Lay 23 bit Mantissa cua float
# Input  : $a0 -> 32-bit float
# Output: Output : $v0 -> Mantissa (8 bits)
extractMantissa:
    li $t0, 0x007FFFFF 
    and $v0, $a0, $t0
    ori  $v0, 0x800000
    jr $ra

# Ham chia 2 so nhi phan
DivisionAlgorithm:
	# Call stack de luu du lieu
    addi $sp, $sp, -12       
    # Luu $ra de nho dia chi tra ve; trong ham co su dung $s0 va $s1 nen luu lai de su dung lai sau khi goi ham
    sw $s0, 0($sp)          
    sw $ra, 4($sp)          
    sw $s1, 8($sp)       
	
	# Day gia tri cua Mantissa mau vao $t0 (Dividend), Mantissa tu vao $t1 (Divisor)
    move $t0, $a0    
    move $t1, $a1 

    add $s0, $0, $0 # Khoi tao quotient ($s0) = 0
    add $v1, $0, $0 # $v1 de tinh phan bu cho Exponent, mac dinh = 0
    li $t8, 0 # Bien dem $t8

	
loop:   
    bgtu $t8, 23, check # Kiem tra xem da du 23 lan lap chua
    addi $t8, $t8, 1 # Tang bien dem them 1
    sub $t0, $t0, $t1 # Dividend -= Divisor
    sll $s0, $s0, 1 # Dich trai de xet bit tiep theo cua Quotient
    slt $t2, $t0, $0 # Neu Dividend duong thi Quotient++, nguoc lai Quotient khong doi, tien hanh xet bit tiep theo
    bne $t2, $0, else 
    addi $s0, $s0, 1
    j out

else:   
    add $t0, $t0, $t1 # Khoi phuc gia tri cho Dividend

out:    
    sll $t0, $t0, 1 # Dich trai Dividend de tiep tuc chia
    j loop 


check:  
    move $a0, $s0 
    jal Normalization # Chuan hoa Quotient 
    j return # Giai phong stack, ket thuc phep chia

return: 
    lw $ra, 4($sp)          
    lw $s0, 0($sp)      
    lw $s1, 8($sp)     
    addi $sp, $sp, 8    
    jr $ra   
	
	
Normalization:
    lui $t0, 0x0080 # Dung $t0 de kiem tra bit thu 24 cua quotient (bit an phai luon bang 1)
    addi $t2, $0, 0 # Bien dem moi de nho so lan dich Quotient

loop2:  
	bgtu $t2, 23, error # Neu kiem tra het 24 bit ma van khong tim duoc bit 1 thi bao loi
    and $t1, $a0, $t0 # Kiem tra bit thu 24 cua Quotient co phai 1 khong
    bne $t1, $0, else2 # Neu bang, thoat khoi vong lap
    addi $t2, $t2, 1 # Tang bien dem
    sll $a0, $a0, 1 # Dich trai Quotient
    j loop2

else2:  
    move $v0, $a0 # Lýu mantissa da chuan hoa $v0
    move $v1, $t2 # Luu so lan dich vi tri vao $v1
    jr $ra   


error:
	addi $v0, $zero, 4
	la $a0, div_err # Cannot divide
	syscall
	jal Kthuc
	
	
# -------------------------------
