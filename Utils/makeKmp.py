import sys

if len(sys.argv) != 3:
	raise Exception('Error in parameters, see README.TXT')

f = open(sys.argv[1], 'r')
t = f.readlines()
f.close

kmp = []
for i in range(512):
	kmp.append(255)
for i in range(420):
	kmp.append(0)

mode = 0
count = 512;

for i in t:
	if i[0] != ';' and i[0] != '\n':
		l = i[:-1]
		p = l.find(';')
		if p != -1:
			l = l[:p-1]
		if l == "[ROM]":
			mode = 1
			continue
		if l == "[PS2]":
			mode = 2
			continue
		if mode == 1:
			d = l.split(',')
			if len(d) < 6 and len(d) > 8:
				raise Exception('Error in section [ROM]: ', d)
			for c in d:
				v = 0;
				if c[0] == "$":
					v = int(c[1:], 16)
				if c[0] == '"':
					v = ord(c[1]);
				kmp[count] = v
				count += 1

		if mode == 2:
			d = l.split(',')
			if len(d) != 3:
				raise Exception('Error in section [PS2]: ', d)
			scancode = int(d[0], 16)
			col = int(d[1], 16)
			row = int(d[2], 16)
			if scancode < 0 or scancode > 511:
				raise Exception('Scancode range error: ', d[0])
			if col < 0 or col > 15:
				raise Exception('Col range error: ', d[0])
			if row < 0 or row > 15:
				raise Exception('Row range error: ', d[0])
			kmp[scancode] = col * 16 + row

f = open(sys.argv[2], 'wb')
f.write("".join(chr(i) for i in kmp))
f.close
print "File generated with no errors.\n"
