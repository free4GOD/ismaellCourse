# HOWTO: https://www.freebsd.org/doc/en/books/pmake/

objs = printGraphicChar.o

.s.o:
	as -alhs=$(@:.o=.lst) -o $@ $<

run.com: $(objs)
	ld -Ttext 0x100 -o run.elf $(objs)
	objcopy -O binary -S run.elf run.com

.PHONY: run
run: run.com
	dosbox ./run.com

.PHONY: clean
clean:
	rm -f run.com run.elf $(objs)
