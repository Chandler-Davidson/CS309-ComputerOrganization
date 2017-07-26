.global main
.func main

main:
	MOV R5, #500		@Gas in inventory (tenths)
	MOV R6, #22		@Price per gallon (cents)

StartLoop:
	MOV R7, #0		@Gas dispensed/sale

	/* Clear the screen */
	LDR R0, =cls
	BL printf

	/* Check current inventort */
	CMP R5, #0
	BLE Exit

	/* Prompt User */
	LDR R0, =strPrompt
	MOV R1, R5
	bl printf

	/* Get Char Input */
	LDR R0, =charInputPattern
	SUB sp, sp, #4
	MOV R1, sp
	bl scanf

	/* Clear Screen */
	LDR R0, =cls
	BL printf

	LDR R1, [sp, #0]	@ Load R1 after clearing
	ADD sp, sp, #4

	/* Check Input */
	CMP R1, #80	@ P - Cont.
	BEQ Continuous

	CMP R1, #83	@ S - Spec.
	BEQ Specific

	CMP R1, #65	@ A - Admin
	BEQ Admin

	B Default	@ Invalid input

Continuous:
	/* Check Inventory */
	CMP R5, #0
	BEQ Exit

	CMP R5, #9
	BLE SellByTenth

	/* Sell Whole Gallon */
	ADD R7, R7, #10		@Add gallon to sale
	SUB R5, R5, #10		@Remove gallon from total

	B FinishCont

SellByTenth:
	LDR R0, =strSellByTenth
	BL printf

	/* Sell Part of Gallon */
	ADD R7, R7, #1		@Add gallon to sale
	SUB R5, R5, #1		@Remove gallon from total

FinishCont:
	MOV R1, R7			@Print gallons sold
	MUL R2, R7, R6		@Find sale $
	LDR R0, =strTotal
	BL printf

	LDR R0, =strInputCont	@ "Continue Pumping?"
	BL printf

	/* Get Char Input */
	LDR R0, =charInputPattern
	SUB sp, sp, #4
	MOV R1, sp
	bl scanf
	LDR R1, [sp, #0]
	ADD sp, sp, #4

	/* Check Input */
	CMP R1, #89	@ Y
	BEQ Continuous

	CMP R1, #78	@ N
	BEQ StartLoop

	B Default 	@ Invalid Input

Specific:
	LDR R0, =strInputPre	@ "Enter dollar amount:"
	BL printf

	/* Get Num Input */
	LDR R0, =numInputPattern
	SUB sp, sp, #4
	MOV R1, sp
	bl scanf
	LDR R1, [sp, #0]
	ADD sp, sp, #4

	/* Compute # of gas for $ */
	LDR R7, =0xBA2E8BB		@ Compute how much gas
	UMULL R9, R7, R1, R7	@ through division

	/* Check if acceptable */
	SUB R8, R5, R7	@ NewInventory = Inventory - Sale
	CMP R8, #0
	BLE NotEnough	@Not enough gas for transaction

	/* Execute purchase */
	MOV R5, R8		@Update actual inventory	

	MOV R2, R1		@$ amount
	MOV R1, R7		@tenths of gas
	LDR R0, =strTotal
	BL printf

	B StartLoop

NotEnough:
	LDR R0, =strNotEnough
	BL printf
	B Specific

Default:
	LDR R0, =strInvalidInput
	BL printf
	B StartLoop

Admin:
	/* Print Totals */
	LDR R0, =strAdminTotal
	MOV R6, #500	@Starting gallons of gas
	SUB R1, R6, R5	@Total gallons sold
	MUL R2, R1, R6	@Total sales $
	BL printf

	/* Collect Input */
	LDR R0, =charInputPattern
	SUB sp, sp, #4
	MOV R1, sp
	bl scanf
	LDR R1, [sp, #0]
	ADD sp, sp, #4

	/* Check Input */
	CMP R1, #69	@ E
	BEQ StartLoop
	
	B Admin
	

Exit:
	LDR R0, =cls
	BL printf

	/* Print no gas */
	LDR R0, =strZReport	@"We're all out!"
	BL printf

	LDR R0, =strTotal
	MOV R6, #500	@Starting gallons of gas
	SUB R1, R6, R5	@Total gallons sold
	MUL R2, R1, R6	@Total sales $
	BL printf

	POP {LR}
	BX LR

.data
.balign 4
strPrompt:		.asciz "Welcome to gasoline pump.\nCurrent inventory of gasoline is:\n   Unleaded    %d (tenths of gallons)\n\nEnter P to start pumping gasoline OR \nS to enter dollar amount you want to dispense.\n"

.balign 4
strInputCont: 	.asciz "\n\nContinue pumping? (Y/N)\n"

.balign 4
strInputPre: 	.asciz "\n\nEnter the dollar amount you want: \n$"

.balign 4
strHidden: 		.asciz "Current Inventory:\n"

.balign 4
strTotal: 		.asciz "\nTotal Sales:\n   Unleaded: %d tenths of gallon\n   %d Cents\n"

.balign 4
strAdminTotal: 	.asciz "\n=====ADMIN Z REPORT=====\nTotal Sales:\n   Unleaded: %d tenths of gallon\n   %d Cents\n\nEnter E to escape\n"

.balign 4
strNotEnough:	.asciz "The amount entered > inventory.\n"

.balign 4
strSellByTenth: .asciz "Now selling by tenths of a gallon.\n"

.balign 4
strZReport: 	.asciz "\n\nWe're all out!\n=================================\nZ REPORT:\n"

.balign 4
charInputPattern: .asciz "%s"

.balign 4
numInputPattern:  .asciz "%d"

.balign 4
strInvalidInput: .asciz "Your input is invalid, restarting loop."

.balign 4
cls:		 	.asciz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

