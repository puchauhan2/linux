os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`
echo "full_os_name ${full_os_name}"

oracle_pkg() {
    packages=("lsof" "bc" "sysstat" "dmidecode" "virt-what" "brutils-2.7" ); # Migration precheck array 
    #packages=("lsof" "bc" "sysstat" "dmidecode" "virt-what" ); # Assesment precheck array 
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

version_id=`grep -i "VERSION_ID" /etc/os-release |awk -F'[^0-9]+' '{print $2}'`

if [[ "${version_id}" == "16" ]] || [[ "${version_id}" == "17" ]] || [[ "${version_id}" == "18" ]] || [[ "${version_id}" == "19" ]]
then
declare -a arr_pkgs=("cifs-utils" "sysstat" "virt-what" "dmidecode" "dosfstools" "isc-dhcp-client" "gdisk" "nfs-common" "lsb-release" "iproute" "brutils")
else
declare -a arr_pkgs=("cifs-utils" "sysstat" "dmidecode" "virt-what" "dosfstools" "isc-dhcp-client" "gdisk" "nfs-common" "e2fsprogs" "iproute2" "lsb-release" "brutils")
fi

for pkg in ${arr_pkgs[@]}; do
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
"SUSE") echo "SUSE linux not supported" ; exit 1 ;; 
"Red") oracle_pkg ;; 
"Oracle") oracle_pkg ;; 
"Amazon") oracle_pkg ;; 
*) echo -e "OS Type not detected ";; 
esac
