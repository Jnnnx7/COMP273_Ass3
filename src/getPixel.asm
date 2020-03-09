# Student ID = 1234567
##########################get pixel #######################
.data

error: 		.asciiz "Position out of image.\n"

.text
.globl get_pixel
get_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	################return##################
	# $v0 -> value of image at (row,column)
	#######################################
	# Add Code
	
	move $s0, $a0			# store struct address in $s0
	
	lw   $s1, 0($s0)		# save width in $s1
	lw   $s2, 4($s0)		# save height in $s2
	
	# check the width we get from the sturct
	#li   $v0, 1
	#add  $a0, $s1, $zero
	#syscall
	
	# check if the position is outside the image
	addi  $t0, $a2, 1		# check if the row number is larger than height
	blt   $s1, $t0, print_error
	
	addi  $t0, $a1, 1		# check if the column numbwe is larger than width
	blt   $s2, $t0, print_error
	
	# compute the actual position in array
	mult  $a1, $s1			# i * width + j + 1
	mflo  $s3
	add   $s3, $s3, $a2
	addi  $s3, $s3, 1
	
	# check the position we get 
	#li   $v0, 1
	#add  $a0, $s3, $zero
	#syscall
	
	# load the pixel from struct
	addi  $t0, $s3, 12		# compute the actual address
	add   $t0, $s0, $t0
	lb    $s4, 0($t0)
	
	# check the pixel we get 
	#li    $v0, 11
	#addi  $a0, $s4, 48
	#syscall
	
	# set the return value
	move  $v0, $s4	

	j     end
	
print_error:
	li   $v0, 4			# print error message
	la   $a0, error
	syscall	  

end:
	jr $ra
