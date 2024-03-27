#!/bin/bash
source var.bash
> count.txt

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
mark100='\U01F4AF'
wrong='\u274c\n'

check_for_root_user(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BR}\n Script must be run as root or sudo ${wrong}${NC}" 1>&2
        exit 1
    fi
}
check_for_root_user

r_text="Detected OS type :"
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`

function create_user() {
    username='gehccloud'
    password='$6$eAmKdfzKWKmAssQL$vOCsi3XJvDVuw/ShbjC14YpD6s/LUmsLOCJVvGiYFx/BVRUbu20iPZja1UWDzJsgdbpG/7bHV/qtp3NDBiaLh1'
   
case $os_flavour_type in
   "Ubuntu")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently Ubuntu is not Supported ${NC}"
      exit 1
      ;;
   "CentOS")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}" 
		user_group=wheel
      ;;
   "SUSE")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently SLES linux is not Supported ${NC}"
      exit 1
		user_group=wheel
      ;;
   "Red")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}" 
		user_group=wheel
      ;;
   "Oracle")
      echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently Oracle linux is not Supported ${NC}"
      exit 1
      ;;
   *)
		echo -e "${BY} OS Type not detected , Exiting${wrong}${NC}";
		exit 1
     ;;
esac

echo -e "${BY}You are going to create user ${NC}${username}${NC}"
#read -p " Press any key to continue... OR Press CTRL + c to Exit " -n1 -s
echo " "

useradd ${username} && usermod -aG ${user_group} ${username} && echo -e "${BG} User created and added as sudo user ${mark100}${NC}"
erroCode=$?
if [[ $erroCode != 0 ]]
then
    echo -e "${BR} Error while creating user,Exiting ${wrong}${NC}"
else

echo ${username}:${password} | chpasswd -e && echo -e "${BG} Password adedd to user ${mark100}${NC}"
grep "+ :${username} : ALL" /etc/security/access.conf 
erroCode1=$?

if [[ $erroCode1 != 0 ]]
then
   echo "+ :${username} : ALL" >> /etc/security/access.conf && echo -e "${BG} witten acces.conf ${mark100}${NC}"
fi

grep "auth   \[default=1 ignore=ignore success=ok\] pam_localuser.so" /etc/pam.d/sshd
erroCode2=$?

if [[ $erroCode2 != 0 ]]
then
   echo "auth   [default=1 ignore=ignore success=ok] pam_localuser.so" >> /etc/pam.d/sshd && echo -e "${BG} Added parameter in sshd ${mark100}${NC}"
fi

grep "${username} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
erroCode3=$?

if [[ $erroCode3 != 0 ]]
then
   echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo -e "${BG} Added passwordless sudo user swithch ${mark100}${NC}"
fi
service sshd restart && echo -e "${BY} restarted SSH Daemon ${mark100}${NC}"

fi
echo "executed 1" >> count.txt
}

function main (){
show_warning
progress &
create_user
remove_splunk
remove_crowd_strike
install_cribil
install_msdefender
install_qualys
}
main