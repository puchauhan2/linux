os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;

arg1=${1};arg2=${2};arg3=${3};arg4=${4};arg5=${5};arg6=${6};arg7=${7};arg8=${8};arg9=${9};arg10=${10}

oracle_pkg() {
    hostnamectl | grep "Operating System"
    # Unable to catch via ${@} and ${*}
    packArray=`echo "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}" "${arg9}" "${arg10}"`
    for pack in ${packArray}
    do 
    case ${pack} in
        "brutils-2.7")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        "lsof")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        "sysstat")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        "dmidecode")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        "virt-what")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        "bc")
		    echo -e "Installing ${pkg}\n"
		    yum install /tmp/brutils-2.7-1.el8.x86_64.rpm
        ;;
        *)
		    echo -e "${R} Package not found ${C}";
		    exit 1
        ;;
    esac
    done
 
}

Ubuntu_exec(){
    hostnamectl | grep "Operating System"
    echo "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}" "${arg9}" "${arg10}" 
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
