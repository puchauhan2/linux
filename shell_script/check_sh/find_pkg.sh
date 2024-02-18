
#!/usr/bin/env bash

#packages=("wow" "lsof" "sysstat" "virt-what" "dmidecode" "bc" "attr" "binutils" "cifs-utils" "dhclient" "dosfstools" "ethtool" "gawk" "lsb-release" "xorriso" "grub2-pc" "nfs-common" "openssl" "parted" "util-linux" "iputils-ping" "kbd" "e2fsprogs" "fdisk" "gzip" "iproute2" "lsb-release" "net-tools" "isolinux" "syslinux" "syslinux-common" "tar" "libxml2-devel" "sysvinit-tools" "brutils-2.5" "lzop")
packages=("wow" "lsof" "sysstat" "virt-what" "dmidecode" "bc" "attr" "binutils" "cifs-utils" "dhclient" "dosfstools" "ethtool" "gawk" "lsb-release" "xorriso" "grub2-pc" "nfs-common" "openssl" "parted" "util-linux" "iputils-ping" "e2fsprogs" "fdisk" "gzip" "iproute2" "lsb-release" "net-tools" "isolinux" "syslinux" "tar" "libxml2-devel" "brutils-2.5" )

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}

for pkg in ${packages[@]}; do

check=`yum -q list installed $pkg 2>&1 /dev/null`

if [ $? -ne 0 ]; then

       echo -e "${BY}${pkg}${BR} not_installed.${NC}"

else

 echo -e  "${BY}${pkg}${BG} is_installed.${NC}"
fi
done
