# Booting Linux - prerequisites
To boot the images on Orange Pi Zero 3 contained in this directory you will need
a proper bootloader. Preferably u-boot from here:
https://github.com/Doct2O/orangepi-zero3-bl

To aviod kernel panic at the end of the boot (when switching to userspace)
besides dtb and kernel itself you'll need a rootfs. It may have many shapes
and forms, but for our little boot test, the most convinient will be use of
initrd (initial ram disk).
I can recommend buildroot for this task: 
https://buildroot.org/download.html

If you only want to test the boot itself, though, you can use rootfs generated 
in next section. Otherwise skip it.

### Building crude initrd only for boot test sake
If you want to quickly test kernel images from here, and you don't want to build
whole buildroot (this can take a while and be cumbersome sometime). 
You can create your own initrd by issuing following commands (requires root):
```
# Invoke two next lines, only if you don't have u-boot tools already.
# Tested on Ubuntu server LTS 22.04
sudo apt update
sudo apt install -y u-boot-tools

mkdir -p /tmp/rootfs/dev && cd /tmp/rootfs
wget https://github.com/polaco1782/linux-static-binaries/raw/master/armv8-aarch64/bash
chmod +x bash && mv bash init

sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1
sudo chown -R root:root init dev 

find | cpio --verbose -o -H newc -R root:root | gzip --best > rootfs.cpio.gz
mkimage -A arm64 -O linux -T ramdisk -C gzip -d rootfs.cpio.gz rootfs.cpio.uboot
```
Commands above will create very crude initrd in ```/tmp/rootfs/rootfs.cpio.uboot```.

# Booting from the card
If you have flashed bootloader along with the FAT32 partition from here:
https://github.com/Doct2O/orangepi-zero3-bl

All you need to do now is to copy: 
- Image 
- sun50i-h618-orangepi-zero3.dtb
- rootfs.cpio.uboot

To SD Card FAT partition as a regular files, and then execute in u-boot:

```
fatload mmc 0:1 0x42000000 Image
fatload mmc 0:1 0x46000000 rootfs.cpio.uboot
fatload mmc 0:1 0x41000000 sun50i-h618-orangepi-zero3.dtb
setenv bootargs "console=ttyS0,115200 earlycon loglevel=8 rootwait"
booti 0x42000000 0x46000000 0x41000000
```
After the last command the Linux should boot right away.


<details>
<summary>Expand for full boot log (custom initrd created by hand):</summary>

```
U-Boot SPL 2023.10-rc4-00039-g252592214f-dirty (Sep 11 2023 - 21:41:22 +0000)
DRAM: 1024 MiB
Trying to boot from MMC1
NOTICE:  BL31: v2.9(debug):v2.9.0-660-g88b2d8134
NOTICE:  BL31: Built : 17:56:15, Sep 11 2023
NOTICE:  BL31: Detected Allwinner H616 SoC (1823)
NOTICE:  BL31: Found U-Boot DTB at 0x4a0b2a38, model: OrangePi Zero3
INFO:    ARM GICv2 driver initialized
INFO:    Configuring SPC Controller
INFO:    PMIC: Probing AXP305 on RSB
ERROR:   RSB: set run-time address: 0x10003
INFO:    Could not init RSB: -65539
INFO:    BL31: Platform setup done
INFO:    BL31: Initializing runtime services
INFO:    BL31: cortex_a53: CPU workaround for erratum 855873 was applied
INFO:    BL31: cortex_a53: CPU workaround for erratum 1530924 was applied
INFO:    PSCI: Suspend is unavailable
INFO:    BL31: Preparing for EL3 exit to normal world
INFO:    Entry point address = 0x4a000000
INFO:    SPSR = 0x3c9
INFO:    Changed devicetree.


U-Boot 2023.10-rc4-00039-g252592214f-dirty (Sep 11 2023 - 21:41:22 +0000) Allwinner Technology

CPU:   Allwinner H616 (SUN50I)
Model: OrangePi Zero3
DRAM:  1 GiB
Core:  53 devices, 22 uclasses, devicetree: separate
WDT:   Not starting watchdog@30090a0
MMC:   mmc@4020000: 0
Loading Environment from FAT... OK
In:    serial@5000000
Out:   serial@5000000
Err:   serial@5000000
Allwinner mUSB OTG (Peripheral)
Net:   eth0: ethernet@5020000using musb-hdrc, OUT ep1out IN ep1in STATUS ep2in
MAC de:ad:be:ef:00:01
HOST MAC de:ad:be:ef:00:00
RNDIS ready
, eth1: usb_ether
=> setenv bootargs "console=ttyS0,115200 earlycon loglevel=8"
=> fatload mmc 0:1 0x42000000 Image
32322048 bytes read in 1341 ms (23 MiB/s)
=> fatload mmc 0:1 0x46000000 rootfs.cpio.uboot
828672 bytes read in 37 ms (21.4 MiB/s)
=> fatload mmc 0:1 0x41000000 sun50i-h618-orangepi-zero3.dtb
14872 bytes read in 2 ms (7.1 MiB/s)
=> booti 0x42000000 0x46000000 0x41000000
## Loading init Ramdisk from Legacy Image at 46000000 ...
   Image Name:
   Image Type:   AArch64 Linux RAMDisk Image (gzip compressed)
   Data Size:    828608 Bytes = 809.2 KiB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
## Flattened Device Tree blob at 41000000
   Booting using the fdt blob at 0x41000000
Working FDT set to 41000000
   Loading Ramdisk to 49f35000, end 49fff4c0 ... OK
   Loading Device Tree to 0000000049f2e000, end 0000000049f34a17 ... OK
Working FDT set to 49f2e000

Starting kernel ...

Booting Linux on physical CPU 0x0000000000 [0x410fd034]
Linux version 6.5.3 (ubuntu@ubuntu-server) (aarch64-linux-gnu-gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #1 SMP Mon Nov  6 12:09:59 UTC 2023
Machine model: OrangePi Zero3
earlycon: uart0 at MMIO32 0x0000000005000000 (options '115200n8')
printk: bootconsole [uart0] enabled
efi: UEFI not found.
OF: reserved mem: 0x0000000040000000..0x000000004003ffff (256 KiB) nomap non-reusable secmon@40000000
Zone ranges:
  DMA      [mem 0x0000000040000000-0x000000007fffffff]
  DMA32    empty
  Normal   empty
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x0000000040000000-0x000000004003ffff]
  node   0: [mem 0x0000000040040000-0x000000007fffffff]
Initmem setup node 0 [mem 0x0000000040000000-0x000000007fffffff]
cma: Reserved 64 MiB at 0x000000007ac00000
psci: probing for conduit method from DT.
psci: PSCIv1.1 detected in firmware.
psci: Using standard PSCI v0.2 function IDs
psci: MIGRATE_INFO_TYPE not supported.
psci: SMC Calling Convention v1.4
percpu: Embedded 29 pages/cpu s78952 r8192 d31640 u118784
pcpu-alloc: s78952 r8192 d31640 u118784 alloc=29*4096
pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
Detected VIPT I-cache on CPU0
alternatives: applying boot alternatives
Kernel command line: console=ttyS0,115200 earlycon loglevel=8
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes, linear)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes, linear)
Built 1 zonelists, mobility grouping on.  Total pages: 258048
mem auto-init: stack:off, heap alloc:off, heap free:off
software IO TLB: area num 4.
software IO TLB: mapped [mem 0x0000000076b80000-0x000000007ab80000] (64MB)
Memory: 862812K/1048576K available (17856K kernel code, 3020K rwdata, 5100K rodata, 5440K init, 725K bss, 120228K reserved, 65536K cma-reserved)
SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
trace event string verifier disabled
rcu: Hierarchical RCU implementation.
rcu:    RCU event tracing is enabled.
        Tracing variant of Tasks RCU enabled.
rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
Root IRQ handler: gic_handle_irq
GIC: Using split EOI/Deactivate mode
rcu: srcu_init: Setting srcu_struct sizes based on contention.
arch_timer: cp15 timer(s) running at 24.00MHz (phys).
clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x588fe9dc0, max_idle_ns: 440795202592 ns
sched_clock: 56 bits at 24MHz, resolution 41ns, wraps every 4398046511097ns
Console: colour dummy device 80x25
Calibrating delay loop (skipped), value calculated using timer frequency.. 48.00 BogoMIPS (lpj=96000)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048 (order: 2, 16384 bytes, linear)
Mountpoint-cache hash table entries: 2048 (order: 2, 16384 bytes, linear)
cacheinfo: Unable to detect cache hierarchy for CPU 0
RCU Tasks Trace: Setting shift to 2 and lim to 1 rcu_task_cb_adjust=1.
rcu: Hierarchical SRCU implementation.
rcu:    Max phase no-delay instances is 1000.
EFI services will not be available.
smp: Bringing up secondary CPUs ...
Detected VIPT I-cache on CPU1
CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
Detected VIPT I-cache on CPU2
CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
Detected VIPT I-cache on CPU3
CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
smp: Brought up 1 node, 4 CPUs
SMP: Total of 4 processors activated.
CPU features: detected: 32-bit EL0 Support
CPU features: detected: CRC32 instructions
CPU: All CPU(s) started at EL2
alternatives: applying system-wide alternatives
devtmpfs: initialized
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
futex hash table entries: 1024 (order: 4, 65536 bytes, linear)
pinctrl core: initialized pinctrl subsystem
DMI not present or invalid.
NET: Registered PF_NETLINK/PF_ROUTE protocol family
DMA: preallocated 128 KiB GFP_KERNEL pool for atomic allocations
DMA: preallocated 128 KiB GFP_KERNEL|GFP_DMA pool for atomic allocations
DMA: preallocated 128 KiB GFP_KERNEL|GFP_DMA32 pool for atomic allocations
thermal_sys: Registered thermal governor 'fair_share'
thermal_sys: Registered thermal governor 'bang_bang'
thermal_sys: Registered thermal governor 'step_wise'
cpuidle: using governor ladder
cpuidle: using governor menu
hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
ASID allocator initialised with 65536 entries
platform 3001000.clock: Fixed dependency cycle(s) with /soc/rtc@7000000
platform 7010000.clock: Fixed dependency cycle(s) with /soc/rtc@7000000
Modules: 24688 pages in range for non-PLT usage
Modules: 516208 pages in range for PLT usage
iommu: Default domain type: Translated
iommu: DMA domain TLB invalidation policy: strict mode
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
mc: Linux media interface: v0.10
videodev: Linux video capture interface: v2.00
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
Advanced Linux Sound Architecture Driver Initialized.
Bluetooth: Core ver 2.22
NET: Registered PF_BLUETOOTH protocol family
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP socket layer initialized
Bluetooth: SCO socket layer initialized
clocksource: Switched to clocksource arch_sys_counter
FS-Cache: Loaded
NET: Registered PF_INET protocol family
IP idents hash table entries: 16384 (order: 5, 131072 bytes, linear)
tcp_listen_portaddr_hash hash table entries: 512 (order: 1, 8192 bytes, linear)
Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)
TCP established hash table entries: 8192 (order: 4, 65536 bytes, linear)
TCP bind hash table entries: 8192 (order: 6, 262144 bytes, linear)
TCP: Hash tables configured (established 8192 bind 8192)
UDP hash table entries: 512 (order: 2, 16384 bytes, linear)
UDP-Lite hash table entries: 512 (order: 2, 16384 bytes, linear)
NET: Registered PF_UNIX/PF_LOCAL protocol family
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp-with-tls transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
Unpacking initramfs...
Initialise system trusted keyrings
workingset: timestamp_bits=46 max_order=18 bucket_order=0
squashfs: version 4.0 (2009/01/31) Phillip Lougher
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
nfs4filelayout_init: NFSv4 File Layout Driver Registering...
Freeing initrd memory: 808K
nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
Key type cifs.idmap registered
fuse: init (API version 7.38)
SGI XFS with ACLs, security attributes, no debug enabled
NET: Registered PF_ALG protocol family
Key type asymmetric registered
Asymmetric key parser 'x509' registered
Asymmetric key parser 'pkcs8' registered
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 246)
io scheduler mq-deadline registered
io scheduler bfq registered
Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
loop: module loaded
zram: Added device: zram0
wireguard: WireGuard 1.0.0 loaded. See www.wireguard.com for information.
wireguard: Copyright (C) 2015-2019 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
tun: Universal TUN/TAP device driver, 1.6
Broadcom 43xx driver loaded [ Features: NLS ]
usbcore: registered new interface driver rt2800usb
usbcore: registered new device driver r8152-cfgselector
usbcore: registered new interface driver r8152
usbcore: registered new interface driver asix
usbcore: registered new interface driver ax88179_178a
usbcore: registered new interface driver cdc_ether
usbcore: registered new interface driver cdc_eem
usbcore: registered new interface driver net1080
usbcore: registered new interface driver cdc_subset
usbcore: registered new interface driver zaurus
usbcore: registered new interface driver cdc_ncm
usbcore: registered new interface driver r8153_ecm
usbcore: registered new interface driver cdc_acm
cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
usbcore: registered new interface driver usblp
usbcore: registered new interface driver cdc_wdm
usbcore: registered new interface driver uas
usbcore: registered new interface driver usb-storage
usbcore: registered new interface driver ch341
usbserial: USB Serial support registered for ch341-uart
usbcore: registered new interface driver cp210x
usbserial: USB Serial support registered for cp210x
usbcore: registered new interface driver ftdi_sio
usbserial: USB Serial support registered for FTDI USB Serial Device
usbcore: registered new interface driver pl2303
usbserial: USB Serial support registered for pl2303
vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 1
vhci_hcd: created sysfs vhci_hcd.0
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.05
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: USB/IP Virtual Host Controller
usb usb1: Manufacturer: Linux 6.5.3 vhci_hcd
usb usb1: SerialNumber: vhci_hcd.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 2
usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 6.05
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: USB/IP Virtual Host Controller
usb usb2: Manufacturer: Linux 6.5.3 vhci_hcd
usb usb2: SerialNumber: vhci_hcd.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 8 ports detected
usbcore: registered new device driver usbip-host
mousedev: PS/2 mouse device common for all mice
sun6i-rtc 7000000.rtc: registered as rtc0
sun6i-rtc 7000000.rtc: setting system clock to 1970-01-02T00:00:30 UTC (86430)
sun6i-rtc 7000000.rtc: RTC enabled
i2c_dev: i2c /dev entries driver
mv64xxx_i2c 7081400.i2c: can't get pinctrl, bus recovery not supported
i2c 0-0036: Fixed dependency cycle(s) with /soc/pinctrl@300b000
IR JVC protocol handler initialized
IR MCE Keyboard/mouse protocol handler initialized
IR NEC protocol handler initialized
IR RC5(x/sz) protocol handler initialized
IR RC6 protocol handler initialized
IR SANYO protocol handler initialized
IR Sharp protocol handler initialized
IR Sony protocol handler initialized
IR XMP protocol handler initialized
usbcore: registered new interface driver uvcvideo
sunxi-wdt 30090a0.watchdog: Watchdog enabled (timeout=16 sec, nowayout=0)
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.48.0-ioctl (2023-03-01) initialised: dm-devel@redhat.com
Bluetooth: HCI UART driver ver 2.3
Bluetooth: HCI UART protocol H4 registered
Bluetooth: HCI UART protocol Broadcom registered
ledtrig-cpu: registered to indicate activity on CPUs
SMCCC: SOC_ID: ID = jep106:091e:1823 Revision = 0x00000002
hid: raw HID events driver (C) Jiri Kosina
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
hw perfevents: enabled with armv8_cortex_a53 PMU driver, 7 counters available
gnss: GNSS driver registered with major 242
usbcore: registered new interface driver snd-usb-audio
GACT probability NOT on
ipip: IPv4 and MPLS over IPv4 tunneling driver
Initializing XFRM netlink socket
NET: Registered PF_INET6 protocol family
Segment Routing with IPv6
In-situ OAM (IOAM) with IPv6
sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
bpfilter: Loaded bpfilter_umh pid 89
NET: Registered PF_PACKET protocol family
NET: Registered PF_KEY protocol family
Bridge firewalling registered
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM ver 1.11
Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Bluetooth: BNEP filters: protocol multicast
Bluetooth: BNEP socket layer initialized
Bluetooth: HIDP (Human Interface Emulation) ver 1.2
Bluetooth: HIDP socket layer initialized
l2tp_core: L2TP core driver, V2.0
l2tp_netlink: L2TP netlink interface
8021q: 802.1Q VLAN Support v1.8
Key type dns_resolver registered
registered taskstats version 1
Loading compiled-in X.509 certificates
Key type .fscrypt registered
Key type fscrypt-provisioning registered
Key type encrypted registered
gpio gpiochip0: Static allocation of GPIO base is deprecated, use dynamic allocation.
sun50i-h616-pinctrl 300b000.pinctrl: initialized sunXi PIO driver
gpio gpiochip1: Static allocation of GPIO base is deprecated, use dynamic allocation.
sun50i-h616-r-pinctrl 7022000.pinctrl: initialized sunXi PIO driver
sun50i-h616-pinctrl 300b000.pinctrl: request() failed for pin 224
sun50i-h616-pinctrl 300b000.pinctrl: pin-224 (5000000.serial) status -517
sun50i-h616-pinctrl 300b000.pinctrl: could not request pin 224 (PH0) from group PH0  on device 300b000.pinctrl
dw-apb-uart 5000000.serial: Error applying setting, reverse things back
sun50i-h616-pinctrl 300b000.pinctrl: request() failed for pin 64
sun50i-h616-pinctrl 300b000.pinctrl: pin-64 (5010000.spi) status -517
sun50i-h616-pinctrl 300b000.pinctrl: could not request pin 64 (PC0) from group PC0  on device 300b000.pinctrl
sun6i-spi 5010000.spi: Error applying setting, reverse things back
axp20x-i2c 0-0036: AXP20x variant AXP313a found
axp20x-i2c 0-0036: AXP20X driver loaded
sunxi-mmc 4020000.mmc: Got CD GPIO
printk: console [ttyS0] disabled
5000000.serial: ttyS0 at MMIO 0x5000000 (irq = 293, base_baud = 1500000) is a 16550A
sunxi-mmc 4020000.mmc: initialized, max. request size: 16384 KB, uses new timings mode
printk: console [ttyS0] enabled
printk: console [ttyS0] enabled
printk: bootconsole [uart0] disabled
printk: bootconsole [uart0] disabled
sun6i-spi 5010000.spi: Failed to request TX DMA channel
sun6i-spi 5010000.spi: Failed to request RX DMA channel
dwmac-sun8i 5020000.ethernet: IRQ eth_wake_irq not found
dwmac-sun8i 5020000.ethernet: IRQ eth_lpi not found
dwmac-sun8i 5020000.ethernet: PTP uses main clock
dwmac-sun8i 5020000.ethernet: Current syscon value is not the default 51fe6 (expect 0)
dwmac-sun8i 5020000.ethernet: No HW DMA feature register supported
dwmac-sun8i 5020000.ethernet: RX Checksum Offload Engine supported
dwmac-sun8i 5020000.ethernet: COE Type 2
dwmac-sun8i 5020000.ethernet: TX Checksum insertion supported
dwmac-sun8i 5020000.ethernet: Normal descriptors
dwmac-sun8i 5020000.ethernet: Chain mode enabled
usb_phy_generic usb_phy_generic.1.auto: dummy supplies not allowed for exclusive requests
mmc0: host does not support reading read-only switch, assuming write-enable
ehci-platform 5200000.usb: EHCI Host Controller
ohci-platform 5200400.usb: Generic Platform OHCI controller
cfg80211: Loading compiled-in X.509 certificates for regulatory database
ohci-platform 5200400.usb: new USB bus registered, assigned bus number 3
ohci-platform 5200400.usb: irq 298, io mem 0x05200400
Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
clk: Disabling unused clocks
ALSA device list:
  #0: Dummy 1
  #1: Loopback 1
platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
cfg80211: failed to load regulatory.db
mmc0: new high speed SDXC card at address 0001
ehci-platform 5200000.usb: new USB bus registered, assigned bus number 4
mmcblk0: mmc0:0001 SD128 116 GiB
ehci-platform 5200000.usb: irq 297, io mem 0x05200000
 mmcblk0: p1
ehci-platform 5200000.usb: USB 2.0 started, EHCI 1.00
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001, bcdDevice= 6.05
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: Generic Platform OHCI controller
usb usb3: Manufacturer: Linux 6.5.3 ohci_hcd
usb usb3: SerialNumber: 5200400.usb
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 1 port detected
usb usb4: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.05
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: EHCI Host Controller
usb usb4: Manufacturer: Linux 6.5.3 ehci_hcd
usb usb4: SerialNumber: 5200000.usb
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 1 port detected
Freeing unused kernel memory: 5440K
Run /init as init process
  with arguments:
    /init
  with environment:
    HOME=/
    TERM=linux
init: cannot set terminal process group (-1): Not a tty
init: no job control in this shell
init-4.4# echo *
dev init root rootfs.cpio.gz
init-4.4#
```
</details>

# Booting through network via ad hoc tftp server
This requires a bit more of preparation, but is way more convinient for testing.

- First connect the board to the PC via ethernet cord
- Set the IP of the network card to, for example: 192.168.100.5/24
- Install python3:
```
sudo apt install -y python3 python3-pip
```
Or for windows from:
https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe
- Install py3tftp package via python's pip3:
```
pip3 install py3tftp
# or
pip install py3tftp
```
- Navigate to say ```/tmp```, copy there:
  * Image 
  * sun50i-h618-orangepi-zero3.dtb
  * rootfs.cpio.uboot
- Start the tftp server there (in ```/tmp```) by (this will expose files from
current dir via tftp):
```
py3tftp --host 192.168.100.5 -p 69 --ack-timeout 2 --conn-timeout 10
# or 
python -m py3tftp --host 192.168.100.5 -p 69 --ack-timeout 2 --conn-timeout 10
# or
sudo py3tftp --host 192.168.100.5 -p 69 --ack-timeout 2 --conn-timeout 10
# or
sudo python -m py3tftp --host 192.168.100.5 -p 69 --ack-timeout 2 --conn-timeout 10
```
Depending on whichever works for you (Linux will require sudo to open ports below 1024).
- Once done, move to the u-boot serial console and invoke:
```
setenv ipaddr 192.168.100.2
setenv serverip 192.168.100.5
tftp 0x42000000 Image
tftp 0x46000000 rootfs.cpio.uboot
tftp 0x41000000 sun50i-h618-orangepi-zero3.dtb
setenv bootargs "console=ttyS0,115200 earlycon loglevel=8"
booti 0x42000000 0x46000000 0x41000000
```
If tftp command fails for you, and the amber LED on the board's ethernet socket
is not shining/blinking, it is the most probably problem with eth link speed
autonegotiation. 
You can fix it by invoking on Linux:
```
sudo ethtool -s <interface> autoneg on speed 100 duplex full
```
On windows it can be changed in Devices Manager properities of the card. 
In advanced tab, search something like ```Speed and duplex``` and pick there
```100 Mbps Full Duplex```.

The board should boot right away:
<details>
<summary>Expand for full boot log (custom initrd created by hand):</summary>

```

U-Boot SPL 2023.10-rc4-00039-g252592214f-dirty (Sep 11 2023 - 21:41:22 +0000)
DRAM: 1024 MiB
Trying to boot from MMC1
NOTICE:  BL31: v2.9(debug):v2.9.0-660-g88b2d8134
NOTICE:  BL31: Built : 17:56:15, Sep 11 2023
NOTICE:  BL31: Detected Allwinner H616 SoC (1823)
NOTICE:  BL31: Found U-Boot DTB at 0x4a0b2a38, model: OrangePi Zero3
INFO:    ARM GICv2 driver initialized
INFO:    Configuring SPC Controller
INFO:    PMIC: Probing AXP305 on RSB
ERROR:   RSB: set run-time address: 0x10003
INFO:    Could not init RSB: -65539
INFO:    BL31: Platform setup done
INFO:    BL31: Initializing runtime services
INFO:    BL31: cortex_a53: CPU workaround for erratum 855873 was applied
INFO:    BL31: cortex_a53: CPU workaround for erratum 1530924 was applied
INFO:    PSCI: Suspend is unavailable
INFO:    BL31: Preparing for EL3 exit to normal world
INFO:    Entry point address = 0x4a000000
INFO:    SPSR = 0x3c9
INFO:    Changed devicetree.


U-Boot 2023.10-rc4-00039-g252592214f-dirty (Sep 11 2023 - 21:41:22 +0000) Allwinner Technology

CPU:   Allwinner H616 (SUN50I)
Model: OrangePi Zero3
DRAM:  1 GiB
Core:  53 devices, 22 uclasses, devicetree: separate
WDT:   Not starting watchdog@30090a0
MMC:   mmc@4020000: 0
Loading Environment from FAT... OK
In:    serial@5000000
Out:   serial@5000000
Err:   serial@5000000
Allwinner mUSB OTG (Peripheral)
Net:   eth0: ethernet@5020000using musb-hdrc, OUT ep1out IN ep1in STATUS ep2in
MAC de:ad:be:ef:00:01
HOST MAC de:ad:be:ef:00:00
RNDIS ready
, eth1: usb_ether
=> setenv ipaddr 192.168.100.2
=> setenv serverip 192.168.100.5
=> tftp 0x42000000 Image
Using ethernet@5020000 device
TFTP from server 192.168.1.5; our IP address is 192.168.1.2
Filename 'Image'.
Load address: 0x42000000
Loading: #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         ############################################T #####################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #################################################################
         #########################################################
         2.6 MiB/s
done
Bytes transferred = 32322048 (1ed3200 hex)
=> tftp 0x46000000 rootfs.cpio.uboot
Using ethernet@5020000 device
TFTP from server 192.168.1.5; our IP address is 192.168.1.2
Filename 'rootfs.cpio.uboot'.
Load address: 0x46000000
Loading: #########################################################
         4.6 MiB/s
done
Bytes transferred = 828672 (ca500 hex)
=> tftp 0x41000000 sun50i-h618-orangepi-zero3.dtb
Using ethernet@5020000 device
TFTP from server 192.168.1.5; our IP address is 192.168.1.2
Filename 'sun50i-h618-orangepi-zero3.dtb'.
Load address: 0x41000000
Loading: ##
         2.4 MiB/s
done
Bytes transferred = 14872 (3a18 hex)
=> setenv bootargs "console=ttyS0,115200 earlycon loglevel=8"
=> booti 0x42000000 0x46000000 0x41000000
## Loading init Ramdisk from Legacy Image at 46000000 ...
   Image Name:
   Image Type:   AArch64 Linux RAMDisk Image (gzip compressed)
   Data Size:    828608 Bytes = 809.2 KiB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
## Flattened Device Tree blob at 41000000
   Booting using the fdt blob at 0x41000000
Working FDT set to 41000000
   Loading Ramdisk to 49f35000, end 49fff4c0 ... OK
   Loading Device Tree to 0000000049f2e000, end 0000000049f34a17 ... OK
Working FDT set to 49f2e000

Starting kernel ...

Booting Linux on physical CPU 0x0000000000 [0x410fd034]
Linux version 6.5.3 (ubuntu@ubuntu-server) (aarch64-linux-gnu-gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #1 SMP Mon Nov  6 12:09:59 UTC 2023
Machine model: OrangePi Zero3
earlycon: uart0 at MMIO32 0x0000000005000000 (options '115200n8')
printk: bootconsole [uart0] enabled
efi: UEFI not found.
OF: reserved mem: 0x0000000040000000..0x000000004003ffff (256 KiB) nomap non-reusable secmon@40000000
Zone ranges:
  DMA      [mem 0x0000000040000000-0x000000007fffffff]
  DMA32    empty
  Normal   empty
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x0000000040000000-0x000000004003ffff]
  node   0: [mem 0x0000000040040000-0x000000007fffffff]
Initmem setup node 0 [mem 0x0000000040000000-0x000000007fffffff]
cma: Reserved 64 MiB at 0x000000007ac00000
psci: probing for conduit method from DT.
psci: PSCIv1.1 detected in firmware.
psci: Using standard PSCI v0.2 function IDs
psci: MIGRATE_INFO_TYPE not supported.
psci: SMC Calling Convention v1.4
percpu: Embedded 29 pages/cpu s78952 r8192 d31640 u118784
pcpu-alloc: s78952 r8192 d31640 u118784 alloc=29*4096
pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3
Detected VIPT I-cache on CPU0
alternatives: applying boot alternatives
Kernel command line: console=ttyS0,115200 earlycon loglevel=8
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes, linear)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes, linear)
Built 1 zonelists, mobility grouping on.  Total pages: 258048
mem auto-init: stack:off, heap alloc:off, heap free:off
software IO TLB: area num 4.
software IO TLB: mapped [mem 0x0000000076b80000-0x000000007ab80000] (64MB)
Memory: 862812K/1048576K available (17856K kernel code, 3020K rwdata, 5100K rodata, 5440K init, 725K bss, 120228K reserved, 65536K cma-reserved)
SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
trace event string verifier disabled
rcu: Hierarchical RCU implementation.
rcu:    RCU event tracing is enabled.
        Tracing variant of Tasks RCU enabled.
rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
Root IRQ handler: gic_handle_irq
GIC: Using split EOI/Deactivate mode
rcu: srcu_init: Setting srcu_struct sizes based on contention.
arch_timer: cp15 timer(s) running at 24.00MHz (phys).
clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x588fe9dc0, max_idle_ns: 440795202592 ns
sched_clock: 56 bits at 24MHz, resolution 41ns, wraps every 4398046511097ns
Console: colour dummy device 80x25
Calibrating delay loop (skipped), value calculated using timer frequency.. 48.00 BogoMIPS (lpj=96000)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048 (order: 2, 16384 bytes, linear)
Mountpoint-cache hash table entries: 2048 (order: 2, 16384 bytes, linear)
cacheinfo: Unable to detect cache hierarchy for CPU 0
RCU Tasks Trace: Setting shift to 2 and lim to 1 rcu_task_cb_adjust=1.
rcu: Hierarchical SRCU implementation.
rcu:    Max phase no-delay instances is 1000.
EFI services will not be available.
smp: Bringing up secondary CPUs ...
Detected VIPT I-cache on CPU1
CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
Detected VIPT I-cache on CPU2
CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
Detected VIPT I-cache on CPU3
CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
smp: Brought up 1 node, 4 CPUs
SMP: Total of 4 processors activated.
CPU features: detected: 32-bit EL0 Support
CPU features: detected: CRC32 instructions
CPU: All CPU(s) started at EL2
alternatives: applying system-wide alternatives
devtmpfs: initialized
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
futex hash table entries: 1024 (order: 4, 65536 bytes, linear)
pinctrl core: initialized pinctrl subsystem
DMI not present or invalid.
NET: Registered PF_NETLINK/PF_ROUTE protocol family
DMA: preallocated 128 KiB GFP_KERNEL pool for atomic allocations
DMA: preallocated 128 KiB GFP_KERNEL|GFP_DMA pool for atomic allocations
DMA: preallocated 128 KiB GFP_KERNEL|GFP_DMA32 pool for atomic allocations
thermal_sys: Registered thermal governor 'fair_share'
thermal_sys: Registered thermal governor 'bang_bang'
thermal_sys: Registered thermal governor 'step_wise'
cpuidle: using governor ladder
cpuidle: using governor menu
hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
ASID allocator initialised with 65536 entries
platform 3001000.clock: Fixed dependency cycle(s) with /soc/rtc@7000000
platform 7010000.clock: Fixed dependency cycle(s) with /soc/rtc@7000000
Modules: 24688 pages in range for non-PLT usage
Modules: 516208 pages in range for PLT usage
iommu: Default domain type: Translated
iommu: DMA domain TLB invalidation policy: strict mode
SCSI subsystem initialized
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
mc: Linux media interface: v0.10
videodev: Linux video capture interface: v2.00
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
Advanced Linux Sound Architecture Driver Initialized.
Bluetooth: Core ver 2.22
NET: Registered PF_BLUETOOTH protocol family
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP socket layer initialized
Bluetooth: SCO socket layer initialized
clocksource: Switched to clocksource arch_sys_counter
FS-Cache: Loaded
NET: Registered PF_INET protocol family
IP idents hash table entries: 16384 (order: 5, 131072 bytes, linear)
tcp_listen_portaddr_hash hash table entries: 512 (order: 1, 8192 bytes, linear)
Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)
TCP established hash table entries: 8192 (order: 4, 65536 bytes, linear)
TCP bind hash table entries: 8192 (order: 6, 262144 bytes, linear)
TCP: Hash tables configured (established 8192 bind 8192)
UDP hash table entries: 512 (order: 2, 16384 bytes, linear)
UDP-Lite hash table entries: 512 (order: 2, 16384 bytes, linear)
NET: Registered PF_UNIX/PF_LOCAL protocol family
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp-with-tls transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
Unpacking initramfs...
Initialise system trusted keyrings
workingset: timestamp_bits=46 max_order=18 bucket_order=0
squashfs: version 4.0 (2009/01/31) Phillip Lougher
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
Freeing initrd memory: 808K
nfs4filelayout_init: NFSv4 File Layout Driver Registering...
nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
Key type cifs.idmap registered
fuse: init (API version 7.38)
SGI XFS with ACLs, security attributes, no debug enabled
NET: Registered PF_ALG protocol family
Key type asymmetric registered
Asymmetric key parser 'x509' registered
Asymmetric key parser 'pkcs8' registered
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 246)
io scheduler mq-deadline registered
io scheduler bfq registered
Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
loop: module loaded
zram: Added device: zram0
wireguard: WireGuard 1.0.0 loaded. See www.wireguard.com for information.
wireguard: Copyright (C) 2015-2019 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
tun: Universal TUN/TAP device driver, 1.6
Broadcom 43xx driver loaded [ Features: NLS ]
usbcore: registered new interface driver rt2800usb
usbcore: registered new device driver r8152-cfgselector
usbcore: registered new interface driver r8152
usbcore: registered new interface driver asix
usbcore: registered new interface driver ax88179_178a
usbcore: registered new interface driver cdc_ether
usbcore: registered new interface driver cdc_eem
usbcore: registered new interface driver net1080
usbcore: registered new interface driver cdc_subset
usbcore: registered new interface driver zaurus
usbcore: registered new interface driver cdc_ncm
usbcore: registered new interface driver r8153_ecm
usbcore: registered new interface driver cdc_acm
cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
usbcore: registered new interface driver usblp
usbcore: registered new interface driver cdc_wdm
usbcore: registered new interface driver uas
usbcore: registered new interface driver usb-storage
usbcore: registered new interface driver ch341
usbserial: USB Serial support registered for ch341-uart
usbcore: registered new interface driver cp210x
usbserial: USB Serial support registered for cp210x
usbcore: registered new interface driver ftdi_sio
usbserial: USB Serial support registered for FTDI USB Serial Device
usbcore: registered new interface driver pl2303
usbserial: USB Serial support registered for pl2303
vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 1
vhci_hcd: created sysfs vhci_hcd.0
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.05
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: USB/IP Virtual Host Controller
usb usb1: Manufacturer: Linux 6.5.3 vhci_hcd
usb usb1: SerialNumber: vhci_hcd.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
vhci_hcd vhci_hcd.0: USB/IP Virtual Host Controller
vhci_hcd vhci_hcd.0: new USB bus registered, assigned bus number 2
usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 6.05
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: USB/IP Virtual Host Controller
usb usb2: Manufacturer: Linux 6.5.3 vhci_hcd
usb usb2: SerialNumber: vhci_hcd.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 8 ports detected
usbcore: registered new device driver usbip-host
mousedev: PS/2 mouse device common for all mice
sun6i-rtc 7000000.rtc: registered as rtc0
sun6i-rtc 7000000.rtc: setting system clock to 1970-01-02T00:01:21 UTC (86481)
sun6i-rtc 7000000.rtc: RTC enabled
i2c_dev: i2c /dev entries driver
mv64xxx_i2c 7081400.i2c: can't get pinctrl, bus recovery not supported
i2c 0-0036: Fixed dependency cycle(s) with /soc/pinctrl@300b000
IR JVC protocol handler initialized
IR MCE Keyboard/mouse protocol handler initialized
IR NEC protocol handler initialized
IR RC5(x/sz) protocol handler initialized
IR RC6 protocol handler initialized
IR SANYO protocol handler initialized
IR Sharp protocol handler initialized
IR Sony protocol handler initialized
IR XMP protocol handler initialized
usbcore: registered new interface driver uvcvideo
sunxi-wdt 30090a0.watchdog: Watchdog enabled (timeout=16 sec, nowayout=0)
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.48.0-ioctl (2023-03-01) initialised: dm-devel@redhat.com
Bluetooth: HCI UART driver ver 2.3
Bluetooth: HCI UART protocol H4 registered
Bluetooth: HCI UART protocol Broadcom registered
ledtrig-cpu: registered to indicate activity on CPUs
SMCCC: SOC_ID: ID = jep106:091e:1823 Revision = 0x00000002
hid: raw HID events driver (C) Jiri Kosina
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
hw perfevents: enabled with armv8_cortex_a53 PMU driver, 7 counters available
gnss: GNSS driver registered with major 242
usbcore: registered new interface driver snd-usb-audio
GACT probability NOT on
ipip: IPv4 and MPLS over IPv4 tunneling driver
Initializing XFRM netlink socket
NET: Registered PF_INET6 protocol family
Segment Routing with IPv6
In-situ OAM (IOAM) with IPv6
sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
bpfilter: Loaded bpfilter_umh pid 89
NET: Registered PF_PACKET protocol family
NET: Registered PF_KEY protocol family
Bridge firewalling registered
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM ver 1.11
Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Bluetooth: BNEP filters: protocol multicast
Bluetooth: BNEP socket layer initialized
Bluetooth: HIDP (Human Interface Emulation) ver 1.2
Bluetooth: HIDP socket layer initialized
l2tp_core: L2TP core driver, V2.0
l2tp_netlink: L2TP netlink interface
8021q: 802.1Q VLAN Support v1.8
Key type dns_resolver registered
registered taskstats version 1
Loading compiled-in X.509 certificates
Key type .fscrypt registered
Key type fscrypt-provisioning registered
Key type encrypted registered
gpio gpiochip0: Static allocation of GPIO base is deprecated, use dynamic allocation.
sun50i-h616-pinctrl 300b000.pinctrl: initialized sunXi PIO driver
gpio gpiochip1: Static allocation of GPIO base is deprecated, use dynamic allocation.
sun50i-h616-r-pinctrl 7022000.pinctrl: initialized sunXi PIO driver
sun50i-h616-pinctrl 300b000.pinctrl: request() failed for pin 224
sun50i-h616-pinctrl 300b000.pinctrl: pin-224 (5000000.serial) status -517
sun50i-h616-pinctrl 300b000.pinctrl: could not request pin 224 (PH0) from group PH0  on device 300b000.pinctrl
dw-apb-uart 5000000.serial: Error applying setting, reverse things back
sun50i-h616-pinctrl 300b000.pinctrl: request() failed for pin 64
sun50i-h616-pinctrl 300b000.pinctrl: pin-64 (5010000.spi) status -517
sun50i-h616-pinctrl 300b000.pinctrl: could not request pin 64 (PC0) from group PC0  on device 300b000.pinctrl
sun6i-spi 5010000.spi: Error applying setting, reverse things back
axp20x-i2c 0-0036: AXP20x variant AXP313a found
axp20x-i2c 0-0036: AXP20X driver loaded
sunxi-mmc 4020000.mmc: Got CD GPIO
printk: console [ttyS0] disabled
5000000.serial: ttyS0 at MMIO 0x5000000 (irq = 293, base_baud = 1500000) is a 16550A
sunxi-mmc 4020000.mmc: initialized, max. request size: 16384 KB, uses new timings mode
printk: console [ttyS0] enabled
printk: console [ttyS0] enabled
printk: bootconsole [uart0] disabled
printk: bootconsole [uart0] disabled
sun6i-spi 5010000.spi: Failed to request TX DMA channel
sun6i-spi 5010000.spi: Failed to request RX DMA channel
dwmac-sun8i 5020000.ethernet: IRQ eth_wake_irq not found
dwmac-sun8i 5020000.ethernet: IRQ eth_lpi not found
dwmac-sun8i 5020000.ethernet: PTP uses main clock
dwmac-sun8i 5020000.ethernet: Current syscon value is not the default 51fe6 (expect 0)
mmc0: host does not support reading read-only switch, assuming write-enable
dwmac-sun8i 5020000.ethernet: No HW DMA feature register supported
mmc0: new high speed SDXC card at address 0001
dwmac-sun8i 5020000.ethernet: RX Checksum Offload Engine supported
mmcblk0: mmc0:0001 SD128 116 GiB
dwmac-sun8i 5020000.ethernet: COE Type 2
 mmcblk0: p1
dwmac-sun8i 5020000.ethernet: TX Checksum insertion supported
dwmac-sun8i 5020000.ethernet: Normal descriptors
dwmac-sun8i 5020000.ethernet: Chain mode enabled
usb_phy_generic usb_phy_generic.1.auto: dummy supplies not allowed for exclusive requests
ehci-platform 5200000.usb: EHCI Host Controller
ohci-platform 5200400.usb: Generic Platform OHCI controller
cfg80211: Loading compiled-in X.509 certificates for regulatory database
Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
clk: Disabling unused clocks
ALSA device list:
  #0: Dummy 1
  #1: Loopback 1
platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
cfg80211: failed to load regulatory.db
ehci-platform 5200000.usb: new USB bus registered, assigned bus number 3
ohci-platform 5200400.usb: new USB bus registered, assigned bus number 4
ehci-platform 5200000.usb: irq 296, io mem 0x05200000
ohci-platform 5200400.usb: irq 298, io mem 0x05200400
ehci-platform 5200000.usb: USB 2.0 started, EHCI 1.00
usb usb3: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.05
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
unusb usb3: Manufacturer: Linux 6.5.3 ehci_hcd
usb usb3: SerialNumber: 5200000.usb
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 1 port detected
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001, bcdDevice= 6.05
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: Generic Platform OHCI controller
usb usb4: Manufacturer: Linux 6.5.3 ohci_hcd
usb usb4: SerialNumber: 5200400.usb
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 1 port detected
Freeing unused kernel memory: 5440K
Run /init as init process
  with arguments:
    /init
  with environment:
    HOME=/
    TERM=linux
init: cannot set terminal process group (-1): Not a tty
init: no job control in this shell
init-4.4# echo *
dev init root rootfs.cpio.gz
init-4.4#

```
</details>

# Drivers for chip 20U5622
This dir besides containing the Kernel Images and DTB, holds the drivers for
chip 20U5622. The drivers are stored in form of a result of kernel's 'modules_install'.
The result is stored in archive ```lib.tar.gz```. To get it working on the target
untar it and copy its content to your's rootfs /lib. After this modprobe should see
the drivers for 20U5622.

```
# modprobe -l
kernel/fs/efivarfs/efivarfs.ko
kernel/drivers/char/hw_random/rng-core.ko
kernel/drivers/char/hw_random/arm_smccc_trng.ko
kernel/drivers/misc/sunxi-rf/sunxi_rfkill.ko
kernel/drivers/net/wireless/uwe5622/unisocwcn/uwe5622_bsp_sdio.ko
kernel/drivers/net/wireless/uwe5622/unisocwifi/sprdwl_ng.ko
kernel/drivers/net/wireless/uwe5622/tty-sdio/sprdbt_tty.ko
```

Before inserting the module, you need to have the wifi chip firmware
in filesystem in ```/lib/firmware```:
 - wcnmodem.bin           - reference file sha256 hash: 119b87ce30875734a67462f7293fb8fe85acf3270fe8b78c978ae24be7715a80
 - wifi_2355b001_1ant.ini - reference file sha256 hash: 1F3C40EC245A8D0B99AD1C23706597D6DD5008AB80CEFB7BCC1956EFC4E938F7 

At lest the two above were tested by me.
They can be found here: https://github.com/orangepi-xunlong/firmware

Due what appears to be timing problems on the sdio bus, please
invoke this command before modprobing the driver, to aviod kernel panic:
```
echo 0 > /proc/sys/kernel/hung_task_timeout_secs
```

After this you can modprobe the driver for 20U5622 itself:
```
modprobe sprdwl_ng.ko 
```

Once done the ```wlan0``` net interface should be available and
scanning WiFi networks by ```iw dev wlan0 scan``` should work as well.

<details>
<summary>Expand for log of modprobing, if listing and wifi scanning:</summary>

```
# modprobe sprdwl_ng.ko
sunxi-rfkill soc:rfkill: module version: v1.0.9
sunxi-rfkill soc:rfkill: pinctrl_lookup_state(default) failed! return ffffffffffffffed
sunxi-rfkill soc:rfkill: get gpio chip_en failed
sunxi-rfkill soc:rfkill: get gpio power_en failed
sunxi-rfkill soc:rfkill: wlan_busnum (1)
sunxi-rfkill soc:rfkill: Missing wlan_power.
sunxi-rfkill soc:rfkill: wlan_regon gpio=210 assert=1
sunxi-rfkill soc:rfkill: wlan_hostwake gpio=207 assert=1
sunxi-rfkill soc:rfkill: wakeup source is enabled
sunxi-rfkill soc:rfkill: Missing bt_power.
udevd[138]: specified group 'input' unknown
sunxi-rfkill soc:rfkill: bt_rst gpio=211 assert=0
udevd[138]: specified group 'kvm' unknown
WCN: marlin_init entry!
WCN: wcn config bt wake host
WCN: marlin_registsr_bt_wake bt_hostwake gpio=208 intnum=204
WCN: wcn config wifi wake host
sdiohal:sdiohal_parse_dt adma_tx:1, adma_rx:1, pwrseq:0, irq type:data, gpio_num:0, blksize:840
sdiohal:sdiohal_init ok
WCN: marlin_probe ok!
WCN: start_marlin [MARLIN_WIFI]
WCN: marlin power state:0, subsys: [MARLIN_WIFI] power 1
WCN: the first power on start
sunxi-rfkill soc:rfkill: wlan power on success
WCN: marlin chip en pull up
sdiohal:sdiohal_scan_card
sunxi-rfkill soc:rfkill: bus_index: 1
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 0Hz bm PP pm UP vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 52, RTO !!
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 52, RTO !!
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 0Hz bm PP pm ON vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 1 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 4 timing LEGACY(SDR12) dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 400000Hz bm PP pm ON vdd 21 width 4 timing UHS-SDR104 dt B
sunxi-mmc-5.4 4021000.sdmmc: sdc set ios:clk 150000000Hz bm PP pm ON vdd 21 width 4 timing UHS-SDR104 dt B
mmc1: new ultra high speed SDR104 SDIO card at address 8800
sdiohal:sdiohal_probe: func->class=0, vendor=0x0000, device=0x0000, func_num=0x0001, clock=150000000
WCN: marlin_scan_finish!
sdiohal:scan end!
sdiohal:probe ok
WCN: then marlin start to download
WCN: marlin_get_wcn_chipid: chipid: 0x2355b001
WCN: marlin_request_firmware from /lib/firmware/wcnmodem.bin start!
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 53, WR DCE !!
sunxi-mmc-5.4 4021000.sdmmc: *****retry:start*****
sunxi-mmc-5.4 4021000.sdmmc: REG_DRV_DL: 0x00010000
sunxi-mmc-5.4 4021000.sdmmc: REG_SD_NTSR: 0x81710000
sunxi-mmc-5.4 4021000.sdmmc: *****retry:re-send cmd*****
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 53, WR DCE !!
sunxi-mmc-5.4 4021000.sdmmc: *****retry:start*****
sunxi-mmc-5.4 4021000.sdmmc: REG_DRV_DL: 0x00010000
sunxi-mmc-5.4 4021000.sdmmc: REG_SD_NTSR: 0x81710000
sunxi-mmc-5.4 4021000.sdmmc: *****retry:re-send cmd*****
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 53, WR DCE !!
sunxi-mmc-5.4 4021000.sdmmc: *****retry:start*****
sunxi-mmc-5.4 4021000.sdmmc: REG_DRV_DL: 0x00010000
sunxi-mmc-5.4 4021000.sdmmc: REG_SD_NTSR: 0x81710000
sunxi-mmc-5.4 4021000.sdmmc: *****retry:re-send cmd*****
sunxi-mmc-5.4 4021000.sdmmc: smc 1 p1 err, cmd 53, WR DCE !!
sunxi-mmc-5.4 4021000.sdmmc: *****retry:start*****
sunxi-mmc-5.4 4021000.sdmmc: REG_DRV_DL: 0x00030000
sunxi-mmc-5.4 4021000.sdmmc: REG_SD_NTSR: 0x81710110
sunxi-mmc-5.4 4021000.sdmmc: *****retry:re-send cmd*****
4,end
WCN: combin_img 0 marlin_firmware_write finish and successful
WCN: marlin_start_run read reset reg val:0x1
WCN: after do marlin_start_run reset reg val:0x0
WCN: s_marlin_bootup_time=145910921068
WCN: clock mode: TSX
WCN: marlin_write_cali_data sync init_state:0xcccccccc
WCN: marlin_write_cali_data sync init_state:0xf0f0f0f1
WCN: sdio_config bt_wake_host trigger:[high]
WCN: sdio_config irq:[inband]
WCN: sdio_config wl_wake_host trigger:[high]
WCN: sdio_config wake_host_level_duration_time:[20ms]
WCN: sdio_config wake_host_data_separation:[bt/wifi reuse]
WCN: marlin_send_sdio_config_to_cp sdio_config:0xb8f01 (enable config)
WCN: marlin_write_cali_data finish
WCN: check_cp_ready sync val:0xf0f0f0f2, prj_type val:0x0
WCN: check_cp_ready sync val:0xf0f0f0f2, prj_type val:0x0
WCN: check_cp_ready sync val:0xf0f0f0f2, prj_type val:0x0
WCN: check_cp_ready sync val:0xf0f0f0f2, prj_type val:0x0
WCN: check_cp_ready sync val:0xf0f0f0f6, prj_type val:0x0
WCN: marlin_bind_verify confuse data: 0x7e72db03cef9fe36d186cbea85dc082
WCN: marlin_bind_verify verify data: 0xc494a3cdbcfb679bc3ce932529261a3
WCN: check_cp_ready sync val:0xf0f0f0f7, prj_type val:0x0
WCN: check_cp_ready sync val:0xf0f0f0ff, prj_type val:0x0
sdiohal:sdiohal_runtime_get entry
WCN: get_cp2_version entry!
WCN: WCND at cmd read:WCN_VER:Platform Version:MARLIN3_19B_W21.05.3~Project Version:sc2355_marlin3_lite_ott~12-15-2021 11:26:33~
WCN: switch_cp2_log - close entry!
WCN: WCND at cmd read:OK
WCN: then marlin download finished and run ok
WCN: start_loopcheck
WCN: get_board_ant_num [one_ant]
wifi ini path = /lib/firmware/wifi_2355b001_1ant.ini
unisoc_wifi unisoc_wifi wlan0: mixed HW and IP checksum settings.
#
#
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: bond0: <BROADCAST,MULTICAST400> mtu 1500 qdisc noop qlen 1000
    link/ether a6:60:ae:41:b9:dd brd ff:ff:ff:ff:ff:ff
3: tunl0@NONE: <NOARP> mtu 1480 qdisc noop qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: ip6_vti0@NONE: <NOARP> mtu 1364 qdisc noop qlen 1000
    link/tunnel6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
5: sit0@NONE: <NOARP> mtu 1480 qdisc noop qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
6: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop qlen 1000
    link/tunnel6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
7: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 02:00:2a:af:18:c4 brd ff:ff:ff:ff:ff:ff
8: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
#
#
# iw dev wlan0 scan
BSS 54:67:51:1e:9b:67(on wlan0)
        TSF: 170781700 usec (0d, 00:02:50)
        freq: 2412
        beacon interval: 100 TUs
        capability: ESS Privacy ShortSlotTime RadioMeasure (0x1411)
        signal: -70.00 dBm
        last seen: 1572 ms ago
        SSID: UPC6276F16
        Supported rates: 1.0* 2.0* 5.5* 11.0* 9.0 18.0 36.0 54.0
        DS Parameter set: channel 1
        ERP: Barker_Preamble_Mode
        Extended supported rates: 6.0 12.0 24.0 48.0
        Country: EU     Environment: Indoor/Outdoor
                Channels [1 - 13] @ 20 dBm
        HT capabilities:
                Capabilities: 0x1ac
                        HT20
                        SM Power Save disabled
                        RX HT20 SGI
                        TX STBC
                        RX STBC 1-stream
                        Max AMSDU length: 3839 bytes
                        No DSSS/CCK HT40
                Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
                Minimum RX AMPDU time spacing: 4 usec (0x05)
                HT RX MCS rate indexes supported: 0-15
                HT TX MCS rate indexes are undefined
        HT operation:
                 * primary channel: 1
                 * secondary channel offset: no secondary
                 * STA channel width: 20 MHz
                 * RIFS: 0
                 * HT protection: no
                 * non-GF present: 1
                 * OBSS non-GF present: 0
                 * dual beacon: 0
                 * dual CTS protection: 0
                 * STBC beacon: 0
                 * L-SIG TXOP Prot: 0
                 * PCO active: 0
                 * PCO phase: 0
        WPA:     * Version: 1
                 * Group cipher: TKIP
                 * Pairwise ciphers: TKIP 00-00-00:0
                 * Authentication suites: PSK
        RSN:     * Version: 1
                 * Group cipher: TKIP
                 * Pairwise ciphers: CCMP TKIP
                 * Authentication suites: PSK
                 * Capabilities: 1-PTKSA-RC 1-GTKSA-RC (0x0000)
        Extended capabilities:
                 * HT Information Exchange Supported
                 * BSS Transition
        BSS Load:
                 * station count: 4
                 * channel utilisation: 69/255
                 * available admission capacity: 31250 [*32us]
        WMM:     * Parameter version 1
                 * BE: CW 15-1023, AIFSN 3
                 * BK: CW 15-1023, AIFSN 7
                 * VI: CW 7-15, AIFSN 2, TXOP 3008 usec
                 * VO: CW 3-7, AIFSN 2, TXOP 1504 usec
        RM enabled capabilities:
                Capabilities: 0x22 0x00 0x00 0x00 0x00
                        Neighbor Report
                        Beacon Active Measurement
                Nonoperating Channel Max Measurement Duration: 0
                Measurement Pilot Capability: 0
        WPS:     * Version: 1.0
                 * Wi-Fi Protected Setup State: 2 (Configured)
                 * Response Type: 3 (AP)
                 * UUID: 8985a700-1dd2-11b2-8601-5543a04a6443
                 * Manufacturer: Ralink Technology, Corp.
                 * Model: Ralink Wireless Access Point
                 * Model Number: RT2860
                 * Serial Number: 12345678
                 * Primary Device Type: 6-0050f204-1
                 * Device name: RalinkAPS
                 * Config methods:
                 * RF Bands: 0x1
                 * Version2: 2.0
(...)
```
</details>

Sadly connecting to the existing network does not work via ```iwconfig wlan0 essid test_hotspot key s:test_hotspot```
resulting in firmware crash.
```
# iwconfig wlan0 essid test_hotspot key s:test_hotspot
warning: `iwconfig' uses wireless extensions which will stop working for Wi-Fi 7 hardware; use nl80211
t key s:test_hotspot
WCN: mdbg_assert_read:WCN Assert in rf_marlin.c line 1010, IS_2G_CHANNEL(pri20_ch_num) || IS_5G_CHANNEL(center_ch_num),data length 128
WCN: stop_loopcheck
WCN_ERR: chip reset & notify every subsystem...
WCN: [marlin_cp2_reset], DO BSP RESET
WCN: marlin power state:4, subsys: [MARLIN_WIFI] power 0
WCN: wcn chip start power off!
sdiohal:sdiohal_runtime_put entry
sdiohal:sdiohal_runtime_put wait xmit_cnt end
WCN: chip_power_off
(...)
```

The same happens on stock reference image of Ubuntu from Sunxi for Orange Pi Zero 3, when using iwconfig.
To connect to net on the Sunxi's image one uses ```nmcli```, but I was unable to get it working
in my build (```nmcli``` and ```NetworkManager``` refuses to manage the wlan0 interface).
This needs further investigation.

But for now it must wait for better times from my side, since my goal was to configure
the WiFi chip as an Access Point, which works great by utilizing ```hostapd``` tooling.
But remember to change the mac (initially it is zeroed), before using ```hostapd``` eg.:
```
ip link set wlan0 address 02:42:ac:11:00:02
```

