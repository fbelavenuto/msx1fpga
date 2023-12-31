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

_OBJS = crt0.rel main.rel mmc.rel fat.rel vdp.rel

DESTNAME = loader
CODELOC = 0x0100
DATALOC = 0x2000

all: $(ODIR) loader

.PHONY:	loader

loader: $(DESTNAME).bin
	$(FILL) $< 8192
	$(SRCAT) $< --bin -o $@.mif --mif 8
	$(ROMGEN) $< ipl_rom a r e > ../../src/rom/ipl_rom.vhd

include ../makefile.inc
