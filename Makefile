mads:
	cd Mad-Assembler
	fpc -Mdelphi -vh -O3 mads.pas
mp:
	cd Mad-Pascal
	fpc -MDelphi -vh -O3 mp.pas
dirs: mads mp
	mkdir buildtools
	cp Mad-Assembler/mads buildtools/
	cp Mad-Pascal/mp buildtools
all: mads mp dirs
