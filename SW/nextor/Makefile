
RM = rm -f
CP = cp

all: NEXTOR.ROM NEXTORH.ROM

clean:
	$(RM) *.ROM N*.bin *.lst

NEXTOR.ROM: NEXTOR.bin

NEXTORH.ROM: NEXTORH.bin

%.ROM: %.bin
	mknexrom Nextor-2.1.2.base.dat $@ /d:$< /m:Mapper.ASCII16.binc
	${CP} $@ ../../Support/SD/MSX1FPGA

NEXTOR.bin: driver.asm
	sjasmplus --nologo --define HWDS=0 --lst=NEXTOR.lst --raw=$@ $<

NEXTORH.bin: driver.asm
	sjasmplus --nologo --define HWDS=1 --lst=NEXTORH.lst --raw=$@ $<
