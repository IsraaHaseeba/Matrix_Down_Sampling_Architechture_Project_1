#STRINGS
.data
fileName: .asciiz "C:\\Users\\sosos\\Desktop\\Arc\\T1.txt"
numBuff: .word 0:50
precBuff: .word 0:50
errorMes: .asciiz "\n\nIncorrect input matrix!"
matrixAddress: .word 0
zero: .double 0.0
divisor: .double 0.1
floatFlag: .word 0




	.text
	.globl main
	
main:
	
	# Initializations:
	li $t9, 0 # Previous row
	li $t8,0 #Size of column
	li $t7,0 #Size of row
	li $v0, 0
	sw $v0, floatFlag
	
	
	# For final matrix
	li $a0, 10240 # $a0 = number of bytes to allocate
	li $v0, 9 # system call 9
	syscall # allocate 100 bytes on the heap
	move $t4, $v0 # $t0 = address of allocated block
	sw $t4,matrixAddress
	
	
	# For buff from file
	li $a0, 10240 # $a0 = number of bytes to allocate
	li $v0, 9 # system call 9
	syscall # allocate 100 bytes on the heap
	move $t1, $v0 # $t0 = address of allocated block

	

	
	
	#HOW TO READ INTO A FILE
	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,0           	# file flag = read (0)
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
	
	#read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	move $a1,$t1  	# The buffer that holds the string of the WHOLE file
	la $a2,10240		# hardcoded buffer length
	syscall

	
	# print whats in the file
	li $v0, 4		# read_string syscall code = 4
	move $a0,$t1
	syscall
	
	# Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	
    	# Parse Numbers into main matrix
    	# 1. file -> null
	# 2. loop while != null:
	# 3. 	buff -> num
	# 4. 	cmp by ','
	# 5. 	if ',' : (BRANCH to function) convert to int: num: (LOOP) var int=0,   +num[0], int * 10 + num[1] ...
		# add to main matrix
	# 6.  	if 'a' newl: size++ :
	# 7. 	if not : continue adding to buff
	

	la $a1, numBuff
	li $a0, 0 # to know the count of digits of the number
	la $a3,precBuff #for float converting
	li $a2,0 #for floating point
	
	
	iterateBuff:
		lb $t0, 0($t1) # load byte: $t0 = source[i]
		beq $t0, 0, endIteration
		bne $t0, 0x2c, checkIsNewLine 	# compute the integer from digits
		jal convertToInt
		move $a1,$v1
		b next
		checkIsNewLine:
		beq $t0,0x2E,operateFloating
		bne $t0, 0x0d, checkIf0x0a
		
		
		jal convertToInt
		move $a1,$v1
		
		beqz $t9,firstIteration
		bne $t9,$t7,Error
		move $t9,$t7
		li $t7,0
		b next
		firstIteration:
		move $t9,$t7
		li $t7,0
		b next
		checkIf0x0a:
		beq $t0, 0x0a, next
		bgt $t0, 0x39, Error
		blt $t0, 0x30, Error
		lw $v0, floatFlag
		beq $v0, 1, addFloat
		sw $t0, 0($a1) # store byte: target[i]= $t0
		addiu $a0, $a0, 1
		addiu $a1, $a1, 4
		b next
		operateFloating:
		li $v0, 1
		sw $v0, floatFlag
		b next
		addFloat:
		sw $t0,0($a3)
		addiu $a3, $a3,4
		addiu $a2, $a2,1
		
		
		
		next:
		addiu $t1, $t1, 1
		b iterateBuff
		
	endIteration:
		la $t0, numBuff
		beq $a1, $t0, endd #if file is empty
		jal convertToInt
		bne $t9,$t7,Error
		endd:
		#check if it is square
		
		
		lw $t0, matrixAddress
		sub $t4, $t4, $t0
		div $t4, $t7      # i mod 4
		li $t7,8
		mflo $t5 
		div $t5, $t7
		mflo $t5          # temp for mod
		bne  $t5,$t9,Error
		move $t8, $t9

		move $a0,$t8
		jal mod_fcn
		b continue
		
	
	Error:
		la $a0,errorMes
		li $v0,4
		syscall 
		b end
	
	continue:
	
	
	
	
	end:
    		li $v0,10
    		syscall
    	
    	
  #-----------------------------------------------
  	
	# function to produce integr	
	convertToInt:
	
		la $a1, numBuff
		li $v0, 0
		li $t0, 10
		lw $t3, 0($a1) # load $t1 = str[i] 
		addiu $v0, $t3, -48 # Convert character to digit 
		addiu $a1, $a1, 4
		addiu $a0, $a0, -1
		beq $a0, 0, secondStep
		
		iterateNumber:
			lw $t3, 0($a1) # load $t1 = str[i] 
			addiu $t3, $t3, -48 # Convert character to digit 
			mul $v0, $v0, $t0 # $v0 = sum * 10 
			addu $v0, $v0, $t3 # $v0 = sum * 10 + digit 
			addiu $a1, $a1, 4
			addiu $a0, $a0, -1
			beq $a0, 0, secondStep
			b iterateNumber # loop back 
			
#------------------------------------------------------------------
		secondStep:
		beqz $a2,  done	
		la $a3, precBuff
		l.d  $f0,zero
		l.d $f2, divisor
		lw $t3, 0($a3) # load $t1 = str[i] 
		addiu $t3, $t3, -48 # Convert character to digit
		mtc1 $t3,$f4
		cvt.d.w $f16,$f4
		mul.d $f0, $f16, $f2 # $v0 = sum * 10
		addiu $a3, $a3, 4
		addiu $a2, $a2, -1
		beq $a2, 0, done
		
		iterateNumber2:
			
			lw $t3, 0($a3) # load $t1 = str[i] 
			addiu $t3, $t3, -48 # Convert character to digit
			mtc1 $t3,$f4 
			cvt.d.w $f16,$f4
			mul.d $f0, $f16, $f2 # $v0 = sum * 10 
			add.d  $f0, $f0, $f4 # $v0 = sum * 10 + digit 
			addiu $a3, $a3, 4
			addiu $a2, $a2, -1
			beq $a2, 0, done
			b iterateNumber2 # loop back 
			
			
		done: 
			mtc1 $v0,$f6
			cvt.d.w $f16,$f6
			add.d $f6,$f16,$f0
			li $v0, 0
			sw $v0, floatFlag
			sdc1 $f6, 0($t4) # store byte: target[i]= $t0
			addiu $t4, $t4, 8
			la $v1,numBuff 
			la $a3,precBuff
			addiu $t7,$t7,1
			
			jr $ra # return to caller	
		
		# function to increment the size of the matrix
		incSizeOfMatrix:
			
			addiu $t8, $t8, 1
			
			jr $ra # return to caller
			
		# Mode function
		mod_fcn: 
			beq $t8, 2, Matrix2x2
			li  $t6, 4
			b Matrix4x4
			Matrix2x2:
			li  $t6, 2
			Matrix4x4:
			div $a0, $t6      # i mod 4
			mfhi $t5          # temp for mod
			move $v0, $t5     # retrun moded num
			bne  $v0,0,Error
			jr  $ra
