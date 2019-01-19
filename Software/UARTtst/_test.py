#!/usr/bin/python
# -*- coding: iso-8859-1 -*-

import serial

ser = serial.Serial('COM5', 115200)
print(ser.name)

while 1:
	a = 0
	while 1:
		b = ord(ser.read())
		if b == 255:
			break

	while 1:
		b = ord(ser.read())
		if a <> b:
			print "Expected",a," Readed",b
			break
		a=a+1
		if a==256:
			a=0
			#print "loop"
