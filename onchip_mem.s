top:
	mvi		r2, 0x10	/* Address of red LEDs. */  
	mvhi	r2, 0x10       
	mvi		r3, 0x00	/* Address of switches. */
	mvhi	r3, 0x10
	mvi		r4, 0x20	/* Address of HEX Display. */
	mvhi	r4, 0x10
RESET:
	mvi 	r6, 0x00	/* Counter initialized to zero */
	mvhi	r6, 0x00
LOOP:
	ld		r7, r3		/* Read the state of switches. */
	st		r7, r2		/* Display the state on LEDs. */
	subi 	r7, 0x00
	jz 		DEFAULT

	add 	r7, r7		/* r7 = r7 x 2^16 */
	add 	r7, r7
	add 	r7, r7
	add 	r7, r7

	add 	r7, r7
	add 	r7, r7
	add 	r7, r7
	add 	r7, r7

	add 	r7, r7
	add 	r7, r7
	add 	r7, r7
	add 	r7, r7

	add 	r7, r7
	add 	r7, r7
	add 	r7, r7
	add 	r7, r7
DELAY:
	subi 	r7, 0x01
	jz		INC			/* increment counter if r7 is zero */
	j 		DELAY
INC:
	addi 	r6, 0x01
	st 		r6, r4		/* Display on hex */
	j		LOOP
DEFAULT:
	mvi 	r7, 0xFF
	mvhi 	r7, 0x00
	j 		DELAY