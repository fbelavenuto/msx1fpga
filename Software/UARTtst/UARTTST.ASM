;
;
;
	output UARTTST.BIN

; -----------------------------------------------------------
; Constants

	db	#FE
	dw	start
	dw	end
	dw	start

	ORG	#9000

start:
	ld	a, #18
	out	(#C8), a
	ld	a, #D0
	out	(#CA), a
	ld	a, #07
	out	(#CB), a
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
