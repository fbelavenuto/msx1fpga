
#
# Copyright (c) 2016 Fabio Belavenuto
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY#  without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

CP = cp
RM = rm -f
MD = mkdir
CC = sdcc
AS = sdasz80
LD = sdcc
ROMGEN = romgen
SRCAT = srec_cat
FILL = fillfile

SDIR = src
LDIR = ../msxclib/lib
IDIR = ../msxclib/inc
ODIR = obj

CFLAGS = -mz80 --disable-warning 85 --opt-code-size --fomit-frame-pointer -I$(IDIR) -Iinc -I..
ASFLAGS = -Iinc -I..
LDFLAGS = -mz80 --code-loc $(CODELOC) --data-loc $(DATALOC) --no-std-crt0

OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

define hex2bin
	objcopy -I ihex -O binary $(1) $(2)
endef

$(DESTNAME).COM: $(DESTNAME).ihx

$(DESTNAME).bin: $(DESTNAME).ihx

$(DESTNAME).ihx: $(ODIR) $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

.PHONY: clean

clean:
	$(RM) $(ODIR)/* *.map *.lk *.noi *.COM *.bin *.ihx *.mif

$(ODIR):
	$(MD) $(ODIR)

$(ODIR)/%.rel: $(SDIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(ODIR)/%.rel: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(ODIR)/%.rel: $(LDIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(ODIR)/%.rel: $(LDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.COM: %.ihx
	$(call hex2bin, $<, $@)

%.bin: %.ihx
	$(call hex2bin, $<, $@)
