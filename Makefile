# HOWTO: https://www.freebsd.org/doc/en/books/pmake/

targets = StaircaseMejorado Programa2

.PHONY: all
all: $(targets)

StaircaseMejorado-objs = StaircaseMejorado.o
StaircaseMejorado: $(StaircaseMejorado-objs)
objs += $(StaircaseMejorado-objs)

Programa2-objs = prog2.o jj.o y.o
Programa2: $(Programa2-objs)
objs += $(Programa2-objs)



$(targets):
	$(CC) $(LDFLAGS) -o $@ $($@-objs)

.PHONY: clean
clean:
	rm -f $(targets) $(objs)
