


#   	*----------------------------------------------------*
#   	|		Authers:			     |
#   	|    	Siham Abu-Rmaileh - 1180548		     |
#   	| 		Israa Haseeba - 1182467		     |
#   	*----------------------------------------------------*


.data

# I/O files.
fileName: .asciiz "C:\\Users\\HP\\Desktop\\4th_Year_2nd_semester\\Architecture\\projects\\project_1\\training\\T1.txt"
outFile: .asciiz "C:\\Users\\HP\\Desktop\\4th_Year_2nd_semester\\Architecture\\projects\\project_1\\training\\d.txt"

# User Messages.
errorMes: .asciiz "\n\nIncorrect input matrix!"
levelError: .asciiz "\n\nLarge level!"
levelMes: .asciiz "\n\n Please enter the number of level: \n\n"
operationMes: .asciiz "\n\n If you want down sampling by meadian please enter '1' and '2' if mean  \n\n "
newLevelmsg: .asciiz "\n\n --- New Level ---"
newLine: .asciiz "\n"
space: .asciiz " "

# Weights of Down_Sampling depending on the level.
evenWindow: .float 1.5, 0.5, 0.5, 1.5
oddWindow: .float 0.5, 1.5, 1.5, 0.5

# Buffers.
numBuff: .word 0:50		# Temporary buffer used to store the digits of the current parsed number.
precBuff: .word 0:50		# Temporary buffer used to store the floating precision. 
buff: .space 10			# Stores the number to be reversed.
buff2: .space 10		# Stores the reversed number.
num: .float 0			# Number to be printed.
sortedArr: .float 0:4		# Array of sorted window numbers. (Used in Median Algorithm). 

# Addresses.
matrixAddress: .word 0		# The address of the heap of the float matrix is stored here.

# Important Arguments.
floatFlag: .word 0		# To announce the program to generate the floating precesion while parsing.	
levelNum: .word 0		# Number of Levels.
algo: .word 0			# Chosen Algorithm.
dimention: .word 0		# The Column & Row values. (Row = Column) (Square Matrix).

# Numbers.
zero: .float 0.0
divisor: .float 0.1		# Multiply by 0.1 = Divide by 10 (Used in Converting String into float).
quarter: .float 0.25
half: .float 0.5
ten: .float 10.0
hundred: .float 100.0


#----------------------------------------------------------
#                        Start. 
#----------------------------------------------------------

.text
.globl main

#----------------------------------------------------------
#                        Main. 
#----------------------------------------------------------
	
main:

# Request the number of levels.
la $a0,levelMes
li $v0,4
syscall 

# Read the number of levels.		
li $v0,5 
syscall 
sw $v0,levelNum

# Print new line.		
la $a0,newLine
li $v0,4
syscall
		
# Request the desired algorithm.		
la $a0,operationMes
li $v0,4
syscall 

# Read the Algorithm.	
li $v0,5
syscall 
sw $v0,algo
		
#----------------------------------------------------------
#                    Initializations. 
#----------------------------------------------------------

li $t9, 0 		# Previous row.
li $t8,0 		# Size of column.
li $t7,0 		# Size of row.
li $v0, 0	
sw $v0, floatFlag	# Initialize the floatFlag to zero. "Don't generate precision".

	
#----------------------------------------------------------
#                         Heap. 
#----------------------------------------------------------	
	
# Main matrix Heap.
li $a0, 10240		# $a0 = number of bytes to allocate.
li $v0, 9 		
syscall	
		
move $t4, $v0 		
sw $t4,matrixAddress	# $t4 = address of allocated block.
	
	
# Temporary heap to save the data when reading from file.
li $a0, 10240 		# $a0 = number of bytes to allocate.
li $v0, 9 		
syscall 		
move $t1, $v0 		# $t1 = address of allocated block.
	

#----------------------------------------------------------
#                         Read File. 
#----------------------------------------------------------

# Open File.
li $v0,13           	# Open_file syscall code = 13.
la $a0,fileName     	# Get the file name.
li $a1,0           	# File flag = read (0).
syscall
move $s0,$v0        	# Save the file descriptor. $s0 = file.
	
# Read File.
li $v0, 14		# Read_file syscall code = 14.
move $a0,$s0		# Get the file descriptor.
move $a1,$t1       	# The buffer that holds the data of the WHOLE file.
la $a2,10240		# Hardcoded buffer length.
syscall

# Print Data.
li $v0, 4		# Read_string syscall code = 4.
move $a0,$t1
syscall
	
# Close the file.
li $v0, 16         	# Close_file syscall code = 16
move $a0,$s0      	
syscall
    	
#----------------------------------------------------------
#                         Parse Data. 
#----------------------------------------------------------


    	# Parse Numbers into main matrix
    	# 1. file -> null
	# 2. loop while != null:
	# 3. 	buff -> num
	# 4. 	cmp by ','
	# 5. 	if ',' : (BRANCH to function) convert to int: num: (LOOP) var int=0,   +num[0], int * 10 + num[1] ...
		# add to main matrix
	# 6.  	if 'a' newl: size++ :
	# 7. 	if not : continue adding to buff
	

la $a1, numBuff		# Get the address of the temporary integer buffer.
li $a0, 0 		# Counter of integr digits.
la $a3,precBuff 	# Get the address of the temporary float buffer
li $a2,0 		# Counter of floating digits.
	
	
iterateBuff:
lb $t0, 0($t1) 				# Load byte: $t0 = source[i]
beq $t0, 0, endIteration		# Exit if it's the end of file.
bne $t0, 0x2c, checkIfNewLine 		# If it is not a ',', Check if it is a '.' or a new line.
jal convertToInt			# If it's a ',', convert chars in numBuff to a number.
move $a1,$v1				# Move the result into $a1.
b next					# Get the next char.

# Check if '.' & 0x0d & 0x0a.
checkIfNewLine:
beq $t0,0x2E,operateFloating		# If it is '.', parse floating.
bne $t0, 0x0d, checkIf0x0a		# If it is not an end of the row, check if new line.

# Convert chars to integer.		
jal convertToInt
move $a1,$v1				# Store the result in $a1.
		
beqz $t9,firstIteration			# If there is no previous row ($t9 = 0), then it is the first iteration.
bne $t9,$t7,Error			# If there is a difference in the length of the current and the previous row, handle an error.
move $t9,$t7				# Overwrite the previous row size by the current row size. ($t9 = $t7).
li $t7,0				# Reset the current row size $t7 to 0 in order to prepare for the next iteration.
b next					# Get the next char.

# First iteration case.
firstIteration:
move $t9,$t7				# Fill the previous size by the current.
li $t7,0				# Reset the current row size $t7 to 0 in order to prepare for the next iteration.
b next					# Get the next char.

#Check if 0x0a & if the char is a digit.
checkIf0x0a:
beq $t0, 0x0a, next			# If it is a new line, Get the next char.
bgt $t0, 0x39, Error			# If it is not a number, handle an error.
blt $t0, 0x30, Error

# If all is going normally:
lw $v0, floatFlag			# Load the current float flag.
beq $v0, 1, addFloat			# If the flag is 1, then it is the time to generate the floating part.
sw $t0, 0($a1) 				# If the flag is 0, store the generate number: target[i]= $t0
addiu $a0, $a0, 1			# Increase the number of integer digits by one.
addiu $a1, $a1, 4			# Go the the next word in the integer buffer.
b next					# Get the next char.

# Rais the float flag to 1 & continue reading chars.
operateFloating:
li $v0, 1
sw $v0, floatFlag
b next

# Store the char in the float digits buffer.
addFloat:
sw $t0,0($a3)
addiu $a3, $a3,4			# Go the the next word in the float buffer. 
addiu $a2, $a2,1			# Increase the number of float digits by one.
			
next:
addiu $t1, $t1, 1
b iterateBuff				# Get the next char.				

		
# Generate the last number.
endIteration:
la $t0, numBuff				
beq $a1, $t0, endd 			# If file is empty, skip this step.
jal convertToInt
bne $t9,$t7,Error			# Handle the error of unequal rows.

endd:


# Check if the matrix is square.

# size / #column = #row * 4.
# (row * 4) / (size of cell = 4) = #row.

lw $t0, matrixAddress			# Get the first address of the matrix. 		
sub $t4, $t4, $t0			# Subtract the first address from the last. Note that $t4 is updated on 'convertToInterger' function. 
div $t4, $t7      			
li $t7,4				
mflo $t5 				
div $t5, $t7
mflo $t5          
bne  $t5,$t9,Error			# Compare #rows to the result.
move $t8, $t9				
sw $t8, dimention			# store the dimention.

move $a0,$t8
jal mod_fcn				# Check if the matrix is able to operate on a window of size 2x2.
b continue				# No error.
		
#----------------------------------------------------------
#                         Error. 
#----------------------------------------------------------	
Error:
la $a0,errorMes
li $v0,4
syscall 
b end


#----------------------------------------------------------
#                   Check the entered level.
#----------------------------------------------------------
	
continue:
lw $t6,dimention		# Load the dimention.
lw $a0,levelNum			# Load the level number.
jal power			# Check level validity through if (2 ^ levelNum > dimention).
move $t4,$v0
bgt $t4,$t6,levelError1		# if (2 ^ levelNum > dimention), handle an error.


#----------------------------------------------------------
#                 Run the chosen algorithm.
#----------------------------------------------------------


lw $t1,algo
beq $t1,1,median		# If algo = 1, run Median. Otherwise, run mean.


# Run Mean.
Mean:
jal meanMethod			
b end				# End the program.

# Run Median.		
median:
jal medianMethod
b end				# End the program.
	
#----------------------------------------------------------
#                   Print Level Error.
#----------------------------------------------------------	
levelError1:
la $a0,levelError
li $v0,4
syscall	


#----------------------------------------------------------
#                   End OF Program.
#----------------------------------------------------------
	
end:
li $v0,10
syscall






#--------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------
#                  				Functions.
#--------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------   	
    	
    	
    	
# *************************************************************************************************************

    	    	
    	
#----------------------------------------------------------
#                   Generate number.
#----------------------------------------------------------
	
convertToInt:
la $a1, numBuff						#Load the address of the buffer that contain the reading asscii from input file.	
li $v0, 0						#Initialize the register to zero to use it in the sum operation.
li $t0, 10						#Initialize The register to 10 to use it in mul operation.
lw $t3, 0($a1) 						#Load the number in asscii value. 
addiu $v0, $t3, -48 					#Convert character to digit (from asscii to integer). 
addiu $a1, $a1, 4					#Move to the next char.
addiu $a0, $a0, -1					#Decrease the counter of the digit by one.
beq $a0, 0, secondStep					#Move to the next step when the counter =0.
		iterateNumber:
		lw $t3, 0($a1)	
		addiu $t3, $t3, -48 			# Convert character to digit. 
		mul $v0, $v0, $t0 			# $v0 = sum * 10. 
		addu $v0, $v0, $t3 			# $v0 = sum * 10 + digit. 
		addiu $a1, $a1, 4
		addiu $a0, $a0, -1
		beq $a0, 0, secondStep
		b iterateNumber				#Loop back. 
			secondStep:			#This step for float part.
			beqz $a2,  done			#Get out of the loop if the float digit end.
			la $a3, precBuff			#Load the address of floating buffer.	
			l.s  $f0,zero			#Load zero on float register to use it in sum operatio.
			l.s $f2, divisor			#Load 10 for mul operation.
			lw $t3, 0($a3) 			#Load the floating char. 
			addiu $t3, $t3, -48		#Convert character to digit.
			mtc1 $t3,$f4			#Move the value from float register to normal register.
			cvt.s.w $f16,$f4			#Convert from word to single precision.
			mul.s $f0, $f16, $f2 		#$f0 = sum * 10.
			addiu $a3, $a3, 4		#Get the next value.
			addiu $a2, $a2, -1
			beq $a2, 0, done
				iterateNumber2:		#If the number contain many digit this step done.
				lw $t3, 0($a3) 
				addiu $t3, $t3, -48	#Convert character to digit.
				mtc1 $t3,$f4 
				cvt.s.w $f16,$f4
				mul.s $f0, $f16, $f2 	# $v0 = sum * 10. 
				add.s  $f0, $f0, $f4 	# $v0 = sum * 10 + digit. 
				addiu $a3, $a3, 4
				addiu $a2, $a2, -1
				beq $a2, 0, done
				b iterateNumber2  
					done: 
					mtc1 $v0,$f6
					cvt.s.w $f16,$f6
					add.s $f6,$f16,$f0
					li $v0, 0
					sw $v0, floatFlag	#Rest the flag value to zero.
					swc1 $f6, 0($t4)		#Store the converted value.
					addiu $t4, $t4, 4		
					la $v1,numBuff 		#Reload the address of the buffer to reuse it.
					la $a3,precBuff		#Reload the address of the float buffer.
					addiu $t7,$t7,1		
			
jr $ra 								# Return to caller.	
		
		
		
#----------------------------------------------------------
#                Increment the size of the matrix. 
#----------------------------------------------------------

incSizeOfMatrix:
addiu $t8, $t8, 1
jr $ra # return to caller.
		
			
					
#----------------------------------------------------------
# 			Mod function 
#----------------------------------------------------------
mod_fcn: 
beq $t8, 2, Matrix2x2		  #If the matrix of size 2x2 go to (Matrix2x2). 
li  $t6, 4
b Matrix4x4			  #If the matrix not of size 2x2 then go to (Matrix4x4).
	Matrix2x2:
	li  $t6, 2
		Matrix4x4:
		div $a0, $t6      #i mod 4.
		mfhi $t5          #Temp for mod.
		move $v0, $t5     #Retrun moded num
		bne  $v0,0,Error  #If the mod not equal zero then display error message.
jr  $ra		


#----------------------------------------------------------
#                       Power.
#----------------------------------------------------------

power:
move $t2,$a0		#Get the value that we want to raise it to the power.
li $t1,1
	loop:
	sll $t1,$t1,1	#Starting shifting to the left until the loop end.
	sub $t2,$t2,1	#Update the value of the power after each mul operation.
	bnez $t2,loop	#Continue shiffting until the power =0.
	move $v0,$t1	#Return the result.
jr $ra
			
			
#----------------------------------------------------------
#                   Mean Algorithm.
#----------------------------------------------------------

meanMethod:
	
sub $sp, $sp, 4 		# Push ra.
sw $ra, 4($sp) 
	
# Initialization.	
li $t0, 0			# i of matrix
li $t1, 0 			# j of matrix
lw $t2, matrixAddress		# Load the addrss of the matrix.
la $t4, evenWindow		
la $t5, oddWindow
lw $t6, dimention
li $t7, 0			# To follow up with the levels.
lw $t9, levelNum
	
li $s0, 0 			# i for window
li $s1, 0 			# j for window
li $s2,0 			# For storing levels i
li $s6,0 			# For storing levels j
li $s7,0			# To store the coordinates of the cell. 
li $k0,0			
li $a3,1			
	
# Print new line.	
la $a0,newLine
li $v0,4		
syscall
	
	
iterateLevel:
		
beq $t7, $t9, end2 		# Check if all levels are done or not.
beq $t6, 1, end2		# If the output of the latest level is one cell, then exit.

# Print "New Level".
la $a0,newLevelmsg		
li $v0,4
syscall

# Print new line.
la $a0,newLine
li $v0,4
syscall


# Check if the first level is even or odd to get the right weights. 
# Here it will be even as $t7 = 0. But if the user decides to change the initialization it will fit.
div $s4,$t7,2			
mfhi $s4
beqz $s4,even

odd:
move $s4,$t5
b go2
		
even:
move $s4,$t4
				
go2:

# Start the Algorithm.

	iterate_j:
	beq $t1, $t6, cont 			# If j is out of range, got to the next level.

			
		iterate_i:
		beq $t0, $t6, cont2		# If i is out of range, got to the next j.
				
				
			iterate_window_j:
			beq $s1,2,conW		# If j_window is out of range, got to the next i_matrix.
				
				iterate_window_i:
				beq $s0,2,conW2	# If i_window is out of range, got to the next j_window.
				
				# i, j --> findCell in matrix
				add $s7,$t0,$s0		# $s7 = i_matrix + i_window
				add $t3,$t1,$s1		# $t3 = j+matrix + j_window
				move $a0,$s7 		# Pass i value to the function
				move $a1,$t3 		# Pass j value to the function
				move $a2,$t2 		# Pass the address for the matrix
				
				jal findCell
				move $t8,$v0 		# Return the address of matrix cell.
				
				# i, j --> findCell in window 
				move $a0,$s0 		#pass i value to the function
				move $a1,$s1 		#pass j value to the function
				move $a2,$s4 		#pass the address for the matrix
				
				jal findWindowCell
				move $s3,$v0 		# Return the address of window cell.
				
				l.s $f0, ($t8)		# Load the value stored in current matrix cell.
				l.s $f2, ($s3)		# Load the value stored in current window cell.
				mul.s $f0, $f0, $f2	# Multiply them.
				add.s $f4, $f4, $f0	# Add the result to $t4, this is the output of the whole window.
				
				addiu $s0,$s0,1		# Iterate i_window.
				b iterate_window_i
				
				conW2:			
				move $s0,$zero		# Reset i_wondow.
				addiu $s1,$s1,1		# Iterate j_window.
				
				# Print space.
				la $a0,space
				li $v0,4
				syscall 
				
				b iterate_window_j
			conW:
			addiu $t0, $t0, 2		# Iterate i_matrix: i = i+2, as the window includes two cells.
			
			# Find the address for storing the number.	
			move $a0,$s2 			
			move $a1,$s6
			move $a2,$t2 			# Pass the address for the matrix.
			jal findCell
				
			l.s $f14 ,quarter		# Load the 0.25 to divide by 4.
			mul.s $f4,$f4,$f14		
			swc1 $f4, 0($v0) 		# Store the number: target[i]= $t0
				
			# Print to file.
			s.s $f4, num			# Store the number in num.
			sub $sp, $sp, 40		# Push used registers into the stack.
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
				
			# Print the result.	
			mov.d $f12,$f4 
			li $v0,2
			syscall 
			 	
				
			l.d $f4,zero		# Reset the result register. 
			move $s0,$zero		# Reset i_window.
			move $s1,$zero		# Reset j_window.
			addiu $s2,$s2,2		# Increase th epointer of the new saved matrix.
				
			# Print Space. 	
			la $a0,space
			li $v0,4
			syscall
			
			b iterate_i
			cont2:
			move $t0,$zero			# Reset i_matrix.
			addiu $t1, $t1, 2		# Iterate j_matrix: j = j+2 as the winodw includes two cells.
			addiu $s6,$s6,1			# Increase the j pointer of the new matrix.
			move $s2,$zero			# Reset the i pointer of the new matrix.
			
			# Print new line.
			la $a0,newLine
			li $v0,4
			syscall
			
			# Print new line on file.
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
			jal WriteNewLine
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
		b iterate_j
		
		cont:
	
		addiu $t7, $t7, 1		# Increase the passed levels.
		move $s2,$zero			# Reset i & j of the new window.
		move $s6,$zero
		div $t6,$t6,2			# Reduce the dimention to fit the new matrix.
		move $t1, $zero			# Reset i & j of the matrix.
		move $t0, $zero
		mul $a3,$a3,2		
		sw $t6,dimention
	
		# Print new line.
		la $a0,newLine
		li $v0,4
		syscall
		
		# Print new line on file twice.
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
		jal WriteNewLine
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
		jal WriteNewLine
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
	b iterateLevel
	
end2:

lw $ra, 4($sp) # pop ra 
add $sp, $sp,4 		
jr  $ra

#----------------------------------------------------------
#                         Find cell address. 
#----------------------------------------------------------

findCell:
lw $t6, dimention	 #Get the num of column.
mul $a1,$a1,$t6		 #(i×COLS).
addu $a1,$a1,$a0		 #(i×COLS + j).
mul $k1,$a3,4
mul $a1,$a1,$k1           #(i×COLS + j) × Element_size.
addu $a2,$a2,$a1		 #&matrix + (i×COLS + j) × Element_size.
move $v0,$a2		 #Return the new address.	
jr $ra


#----------------------------------------------------------
#                         #Find cell of window. 
#----------------------------------------------------------

findWindowCell:

mul $a1,$a1,2 		#(i×COLS).
addu $a1,$a1,$a0 	#(i×COLS + j).
mul $a1,$a1,4  		#(i×COLS + j) × Element_size.
addu $a2,$a2,$a1 	#&matrix + (i×COLS + j) × Element_size.
move $v0,$a2 		#Return the new address.	
jr $ra



#----------------------------------------------------------
#                        Bubble Sort 
#----------------------------------------------------------

bubbleSort: 		 			# $a0 = &A, $a1 = n.
	do: addiu $a1, $a1,-1 			# n = n-1.

	blez $a1, L2				# Branch if (n <= 0).
	move $t0, $a0
	li $t1, 0 				# $t1 = swapped = 0.
	li $t2, 0 				# $t2 = i = 0.
		for: lwc1  $f0, 0($t0) 		# $f0 = A[i].
		lwc1  $f1, 4($t0) 		# $f1 = A[i+1].
		c.le.s $f0, $f1 			# Branch if (A[i] <= A[i+1]).
		bc1t L1 
		swc1 $f1, 0($t0) 		# A[i] = $f1.
		swc1 $f0, 4($t0) 		# A[i+1] = $f0.
		li $t1, 1 			# Swapped = 1.
			L1: addiu $t2, $t2, 1	# i++.
			addiu $t0, $t0, 4 	# $t0 = &A[i].
			bne $t2, $a1, for 	# Branch if (i != n).
			bnez $t1, do 		# Branch if (swapped).
				L2: jr $ra

#----------------------------------------------------------
#                         Median methods. 
#----------------------------------------------------------

medianMethod:
sub $sp, $sp, 4		# Push ra to save it when calling other functions.
sw $ra, 4($sp) 
	
	
li $t0, 0 		#i of matrix.
li $t1, 0 		#j of matrix.
lw $t2, matrixAddress
la $t4, evenWindow
la $t5, oddWindow
lw $t6, dimention
li $t7, 0
lw $t9, levelNum
li $s0, 0		#i for window.
li $s1, 0		#j for window.
li $s2,0			#For storing levels i.
li $s6,0			#For storing levels j.
li $s7,0
li $k0,0
li $a3,1
la $s3, sortedArr
la $a0,newLine
li $v0,4
syscall
	
	
	iterateLevel2:
	beq $t7, $t9, end222					# All levels are done.
	beq $t6, 1, end222
	la $a0,newLevelmsg					#Printing new level message.
	li $v0,4
	syscall
	la $a0,newLine						#Printing new line.
	li $v0,4
	syscall
		iterate_j2:		
		beq $t1, $t6, cont22				#Check if the one row done.
			
			
			iterate_i2:	
			beq $t0, $t6, cont222			#Check if one colum done.
				
				
				iterate_window_j2:		#Loop for iterate window.
				beq $s1,2,conW22			#Check if row int the window done.
				
					iterate_window_i2:	#Check if column done in the window.
					beq $s0,2,conW222
					add $s7,$t0,$s0
					add $t3,$t1,$s1
					move $a0,$s7		#Pass i value to the function.
					move $a1,$t3		#Pass j value to the function.
					move $a2,$t2 		#Pass the address for the matrix.
				        jal findCell
					move $t8,$v0 		#Save the returned address of the matrix cell.
					l.s $f5, ($t8)		#Load the value of the returned address
					swc1  $f5, ($s3)
					addiu $s3,$s3,4 		#Move index.
					addiu $s0,$s0,1		#Increment the value of the row to the window.
				b iterate_window_i2
				
						conW222:
						move $s0,$zero	#Return to the firt column.
						addiu $s1,$s1,1	#Increment row value.
						la $a0,space	#Printing space.
			 			li $v0,4
			 			syscall 
			 	
			 	b iterate_window_j2
						conW22:
						sub $sp, $sp,32 	# Push some regesters' value to save it from change. 
						sw $t1, 4($sp)
						sw $t0, 8($sp)
						sw $t2, 12($sp)
						la $a0, sortedArr
						li $a1, 4
						jal bubbleSort	#Sorting the values to get the median.
						lw $t1, 4($sp)	#Pop the register' value.
						lw $t0, 8($sp)
						lw $t2, 12($sp) 
						add $sp, $sp,32	
						lwc1 $f2,4($a0)	#Get the first value.
						lwc1 $f3,8($a0)	#Get the second value.
						add.s $f2,$f2,$f3
						lwc1  $f4,half	#Calculate average of the two median.
						mul.s $f2,$f2,$f4
						move $a0,$s2 	#Finding the address for storing.
						move $a1,$s6
						move $a2,$t2 	#Pass the address for the matrix.
						jal findCell
						swc1 $f2, ($v0) 	
						s.s $f2, num	#Store the average to print it on the output file.
						sub $sp, $sp,40
						sw $s0, 4($sp)	#Push register value to the stack.
						sw $v0, 8($sp)
						sw $t0, 12($sp)
						sw $t2, 16($sp)
						sw $t5, 20($sp)
						sw $a0, 24($sp)
						sw $a1, 28($sp)
						sw $a2, 32($sp)
						sw $a3, 36($sp)
						jal write	#Write the value on the output file.
						lw $s0, 4($sp)	#Pop the register value.
						lw $v0, 8($sp)
						lw $t0, 12($sp)
						lw $t2, 16($sp)
						lw $t5, 20($sp)
						lw $a0, 24($sp)
						lw $a1, 28($sp)
						lw $a2, 32($sp)
						lw $a3, 36($sp)
						add $sp, $sp, 40
						mov.d $f12,$f2	#Print the result on console.
			 			li $v0,2
			 			syscall 
						l.d $f2,zero	#Return f2 to 0..
						move $s0,$zero	#Return to the start of the window
						move $s1,$zero
						addiu $t0, $t0, 2
						la $s3,sortedArr	#Get the sorted arrray.
						addiu $s2,$s2,2
						la $a0,space	#Print space.
						li $v0,4
						syscall
				   
				
				
			b iterate_i2
				cont222:
				move $t0,$zero			#Return i value for the matrix to 0.
				addiu $t1, $t1, 2		#Go to a new cell.
				addiu $s6,$s6,1
				move $s2,$zero
				la $a0,newLine
				li $v0,4
				syscall
				
		b iterate_j2
		
			cont22:
			addiu $t7, $t7,-1			#Decrese the level number.
			move $s2,$zero
			move $s6,$zero
			div $t6,$t6,2				#Reduce the dimention size to start new level.
			move $t1, $zero				#Start from the begin of the matrix.
			move $t0, $zero
			mul $a3,$a3,2
			sw $t6,dimention				#Store the new value of the dimention.
			la $a0,newLine				#Print new line on the console.
			li $v0,4
			syscall
			sub $sp, $sp, 40				#Push the registers' value.
			sw $s0, 4($sp)
			sw $v0, 8($sp)
			sw $t0, 12($sp)
			sw $t2, 16($sp)
			sw $t5, 20($sp)
			sw $a0, 24($sp)
			sw $a1, 28($sp)
			sw $a2, 32($sp)				
			sw $a3, 36($sp)
			jal WriteNewLine				#Write new line on the output file.
			lw $s0, 4($sp)				#Pop the registers' value.
			lw $v0, 8($sp)
			lw $t0, 12($sp)
			lw $t2, 16($sp)
			lw $t5, 20($sp)
			lw $a0, 24($sp)
			lw $a1, 28($sp)
			lw $a2, 32($sp)
			lw $a3, 36($sp)
			add $sp, $sp, 40			
	b iterateLevel2
	
end222:
lw $ra, 4($sp) 							#Pop the address of the function
add $sp, $sp,4 		
jr  $ra
#----------------------------------------------------------
#                   Write into file.
#----------------------------------------------------------
write:

# Save the $ra value fo write function.	
sub $sp, $sp, 4 # push ra 
sw $ra, 4($sp)

# Reset Buffers.
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

# Writing:		
li $v0,13           	# Open_file syscall code = 13
la $a0,outFile     	# Get the file name
li $a1,9          	# File flag = append (9)
li $a2,0
syscall
move $s0,$v0        	# Save the file descriptor. $s0 = file
  
    	  	
# Convertion from integer to string.		
l.s $f30, num		# Load the number to be printed.
cvt.w.s $f28,$f30	# Convert the number to integer in order to get the integer part only.
mfc1 $t0, $f28  	# Save the integer part in $t0.
la $t2, buff		# The sequence of chars will be stored in buff.
move $a2, $zero 	# Digits counter.


# The number will be divided by 10 every iteration in order to take the remainder. 				
loop4:
beqz $t0, rev1		# If the number become zero, all chars are taken, apply reverse.
div $t0, $t0, 10	# num = num / 10.
mfhi $a1		# Get the remainder.
addiu $a1, $a1, 48	# Get the ascii of the digit.
sb $a1, ($t2)		# Store the char into buff.
addiu $t2, $t2, 1	# Increase the pointer. 
addiu $a2,$a2, 1	# Increase the numbers of taken digits so far.
b loop4

# Send parameters to reverse1 function.			
rev1:
la $a0, buff
la $a3, buff2 		# The array of chars will be stored here.
jal reverse1
move $t5, $v0		# Return the number of digits stored in buff2 so far.



# Digits after floating point. 	
float:
l.s $f30, num		# Load the number again.
cvt.w.s $f28,$f30	# Convrt it to integer and store in $f28.
mfc1 $t0, $f28 		# Store it in $t0.
			
cvt.s.w $f31, $f28	# Convert it again to float. The result will be only the integer part but in floating format.
sub.s $f30, $f30, $f31	# The generated float - The original float =  Fraction.
			
l.s $f29, hundred
mul.s $f30,$f30, $f29	# Multiply by 100 in order to get a precision of 2.
cvt.w.s $f28, $f30	# Convert the fraction into integer in order to get rid of the small fraction. 
mfc1 $t0, $f28 		# Store the result in $t0.
move $a1, $zero


# The same operation of integer part soncersion will done.				
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

			
# Reverse the buffer.			
rev2:
li $a1, 46		# Append a dot after the fraction chars.
sb $a1, ($t2)			
addiu $t2, $t2, 1
addiu $a2, $a2, 1
la $a0, buff
la $a3, buff2
addu $a3, $a3, $t5	# buff2 + (stored chars so far (from the integer part)) = first address to continue storing. 
jal reverse1
			

# Print the buffer into the file.						
print:			
la $a1, buff2		# Load the addrss of the buffer to print.
li   $v0, 15       	# System call for write to file.
move $a0, $s0      	# File descriptor.
li $a2,8    
syscall            	# write to file.
			
			

li   $v0, 16       	# System call for close file.
move $a0, $s0      	# File descriptor to close.
syscall 


lw $ra, 4($sp) 		# pop ra 
add $sp, $sp,4 

jr $ra
		
		
#----------------------------------------------------------
#                       Reverse.
#----------------------------------------------------------

reverse1:

move $v0,$a2 		# Get the number of digits to store.
Loop:
sub     $a2, $a2, 1     # Decrement the number of digits to store.
lb      $a0, buff($a2)  # Load value.
sb 	$a0, ($a3)	# Store the char in buff2.
addiu 	$a3, $a3, 1	# Increase pointer.
bnez    $a2, Loop       
     	
jr $ra
        
   		
 
#----------------------------------------------------------
#                    Print new line.
#----------------------------------------------------------       


WriteNewLine:

# Open File.
li $v0,13           	# open_file syscall code = 13
la $a0,outFile     	# get the file name
li $a1,9          	# file flag = append (9)
syscall
move $s0,$v0        	# save the file descriptor. $s0 = file
    	

# Print new line.			
la $a1, newLine
li   $v0, 15       	# system call for write to file
move $a0, $s0      	# file descriptor  
li $a2,1     
syscall            	# write to file

# Close the file.			
li   $v0, 16       	# system call for close file
move $a0, $s0      	# file descriptor to close
syscall 
jr $ra
