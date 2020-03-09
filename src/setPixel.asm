# Student ID = 1234567
##########################set pixel #######################
.data

error: 		.asciiz "Position out of image.\n"

.text
.globl set_pixel
set_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	# $a3 -> new value (clipped at 255)
	###############return################
	#void
	# Add code here

	move $s0, $a0			# store struct address in $s0
	
	lw   $s1, 0($s0)		# save width in $s1
	lw   $s2, 4($s0)		# save height in $s2
	
	# check if the position is outside the image
	addi  $t0, $a2, 1		# check if the row number is larger than height
	blt   $s1, $t0, print_error
	
	addi  $t0, $a1, 1		# check if the column numbwe is larger than width
	blt   $s2, $t0, print_error
	
	# check if the input value is larger than 255
	addi  $t0, $zero, 255
	bgt   $t0, $a3, continue
	
	addi  $a3, $zero, 255 		# if larger than 255, set input to 255
	
continue:
	
	# check if input updated
	#li   $v0, 1
	#add  $a0, $a3, $zero
	#syscall
	
	# compute the actual position in array
	mult  $a1, $s1			# i * width + j + 1
	mflo  $s3
	add   $s3, $s3, $a2
	
	# set the pixel from struct
	addi  $t0, $s3, 12		# compute the actual address
	add   $t0, $s0, $t0
	sb    $a3, 0($t0)
	
	j     end
	


print_error:
	li   $v0, 4			# print error message
	la   $a0, error
	syscall
	
end:	

	jr $ra
