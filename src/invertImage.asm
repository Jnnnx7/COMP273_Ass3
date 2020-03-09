#Student ID = 1234567
#################################invert Image######################
.data
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	
	move  $s0, $a0			# store struct address in $s0
	
	lw    $s1, 0($s0)		# save width in $s1
	lw    $s2, 4($s0)		# save height in $s2
	lw    $s3, 8($s0)		# save max value in $s3
	
	# $s4 used to store the new max value
	addi  $s4, $zero, 0		# $s4 = 0
	
	# compute total number of pixels
	mult  $s1, $s2
	mflo  $s5			# store in $s5
	
	# invert byte by byte
	la    $t0, 12($s0)		# $t0 used to go through the array
	addi  $t1, $zero, 0		# count number of pixels inverted
	
invert:
	lb    $t2, 0($t0)		# load byte
	sub   $t3, $s3, $t2		# compute the inverted value
	sb    $t3, 0($t0)		# store the new value
	
	# check if max value need to be updated
	blt   $t3, $s4, next
	move  $s4, $t3
	
next:
	addi  $t1, $t1, 1		# increase the number of pixels updated
	beq   $t1, $s5, end		# if all pixels inverted, goto end
	
	addi  $t0, $t0, 1		# move to next pixel
	j     invert
	
end:
	sw    $s4, 8($s0)		# update new max value
	
	move  $v0, $s0			# set return value
	
	jr $ra
