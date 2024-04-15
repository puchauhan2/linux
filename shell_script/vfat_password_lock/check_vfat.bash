#!/bin/bash
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
m100='\U01F4AF'     # ${m100}
cross='\u274c\n'    # ${cross}

function add_password(){
    username='gecloud'
    password='$6$y5Nkq./rYUPNrwXw$7XHMGjC93HwLRnqeGr4RC.4GYyvUnqML/3yKKsejWn7OfH6Lzfn7sJ1EE9j.y5yNWrEBHNE9gq/pGLYg4qeSx1' # Password  hash sha512
    echo ${username}:${password} | chpasswd -e
    errorCode1=${?}
    if [[ ${errorCode1} = 0 ]]
    then
    echo -e "\n${BY}OutPut :${BG} Password added to ${username} user ${m100}${NC}"
    else
    echo -e "\n${BY}OutPut :${BR} Error while adding Password to ${username} ${cross}"
    fi
}

function enable_vfat(){

    grep '#install fat /bin/true' /etc/modprobe.d/dev-sec.conf
    errorCode5=${?}
    grep '#install vfat /bin/true' /etc/modprobe.d/dev-sec.conf
    errorCode6=${?}

    if [[ ${errorCode5} = 0 ]] || [[ ${errorCode6} = 0 ]]
    then 
    modprobe -v vfat && echo -e "${BY}OutPut :${BG} UnModified Config: Enabled Vfat ${m100}${NC}"
    else 
    echo -e "Taking Backup of config file"
    cp -p /etc/modprobe.d/dev-sec.conf /etc/modprobe.d/dev-sec.conf_bk && echo -e "${BG} Backup configuration Completed ${m100}${NC}"
    sed -i 's:install vfat /bin/true:#install vfat /bin/true:g'  /etc/modprobe.d/dev-sec.conf
    sed -i 's:install fat /bin/true:#install fat /bin/true:g'  /etc/modprobe.d/dev-sec.conf
    modprobe -v vfat && echo -e "${BY}OutPut :${BG} Modified Config: Enabled Vfat ${m100}${NC}"
    fi
}

function check_vfat_cfg(){
    grep 'install fat /bin/true' /etc/modprobe.d/dev-sec.conf
    errorCode3=${?}
    grep 'install vfat /bin/true' /etc/modprobe.d/dev-sec.conf
    errorCode4=${?}

    if [[ ${errorCode3} = 0 ]] || [[ ${errorCode4} = 0 ]]
    then 
    echo -e "${BG} Vfat configuration file found,going to enable Vfat ${m100}${NC}"
    enable_vfat
    else 
    echo -e "${BY}OutPut :${BG} Vfat configuration file not found but Still you can proceed for migration ${m100}${NC}"
    fi
}

function check_vfat(){
    lsmod | grep vfat
    errorCode2=${?}

    if [[ ${errorCode2} != 0 ]]
    then 
    echo -e "Vfat not Found,checking configuration"
    check_vfat_cfg
    else 
    echo -e "\n${BY}OutPut :${BG} Vfat already enabled ${m100}${NC}"
    fi
}

go(){
    add_password
    check_vfat
}

case ${os_flavour_type} in 
"Ubuntu") go ;; 
"CentOS") go ;; 
"SUSE") echo -e "${BY}OutPut :${BR} SUSE linux not supported${NC}" ;; 
"Red") go ;; 
"Oracle") echo -e "${BY}OutPut :${BR} Oracle linux not supported currently${NC}" ;; 
"Amazon") go ;; 
*) echo -e "${BY}OutPut :${BR} OS Type not detected ${NC}";; 
esac

#echo -e "${BY}OutPut :${BR} Amazon linux not supported currently${NC}"
#echo -e "${BY}OutPut :${BR} Ubuntu linux not supported currently${NC}"