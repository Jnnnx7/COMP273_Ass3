# Student ID = 260834196
####################################write Image#####################
.data

header_length:		.word 0x13	# hard code max header length of 19
openError: 		.asciiz "Opening file failed.\n"
space:			.word 0x20

.text
.globl write_image
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.

	addi $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw   $ra, 0($sp)           	# since we will use nested procedures
	
	move $s0, $a0			# store struct address in $s0
	move $s1, $a1			# store the file name in $s1
	
	lw   $s2, 0($a0)		# save width in $s2
	lw   $s3, 4($a0)		# save height in $s3
	lw   $s4, 8($a0)		# save max value in $s4
	
	# check the width we get from the sturct
	#li   $v0, 1
	#add  $a0, $s4, $zero
	#syscall
	
	# compute the size of the contents
	mult $s2, $s3
	mflo $s5
	
	# check the size we get from the sturct
	#li   $v0, 1
	#add  $a0, $s5, $zero
	#syscall
	
	# check the file type, 0 for P5 & 1 for P2
	beq  $a2, $zero, write_P5
	
	j    write_P2
	
write_P5:
	# check we goto the right branch
	#li   $v0, 1
	#addi $a0, $zero, 7
	#syscall
	
	addi  $s6, $zero, 0 		# $s6 will count the length of header
	
	# allocate space to write header
	li    $v0, 9
	lw    $a0, header_length
	syscall
	
	move  $a1, $v0			# save the address for header in $a1
	
	# write file type (P5) into buffer
	li    $t0, 'P'			# write 'P' into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	li    $t0, '5'			# write '5' into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	li    $t0, 0x20			# write white space into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	addiu $s6, $s6, 3		# increase the header length by 3
  	
  	# check the header we write
  	#addi  $a1, $a1, -3
  	
  	#li    $v0, 11
  	#lb    $a0, 1($a1)
  	#syscall
  	
  	# write width into buffer
  	addi  $a0, $s2, 0		# transfer width to ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x20			# append white space
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1		# advance the pointer by 1 to write next byte
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
  	
  	# write height into buffer
	addi  $a0, $s3, 0		# transfer height to ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x20			# append white space
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1		# advance the pointer by 1 to write next byte
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
  	
  	# write max value into buffer
  	addi  $a0, $s4, 0		# transfer max value into ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x0A			# append '\n'
  	sb    $t0, 0($a1)
  	addiu $t7, $a1, 1		# advance the pointer by 1 and store it in $t7
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
	
	# check the width we write
	#sub   $a1, $t7, $s6
	#li    $v0, 11
	#lb    $a0, 3($a1)
	#syscall
	
	# open file for write
	li    $v0, 13
	move  $a0, $s1			# restore the outputFile name
	li   $a1, 1             	# open for writing
	li   $a2, 0
	syscall
	
	move $a0, $v0           	# save the file descriptor in $a0
	
	bltz $a0, open_error    	# if open file fails (negative return value), go to open error
	
	# write header into the file
	li    $v0, 15
	sub   $a1, $t7, $s6     	# set string address for create header
	la    $a2, 0($s6)       	# header length
	syscall
	
	# write content into the file
	li    $v0, 15
	la    $a1, 12($s0)
	addi  $a2, $s5, 0
	syscall
	
	# close file
	li   $v0, 16            	# system call for close file
					# $a0 already store file descriptor
	syscall                 	# close file
	
	j     end
	
write_P2:
	# check we goto the right branch
	#li   $v0, 1
	#addi $a0, $zero, 17
	#syscall
	
	addi  $s6, $zero, 0 		# $s6 will count the length of header
	
	# allocate space to write header
	li    $v0, 9
	lw    $a0, header_length
	syscall
	
	move  $a1, $v0			# save the address for header in $a1
	
	# write file type (P2) into buffer
	li    $t0, 'P'			# write 'P' into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	li    $t0, '2'			# write '2' into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	li    $t0, 0x20			# write white space into buffer
  	sb    $t0, 0($a1)		
  	addiu $a1, $a1, 1		# advance the pointer by 1
  	addiu $s6, $s6, 3		# increase the header length by 3
  	
  	# check the header we write
  	#addi  $a1, $a1, -3
  	
  	#li    $v0, 11
  	#lb    $a0, 1($a1)
  	#syscall
  	
  	# write width into buffer
  	addi  $a0, $s2, 0		# transfer width to ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x20			# append white space
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1		# advance the pointer by 1 to write next byte
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
  	
  	# write height into buffer
	addi  $a0, $s3, 0		# transfer height to ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x20			# append white space
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1		# advance the pointer by 1 to write next byte
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
  	
  	# write max value into buffer
  	addi  $a0, $s4, 0		# transfer max value into ascii code
  	jal   itoa
  	add   $s6, $s6, $v0		# increase the header length by the string length we counted
  	li    $t0, 0x0A			# append '\n'
  	sb    $t0, 0($a1)
  	addiu $t7, $a1, 1		# advance the pointer by 1 and store it in $t7
  	addiu $s6, $s6, 1		# increase the header length by 1 for the white space
	
	# check the width we write
	#sub   $a1, $t7, $s6
	#li    $v0, 11
	#lb    $a0, 4($a1)
	#syscall
	
	
	
	# open file for write
	li    $v0, 13
	move  $a0, $s1			# restore the outputFile name
	li    $a1, 1             	# open for writing
	li    $a2, 0
	syscall
	
	move $a0, $v0           	# save the file descriptor in $a0
	
	bltz $a0, open_error    	# if open file fails (negative return value), go to open error
	
	# write header into the file
	li    $v0, 15
	sub   $a1, $t7, $s6     	# set string address for create header
	la    $a2, 0($s6)       	# header length
	syscall
	
	# write content into the file
	addi  $t0, $zero, 10         	# devider[base] - dec 10
	addi  $t1, $zero, 0		# $t1 = 0, count number of bytes written
	la    $t2, 12($s0)		# $t2 used to go through the array
	addi  $t5, $zero, 0		# t5 used to count number of ascii codes each time
	

content_loop:
	lb    $t3, 0($t2)		# load byte by byte
	
	# check the byte loaded
	#li    $v0, 11
	#addi  $a0, $t3, 48
	#syscall

convert_loop:	
	div   $t3, $t0
	mflo  $t3			# $t3 => quotient
	mfhi  $t4			# $t4 => remainder
	
	# each time, transfer the least significant bit to ascii
  	addi  $t4, $t4, 48         	# convert to ASCII (+48 ~ [eq 0])
	
	# since we don not know the actual number of bits in the number
  	# we need to borrow space from stack to store the ascii we get
  	addi  $sp, $sp, -1           	# make space for 1 byte in the stack
  	sb    $t4, 0($sp)            	# push $t2 in the stack
  	
  	# increase the number of digits counted
  	addi  $t5, $t5, 1            	# $t6++, count up
  	
  	
  	# if quotient($t4) is not equal zero, continue converting
  	bne   $t3, $zero, convert_loop
  	
  	# save the number of digits in $t7, will be used in write
  	#add   $t7, $zero, $t6 
 
convert_order:
  	# write byte by byte to file
  	li    $v0, 15
  	la    $a1, 0($sp)		# pop the last byte for the stack
  	addi  $a2, $zero, 1
  	syscall
  	
  	addiu $sp, $sp, 1            	# restore the stack size by 1 byte
  	
  	# if $t5 reaches 0, stop pop from stack
  	addi  $t5, $t5, -1		# $t6--, count down
  	bne   $t5, $zero, convert_order

	# append white space after the byte just write
	li    $v0, 15
  	la    $a1, space		# pop the last byte for the stack
  	addi  $a2, $zero, 1
  	syscall
  	
  	addi  $t2, $t2, 1		# advance the array pointer
  	addi  $t1, $t1, 1		# increase the number of bytes we write
  	
  	beq   $t1, $s5, end_loop
 
 	j    content_loop
	
end_loop:	
	# close file
	li   $v0, 16            	# system call for close file
					# $a0 already store file descriptor
	syscall                 	# close file
	
	j     end
itoa:
  	addi  $t0, $zero, 10         	# devider[base] - dec 10
  	add   $t1, $zero, $a0        	# $t1 = $a0
  	add   $t3, $zero, $zero      	# $t3 = 0, count number of digits
  	
itoa_loop:
  	div   $t1, $t0               	# $t1 / 10
  	mflo  $t1                    	# $t1 => quotient
  	mfhi  $t2                    	# $t2 => remainder
  	
  	# each time, transfer the least significant bit to ascii
  	addi  $t2, $t2, 48         	# convert to ASCII (+48 ~ [eq 0])
  	
  	# since we don not know the actual number of bits in the number
  	# we need to borrow space from stack to store the ascii we get
  	addi  $sp, $sp, -1           	# make space for 1 byte in the stack
  	sb    $t2, 0($sp)            	# push $t2 in the stack
  	
  	# increase the number of digits counted
  	addi  $t3, $t3, 1            	# $t3++, count up
  	
  	# if quotient($t1) is not equal zero, continue converting
  	bne   $t1, $zero, itoa_loop  
  	
  	# the procedure return the number of bits	
  	add   $v0, $zero, $t3        	# save string length in $v0
  	
  	# now we need to read back all the ascii codes stored in stack
itoa_order:
  	lb    $t1, 0($sp)            	# pop the last byte for the stack
  	addiu $sp, $sp, 1            	# restore the stack size by 1 byte
  	
  	sb    $t1, 0($a1)          	# save byte to the proper location of memory
  	addiu $a1, $a1, 1		# advance the pointer to store next byte
  	
  	# if $t3 reaches 0, we need to to restoring
  	addi  $t3, $t3, -1           	# $t3--, count down
  	bne   $t3, $zero, itoa_order 	# loop itoa_order unless all chars iterated	

	jr $ra		

open_error:                             
        li   $v0, 4			# print error message
	la   $a0, openError
	syscall	  
	
	j end		
	
end:
	lw $ra,0($sp)			# restore $ra and 
	addi $sp,$sp,4			# restore the stack

	jr $ra
