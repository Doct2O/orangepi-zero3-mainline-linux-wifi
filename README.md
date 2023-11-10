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

The more info on how to boot the Linux, what is needed to compose rootfs for working WiFi chip, how to connect to WiFi, set up an Access Point can be found in README from ```build``` subdirectory.

# I will put here more comprehensive report from enabling driver for 20U5622 some later on, for now README.md from build subfolder must be sufficient on running the images built from here. If you still want to know the details on driver porting it is highly recommended to see diffs in commits.
