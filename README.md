# Disclaimer
Almost all of the code contained in this repo is not mine. Mostly what I've done is putting together
Linux sources from kernel.org in version 6.5.3 (which do pretty good job in terms of HW support for Orange Pi Zero 3)
and driver sources of: rfkill, WiFi+BT chip and SDIO from sunxi repo: 
https://github.com/orangepi-xunlong/linux-orangepi.git, branch: orange-pi-5.4-sun50iw9, commit: 9ab7a758149d3c9b721878a0c18b3f9c5d6c93e6.
It required a bit of input from me, like fixes in DTS, but it wasn't THAT much.
And thus I am not going to actively maintain it, if there is any workaround for anything, the workaround is prefered. 
That being said, if I find anything that directly affects my use case (WiFi chip in Access Point mode for example) I'll probably fix it.
And last but not least, when Linux will get its 6.x.x version marked as LTS by the end of this year, I will probably try to adapt the changes done
in version 6.5.3 to the LTS one.

### Little shoutout
It may be also a good idea to monitor this repo and this author: https://github.com/hsvikum/linux-6.5-orange-pi-zero-3. It seems that
he actively supports Linux for Orange Pi and seems to work with mainline Linux under Sunxi's wing, at least to some extent (but not sure about that).
Sadly, I didn't manage to build his altered version of Linux for Orange Pi Zero3 out of the box (didn't try too hard, though).

# What is working?
Pretty much everything that works on the mainline Linux plus WiFi (AP and connecting to the net). Not sure how about the bluetooth, never tested it.
From things I've tested: USB, Ethernet, WiFi, Serial and GPIO, all seems to work just fine.

# Major commits worth a checkout (if you hate traversing commits history as much as I do), chronologically top-bottom
 - **73f07d35f55094932070cfbf33234005bff8093a** - Added support for Orange Pi Zero3 board (DTS and defconfig) to mainline Linux
 - **a58f2ec8022fb7e6b64d880cfad2f22fd9074533** - Ugly, but working port of driver for 20U5622 WiFi chip based on Sunxi's one for Linux 5.4

# Prerequisites to build the Kernel image
- Linux machine to perform the build (tested on Ubuntu server 20.04.6 LTS)
- Some cross compiler for aarch64. This one should cut:
  https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.xz
  Or install one via package manager eg. for ubuntu: 
  ```
  sudo apt update
  sudo apt -y install gcc-aarch64-linux-gnu
  ```

# Building the image
Building the image follows regular Linux Kernel build process:

- First navigate to directory ```linux-6.5.3```
- Then generate the config based on defconfig for Orange Pi Zero3 (providing you are using the compiler installed by package manager):
```
CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 make -j $(($(nproc)+2)) orangepi_zero3_defconfig
```
- And finally perform the build itself (providing you are using the compiler installed by package manager):
```
CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 make -j $(($(nproc)+2))
``` 
- Additionally, you can install the drivers for WiFi chip, generated during the build by invoking following command:
```
CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=<given_rootfs_root> ARCH=arm64 make -j $(($(nproc)+2)) modules_install
```
They will be stored in ```/lib/modules``` subdir of the rootfs pointed by INSTALL_MOD_PATH variable.

Your Image will be in a subdir, here: ```arch/arm64/boot/Image``` and the DTB in ```arch/arm64/boot/dts/allwinner/sun50i-h618-orangepi-zero3.dtb```.
Both are required to boot the board.

# Booting Linux kernel
The more info on how to boot the Linux and work with WiFi, along with pre-built images and boot logs are contained in ```build``` subdirectory. Rapid reference:
- Booting linux: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#booting-linux---prerequisites
   * SD Card:  https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#booting-from-the-card
   * Via tftp: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#booting-through-network-via-ad-hoc-tftp-server
- Setting up system to work with WiFi driver: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#drivers-for-chip-20u5622
- Connecting to existing WiFi network: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#connecting-to-wifi-network
- Setting the Access point up: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#setting-up-access-point


# 20U5622 WiFi+BT chip enablement
The process of porting drivers from 5.4 to 6.5.3 was pretty standard - some kernel API was no longer public and had to be exported again, some was replaced, and some was compeletely missing and needed reimplementation (for the latter, see this file: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/blob/main/linux-6.5.3/drivers/net/wireless/uwe5622/missing-from-5.4.h). 

All that was done to keep original driver intact, as much as possible. Otherwise I would be porting this up until this day. But at least the code would be nice (or not - it would be code of mine, after all).

I will skip whole v6 vs v5 kernel discrapancy patching process, more curious readers always may see diffs in commits.
What I will describe though, are two other aspects of porting - the ones which I would like to know earlier, and which would spare me a lot of head scraching, head banging - mostly - against the wall and headache (in this order).

### Hardware wiring
When I started working on this port, the board schematic was not yet avaliable. Now it can be found here:
https://drive.google.com/file/d/1GelRJz-6Dg4i_EQ1SwrfHeqfLOPw9kdO/view (taken from the Sunxi website: http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-Zero-3.html).

Some say the same schematic is archived here: https://web.archive.org/web/20231120203854/https://doc-14-ag-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/lqoghaa3ji66q97hk2a6r05c9m8rj376/1700512725000/11359042997240094710/*/1GelRJz-6Dg4i_EQ1SwrfHeqfLOPw9kdO?e=download&uuid=4e7a6a87-3489-4848-b3b0-4335daf848c8 (:

But don't get too exited, because, as the H618 chip's pads seems to be marked alright, the WiFi+BT chip (20U5622) labels are all wrong, except they don't (at least not entirely).

Reference 20U5622 datasheet to see yourself how wrong they are, can be found here: https://fccid.io/2AQ9Y-OPI3LTS/Parts-List/Tune-Up-Info/Antenna-Specification-2-6192129.pdf
and may or may not be archived here: https://web.archive.org/web/20231120204424/https://fccid.io/2AQ9Y-OPI3LTS/Parts-List/Tune-Up-Info/Antenna-Specification-2-6192129.pdf

Anyways, under closer investigation, and after using sophisticated methods of HW analysis, which I call: "Turn on and off H618's GPIO pad periodically, while measuring the logical level at the other side"™ it turns out, that the labels are indeed all wrong, but the 20U5622 pins numbers on the board's schematic matches the ones in the datasheet.

After physically tracing, well, the traces on the Orange Pi PCB, here is what wiring I came up with:
```
+==========+=================================+
| H618 pad | 20U5622 pin number and function |
+==========+=================================+
| PG19     | PIN34 - NC                      |
+----------+---------------------------------+
| PG18     | PIN12 - RST_N                   |
+----------+---------------------------------+
| PG17     | PIN06 - CHIP_EN                 |
+----------+---------------------------------+
| PG16     | PIN7  - INT                     |
+----------+---------------------------------+
| PG15     | PIN13 - GPIO1                   |
+----------+---------------------------------+
```

The SDIO pins are connected 1:1 between the two chips, so I don't include them here. The table above is important, because the pins
mentioned there are used during WiFi chip's power on sequence, and are used both in UWE5622 and rfkill drivers authored by Sunxi for Linux 5.4.

And btw., this is how the table above translates to pin function in Sunxi drivers nomenclature:
```
bt_rst_n      - PG19
wlan_regon    - PG18
bt_wake       - PG17
bt_hostwake   - PG16
wlan_hostwake - PG15
```

All that is contained in DTS for Orange Pi Zero3, here:

https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/blob/main/linux-6.5.3/arch/arm64/boot/dts/allwinner/sun50i-h618-orangepi-zero3.dts

If you wonder what that second number around GPIO pins in DTS actually represents, eg. 0x06 here:
```
bt_hostwake = <&pio 0x06 0x10 GPIO_ACTIVE_HIGH>;
```
This is the pins group number. For ```G``` group i.e. ```PGxx``` it is 0x06.

The last two things to ascertain was the clocks and interrupts numbers in DTS for the SDIO controller. 
I've get those by decompiling the dtb from original, official image of Ubuntu for Orange Pi Zero3,
and then comparing them against Linux 5.4 sources taken from Sunxi Github. See disclaimer section
for more precise reference to the Sunxi sources. 

After this I seeked for the same (or similar) clocks and interrupts names in mainline Linux 6.5.3 
sources and shoved them into DTS node inspired by Sunxi's one. Finally I were observing the logs
and comparing what drivers report in comparison with the official Sunxi Ubuntu image. Loop and repeat.
Boring stuff.

### Challenge-Response code quirks
After I got something, what looked like valid trinity of: hardware wiring, clocks and interrupts. I could actually test the driver. 
And right of the bat, just after modprobing the module I got somewhat weird and intriguing error:
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
sunxi-rfkill soc:rfkill: bt_rst gpio=211 assert=0
------------[ cut here ]------------
WARNING: CPU: 2 PID: 181 at arch/arm64/kernel/module-plts.c:94 module_emit_plt_entry+0x178/0x1b0
Modules linked in: sunxi_rfkill
CPU: 2 PID: 181 Comm: modprobe Not tainted 6.5.3 #2
Hardware name: OrangePi Zero3 (DT)
pstate: 20000005 (nzCv daif -PAN -UAO -TCO -DIT -SSBS BTYPE=--)
pc : module_emit_plt_entry+0x178/0x1b0
lr : module_emit_plt_entry+0x80/0x1b0
sp : ffffffc0824f3ab0
x29: ffffffc0824f3ab0 x28: ffffffc082551830 x27: ffffffc082529650
x26: ffffffc082550c30 x25: ffffffc079fb6000 x24: 00000000ffffffff
x23: ffffffc08254c7f8 x22: 0000000000000000 x21: ffffffc079fb9038
x20: ffffffc079fb6000 x19: ffffffc079fb6000 x18: 0000000000000002
x17: 9400000091000000 x16: 9000000094000000 x15: 6972775f6f696473
x14: 0062646165725f6f x13: 0000000000000005 x12: 73007172695f656c
x11: 0101010101010101 x10: ffffffffff134b57 x9 : 0000000000000000
x8 : 0000000000000000 x7 : 0000000000000048 x6 : ffffffc081352658
x5 : 0000000000000007 x4 : 0000000000000004 x3 : 00000000ffc003ff
x2 : 0000000091000210 x1 : 0000000000000000 x0 : 0000000000000001
Call trace:
 module_emit_plt_entry+0x178/0x1b0
 apply_relocate_add+0x278/0x770
 load_module+0xde4/0x1b14
 init_module_from_file+0x78/0x98
 __arm64_sys_finit_module+0x1c4/0x310
 invoke_syscall.constprop.0+0x4c/0xd8
 do_el0_svc+0x58/0x150
 el0_svc+0x38/0xf0
 el0t_64_sync_handler+0xc0/0xc4
 el0t_64_sync+0x190/0x194
---[ end trace 0000000000000000 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 181 at arch/arm64/kernel/module-plts.c:94 module_emit_plt_entry+0x178/0x1b0
Modules linked in: sunxi_rfkill
CPU: 2 PID: 181 Comm: modprobe Tainted: G        W          6.5.3 #2
Hardware name: OrangePi Zero3 (DT)
pstate: 20000005 (nzCv daif -PAN -UAO -TCO -DIT -SSBS BTYPE=--)
pc : module_emit_plt_entry+0x178/0x1b0
lr : module_emit_plt_entry+0x80/0x1b0
sp : ffffffc0824f3b30
x29: ffffffc0824f3b30 x28: ffffffc0825af830 x27: ffffffc082587650
x26: ffffffc0825aec30 x25: ffffffc079ffa000 x24: 00000000ffffffff
x23: ffffffc0825aa7f8 x22: 0000000000000000 x21: ffffffc079ffd038
x20: ffffffc079ffa000 x19: ffffffc079ffa000 x18: 0000000000000002
x17: 9400000091000000 x16: 9000000094000000 x15: 6972775f6f696473
x14: 0062646165725f6f x13: 0000000000000005 x12: 73007172695f656c
x11: 0101010101010101 x10: ffffffffff0d6b57 x9 : 0000000000000000
x8 : 0000000000000000 x7 : 0000000000000048 x6 : ffffffc081352658
x5 : 0000000000000007 x4 : 0000000000000004 x3 : 00000000ffc003ff
x2 : 0000000091000210 x1 : 0000000000000000 x0 : 0000000000000001
Call trace:
 module_emit_plt_entry+0x178/0x1b0
 apply_relocate_add+0x278/0x770
 load_module+0xde4/0x1b14
 __do_sys_init_module+0x10c/0x188
 __arm64_sys_init_module+0x1c/0x28
 invoke_syscall.constprop.0+0x4c/0xd8
 do_el0_svc+0x58/0x150
 el0_svc+0x38/0xf0
 el0t_64_sync_handler+0xc0/0xc4
 el0t_64_sync+0x190/0x194
---[ end trace 0000000000000000 ]---
modprobe: can't load module uwe5622_bsp_sdio (kernel/drivers/net/wireless/uwe5622/unisocwcn/uwe5622_bsp_sdio.ko): invalid module format
```

If you wonder how the hell driver built in-kernel-tree can spit out: "invalid module format", and cause crash,
despite being modprobed on the exact same kernel it had been built along, congratulations your reasoning works allright - and also - I had no clue back then too.
I mean, I still don't know, but now, at least I know the real underlying root cause.

After some wizardry and hackering, I managed to push it a bit further:
```
(...)
sunxi-rfkill soc:rfkill: bt_rst gpio=211 assert=0
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
WCN: s_marlin_bootup_time=22777558579
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
WCN: marlin_bind_verify confuse data: 0x8b4411b712507e7321c4f80911217cc
Kernel text patching generated an invalid instruction at wcn_bind_verify_calculate_verify_data+0xf8/0x10f8 [uwe5622_bsp_sdio]!
Unexpected kernel BRK exception at EL1
(...the rest of the crash trace junk...)
```

The spell I've casted is called offum-by-oneum. I simply added 1 to ```mod->arch.core.plt_max_entries``` while initializing
this structure, so the check later on won't detect any issues:
``` 
if (WARN_ON(pltsec->plt_num_entries > pltsec->plt_max_entries))
                return 0;
```

After this I got the log from above. I compared it with the boot log of kernel from the guys that actually seem to know what are they doing - Ubuntu from Sunxi - 
and it looked good so far. Maybe excepct that their driver did not crash in contrast to mine.
Nevertheless I got some additional info about the crash in the log. And there, one can spot that, there is something wrong with function ```wcn_bind_verify_calculate_verify_data```.

And if you are now thinking "Aha! I knew it from the very beginning" - of course you did, I literally said where the problem was in the title of the chapter.
But bear with me, that's still not the end of this joyride.

After I had started to look for the Challenge-Response symbol, I found out that, there is no match in the sources, only in the object files, which was weird. 
I got more suspicious, so I tracked the origin of the object file holding the symbol.
This led me to the file: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/blob/main/linux-6.5.3/drivers/net/wireless/uwe5622/unisocwcn/platform/wcn_bind_helper.c

If you are twisted as I am, you can immediately notice ```0x1f 0x8b``` bytes at the start of the arrays there. And also the other array a little bit further in the code, holding what seems as prefixes for cross compilers.

This was big "Aha!" moment for me. After which I instantly praised the technical idea behind that (except not in conventional way, let's say if back then, my words were ASCII characters, they would occupy values below 32).

But what actually is going on here?

Well the ```wcn_bind_helper.c``` compiles as a host executable, sometime during the build of kernel. Once built, it is run with the argument matching the currently used cross-compiler.
Depending on the cross compiler the respective object file is saved as an tar.gz archive (gzip part could be recognized by ```0x1f 0x8b``` magic at the begining of the arrays) and unpacked.
After all those actions it is included into driver build as a normal, legit, built from sources object file would. 

The problem is that, such precompiled object file may not be compatible with your particular cross compiler. I managed to track down the toolchain used to build the object file - 
it was one of the Linaro variety. And I told to myself: "ah təˈmeɪtoʊ, təˈmɑːtəʊ, let's switch to the Linaro one".

After discovering that one cannot simply build Linux kernel with Linaro toolchain, and after hacking Linux sources in such a way, that you can, it turned out the module still crashes in the exact same way. Totally worth it.

As a grown adult I did what every grown up would do, and as a last struggle I had dumped the object file's executable sections as an aarch64 assembly and patched it, so now it compiles and links using regular gcc assembler and linker.
After adjusting the Makefile accordingly, the build worked and so the Challenge-Response calculations.

If anyone is crazy enough to reverse-engineer the Challenge-Response algorithm and implement it in more human-like language, here is example input and output data:
```
[   49.798923] WCN: marlin_bind_verify confuse data: 0xf71c8447f73048472ce84dba1253605a
[   49.798938] WCN: marlin_bind_verify verify data:  0xa4eb5eda181e56a4c79873c0e84c8018
```

GL&HF

# Known problems
Here is the list of lingering problems, which I know about. 
But between my laziness and existing workarounds for them (or them not breaking anything), I am not going to resolve them, at least for now, most likely ever. 
Good enough is good for me.

- From time to time, when board is booted in SMP mode, the jibberish output can be observed on serial console:
```
 mmcblk0: p1
printk: console [ttyS0] disabled
sunx▒▒▒<▒<▒▒▒▒▒▒▒▒▒<▒▒<<8▒<▒▒<<▒<▒▒▒▒<▒<▒8▒<▒▒<<▒<▒<▒<▒▒<▒▒<▒<▒▒8<▒▒▒▒▒▒▒▒<<▒<▒<<▒<▒▒▒▒▒<▒▒▒▒8▒▒<<▒<<<<▒<<<<▒8▒<▒▒<▒<▒▒▒▒▒▒▒<<▒<▒8▒<▒<<▒<▒▒▒▒<▒▒<▒▒▒<<▒▒<printk: console [ttyS0] enabled
printk: console [ttyS0] enabled
printk: bootconsole [uart0] disabled
printk: bootconsole [uart0] disabled
```
Sometimes those are a few lines (or single, as in log above), sometimes it is plenty of lines, I haven't seen this symptom to drags on longer than till switch to userspace. So, harmless I guess.

- Timeouts on SDIO bus while transferring 20U5622 chip firmware
```
# modprobe sprdwl_ng.ko
(...)
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
(...)
```
It is reproducible every single time after modprobing the 20U5622 chip driver. It does not impact further driver loading, so I decided to ignore that.

- The background task which is listening for heartbeat on modem console of the 20U5622 chip, is considered hang and crashes kernel (after approx. 3.5-4 minutes):
```
task:SPRDWL_TX_QUEUE state:D stack:0     pid:190   ppid:2      flags:0x00000008
Call trace:
 __switch_to+0xd0/0x1a0
 __schedule+0x298/0xabc
 schedule+0x50/0xe0
 schedule_timeout+0x234/0x2d0
 wait_for_completion+0x94/0x1fc
 sprdwl_tx_work_queue+0x158/0x294 [sprdwl_ng]
 kthread+0xe8/0xf4
 ret_from_fork+0x10/0x20
Kernel panic - not syncing: hung_task: blocked tasks
CPU: 1 PID: 35 Comm: khungtaskd Not tainted 6.5.3 #2
Hardware name: OrangePi Zero3 (DT)
Call trace:
 dump_backtrace+0x94/0xec
 show_stack+0x18/0x24
 dump_stack_lvl+0x48/0x60
 dump_stack+0x18/0x24
 panic+0x2ec/0x344
 watchdog+0x2e4/0x55c
 kthread+0xe8/0xf4
 ret_from_fork+0x10/0x20
SMP: stopping secondary CPUs
Kernel Offset: disabled
CPU features: 0x00000000,00010000,0000420b
Memory Limit: none
---[ end Kernel panic - not syncing: hung_task: blocked tasks ]---
```

This has probably the same culprit as the bullet point above - some SDIO timing issues. 
Thankfully kernel is so nice, that it exactly tells us what to do, to ignore such problems.
Simply invoke before modprobing 20U5622 driver:

```
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
```

- wlan0 interface, provided by 20U5622 chip driver has initially zeroed MAC address
```
# ip a
(...)
8: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
```

This can get in a way in a few places, like setting up AP or connecting to the network. But one can simply change the MAC manually beforehand, by issuing command:

```
ip link set wlan0 address <new_MAC_addr>
```
eg.
```
ip link set wlan0 address 02:42:ac:11:00:02
```

- ```iwconfig``` used to connect to the WiFi results in kernel crash like this:
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

This is not a kernel crash (not directly), but rather 20U5622 chip's firmware. I have no resolution strictly for ```iwconfig```, but I've got an alternative.
To connect to the WiFi use ```wpa_supplicant``` instead of ```iwconfig```, as described here: https://github.com/Doct2O/orangepi-zero3-mainline-linux-wifi/tree/main/build#connecting-to-wifi-network
