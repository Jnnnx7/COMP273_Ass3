#Student ID = 260834196
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "test1.txt"
			.align 2
inputTest2:		.asciiz "test2.txt"
			.align 2
outputFile:		.asciiz "copy.pgm"
			.align 2
buffer:			.space 1024

# 3 kinds of errors
openError: 		.asciiz "Opening file failed.\n"
readError:		.asciiz "Reading file failed.\n"
writeError:		.asciiz "Writing file failed.\n"

header: 		.asciiz "P2\n24 7\n15\n"              #the header of pgm file

.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest2
	jal read_file
	
	la $a0,outputFile
	jal write_file
	
end: 	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
	# $a0 -> input filename	
	# Opens file
	# read file into buffer
	# return
	# Add code here
	
	li   $v0, 13            # system call for open file
	li   $a1, 0             # Open for reading
	li   $a2, 0
	syscall                 # open a file (file descriptor returned in $v0)
	
	move $s0, $v0           # save the file descriptor in $s0
	
	bltz $s0, open_error    # if open file fails (negative return value), go to open error
	
	li   $v0, 14            # system call for read from file
	move $a0, $s0           # file descriptor 
	la   $a1, buffer        # address of buffer to which to read
	li   $a2, 1024          # hardcoded buffer length
	syscall                 # read from file
	
	slt  $t0, $0, $v0       # if read file fails, go to read error
        beq  $t0, $0, read_error
        
        li   $v0,4              #print out the content of the file
        la   $a0, buffer
        syscall

	li   $v0, 16            # system call for close file
	move $a0, $s0           # file descriptor to close
	syscall                 # close file
	
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	# open file for writing
	# write following contents:
	# P2
	# 24 7
	# 15
	# write out contents read into buffer
	# close file
	# Add  code here
	
	li   $v0, 13            # system call for open file
	li   $a1, 1             # open for writing
	li   $a2, 0
	syscall                 # open a file (file descriptor returned in $v0)
	
	move $s0, $v0           # save the file descriptor in $s0
	
	bltz $s0, open_error    # if open file fails (negative return value), go to open error
	
	li   $v0, 15            # system call for write to file
  	move $a0, $s0           # file descriptor 
  	la   $a1, header        # address of buffer from which to write
  	li   $a2, 11            # hardcoded header length
  	syscall                 # write to file
  	
  	slt  $t0, $0, $v0       # if write file fails, go to write error
        beq  $t0, $0, write_error
        
        li   $v0, 15       	# system call for write to file
 	move $a0, $s0      	# file descriptor 
  	la   $a1, buffer   	# address of buffer from which to write
  	li   $a2, 1024       	# hardcoded buffer length
  	syscall            	# write to file
  	
  	slt  $t0, $0, $v0       # if write file fails, go to write error
        beq  $t0, $0, write_error
        
        li   $v0, 16            # system call for close file
	move $a0, $s0           # file descriptor to close
	syscall                 # close file
	
	jr $ra
	
open_error:                             
        
        li   $v0, 4
	la   $a0, openError
	syscall	  
	
	li   $v0, 16            # system call for close file
	move $a0, $s0           # file descriptor to close
	syscall                 # close file
	
	j end
	
read_error:

	li   $v0, 4
	la   $a0, readError
	syscall	  
	
	li   $v0, 16            # system call for close file
	move $a0, $s0           # file descriptor to close
	syscall                 # close file
	
	j end

write_error:

	li   $v0, 4
	la   $a0, writeError
	syscall	  
	
	li   $v0, 16            # system call for close file
	move $a0, $s0           # file descriptor to close
	syscall                 # close file
	
	j end
