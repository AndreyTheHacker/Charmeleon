include defs.mk

all:
	mkdir build || true
	mkdir temps || true
	as --32 src/boot.s -o temps/boot.o
	python3 src/png2charmeleon.py image.png > image.c
	$(PREFIX)gcc $(CFLAGS) src/main.c -o temps/main.o
	$(PREFIX)gcc $(CFLAGS) image.c -o temps/image.o
	$(PREFIX)gcc $(CFLAGS) src/font.c -o temps/font.o
	$(PREFIX)gcc $(CFLAGS) src/font_parse.c -o temps/font_parse.o
	$(PREFIX)gcc $(CFLAGS) src/string.c -o temps/string.o
	$(PREFIX)gcc $(CFLAGS) src/random.c -o temps/random.o
	$(PREFIX)gcc $(CFLAGS) src/ports.c -o temps/ports.o
	$(PREFIX)gcc $(CFLAGS) src/rtc.c -o temps/rtc.o
	$(PREFIX)ld $(LDFLAGS) temps/boot.o temps/main.o temps/string.o temps/rtc.o temps/ports.o temps/random.o temps/font_parse.o temps/font.o temps/image.o -o build/main.bin
	#setup
	mkdir build/boot/grub/ -p || true
	cp src/grub.cfg build/boot/grub/grub.cfg
	grub-mkrescue build/ -o total.iso
	qemu-system-x86_64 -m 150M -s -cdrom total.iso

clean:
	rm build/* -r || true
	rm temps/* -r || true
	rm total.iso || true
	rm image.c || true

clean_nototal:
	rm build/* -r || true
	rm temps/* -r || true

install:	
	sudo cp build/main.bin /boot/charmeleon.bin # On my machine, add entries to grub.cfg
