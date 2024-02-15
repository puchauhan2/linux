#!/bin/bash

username=trianz-admin2
password=trinaz#872465sdffs
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}

check_for_root_user(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BR}\n Script must be run as root or sudo${NC}" 1>&2
        exit 1
    fi
}
check_for_root_user

case $os_flavour_type in
   "Ubuntu")
		echo -e "1)${BY} Detected OS type : $full_os_name${NC}"
		user_group=sudo
      ;;
   "CentOS")
		echo -e "1)${BY} Detected OS type : $full_os_name${NC}" 
		user_group=wheel
      ;;
   "SUSE")
		echo -e "1)${BY} Detected OS type : $full_os_name${NC}" 
		user_group=wheel
      ;;
   "Red")
		echo -e "1)${BY} Detected OS type : $full_os_name${NC}" 
		user_group=wheel
      ;;
   "Oracle")
		echo -e "1)${BY} Detected OS type : $full_os_name${NC}" 
		user_group=wheel
      ;;
   *)
		echo -e "1)${BY} OS Type not detected , Exiting${NC}";
		exit 1
     ;;
esac

echo -e "${BY}You are going to create user ${NC}${username}${BY},You can also change public key ${NC}"
read -p " Press any key to continue... OR Press CTRL + c to Exit " -n1 -s
echo " "

useradd ${username} && usermod -aG ${user_group} ${username} && echo -e "2)${BG} User created and added as sudo user${NC}"

erroCode=$?

if [[ $erroCode != 0 ]]
then

   echo -e "2) ${BG}Error while creating user,Exiting${NC}"
   exit 1

else

echo ${username}:${password} | chpasswd && echo -e "${BG}Password adedd to user${NC}"

grep "+ : ${username} : ALL" /etc/security/access.conf 
erroCode1=$?

if [[ $erroCode1 != 0 ]]
then
   echo "+ : ${username} : ALL" >> /etc/security/access.conf && echo -e "3)${BG} witten acces.conf${NC}"
fi

grep "auth   \[default=1 ignore=ignore success=ok\] pam_localuser.so" /etc/pam.d/sshd
erroCode2=$?

if [[ $erroCode2 != 0 ]]
then
   echo "auth   [default=1 ignore=ignore success=ok] pam_localuser.so" >> /etc/pam.d/sshd && echo -e "4)${BG} Added parameter in sshd${NC}"
fi

grep "${username} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
erroCode3=$?

if [[ $erroCode3 != 0 ]]
then
   echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo -e "5)${BG} Added passwordless sudo user swithch${NC}"
fi

mkdir -p /home/${username}/.ssh && echo -e "6)${BG} created .ssh dir${NC}"
touch /home/${username}/.ssh/authorized_keys && echo -e "7)${BG} created file authorized_keys${NC}"
chmod 700 /home/${username}/.ssh && echo -e "8)${BG} permission changed 700 on .ssh${NC}"
chmod 600 /home/${username}/.ssh/authorized_keys && echo -e "9)${BG} permission changed 600 on authorized_keys ${NC}"
chown -R ${username} /home/${username}/.ssh && echo -e "10)${BG} changed ownership${NC}"

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgqrnLnkW+5xJeFxDXLF8hundVkvUc4ykNOjjk/GDxB8SHxpkEPQ63P0scbZfuqmrY74KlN60rxG4m/iSPcWYFtkEAmvPwGyGvGqBVDRzsCr+X/NIoBID/fenZvrliQCtxY+26uFv+jLrGB6aVfAlU+C73ZUCFBXZXa3e/vokN9zPzXDcg/60aXzNAAj27qii71npcu3mrc0mJ+EJ7J9pG+Z4KhnAFwgaK8YfXC7ixwYrj7KAcSpPsbE23I5cF2qQeDUeCj6v0oiJy7l6rNWuWF8v6gv7Tt7UqJu8Sz1hLsqB6kQlYDazGGl3NdvGgpPOFPnAbbNfg5DMMBx8JKVZbMz87mkXqac2T5K4PunsgLSh2Iv8A7gI8bIzwZqE5Uh4RT6lUnA7n4vBXYQPOveXrmRZwyz9pFO5uXhTHPCiT6EWhO/vtl66wjDTTrLpm+Ko1qgzrP4vMcm7w0y0NFbP8jxjcaKWqoRUznWzxIEHGTgmeIYd4lijiK5r6yB99X48= TRIANZ+puneet.chauhan@DESKTOP-DPV83G5" > /home/${username}/.ssh/authorized_keys && echo -e "11)${BG} key added${NC}"

## Repalce your public key in above line in echo 

service sshd restart && echo -e "12)${BY} restarted SSH Daemon${NC}"

fi