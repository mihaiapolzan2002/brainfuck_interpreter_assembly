.data
	jumpTable:  # The jumptable
		.quad case0
		.skip 72
		.quad case0
		.skip 256 # skip the first 42 characters 
		.quad caseIncrease # case 43
		.quad caseInput # case 44
		.quad caseDecrease # case 45 
		.quad casePrint # case 46
		.skip 104 # skip the next 13 characters
		.quad casePrevious # case 60
		.skip 8 # skip the next character
		.quad caseNext
		.skip 224 # skip the next 28 characters
		.quad caseStartWhile
		.skip 8 # skip the next character
		.quad caseEndWhile

	array: 	.skip 32768
	brain: .asciz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
// .global brainfuck

.text 
	formatCh: .asciz "%c"
	formatNum: .asciz "%ld\n"
	format_str: .asciz "We should be executing the following code:\n%s"

.global main

	main:
	pushq %rbp
	movq %rsp, %rbp

	movq $brain, %rdi
	call brainfuck

	movq $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret
# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %r15

	movq $0, %r12 # the counter in the brainfuck code
	movq $0, %r14 # the pointer
mainLoop:

	movq $0, %rsi
	movq $0, %r13

	movb (%r15,%r12,1), %r13b # this is the current character

	movq %r13, %rax
	movq jumpTable(,%rax,8), %rax # load the address from the table
	jmp *%rax # call the subroutine; * is used when calling a subroutine whose address is into a register

postJump:
	// movq %r12, %rsi
	// movq $formatNum, %rdi
	// call printf

	incq %r12

	cmp $0, %r13b # stopping condition
	jne mainLoop

	movq %rbp, %rsp
	popq %rbp
	ret

case0:
	jmp postJump
caseIncrease:
	incq array(%r14)
	jmp postJump
caseDecrease:
	decq array(%r14)
	jmp postJump
casePrint:
	movq array(%r14), %rsi
	movq $formatCh, %rdi
	call printf
	jmp postJump
caseInput:
	movq $0, %rax
	movq $0,%rdi
	leaq array(%r14), %rsi
	movq $1, %rdx
	syscall
	jmp postJump
caseStartWhile:
	movq %r12, %rsi
	movq $formatNum, %rdi
	call printf
	movq $1, %rbx # the number of [

	cmpq $0, array(%r14)
	je skipInstructionsCase # if the pointer is 0, we need to skip the whole while
	pushq %r12
	jmp postJump

	skipInstructionsCase:
		incq %r12 # move the brainfuck pointer

		cmpb $91, (%r15,%r12,1) # this is the current character
		je caseOpenPharantesis
		cmpb $93, (%r15,%r12,1)
		je caseClosedPharantesis

		postSquaredParanthesis:
		cmpq $0, %rbx
		jne skipInstructionsCase
	
		jmp postJump
	
	caseOpenPharantesis:
		incq %rbx
		jmp postSquaredParanthesis
	caseClosedPharantesis:
		decq %rbx
		jmp postSquaredParanthesis

caseEndWhile:
	// movq %r12, %rsi
	// movq $formatNum, %rdi
	// call printf

	// popq %r12

	cmpq $0, array(%r14)
	jg differentZeroCase
	popq %r8

	jmp postJump
	differentZeroCase:
	movq (%rsp), %r12
	jmp postJump

casePrevious:
	decq %r14
	jmp postJump
caseNext:
	incq %r14
	jmp postJump
