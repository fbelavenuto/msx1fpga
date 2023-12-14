
RM = rm -f
CP = cp

all: NEXTOR.ROM NEXTORH.ROM

clean:
	$(RM) *.ROM driver*.bin *.lst

NEXTOR.ROM: driver.bin

NEXTORH.ROM: driverH.bin

%.ROM: %.bin
	mknexrom Nextor-2.1.0.base.dat $@ /d:$< /m:Mapper.ASCII16.bin
	${CP} $@ ..\..\Support\SD\MSX1FPGA

driver.bin: driver.asm
	sjasmplus --nologo --define HWDS=0 --lst=driver.lst --raw=$@ $<

driverH.bin: driver.asm
	sjasmplus --nologo --define HWDS=1 --lst=driverH.lst --raw=$@ $<
