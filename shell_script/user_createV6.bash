#!/bin/bash

username=trianz-admin
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`

case $os_flavour_type in
   "Ubuntu")
		echo "1) Detected OS type : $full_os_name"
		user_group=sudo
      ;;
   "CentOS")
		echo "1) Detected OS type : $full_os_name" 
		user_group=wheel
      ;;
   "SUSE")
		echo "1) Detected OS type : $full_os_name" 
		user_group=wheel
      ;;
   "Red")
		echo "1) Detected OS type : $full_os_name" 
		user_group=wheel
      ;;
   "Oracle")
		echo "1) Detected OS type : $full_os_name" 
		user_group=wheel
      ;;
   *)
		echo "1) OS Type not detected , Exiting";
		exit 1
     ;;
esac

useradd ${username} && usermod -aG ${user_group} ${username} && echo "2) User created and added as sudo user"

erroCode=$?

if [ $erroCode != 0 ]
then

   echo "2) Error while creating user,Exiting"
   exit 1

else

grep "+ : ${username} : ALL" /etc/security/access.conf 
erroCode1=$?

if [ $erroCode1 != 0 ]
then
   echo "+ : ${username} : ALL" >> /etc/security/access.conf && echo "3) witten acces.conf"
fi

grep "auth   \[default=1 ignore=ignore success=ok\] pam_localuser.so" /etc/pam.d/sshd
erroCode2=$?

if [ $erroCode2 != 0 ]
then
   echo "auth   [default=1 ignore=ignore success=ok] pam_localuser.so" >> /etc/pam.d/sshd && echo "4) Added parameter in sshd"
fi

grep "${username} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
erroCode3=$?

if [ $erroCode3 != 0 ]
then
   echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo "5) Added passwordless sudo user swithch"
fi

mkdir -p /home/${username}/.ssh && echo "6) created .ssh dir"
touch /home/${username}/.ssh/authorized_keys && echo "7) created file authorized_keys"
chmod 700 /home/${username}/.ssh && echo "8) permission changed 700 on .ssh"
chmod 600 /home/${username}/.ssh/authorized_keys && echo "9) permission changed 600 on authorized_keys "
chown -R ${username} /home/${username}/.ssh && echo "10) changed ownership"


echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgqrnLnkW+5xJeFxDXLF8hundVkvUc4ykNOjjk/GDxB8SHxpkEPQ63P0scbZfuqmrY74KlN60rxG4m/iSPcWYFtkEAmvPwGyGvGqBVDRzsCr+X/NIoBID/fenZvrliQCtxY+26uFv+jLrGB6aVfAlU+C73ZUCFBXZXa3e/vokN9zPzXDcg/60aXzNAAj27qii71npcu3mrc0mJ+EJ7J9pG+Z4KhnAFwgaK8YfXC7ixwYrj7KAcSpPsbE23I5cF2qQeDUeCj6v0oiJy7l6rNWuWF8v6gv7Tt7UqJu8Sz1hLsqB6kQlYDazGGl3NdvGgpPOFPnAbbNfg5DMMBx8JKVZbMz87mkXqac2T5K4PunsgLSh2Iv8A7gI8bIzwZqE5Uh4RT6lUnA7n4vBXYQPOveXrmRZwyz9pFO5uXhTHPCiT6EWhO/vtl66wjDTTrLpm+Ko1qgzrP4vMcm7w0y0NFbP8jxjcaKWqoRUznWzxIEHGTgmeIYd4lijiK5r6yB99X48= TRIANZ+puneet.chauhan@DESKTOP-DPV83G5" > /home/${username}/.ssh/authorized_keys && echo "11) key added"

## Repalce your public key in above line in echo 


service sshd restart && echo "12) restarted SSH Daemon"

fi