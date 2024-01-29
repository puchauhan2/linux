#!/bin/bash

os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`
BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}

swap_create(){
    echo -e " ${BR}From this point ,action cannot be reverted${NC} "
    dd if=/dev/zero of=/mnt/swapfile bs=1M count=${swap_mb}
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile

    echo "/mnt/swapfile swap swap defaults 0 0" >>  /etc/fstab
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    sysctl -p
    swapon --show && echo -e "${BY} SWAP created ${NC}"

}

check_for_root_user(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BG}\n Script must be run as root or sudo${NC}" 1>&2
        exit 1
    fi
}
check_for_root_user

os_check(){
case $os_flavour_type in
   "Red")
		echo -e "${BG}\n Detected OS type : $full_os_name ${NC}" 
      ;;
   *)
		echo -e "${BR}\n OS Type not detected ,Required OS Redhat ,Exiting${NC}";
		exit 1
     ;;
esac
}

ram_check(){
    pref_value=16
    ram_installed_kb=`grep MemTotal /proc/meminfo | awk '{print $2}'`
    ram_installed_gb=$(( ${ram_installed_kb}/1000000))
    if [ ${ram_installed_gb} -le ${pref_value} ]
    then
        echo -e "${BG}\n System RAM is ${ram_installed_gb} GB , It is recommended to Create SWAP less than or equal to ${ram_installed_gb} GB${NC}"
    else
        echo -e "${BG}\n System RAM is more than ${pref_value} GB ,It is recommended to Create SWAP upto ${pref_value} GB${NC}"
    fi
}

sys_info(){
    disk_info=$(df -h / | awk 'NR==2 {print $4}')
    mem_info=$(free -h | awk 'NR==2 {print $2}')
    echo -e "${BG}\n Available diskspace is  ${disk_info} \n Total RAM is ${mem_info} ${NC}"
}
sys_info

disk_check() {
    disk_available=$(df / | awk 'NR==2 {print $4}')
    percent_inc=0.4
    swap_inc=$(awk "BEGIN {print ${swap_size_in_KB} * ${percent_inc}}")
    swap_40_inc=$(awk "BEGIN {print ${swap_size_in_KB} + ${swap_inc}}")

    if [[ $swap_40_inc -le $disk_available ]]
    then
        echo -e "${BG}\n Disk size is 40% greater or equal to SWAP , Operation can be performed  ${NC}"
    else
        echo -e "${BR}\n Disk has less space available,please increase disk size alteast 40 % of SWAP  ${NC}"
        exit 1
    fi
}

swap_check() {
    swap_dir=`swapon -s|awk '{print $1}'`
    if [[ -z "${swap_dir}" ]]
    then
        echo -e "${BG}\n SWAP file not found,executing further operation${NC}"
    else
        echo -e "${BR}\n SWAP file found : ${swap_dir} , exiting ${NC}"
        exit 1
    fi
}
swap_check

read_swap() {
    echo -e "${BG}\n Enter SWAP memory Size in Megabytes in multiple of 1024,example: 0.5 GB = 512, 1GB = 1024 MB,2 GB = 2048,4 GB = 4096 ....${NC} "
    echo -e "${BY}\n SWAP SIZE should be 40% less than total available disk space ${NC}"
    read swap_mb
}
read_swap

swap_size_check(){
    swap_size_in_KB=$((1024 * ${swap_mb}))
    mem_kb=`grep MemTotal /proc/meminfo | awk '{print $2}'`
    pref_inc_ram=0.2
    mem_20=$(awk "BEGIN {print ${mem_kb} * ${pref_inc_ram}}")
    mem=$(awk "BEGIN {print ${mem_kb} + ${mem_20}}")

    echo $swap_size_in_KB
    if [[ ${swap_size_in_KB} -le ${mem} ]]
    then
        echo -e "${BG}\n Entered SWAP value is less than RAM,Operation can be continued${NC}"
    else
        echo -e "${BR}\n Entered SWAP value is greater than RAM, Operation cannot be continued ${NC}"
        exit 1
    fi
}

if [[ ! -z ${swap_mb} ]]
then
    swap_size_check
    disk_check
    echo -e "${BG}\n your are going to create swap of ${BR}${swap_mb} MB${NC}"
    read -p " Press any key to continue... OR Press CTRL + c to Exit " -n1 -s
    echo " "
    swap_create
else
  echo -e "${BR}\n swap value is not provided,exiting ${NC}"
fi