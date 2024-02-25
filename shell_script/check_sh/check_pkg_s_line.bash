packages=("wow" "lsof" "sysstat" "virt-what" "dmidecode" "bc" "attr" "e2fsprogs" "fdisk" "gzip" "iproute2" "tar" "libxml2-devel" "brutils-2.5" );
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;

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
case $os_flavour_type in 
"Ubuntu") Ubuntu_exec;; 
"CentOS") oracle_pkg ;; 
"SUSE") echo "SUSE linux not supported" ;; 
"Red") oracle_pkg ;; 
"Oracle") oracle_pkg ;; 
"Amazon") oracle_pkg ;; 
*) echo -e "OS Type not detected ";; 
esac
