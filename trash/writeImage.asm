# Student ID = 260834196
####################################write Image#####################
.data
header_length:		.word 0x13	# hard code max header length of 19

openError: 		.asciiz "Opening file failed.\n"

O_WRONLY:  		.word 0x0001    # open for writing only
O_CREAT:   		.word 0x0040    # create if nonexistent
P_0777:    		.word 0x01FF

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
	
	lw   $s2, 0($s0)		# save width in $s2
	lw   $s3, 4($s0)		# save height in $s3
	lw   $s4, 8($s0)		# save max value in $s4
	
	beqz $a3, write_P5		# check if the file is P5 or P2
	
write_P2:
	addi $t7, $zero, 0		# $t7 used to count the number of characters in header
	
	# allocate space for header
	li   $v0, 9			# syscall for sbrk (malloc)
	lw   $a0, header_length		# number of bytes to be allocated
	syscall
	
	move $a1, $v0			# save the address for header in $a1
					# allocated space is the buffer for writing
	
	# save type into buffer
  	li    $t0, 'P'
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	li    $t0, '2'
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 3
  	
  	# save width into buffer
  	move  $a0, $s2
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 1
	
	# save height into buffer
  	move  $a0, $s3
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 1
  	
  	# save max value into buffer
  	move  $a0, $s4
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x0A
  	sb    $t0, 0($a1)
  	addiu $t6, $a1, 1	# save the final address into $t6
  	addiu $t7, $t7, 1
  	
  	# open file for writing
  	li   $v0, 13            # system call for open file
  	move $a0, $s1		# load filename into $a0
	li   $a1, 1             # Open for writing
	li   $a2, 0
	syscall                 # open a file (file descriptor returned in $v0)
	
	move $a0, $v0		# save file descriptor in $a0
	
	bltz $v0, open_error    # if open file fails (negative return value), go to open error
	
	# write header to file
	li   $v0, 15            # system call for write to file
	sub  $a1, $t6, $t7	# get to the start of the buffer
	la   $a2, 0($s3)            # header length
	syscall

write_P5:
	addi $t7, $zero, 0		# $t7 used to count the number of characters in header
	
	# allocate space for header
	li   $v0, 9			# syscall for sbrk (malloc)
	lw   $a0, header_length		# number of bytes to be allocated
	syscall
	
	move $a1, $v0			# save the address for header in $a1
					# allocated space is the buffer for writing
	
	# save type into buffer
  	li    $t0, 'P'
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	li    $t0, '5'
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 3
  	
  	# save width into buffer
  	move  $a0, $s2
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 1
	
	# save height into buffer
  	move  $a0, $s3
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x20
  	sb    $t0, 0($a1)
  	addiu $a1, $a1, 1
  	addiu $t7, $t7, 1
  	
  	# save max value into buffer
  	move  $a0, $s4
  	jal   itoa
  	add   $t7, $t7, $v0
  	li    $t0, 0x0A
  	sb    $t0, 0($a1)
  	addiu $t6, $a1, 1	# save the final address into $t6
  	addiu $t7, $t7, 1
  	
  	# open file for writing
  	li   $v0, 13            # system call for open file
  	move $a0, $s1		# load filename into $a0
	#lw   $t0, O_WRONLY     # need only to write to file
  	#lw   $t1, O_CREAT      # if file not exist -> create
 	#or   $a1, $t0, $t1     # combine flags
 	li   $a1, 1
	lw   $a2, P_0777
	syscall                 # open a file (file descriptor returned in $v0)
	
	move $a0, $v0		# save file descriptor in $a0
	
	bltz $a0, open_error    # if open file fails (negative return value), go to open error
	
	# write header to file
	li   $v0, 15            # system call for write to file
	sub  $a1, $t6, $t7	# get to the start of the buffer
	la   $a2, 0($s3)            # header length
	syscall			
	
	j end
	
	
itoa:
  	addi  $t0, $zero, 10         	# devider[base] - dec 10
  	add   $t1, $zero, $a0        	# $t1 = $a0
  	add   $t3, $zero, $zero      	# $t3 = 0
itoa_loop:
  	div   $t1, $t0               	# $t1 / 10
  	mflo  $t1                    	# $t1 => quotient
  	mfhi  $t2                    	# $t2 => remainder
  	addi  $t2, $t2, 0x30         	# Convert to ASCII (+48 ~ [eq 0])
  	addi  $sp, $sp, -1           	# make space for 1 byte in the stack
  	sb    $t2, 0($sp)            	# push $t2 in the stack
  	addi  $t3, $t3, 1            	# $t3++ <count up>
  	bne   $t1, $zero, itoa_loop  	# if quotient($t1) is not equal zero loop
  	add   $v0, $zero, $t3        	# save string length
itoa_order:
  	lb    $t1, 0($sp)            	# pop the last byte for the stack
  	addiu $sp, $sp, 1            	# reduce the stack size by 1 byte
  	sb    $t1, 0($a1)          	# save byte to the proper location of memory
  	addiu $a1, $a1, 1
  	addi  $t3, $t3, -1           	# $t3--
  	bne   $t3, $zero, itoa_order 	# loop itoa_order unless all chars iterated

  	jr    $ra                    	# jump to caller
  	
 open_error:                             
        li   $v0, 4			# print error message
	la   $a0, openError
	syscall	  
	
	j end	

	
end:
	lw $ra,0($sp)			# restore $ra and 
	addi $sp,$sp,4			# restore the stack

	jr $ra
