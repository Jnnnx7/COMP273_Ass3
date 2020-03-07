#Student ID = 1234567
#########################Read Image#########################
.data

header_length:		.word 0x13	# hard code max header length of 19

# 2 kinds of errors
openError: 		.asciiz "Opening file failed.\n"
typeError:		.asciiz "Input PGM should be either P2 or P5.\n"

.text
		.globl read_image
	
	
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	addi $sp, $sp, -4		# create 4 bytes on the stack to save $ra
	sw   $ra, 0($sp)           	# since we will use nested procedures
	
	move $s0, $a0			# save the inputFile address into $s0
					# since $a0 will be used in syscall
	
	# allocate space for header
	li   $v0, 9			# syscall for sbrk (malloc)
	lw   $a0, header_length		# number of bytes to be allocated
	syscall
	
	move $s1, $v0			# save the address for header in $s1
					# allocated space is the buffer for reading
	
	# open file for the first time to read header
	li   $v0, 13            	# syscall for open file
	la   $a0, 0($s0)            	# reset pointer to filename
	li   $a1, 0             	# open for reading
	li   $a2, 0
	syscall                 	# open a file (file descriptor returned in $v0)
	
	bltz $v0, open_error    	# if open file fails (negative return value), go to open error
	
	move $a0, $v0			# save the file descriptor in $a0 for read & close
	
	# read header
	li   $v0, 14			# syscall for read file
	la   $a1, 0($s1)  		# address of buffer
	lw   $a2, header_length         # load binary - header length, max length to read
	syscall
	
	# close file
	li   $v0, 16            	# system call for close file
					# $a0 already store file descriptor
	syscall                 	# close file
	
	addi $s5, $zero, 0		# $s5 used to count the number of characters in header
					# will be used to jump the header to read contents later
	
	# read magic number, only P2 & P5
	lb    $t0, 1($s1)            	# load 2nd character of header - magic number
	bne   $t0, '2', check_5    	# check magic number - if not 2, then check 5
	j     continue			# else continue to read width
	
check_5:
	bne   $t0, '5', wrong_type    	# check magic number - if not 5, wrong pgm type
	
continue:
	# check the magic number we get
	#addi $t0, $t0, -48
	
	#li   $v0, 1
	#add  $a0, $zero, $t0
	#syscall
	
	addi $s5, $s5, 6		# increase the number of characters by 6
					# 6 = magic number (2) + 4 * Whitespace
	
	######## use of atoi ########
	# the width, height, and maximum gray value in the header
	# are all formatted as ASCII characters in decimal,
	# so we need to transform them into real integer value
	# http://netpbm.sourceforge.net/doc/pgm.html
	#############################
	
	# read width
	la    $a0, 3($s1)            	# set char pointer to width
  	jal   atoi                   	# convert ascii int
  	la    $t0, 0($a0)            	# save char pointer
  	add   $s5, $s5, $v1          	# add width length to counter
  	move  $s2, $v0               	# save width into $s2
  	
  	# check the width we get
  	#li   $v0, 1
	#add  $a0, $zero, $s2
	#syscall
	
	# read height
	la    $a0, 1($t0)            	# set char pointer to height
  	jal   atoi                   	# convert ascii int
  	la    $t0, 0($a0)            	# save char pointer
  	add   $s5, $s5, $v1          	# add height length to counter
  	move  $s3, $v0               	# save height into $s3
  	
  	# check the height we get
  	#li   $v0, 1
	#add  $a0, $zero, $s3
	#syscall

	# read max value
	la    $a0, 1($t0)            	# set char pointer to max value
  	jal   atoi                   	# convert ascii int
  	add   $s5, $s5, $v1          	# add max value length to counter
  	move  $s4, $v0               	# save max value to $s4
  	
  	# check the max value we get
  	#li   $v0, 1
	#add  $a0, $zero, $s4
	#syscall
	
	# check the length we get
	#li   $v0, 1
	#add  $a0, $zero, $s5
	#syscall

	# calculate the memory needed to for the contents
	mult  $s2, $s3               	# width * height = Hi and Lo registers
  	mflo  $s6  
  	                 	                 	
	# calculate the total space we need for struct
	# 3 int + char array = 3 * 4 + $s6
	addi $s6, $s6, 12
	
	# allocate space for struct
	li   $v0, 9
	add  $a0, $s6, $zero
	syscall
	
	move $s1, $v0			# save the address of the allocated memory to $s1
	
	# save width to first 4 bytes of the allocated memory
	sw   $s2, 0($s1)
	
	# save height to 5th-8th bytes of the allocated memory
	sw   $s3, 4($s1)
	
	# save max value to 9th-11th bytes of the allocated memory
	sw   $s4, 8($s1)
	
	# reopen the file to read content
	li   $v0, 13            	# syscall for open file
	la   $a0, 0($s0)            	# reset pointer to filename
	li   $a1, 0             	# open for reading
	li   $a2, 0
	syscall                 	# open a file (file descriptor returned in $v0)
	
	bltz $v0, open_error    	# if open file fails (negative return value), go to open error
	
	move $a0, $v0			# save the file descriptor in $a0 for read & close
	
	# read contents only into struct
	# read the header first, then read the contents
	# overwrite the header in buffer by contents
	
	addi $t0, $s6, -12		# will be used for $a2 in syscall of read
	#addi $t1, $zero, 3
	#mult $t0, $t1
	#mflo $t0
	
	li   $v0, 14			# syscall for read file
	la   $a1, 12($s1)            	# buffer address
	la   $a2, 0($s5)            	# length of header
	syscall
	
	li   $v0, 14
	la   $a2, 0($t0)		# length of contents
	syscall
	
	li   $v0, 16            	# system call for close file
					# $a0 already store file descriptor
	syscall                 	# close file
	
	# check the contents we get
	#li   $v0, 4              	# print out the content of the file
        #la   $a0, 12($s1)
        #syscall
	
	move $s1, $v0			# set the return value	
	
        j end
        
atoi:
  	li    $v0, 0                 	# set $v0 to $zero
  	li    $v1, 0                 	# set $v1 to $zero
  	li    $t1, 10                	# multiplyer - decimal 10
atoi_loop:
  	lb    $t0, 0($a0)            	# transfers one byte of data from buffer to a register.

  	blt   $t0, 0x30, atoi_end    	# if the ASCII code is less than 48 (ASCII of zero is 48) 
  	bgt   $t0, 0x39, atoi_end    	# if the ASCII code is greater than 57 (ASCII of nine is 57)
  					# end checking

  	addi  $v1, $v1, 1            	# increas the number of characters
  					# we will add the number in $v1 back to $s5 later

	# if there are more digits to read
	# we need to multiply the number stores in $v0 by 10
	# this way we can add the additional digit after current value stored
  	mult  $v0, $t1               	
  	mflo  $v0                    	
	
  	addi  $t0, $t0, -48          	# ascii numbers beginn at 48 for '0' ~ 57 for '9'
  	add   $v0, $v0, $t0          	# add to value

  	addiu $a0, $a0, 1            	# check next char
  	j     atoi_loop              	
atoi_end:
  	jr    $ra                    	# jump to caller
	
        

open_error:                             
        li   $v0, 4			# print error message
	la   $a0, openError
	syscall	  
	
	j end

wrong_type:
	li   $v0, 4			# print error message
	la   $a0, typeError
	syscall	  
	
	j end
	
end:	
	lw $ra,0($sp)			# restore $ra and 
	addi $sp,$sp,4			# restore the stack
	jr $ra
