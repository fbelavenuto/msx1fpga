
RM = rm -f

all: NEXTOR.ROM NEXTORH.ROM

clean:
	$(RM) *.ROM driver*.bin *.lst

NEXTOR.ROM: driver.bin

NEXTORH.ROM: driverH.bin

%.ROM: %.bin
	mknexrom Nextor-2.1.0.base.dat $@ /d:$< /m:Mapper.ASCII16.bin
	copy $@ ..\..\Support\SD\MSX1FPGA

driver.bin: driver.asm
	sjasmplus --nologo -DHWDS=0 --lst=driver.lst --raw=$@ $<

driverH.bin: driver.asm
	sjasmplus --nologo -DHWDS=1 --lst=driverH.lst --raw=$@ $<
