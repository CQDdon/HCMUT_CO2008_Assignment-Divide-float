#===================================
# LUU Y KHI SU DUNG GITHUB
# Tao branch rieng de code, khong code tren branch main
# Truoc khi code, phai git pull origin main ve branch cua minh, de khong bi lech lich su commit
# Khong duoc push truc tiep len main, phai push ben branch cua ban than, sau do thong bao cho thanh vien con lai de kiem tra roi moi merge pull request
# Khuyen khich viet description cho pull request 
#===================================

#Chuong trinh: BTL de 4
.include "macro.mac" 
# Data segment 
.data 
# Cac dinh nghia bien 
mau: .space 4 
tu: .space 4 
tenfile: .asciiz "FLOAT2.BIN" 
fdescr: .word 0 
# Cac cau nhac nhap/xuat du lieu 
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
    # Dua du lieu tu dang nhi phan ve IEEE 754
    # Truoc tien, ta lay sign bang cach dich phai 31 bit
    ##
    # Sau do lay phan exponent bang cach dich trai 1 bit de loai bit sign, va dich phai 23 bit de lay 8 bit exponent
    ##
    # Cuoi cung lay phan mantisa thong qua phep AND voi 0x0007FFFF
    ##
    # Ket thuc chuan hoa nhi phan
    #===================================
    # Thuc hien phep chia
    # Quy uoc: (-1)^Sign*1.Mantisa*2^(Exponent-127)
    # sign = sign mau XOR sign tu
    ##
    # exponent = Emau - Etu (exponent co the be hon 127)
    ##
    # 1.mantisa = 1.Mmau / 1.Mtu; Dieu kien: 1 <= 1.mantisa < 2
    # neu 1.mantisa < 1 thi shift left den khi thoa man, dong thoi exponent +1 tuong ung
    # neu 1.mantisa >= 2 thi shift right den khi thoa man, dong thoi exponent -1 tuong ung
    ##
    # Ket thuc phep chia
    #===================================

#ket thuc chuong trinh (syscall)
Kthuc:	
    addi $v0,$zero,10
	syscall
# -------------------------------	
# Cac chuong trinh khac
# -------------------------------
