packages=("wow" "lsof" "sysstat" "virt-what" "dmidecode" "bc" "attr" "e2fsprogs" "fdisk" "gzip" "iproute2" "tar" "libxml2-devel" "brutils-2.5" ); for pkg in ${packages[@]}; do check=`yum -q list installed $pkg 2>&1 /dev/null`; if [ $? -ne 0 ]; then echo -e "${pkg} not_installed."; else echo -e  "${pkg} is_installed.";fi done
