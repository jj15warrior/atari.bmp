mads:
	cd Mad-Assembler; fpc -Mdelphi -vh -O3 mads.pas
mp:
	cd Mad-Pascal; $(MAKE) all

dirs: mads mp
	mkdir build
all: mads mp dirs

clean:
	rm -fr build
	cd Mad-Pascal; make clean
	cd Mad-Assembler; rm mads;
