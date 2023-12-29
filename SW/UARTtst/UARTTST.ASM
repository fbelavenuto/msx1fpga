;
;
;
	output UARTTST.BIN

; -----------------------------------------------------------
; Constants
CLOCK = 21429000
BAUDRATE = CLOCK / 115200

	db	#FE
	dw	start
	dw	end
	dw	start

	ORG	#9000

start:
	ld	a, #18
	out	(#C8), a
	ld	a, LOW BAUDRATE
	out	(#CA), a
	out	(#CC), a
	ld	a, HIGH BAUDRATE
	out	(#CB), a
	out	(#CD), a
	xor	a
loop:
	ld	b, a
wait:
	in	a, (#C8)
	and	#04
	jr	nz, wait
	ld	a, b
	out	(#CF), a
	inc	a
	jr	loop

end:
