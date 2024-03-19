packages=("wow" "lsof" "sysstat" "virt-what" "dmidecode" "bc" "attr" "binutils" "cifs-utils" "dhclient" "dosfstools" "ethtool" "gawk" "lsb-release" "xorriso" "grub2-pc" "nfs-common" "openssl" "parted" "util-linux" "iputils-ping" "kbd" "e2fsprogs" "fdisk" "gzip" "iproute2" "lsb-release" "net-tools" "isolinux" "syslinux" "syslinux-common" "tar" "libxml2-devel" "sysvinit-tools" "brutils-2.5" "lzop")

source /etc/os-release

oracle_pkg() {
    for pkg in ${packages[@]};
     do check=`yum -q list installed $pkg 2>&1 /dev/null`; 
        if [ $? -ne 0 ]; then
        echo "${pkg} not_installed.";
        else 
        echo "${pkg} is_installed.";
        fi 
    done
}

Ubuntu_exec(){
for pkg in ${packages[@]}; do
    pkg_info=`apt list $pkg 2> /dev/null |grep -i installed | sed 's/\// /g'  | awk '{print $1}'`
    if [ "${pkg}" == "${pkg_info}" ]; then
		echo "${pkg} is_installed"
	else
		echo "${pkg} not_installed"
	fi
done

}
case ${ID} in 
"debain") echo "Ubuntu linux not supported as of now" ;; 
"CentOS") oracle_pkg ;; 
"SUSE") echo "SUSE linux not supported" ;; 
"Red") oracle_pkg ;; 
"Oracle") oracle_pkg ;; 
"Amazon") oracle_pkg ;; 
*) echo -e "OS Type not detected ";; 
esac
