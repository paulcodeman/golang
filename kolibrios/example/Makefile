PROGRAM = example
GO_COMPILER_FLAGS = -m32 -c -nostdlib -nostdinc -fno-stack-protector -fno-split-stack -static -fno-leading-underscore -fno-common -fno-pie -g -ffunction-sections -fdata-sections -I.
GCC_COMPILER_FLAGS = -m32 -c -ffunction-sections -fdata-sections
ASM_COMPILER_FLAGS = -g -f elf32 -F dwarf
LDFLAGS = -n -T static.lds -m elf_i386 --no-ld-generated-unwind-info -z noexecstack -z relro -z now --gc-sections --entry=go_0example.Main
GO = gccgo
GCC = gcc
NASM = nasm $(ASM_COMPILER_FLAGS)
OBJCOPY = objcopy
OBJS = ../syscalls.o ../runtime.gcc.o colors.go.o colors.gox ../kos.go.o ../kos.gox $(PROGRAM).go.o

.PHONY: all clean link

all: $(OBJS) link

clean:
	rm -f $(OBJS) $(PROGRAM).kex

link:
	ld $(LDFLAGS) -o $(PROGRAM).kex $(OBJS)
	strip $(PROGRAM).kex
	$(OBJCOPY) $(PROGRAM).kex -O binary

# Правила для компиляции .go в .go.o
%.go.o: %.go
	$(GO) $(GO_COMPILER_FLAGS) -o $@ -c $<

# Генерация .gox из .go.o
%.gox: %.go.o
	$(OBJCOPY) -j .go_export $< $@

# Универсальные правила для компиляции .c и .asm
%.gcc.o: %.c
	$(GCC) $(GCC_COMPILER_FLAGS) $< -o $@

%.o: %.asm
	$(NASM) $< -o $@
