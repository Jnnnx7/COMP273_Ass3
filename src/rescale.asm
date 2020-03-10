# Student ID = 1234567
###############################rescale image######################
.data
.text
.globl rescale_image
rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
	# Add Code
	
	move  $s0, $a0			# store struct address in $s0
	
	lw    $s1, 0($s0)		# save width in $s1
	lw    $s2, 4($s0)		# save height in $s2
	lw    $s3, 8($s0)		# save max value in $s3
	
	# check the width we get from the sturct
	#li   $v0, 1
	#add  $a0, $s3, $zero
	#syscall
	
	# compute total number of pixels
	mult  $s1, $s2
	mflo  $s4			# store in $s4
	
	# find min value, store in $s5
	add   $s5, $zero, $s3		# $s5 = max value first
	la    $t0, 12($s0)		# $t0 used to go through the array
	addi  $t1, $zero, 0		# count number of pixels checked

find_min:
	lb    $t2, 0($t0)		# load byte
	
	# check the byte we get
	#li    $v0, 1
	#move  $a0, $t2
	#syscall
	
	# if $t2 is less than $s5, update $s5
	bgt   $t2, $s5, check_next
	addiu $s5, $t2, 0
	
	# check the min value we update
	#li    $v0, 1
	#addi  $a0, $s5, 0
	#syscall
	
	# if min value reaches 0, end
	#beqz  $s5, end_find
	
check_next:
	addiu $t1, $t1, 1		# increase the number of pixels checked
	beq   $t1, $s4, end_find	# if all pixels checked, goto end
	
	addiu $t0, $t0, 1		# move to next pixel
	j     find_min

end_find:
	# check the min value we get
	#li    $v0, 1
	#addi  $a0, $s5, 0
	#syscall	
	
	# if min value = max, do nothing to the graph
	beq    $s3, $s5, end
	
	sub    $s6, $s3, $s5
	
	# check the result we get
	#li     $v0, 1
	#addi   $a0, $s6, 0
	#syscall
  	
  	# convert $s6 to single point float number
	mtc1  $s6, $f0
  	cvt.s.w $f0, $f0
  	
  	# check the float we get
  	#mtc1   $zero, $f2
  	#li     $v0, 2
  	#add.s   $f12, $f0, $f2
  	#syscall
  	
 	# rescale byte by byte
 	la    $t0, 12($s0)		# $t0 used to go through the array
	addi  $t1, $zero, 0		# count number of pixels inverted
	addi  $t2, $zero, 255		# save 255 for computing
	
 rescale:
 	lb    $t3, 0($t0)		# load byte
 	
 	# compute the rescaled value
 	sub   $t4, $t3, $s5		# x - min_value
 	
 	# if x is max value, directly load 255
check_max:
	bne   $t3, $s3, check_min
	addiu $t5, $zero, 255
	#lb    $t5, 0($t7)
	j     save
 	
 	# if x in min value, directly load 0
check_min: 	
 	bne   $t3, $s5, multiply
 	addi  $t5, $zero, 0
 	j     save
 	
multiply: 	
 	mult  $t4, $t2			# * 255
 	mflo  $t4			
 	
 	# convert $t4 to single point float number
 	mtc1  $t4, $f1
 	cvt.s.w $f1, $f1
 	
 	# check the float we get
 	#mtc1   $zero, $f2
  	#li     $v0, 2
  	#add.s   $f12, $f1, $f2
  	#syscall
  	
  	# convert $s6 to single point float number
	mtc1  $s6, $f0
  	cvt.s.w $f0, $f0
 	
 	div.s  $f2, $f1, $f0		# divide to get the new value
 	
 	# check the float we get
 	#mtc1   $zero, $f3
  	#li     $v0, 2
  	#add.s   $f12, $f2, $f3
  	#syscall
  	
  	# round to the nearest integer
  	round.w.s $f2, $f2
	mfc1   $t5, $f2            # moving the integer into $t5
	
	# check the integer we get
	#li    $v0, 1
	#addi  $a0, $t5, 0
	#syscall

save:	
	# store the rescaled value
	sb    $t5, 0($t0)
	
	# check the integer we store
	#li    $v0, 1
	#lb    $a0, 0($t0)
	#syscall
	
	addi  $t1, $t1, 1		# increase the number of pixels updated
	beq   $t1, $s4, end		# if all pixels inverted, goto end
	
	addi  $t0, $t0, 1		# move to next pixel
	j     rescale
	

end:	
	# update the max value to 255
	sw     $t2, 8($s0)
	
	move   $v0, $s0			# restore the return value

	jr $ra
