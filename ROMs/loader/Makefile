CP = copy
RM = rm -f
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

all: dir loader

loader: loader.bin
	$(FILL) $< 8192
#	$(SRCAT) $< --bin -o $@.mif --mif 8
#	$(ROMGEN) $< ipl_rom a r > ../../src/rom/ipl_rom.vhd

loader.bin: loader.ihx

loader.ihx: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

.PHONY: clean dir

clean:
	$(RM) $(ODIR)/* *.map *.lk *.noi *.bin *.ihx

dir:
	if not exist obj mkdir obj

$(ODIR)/%.rel: $(SDIR)/%.S
	$(AS) -o $@ $<

$(ODIR)/%.rel: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.bin: %.ihx
	$(H2B) -e bin $<
