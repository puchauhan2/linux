os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;
R='\033[1;31m'     # ${R}
G='\033[1;32m'     # ${G}
C='\033[0m'        # ${C}
Y='\033[1;33m'     # ${Y}

    # Unable to catch via ${@} and ${*}
arg1=${1};arg2=${2};arg3=${3};arg4=${4};arg5=${5};arg6=${6};arg7=${7};arg8=${8};arg9=${9};arg10=${10}

check_status(){
    if [[ ${1} != "0" ]]
    then
        echo -e "${R}Unable to install package ${2}${C}"
    else
        echo -e "${G}Sucessfully installed package ${2}${C}"
    fi
}

oracle_pkg() {
    hostnamectl | grep "Operating System"
    packArray=`echo "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}" "${arg9}" "${arg10}"`
    for pack in ${packArray}
    do 
    case ${pack} in
        "brutils-2.7")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    yum localinstall /tmp/brutils-2.7-1.el8.x86_64.rpm -y
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "lsof")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    yum localinstall /tmp/lsof-4.87-6.el7.x86_64.rpm -y
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "sysstat")
		    echo -e "${Y}Installing ${pack}}${C}\n"
		    yum localinstall /tmp/sysstat-10.1.5-20.el7_9.x86_64.rpm -y
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "dmidecode")
		    echo -e "${y}Installing ${pack}${C}\n"
		    yum localinstall /tmp/dmidecode-3.2-5.el7_9.1.x86_64.rpm -y
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "virt-what")
		    echo -e "${y}Installing ${pack}${C}\n"
		    yum localinstall /tmp/virt-what-1.18-4.el7_9.1.x86_64.rpm -y
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "bc")
		    echo -e "${y}Installing ${pack}${C}\n"
		    yum localinstall /tmp/brutils-2.7-1.el8.x86_64.rpm
            errorCode=${?}
            check_status ${errorCode} ${pack}
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
    apt update
    echo -e "${Y} Installing packages${C}"
    packArray=`echo "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}" "${arg9}" "${arg10}"`
    for pack in ${packArray}
    do 
    case ${pack} in
        "brutils")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y /tmp/brutils_2.7-0_amd64.deb
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "gdisk")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "iproute2")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "dmidecode")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "dosfstools")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "lsb-release")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "bc")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "cifs-utils")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "isc-dhcp-client")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "nfs-common")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "sysstat")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        "virt-what")
		    echo -e "${Y}Installing ${pack}${C}\n"
		    apt install -y ${pack}
            errorCode=${?}
            check_status ${errorCode} ${pack}
        ;;
        *)
		    echo -e "${R} Package not found ${C}";
		    exit 1
        ;;
    esac
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
