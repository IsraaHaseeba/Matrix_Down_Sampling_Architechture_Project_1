#STRINGS
.data
fileName: .asciiz "C:\\Users\\HP\\Desktop\\4th_Year_2nd_semester\\Architecture\\projects\\project_1\\training\\T1.txt"
numBuff: .word 0:50
precBuff: .word 0:50
errorMes: .asciiz "\n\nIncorrect input matrix!"
levelError: .asciiz "\n\nLarge level!"
levelMes: .asciiz "\n\n Please enter the number of level: \n\n"
operationMes: .asciiz "\n\n If you want down sampling by meadian please enter '1' and '2' if mean  \n\n "
newLevelmsg: .asciiz "\n\n --- New Level ---"
matrixAddress: .word 0
dimention: .word 0
zero: .float 0.0
half: .float 0.5
divisor: .float 0.1
quarter: .float 0.25
floatFlag: .word 0
evenWindow: .float 1.5, 0.5, 0.5, 1.5
oddWindow: .float 0.5, 1.5, 1.5, 0.5
levelNum: .word 0
algo: .word 0
newLine: .asciiz "\n\n"
newL: .byte 10
space: .asciiz " "
sortedArr: .float 0:4
ten: .float 10.0
outFile: .asciiz "C:\\Users\\HP\\Desktop\\4th_Year_2nd_semester\\Architecture\\projects\\project_1\\training\\d.txt"
buff: .space 10
buff2: .space 10
buff3: .space 10
hundred: .float 100.0
num: .float 0
output: .float 0:104200




	.text
	.globl main
	
main:
		la $a0,levelMes
		li $v0,4
		syscall 
	
		li $v0,5 #Read the num of level
		syscall 
		sw $v0,levelNum
		
		la $a0,newLine
		li $v0,4
		syscall
		
		la $a0,operationMes
		li $v0,4
		syscall 
	
		li $v0,5 #Read the operation
		syscall 
		sw $v0,algo
		
		
		
		


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
	move $a1,$t1       	# The buffer that holds the string of the WHOLE file
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
		li $t7,4
		mflo $t5 
		div $t5, $t7
		mflo $t5          # temp for mod
		bne  $t5,$t9,Error
		move $t8, $t9
		sw $t8, dimention

		move $a0,$t8
		jal mod_fcn
		b continue
		
	
	Error:
		la $a0,errorMes
		li $v0,4
		syscall 
		b end
	
	continue:
	lw $t6,dimention
	lw $a0,levelNum
	
	jal power
	move $t4,$v0
	bgt $t4,$t6,levelError1
	# Window method.
	lw $t1,algo
	beq $t1,1,median
	jal windowMethod
	b end
		
	median:
	jal medianMethod
	b end	
		
	levelError1:
	la $a0,levelError
	li $v0,4
	syscall	

		
				
	
	
	
	
	
	
	
	
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
		l.s  $f0,zero
		l.s $f2, divisor
		lw $t3, 0($a3) # load $t1 = str[i] 
		addiu $t3, $t3, -48 # Convert character to digit
		mtc1 $t3,$f4
		cvt.s.w $f16,$f4
		mul.s $f0, $f16, $f2 # $v0 = sum * 10
		addiu $a3, $a3, 4
		addiu $a2, $a2, -1
		beq $a2, 0, done
		
		iterateNumber2:
			
			lw $t3, 0($a3) # load $t1 = str[i] 
			addiu $t3, $t3, -48 # Convert character to digit
			mtc1 $t3,$f4 
			cvt.s.w $f16,$f4
			mul.s $f0, $f16, $f2 # $v0 = sum * 10 
			add.s  $f0, $f0, $f4 # $v0 = sum * 10 + digit 
			addiu $a3, $a3, 4
			addiu $a2, $a2, -1
			beq $a2, 0, done
			b iterateNumber2 # loop back 
			
			
		done: 
			mtc1 $v0,$f6
			cvt.s.w $f16,$f6
			add.s $f6,$f16,$f0
			li $v0, 0
			sw $v0, floatFlag
			swc1 $f6, 0($t4) # store byte: target[i]= $t0
			addiu $t4, $t4, 4
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
			
			
# -------------- window method -----------------
	# $t0 = i, $t1 = j, $t2 = matrixAddress.
	# $t3 = cell counts of the reduced matrix.
	# $t4 = address of evenWindow.
	# $t5 = address of oddWindow
	# $t6 = dimention
	# $t7 = remaining number of levels
windowMethod:
	
	sub $sp, $sp, 4 # push ra 
	sw $ra, 4($sp) 
	
	
	li $t0, 0 #i of matrix
	li $t1, 0 #j of matrix
	lw $t2, matrixAddress
	la $t4, evenWindow
	la $t5, oddWindow
	lw $t6, dimention
	lw $t7, levelNum
	li $s0, 0 #i for window
	li $s1, 0 #j for window
	li $s2,0 #for storing levels i
	li $s6,0 #for storing levels j
	li $s7,0
	li $k0,0
	li $a3,1
	
	la $a0,newLine
	li $v0,4		
	syscall
	
	
	iterateLevel:
		
		beq $t7, 0, end2 # all levels are done
		beq $t6, 1, end2
		la $a0,newLevelmsg
		li $v0,4
		syscall
		la $a0,newLine
		li $v0,4
		syscall
		div $s4,$t7,2
		mfhi $s4
		beqz $s4,even
		odd:
		move $s4,$t5
		b go2
		
		even:
		move $s4,$t4
				
		go2:
		iterate_j:
			beq $t1, $t6, cont
			#l.d $f0,0 # the result of one rectangle 
			
			iterate_i:
				beq $t0, $t6, cont2
				
				
				iterate_window_j:
				beq $s1,2,conW
				
				iterate_window_i:
				beq $s0,2,conW2
				
				# i, j --> findCell in matrix
				add $s7,$t0,$s0
				add $t3,$t1,$s1
				move $a0,$s7 #pass i value to the function
				move $a1,$t3 #pass j value to the function
				move $a2,$t2 #pass the address for the matrix
				
				jal findCell
				move $t8,$v0 #address of matrix cell
				
				# i, j --> findCell in window 
				move $a0,$s0 #pass j value to the function
				move $a1,$s1 #pass j value to the function
			
				move $a2,$s4 #pass the address for the matrix
				
				jal findWindowCell
				move $s3,$v0 ##address of window cell
				
				l.s $f0, ($t8)
				l.s $f2, ($s3)
				mul.s $f0, $f0, $f2
				add.s $f4, $f4, $f0
				
				addiu $s0,$s0,1
				b iterate_window_i
				
				conW2:
				move $s0,$zero
				addiu $s1,$s1,1
				
			 	la $a0,space
			 	li $v0,4
			 	syscall 
			 	
			b iterate_window_j
				conW:
				addiu $t0, $t0, 2
				
				move $a0,$s2 #finding the address for storing
				move $a1,$s6
				move $a2,$t2 #pass the address for the matrix
				
				jal findCell
				
				l.s $f14 ,quarter
			 	mul.s $f4,$f4,$f14
				swc1 $f4, 0($v0) # store byte: target[i]= $t0
				
				#printToFile
				s.s $f2, num
				sub $sp, $sp, 40
				sw $s0, 4($sp)
				sw $v0, 8($sp)
				sw $t0, 12($sp)
				sw $t2, 16($sp)
				sw $t5, 20($sp)
				sw $a0, 24($sp)
				sw $a1, 28($sp)
				sw $a2, 32($sp)
				sw $a3, 36($sp)
				jal write
				lw $s0, 4($sp)
				lw $v0, 8($sp)
				lw $t0, 12($sp)
				lw $t2, 16($sp)
				lw $t5, 20($sp)
				lw $a0, 24($sp)
				lw $a1, 28($sp)
				lw $a2, 32($sp)
				lw $a3, 36($sp)
				add $sp, $sp, 40
				
				
				mov.d $f12,$f4 #print avg
			 	li $v0,2
			 	syscall 
			 	
				
				
				l.d $f4,zero
				move $s0,$zero
				move $s1,$zero
				
				addiu $s2,$s2,2
				
			 	
				la $a0,space
				li $v0,4
				syscall
			
				
				
				#store f4 in the output heap
				#f4=0,s1=0,s0=0
			b iterate_i
			cont2:
			move $t0,$zero
			addiu $t1, $t1, 2
			addiu $s6,$s6,1
			move $s2,$zero
			la $a0,newLine
				li $v0,4
				syscall
		b iterate_j
		
	cont:
	
	addiu $t7, $t7, -1
	move $s2,$zero
	move $s6,$zero
	div $t6,$t6,2
	move $t1, $zero
	move $t0, $zero
	mul $a3,$a3,2
	sw $t6,dimention
	
	la $a0,newLine
	li $v0,4
	syscall
	b iterateLevel
	
end2:
lw $ra, 4($sp) # pop ra 
add $sp, $sp,4 		
jr  $ra


#----------- find cell address -----------
findCell:
lw $t6, dimention #get the num of column
mul $a1,$a1,$t6 #(iÃ—COLS)
addu $a1,$a1,$a0 #(iÃ—COLS + j)
mul $k1,$a3,4
mul $a1,$a1,$k1 #(iÃ—COLS + j) Ã— Element_size
addu $a2,$a2,$a1 #&matrix + (iÃ—COLS + j)


move $v0,$a2 #return the new address	
jr $ra



#find cell of window
findWindowCell:

mul $a1,$a1,2 #(iÃ—COLS)
addu $a1,$a1,$a0 #(iÃ—COLS + j)
mul $a1,$a1,4 #(iÃ—COLS + j) Ã— Element_size
addu $a2,$a2,$a1 #&matrix + (iÃ—COLS + j)


move $v0,$a2 #return the new address	
jr $ra



#---------- Bubble Sort ----------
bubbleSort: # $a0 = &A, $a1 = n

do: addiu $a1, $a1, -1 # n = n-1

blez $a1, L2 # branch if (n <= 0)
move $t0, $a0
li $t1, 0 # $t1 = swapped = 0
li $t2, 0 # $t2 = i = 0
for: lwc1  $f0, 0($t0) # $f0 = A[i]
lwc1  $f1, 4($t0) # $f1 = A[i+1]
c.le.s $f0, $f1 # branch if (A[i] <= A[i+1])
bc1t L1 
swc1 $f1, 0($t0) # A[i] = $f1
swc1 $f0, 4($t0) # A[i+1] = $f0
li $t1, 1 # swapped = 1
L1: addiu $t2, $t2, 1 # i++
addiu $t0, $t0, 4 # $t0 = &A[i]
bne $t2, $a1, for # branch if (i != n)

bnez $t1, do # branch if (swapped)

L2: jr $ra


# ------------- Median method ----------
medianMethod:
	
	sub $sp, $sp, 4 # push ra 
	sw $ra, 4($sp) 
	
	
	li $t0, 0 #i of matrix
	li $t1, 0 #j of matrix
	lw $t2, matrixAddress
	la $t4, evenWindow
	la $t5, oddWindow
	lw $t6, dimention
	lw $t7, levelNum
	li $s0, 0 #i for window
	li $s1, 0 #j for window
	li $s2,0 #for storing levels i
	li $s6,0 #for storing levels j
	li $s7,0
	li $k0,0
	li $a3,1
	la $s3, sortedArr
	
	la $a0,newLine
	li $v0,4
	syscall
	
	
	iterateLevel2:
		
		beq $t7, 0, end222 # all levels are done
		beq $t6, 1, end222
		la $a0,newLevelmsg
		li $v0,4
		syscall
		la $a0,newLine
		li $v0,4
		syscall
		iterate_j2:
			beq $t1, $t6, cont22
			#l.d $f0,0 # the result of one rectangle 
			
			iterate_i2:
				beq $t0, $t6, cont222
				
				
				iterate_window_j2:
				beq $s1,2,conW22
				
				iterate_window_i2:
				beq $s0,2,conW222
				
				# i, j --> findCell in matrix
				add $s7,$t0,$s0
				add $t3,$t1,$s1
				move $a0,$s7 #pass i value to the function
				move $a1,$t3 #pass j value to the function
				move $a2,$t2 #pass the address for the matrix
				
				jal findCell
				move $t8,$v0 #address of matrix cell
				
				l.s $f5, ($t8)
				swc1  $f5, ($s3)
				addiu $s3,$s3,4 #move index
				
				
				addiu $s0,$s0,1
				b iterate_window_i2
				
				conW222:
				move $s0,$zero
				addiu $s1,$s1,1
				
			 	la $a0,space
			 	li $v0,4
			 	syscall 
			 	
			b iterate_window_j2
				conW22:
				
				
				
				sub $sp, $sp,32 # push ra 
				sw $t1, 4($sp)
				sw $t0, 8($sp)
				sw $t2, 12($sp)
				la $a0, sortedArr
				li $a1, 4
				jal bubbleSort
				lw $t1, 4($sp) # pop ra 
				lw $t0, 8($sp) # pop ra
				lw $t2, 12($sp) # pop ra
				add $sp, $sp,32	
				
				lwc1 $f2,4($a0)
				lwc1 $f3, 8($a0)
				add.s $f2, $f2, $f3
				lwc1  $f4, half
				mul.s $f2, $f2, $f4 #calculate average of the two median
				
				move $a0,$s2 #finding the address for storing
				move $a1,$s6
				move $a2,$t2 #pass the address for the matrix
				jal findCell
				
				swc1 $f2, ($v0) # store byte: target[i]= $t0
				
				s.s $f2, num
				sub $sp, $sp, 40
				sw $s0, 4($sp)
				sw $v0, 8($sp)
				sw $t0, 12($sp)
				sw $t2, 16($sp)
				sw $t5, 20($sp)
				sw $a0, 24($sp)
				sw $a1, 28($sp)
				sw $a2, 32($sp)
				sw $a3, 36($sp)
				jal write
				lw $s0, 4($sp)
				lw $v0, 8($sp)
				lw $t0, 12($sp)
				lw $t2, 16($sp)
				lw $t5, 20($sp)
				lw $a0, 24($sp)
				lw $a1, 28($sp)
				lw $a2, 32($sp)
				lw $a3, 36($sp)
				add $sp, $sp, 40
				
				mov.d $f12,$f2 #print avg
			 	li $v0,2
			 	syscall 
			 	
				
				
				l.d $f2,zero
				move $s0,$zero
				move $s1,$zero
				addiu $t0, $t0, 2
				la $s3,sortedArr
				addiu $s2,$s2,2
				
			 	
				la $a0,space
				li $v0,4
				syscall
				   
				
				#store f4 in the output heap
				#f4=0,s1=0,s0=0
			b iterate_i2
			cont222:
			move $t0,$zero
			addiu $t1, $t1, 2
			addiu $s6,$s6,1
			move $s2,$zero
			la $a0,newLine
				li $v0,4
				syscall
				
		b iterate_j2
		
	cont22:
	
	addiu $t7, $t7, -1
	move $s2,$zero
	move $s6,$zero
	div $t6,$t6,2
	move $t1, $zero
	move $t0, $zero
	mul $a3,$a3,2
	sw $t6,dimention
	
	la $a0,newLine
	li $v0,4
	syscall
	
				
	b iterateLevel2
	
end222:
lw $ra, 4($sp) # pop ra 
add $sp, $sp,4 		
jr  $ra


#------power-----
power:
move $t2,$a0
li $t1,1
loop:
sll $t1,$t1,1
sub $t2,$t2,1
bnez $t2,loop
move $v0,$t1
jr $ra


# -------------- write to file -------------
	write:
	
	sub $sp, $sp, 4 # push ra 
	sw $ra, 4($sp)
	
	la $t0, buff
	li $t2, 0
	sb $t2, buff($t2)
	sb $t2, buff+1($t2)
	sb $t2, buff+2($t2)
	sb $t2, buff+3($t2)
	sb $t2, buff+4($t2)
	la $t0, buff2
	li $t2, 0
	sb $t2, buff2($t2)
	sb $t2, buff2+1($t2)
	sb $t2, buff2+2($t2)
	sb $t2, buff2+3($t2)
	sb $t2, buff2+4($t2)
	
	
	li $v0,13           	# open_file syscall code = 13
    	la $a0,outFile     	# get the file name
    	li $a1,9          	# file flag = read (0)
    	li $a2,0
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
    	

	
		l.s $f30, num
		cvt.w.s $f28,$f30
		mfc1 $t0, $f28  
		la $t2, buff
		move $a2, $zero # digit counter
		
			loop4:
			beqz $t0, rev1
			div $t0, $t0, 10
			mfhi $a1
			addiu $a1, $a1, 48
			sb $a1, ($t2)
			addiu $t2, $t2, 1
			addiu $a2,$a2, 1
			b loop4
			
			rev1:
			la $a0, buff
			la $a3, buff2
			jal reverse1
			move $t5, $v0
			#----- float ----
			
			float:
			 l.s $f30, num
			cvt.w.s $f28,$f30
			mfc1 $t0, $f28 
			
			cvt.s.w $f31, $f28
			sub.s $f30, $f30, $f31
			
			l.s $f29, hundred
			mul.s $f30,$f30, $f29
			cvt.w.s $f28, $f30
			mfc1 $t0, $f28 
			move $a1, $zero
			
			
			la $t2, buff
			move $a2, $zero
			move $a3, $zero
			
			loop2: 
			beq $a3, 2, rev2
			div $t0, $t0, 10
			mfhi $a1
			addiu $a1, $a1, 48
			sb $a1, ($t2)
			addiu $t2, $t2, 1
			addiu $a2, $a2, 1
			addiu $a3, $a3, 1
			b loop2
			
			rev2:
			li $a1, 46
			sb $a1, ($t2)
			addiu $t2, $t2, 1
			addiu $a2, $a2, 1
			la $a0, buff
			la $a3, buff2
			addu $a3, $a3, $t5 
			jal reverse1
			
			
			
			
			print:
			
			la $a1, buff2
			#jal reverse 
			#move $a1, $v0
			li   $v0, 15       # system call for write to file
			move $a0, $s0      # file descriptor  
			li $a2,11     
			syscall            # write to file
			
			
			 # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s0      # file descriptor to close
  syscall 
			lw $ra, 4($sp) # pop ra 
			add $sp, $sp,4 
			jr $ra
		
#----------- reversing----------
 reverse1:
  move $v0,$a2
    	Loop:
        sub     $a2, $a2, 1     #this statement is now before the 'load address'
        lb      $a0, buff($a2)   #loading value
        sb 	$a0, ($a3)
        addiu 	$a3, $a3, 1
        bnez    $a2, Loop       
     	
        jr $ra
        
   		
 
        
    #----- print new line----
    WriteNewLine:
    li $v0,13           	# open_file syscall code = 13
    	la $a0,outFile     	# get the file name
    	li $a1,9          	# file flag = read (0)
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
    	
			
			la $a1, newLine
			#jal reverse 
			#move $a1, $v0
			li   $v0, 15       # system call for write to file
			move $a0, $s0      # file descriptor  
			li $a2,5     
			syscall            # write to file
			
