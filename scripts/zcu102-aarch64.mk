# Makefile for Xilinx ZCU102 AArch64 platform
# created on 2024.12.2, wheatfox(enkerewpo@hotmail.com)

QEMU := sudo /path_to_xilinx_qemu/qemu-system-aarch64

UBOOT := $(image_dir)/bootloader/zcu102/u-boot.elf
BL31 := $(image_dir)/bootloader/zcu102/bl31.elf
HW_DTB := $(image_dir)/devicetree/zcu102/zynqmp-qemu-multiarch-arm.dtb
PMU_CONF := $(image_dir)/bootloader/zcu102/pmu-conf.bin

# according to petalinux-boot qemu
# qemu-system-aarch64 -M arm-generic-fdt
# -serial mon:stdio -serial /dev/null -display none 
# -device loader,file=system.dtb,addr=0x100000,force-raw=on
# -device loader,file=u-boot.elf
# -device loader,file=Image,addr=0x200000,force-raw=on
# -device loader,file=rootfs.cpio.gz.u-boot,addr=0x4000000,force-raw=on
# -device loader,file=bl31.elf,cpu-num=0
# -global xlnx,zynqmp-boot.cpu-num=0
# -global xlnx,zynqmp-boot.use-pmufw=true
# -global xlnx,zynqmp-boot.drive=pmu-cfg
# -blockdev node-name=pmu-cfg,filename=pmu-conf.bin,driver=file
# -hw-dtb zynqmp-qemu-multiarch-arm.dtb
# -device loader,file=boot.scr,addr=0x20000000,force-raw=on
# -gdb tcp:localhost:9000
# -net nic -net nic -net nic -net nic,netdev=eth3 -netdev user,id=eth3,tftp=/tftpboot
# -machine-path /tmp/tmpbf8tgt6q
# -m 4G

QEMU_ARGS := -machine arm-generic-fdt

QEMU_ARGS += -m 4G
QEMU_ARGS += -nographic
QEUM_ARGS += -serial mon:stdio -serial /dev/null -display none

QEMU_ARGS += -global xlnx,zynqmp-boot.cpu-num=0
QEMU_ARGS += -global xlnx,zynqmp-boot.use-pmufw=true
QEMU_ARGS += -global xlnx,zynqmp-boot.drive=pmu-cfg
QEMU_ARGS += -blockdev node-name=pmu-cfg,filename=$(PMU_CONF),driver=file

QEMU_ARGS += -hw-dtb $(HW_DTB)

QEMU_ARGS += -device loader,file="$(BL31)",cpu-num=0
QEMU_ARGS += -device loader,file="$(UBOOT)"
QEMU_ARGS += -device loader,file="$(hvisor_bin)",addr=0x40400000

$(hvisor_bin): elf
	@if ! command -v mkimage > /dev/null; then \
		if [ "$(shell uname)" = "Linux" ]; then \
			echo "mkimage not found. Installing using apt..."; \
			sudo apt update && sudo apt install -y u-boot-tools; \
		elif [ "$(shell uname)" = "Darwin" ]; then \
			echo "mkimage not found. Installing using brew, you may need to reopen the Terminal App"; \
			brew install u-boot-tools; \
		else \
			echo "Unsupported operating system. Please install u-boot-tools manually."; \
			exit 1; \
		fi; \
	fi && \
	$(OBJCOPY) $(hvisor_elf) --strip-all -O binary $(hvisor_bin).tmp && \
	mkimage -n hvisor_img -A arm64 -O linux -C none -T kernel -a 0x40400000 \
	-e 0x40400000 -d $(hvisor_bin).tmp $(hvisor_bin) && \
	rm -rf $(hvisor_bin).tmp