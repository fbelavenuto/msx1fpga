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
H2B = hex2bin

SDIR = src
LDIR = ../../msxclib/lib
IDIR = ../../msxclib/inc
ODIR = obj

CFLAGS = -mz80 --opt-code-size --fomit-frame-pointer -I$(IDIR) -Iinc -I..
LDFLAGS = -mz80 --code-loc 0x0180 --data-loc 0 --no-std-crt0

_OBJS = crt0.rel conio.rel putchar.rel msxdos.rel getopt.rel main.rel
OBJS = $(patsubst %,$(ODIR)/%,$(_OBJS))

all: $(ODIR) MSXCTRL.COM

MSXCTRL.COM: MSXCTRL.ihx

MSXCTRL.ihx: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

.PHONY: clean

clean:
	$(RM) $(ODIR)/* *.map *.lk *.noi *.com *.ihx

$(ODIR):
	$(MD) $(ODIR)

$(ODIR)/%.rel: $(SDIR)/%.S
	$(AS) -o $@ $<

$(ODIR)/%.rel: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(ODIR)/%.rel: $(LDIR)/%.s
	$(AS) -o $@ $<

$(ODIR)/%.rel: $(LDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.COM: %.ihx
	$(H2B) -e COM $<
