
SHELL := cmd.exe
RM := rm -rf
TOOLCHAIN_PATH :=C:/Program Files (x86)/Atmel/AVR Studio 5.0/AVR ToolChain/bin/
COMMA :=,

DEVICE := atmega328
DEFS:= F_CPU=16000000


PROJ_NAME := serial_test
C_DEPS := 
LIBS := serial
LIB_DIR :=../../..

export C_OPTS := -O3 -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -g2 -Wall -std=gnu99 -mmcu=$(DEVICE)



SOURCES := $(PROJ_NAME).c
SOURCES += $(addsuffix .c,$(C_DEPS))

OBJS := $(SOURCES:%.c=%.o)

export DEFSTRING := $(addprefix -D,$(DEFS))
LIB_PATHS := $(foreach lib,$(LIBS),$(LIB_DIR)/$(lib))
INC_PATHS := $(addprefix -I,$(LIB_PATHS))
LINK_LIB_PATHS := $(addprefix -Wl$(COMMA)-L,$(LIB_PATHS))
LINK_LIBS := $(addprefix -Wl$(COMMA)-l,$(LIBS))



.PHONY: all libs $(LIB_PATHS) clean


all: $(PROJ_NAME).elf $(PROJ_NAME).hex size


$(PROJ_NAME).elf: $(OBJS)
	@echo Building target: $@
	$(TOOLCHAIN_PATH)avr-gcc.exe $(LINK_LIB_PATHS) -mmcu=$(DEVICE)  -o $(PROJ_NAME).elf  $(OBJS) $(LINK_LIBS)
	@echo Finished building target: $@


$(PROJ_NAME).hex: $(PROJ_NAME).elf
	@echo Building target: $@
	$(TOOLCHAIN_PATH)avr-objcopy.exe -O ihex -R .eeprom -R .fuse -R .lock -R .signature  $<  $@
	@echo Finished building target: $@


size: $(PROJ_NAME).elf
	@$(TOOLCHAIN_PATH)avr-size.exe -C --mcu=$(DEVICE) $(PROJ_NAME).elf


%.o: %.c libs
	@echo Building file: $<
	"$(TOOLCHAIN_PATH)avr-gcc.exe" $(C_OPTS) $(DEFSTRING) $(INC_PATHS) -o $@ -c $<
	@echo Finished building: $<



libs: $(LIB_PATHS)
	@echo Building libs.

$(LIB_PATHS):
	"$(TOOLCHAIN_PATH)make.exe" -C $@ -f "Makefile" all



clean:
	-$(RM) *.o $(PROJ_NAME).hex $(PROJ_NAME).elf

