# Makefile for ACPI daemon
TOPDIR = $(shell pwd)

# our build config file
BUILD_CONFIG = $(TOPDIR)/BUILD_CONFIG

# project version
PRJ_VERSION = 0.5.0

# assign build options default values
# Use '?=' variable assignment so ENV variables can be used.

DEBUG ?= 1		# boolean
STATIC ?= 0		# option: 0=no, 1=yes, 2=partial
PROFILE ?= 0		# boolean
BUILD_MCE_DB ?= 0	# boolean

# assign any flags variables
# Use '+=' variable assignment so ENV variables can be used.

DEFS += -D_GNU_SOURCE
CWARNS += -Wundef -Wshadow
CFLAGS += -DBUILD_MCE_DB=$(BUILD_MCE_DB)
ifneq "$(BUILD_MCE_DB)" "0"
LDFLAGS += -ldb
endif

# include the generic rules
include $(TOPDIR)/Makerules.mk

INSTPREFIX =
BINDIR = $(INSTPREFIX)/usr/bin
SBINDIR = $(INSTPREFIX)/usr/sbin
MAN8DIR = $(INSTPREFIX)/usr/share/man/man8

SBIN_PROGS = mced
BIN_PROGS = mce_listen mce_decode
PROGS = $(SBIN_PROGS) $(BIN_PROGS)

mced_SRCS = mced.c rules.c ud_socket.c
mced_OBJS = $(mced_SRCS:.c=.o)

mce_listen_SRCS = mce_listen.c ud_socket.c
mce_listen_OBJS = $(mce_listen_SRCS:.c=.o)

mce_decode_SRCS = mce_decode.c
mce_decode_OBJS = $(mce_listen_SRCS:.c=.o)

MAN8 = mced.8 mce_listen.8 mce_decode.8
MAN8GZ = $(MAN8:.8=.8.gz)

#
# Our rules
#

all: $(PROGS)

mced: $(mced_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

mce_listen: $(mce_listen_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

man: $(MAN8)
	for a in $^; do gzip -f -9 -c $$a > $$a.gz; done

install: $(PROGS) man
	mkdir -p $(SBINDIR)
	mkdir -p $(BINDIR)
	install -m 750 mced $(SBINDIR)
	install -m 755 mce_listen $(BINDIR)
	mkdir -p $(MAN8DIR)
	install -m 644 $(MAN8GZ) $(MAN8DIR)

DISTTMP=/tmp
dist:
	rm -rf $(DISTTMP)/mced-$(VERSION)
	mkdir -p $(DISTTMP)/mced-$(VERSION)
	cp -a * $(DISTTMP)/mced-$(VERSION)
	find $(DISTTMP)/mced-$(VERSION) -type d -name CVS | xargs rm -rf
	make -C $(DISTTMP)/mced-$(VERSION) clean
	tar -C $(DISTTMP) -zcvf mced-$(VERSION).tar.gz mced-$(VERSION)
	rm -rf $(DISTTMP)/mced-$(VERSION)

clean:
	$(RM) $(PROGS) $(MAN8GZ) *.o

distclean:
	$(RM) $(BUILD_CONFIG)

.depend: $(mced_SRCS) $(mce_listen_SRCS)