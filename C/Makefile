# HOWTO: https://www.freebsd.org/doc/en/books/pmake/
prog = StaircaseMejorado.c
objs = StaircaseMejorado.o

$(prog): $(objs)
	$(CC) $(LDFLAGS) -o $@ $(objs)

.PHONY: clean
clean:
	rm -f $(prog) $(objs)
