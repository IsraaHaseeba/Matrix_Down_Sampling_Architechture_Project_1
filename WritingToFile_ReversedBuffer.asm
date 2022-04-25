.data
num: .float 475.522
ten: .float 10.0
fileName: .asciiz "C:\\Users\\HP\\Desktop\\4th_Year_2nd_semester\\Architecture\\projects\\project_1\\training\\d.txt"
buff: .space 50
buff2: .space 50
hundred: .float 1000.0
.text
.globl main
main:

	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,1           	# file flag = read (0)
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
    	

	
		l.s $f1, num
		cvt.w.s $f2,$f1
		mfc1 $t0, $f2  
		la $t2, buff
		
			loop:
			beqz $t0, loop3
			div $t0, $t0, 10
			mfhi $a1
			addiu $a1, $a1, 48
			sub $sp, $sp, 1 # push ra 
			sb $a1, 1($sp)
			b loop
			
			
			loop3:
			 
			lb $t7, 1($sp)
			add $sp, $sp, 1 # push ra
			beqz $t7,float
			sb $t7,($t2)
			addiu $t2,$t2,1
			b loop3
			
			 float:
			 
			
			cvt.w.s $f2,$f1
			mfc1 $t0, $f2 
			
			cvt.s.w $f3, $f2
			sub.s $f1, $f1, $f3
			
			l.s $f4, hundred
			mul.s $f1,$f1, $f4
			cvt.w.s $f2, $f1
			mfc1 $t0, $f2 
			move $a1, $zero
			
			li $t7, 46
			sb $t7, ($t2)
			addiu $t2, $t2, 1
			
			
			loop2: 
			beqz $t0, loop4
			div $t0, $t0, 10
			mfhi $a1
			addiu $a1, $a1, 48
			sub $sp, $sp, 1 # push ra 
			sb $a1, 1($sp)
			
			b loop2
			
			
			loop4:
			
			lb $t7, 1($sp)
			add $sp, $sp, 1 # push ra 
			beqz $t7,print
			sb $t7,($t2)
			addiu $t2,$t2,1
			b loop4
			print:
			la $a1, buff
			#jal reverse 
			#move $a1, $v0
			li   $v0, 15       # system call for write to file
			move $a0, $s0      # file descriptor  
			li $a2,50     
			syscall            # write to file
			la $a1, buff2
			#jal reverse 
			#move $a1, $v0
			li   $v0, 15       # system call for write to file
			move $a0, $s0      # file descriptor  
			li $a2,50     
			syscall  

		end:
    		li $v0,10
    		syscall
