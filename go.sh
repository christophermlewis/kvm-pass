#!/bin/bash 
packages() { 
  apt-get install qemu-kvm bridge-utils 
}

kernel_modules() {
  echo 'kvm' >> /etc/modules
  echo 'kvm_intel' >> /etc/modules
  echo 'pci_stub' >> /etc/modules
  echo 'vfio-pci' >> /etc/modules
}

grub_options() {
  sed "s/GRUB_CMDLINE_LINUX_DEFAULT=\\"quiet\\"/GRUB_CMDLINE_LINUX_DEFAULT=\\"quiet\\"\ intel_iommu=on\ pci-stub.ids=$(lspci -n | grep '01:00.0' | awk '{print $3}'),$(lspci -n | grep '01:00.1' | awk '{print $3}')\ vfio_iommu_type1.allow_unsafe_interrupts=1"
}

bridge_network() {
  sed s/iface\ eth0\ inet\ dhcp/iface\ eth0\ inet\ manual
  printf 'iface br0 inet dhcp\n  bridge_ports eth0\n  bridge_fd 0\n  bridge_maxwait 0\n  bridge_stp on' > /etc/network/interfaces.d/br0
  echo 'allow br0' > /etc/qemu/bridge.conf
}

a_windows_with_pass_through() {
'
qemu-system-x86_64 -enable-kvm  -M q35 -m 8024 -cpu host -smp 4 \
  -daemonize \
  -vnc :10 \
  -boot dc \
  -drive file=/home/chrisl/Windows10_x64.iso,id=c0,media=cdrom,if=none \
  -drive file=/dev/hal-vg2/test,format=raw,id=d0,if=none \
  -device ide-cd,drive=c0 \
  -device ich9-ahci,id=ahci \
  -device ide-drive,drive=d0,bus=ahci.0
 # -vga none \
 # -rtc base=localtime \
 # -device piix4-ide,bus=pcie.0,id=piix4-ide \
 # -drive file=/dev/hal-vg/win8,id=diskb,format=raw,if=virtio \
 # -netdev bridge,id=hn0 -device virtio-net-pci,netdev=hn0,id=nic1 \
 # -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
 # -device vfio-pci,host=01:00.0,bus=root.1,addr=00.0,multifunction=on,x-vga=on \
 # -device vfio-pci,host=01:00.1,bus=pcie.0 \
 # -device vfio-pci,host=00:03.0,bus=pcie.0 \
 # -device vfio-pci,host=00:1d.0,bus=pcie.0 \
 # -device vfio-pci,host=00:1b.0,bus=pcie.0
#  -device vfio-pci,host=00:1d.0,bus=pcie.0

'

}

packages
kernel_modules
grub_options
#bridge_network
