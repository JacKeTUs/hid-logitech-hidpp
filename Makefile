KVERSION := `uname -r`
KDIR := /lib/modules/${KVERSION}/build
MY_CFLAGS += -g -DDEBUG

LSMOD_GREP = $(shell lsmod | grep "hid_logitech_hidpp")
LSUSB_GREP = $(shell lsusb | grep "Logitech, Inc. PRO Racing Wheel")


default:
	$(MAKE) -C $(KDIR) M=$$PWD modules

debug:
	$(MAKE) -C $(KDIR) M=$$PWD modules EXTRA_CFLAGS="$(MY_CFLAGS)"

install: default
	$(MAKE) -C $(KDIR) M=$$PWD modules_install
	depmod -A
	insmod ./hid-logitech-hidpp.ko

uninstall:
ifeq ($(LSMOD_GREP),)
	@echo "module not installed, doing nothing"; \
	exit 1
else
	@echo "hid_logitech_hidpp module is installed, attempting to remove"
endif

ifeq ($(LSUSB_GREP),)
	@echo "device unplugged, OK to continue"
else
	@echo "ERROR: device is still plugged in, DO NOT RMMOD!"
	exit 1
endif

	@echo "checking if superuser"

ifeq ($(shell id -u), 0)
	@echo "user is superuser, removing module"
	rmmod hid-logitech-hidpp
else
	@echo "ERROR: must uninstall as superuser"
	exit 1
endif

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

