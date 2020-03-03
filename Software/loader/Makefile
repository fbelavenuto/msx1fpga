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

SHELL := /bin/bash

CP = cp
RM = rm -f
MD = mkdir
CC = sdcc
AS = sdasz80
LD = sdcc
H2B = hex2bin
ROMGEN = romgen
SRCAT = srec_cat
FILL = fillfile

SDIR = src
IDIR = inc
ODIR = obj

CFLAGS = -mz80 --opt-code-size --fomit-frame-pointer -I$(IDIR) -I..
LDFLAGS = -mz80 --code-loc 0x0100 --data-loc 0x4000 --no-std-crt0

_OBJS = crt0.rel main.rel mmc.rel fat.rel vdp.rel
OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

all: $(ODIR) loader

loader: loader.bin
	$(FILL) $< 8192
	$(SRCAT) $< --bin -o $@.mif --mif 8
	$(ROMGEN) $< ipl_rom a r > ../../src/rom/ipl_rom.vhd

loader.bin: loader.ihx

loader.ihx: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

.PHONY: clean

clean:
	$(RM) $(ODIR)/* *.map *.lk *.noi *.bin *.ihx

$(ODIR):
	$(MD) $(ODIR)

$(ODIR)/%.rel: $(SDIR)/%.S
	$(AS) -o $@ $<

$(ODIR)/%.rel: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.bin: %.ihx
	$(H2B) -e bin $<
