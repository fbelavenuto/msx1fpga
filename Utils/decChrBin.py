#!/usr/bin/python

import sys
from PIL import Image, ImageDraw

if len(sys.argv) != 2:
	raise Exception('Error in parameters, see README.TXT')

f = open(sys.argv[1], "rb")
raw = f.read()
f.close

if len(raw) != 2048:
	raise Exception('File must be 2048 bytes in size.')

chars = []
for b in raw:
	chars.append(ord(b))

img = Image.new('RGB', (768, 768), color = (255, 255, 255))
draw = ImageDraw.Draw(img)

for i in range(16):
	draw.line([(0, 48*i), (767, 48*i)], fill=0)
	draw.line([(48*i, 0), (48*i, 767)], fill=0)
draw.line([(0, 767), (767, 767)], fill=0)
draw.line([(767, 0), (767, 767)], fill=0)

it = iter(chars)
for i in range(256):
	x = (i % 16) * 48 + 18
	y = (i / 16) * 48
	draw.text((x, y+2), "%0.2X" % i, fill=(255,0,0))
	y += 24
	draw.rectangle([x, y, x+15, y+15], fill=(0,255,0))
	for c in range(8):
		byte = next(it)
		for l in range(8):
			bit = byte & (0x80 >> l)
			if bit != 0:
				draw.rectangle([x+l*2, y+c*2, x+l*2+1, y+c*2+1], fill=0)

img.save('chars.png')
