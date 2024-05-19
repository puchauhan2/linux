

#!/bin/bash
source modules/report.bash
initializer

orgument='-q -o BatchMode=yes -o StrictHostKeyChecking=no'
pack='MicrosoftDefenderATPOnboardingLinuxServer.py  QualysCloudAgentx64.rpm cribl-4.tgz modules/status.bash'
#pack='post_migrationscript.bash'
bypass='-o StrictHostKeyChecking=no -O'
mkdir -p log
> count.txt
R='\033[1;31m'     # ${BR}
G='\033[1;32m'     # ${BG}
C='\033[0m'        # ${NC}
Y='\033[1;33m'     # ${BY}
m100='\U01F4AF'
cross='\u274c'
ssh_user='ec2-user'
key=./key.pem


function send_file(){
    log_path=${PWD}/log/${1}_scp_log.txt
    echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
    scp -v -i ${key} ${bypass} ${pack} ${ssh_user}@$1:/home/${ssh_user}/  2>&1| tee -a "${log_path}"
}

function scp_xfer() {

    echo -e "${Y} Sending File ${1}${C}"
    log_path=${PWD}/log/${1}_scp_log.txt
    send_file ${1}
    errorCode1=${?}

    if [[ ${errorCode1} = 0 ]]
    then
        echo -e "${G} File Sent successfully to ${1}${C}"
        echo -e ${1} >> final.txt
    else
        echo -e "${R} Connection or Something error for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function send_postmgr_file(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server_list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            scp_xfer ${ip} &
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}


function menu (){
echo -e "${Y} Press 1 to Execute One Shot Postmigration ${C}\n"
echo -e "${Y} Press 2 to Send package to servers ${C}\n"
echo -e "${Y} Press 3 to Execute Postmigration first time on server ${C}\n"
echo -e "${Y} Press 4 to Execute Postmigration normally on server ${C}\n"
echo -e "${Y} Press 5 to Delete Migration package  ${C}\n"
read -p "Please enter your choice OR Press CTRL + c to Exit " choice

case ${choice} in
   "2")
		echo -e "${Y} Sending package ${C}\n"
		send_postmgr_file
      ;;
   "3")
		echo -e "${Y} Executing Postmigration firstrun ${C}\n"
        execute_command
      ;;
   "4")
		echo -e "${Y} Executing Postmigration normally ${C}\n"
         postmigration_normal
      ;;
   "5")
		echo -e "${Y} Deleting Migration Package ${C}\n"
        delete_pkg_server
      ;;
   "1")
		echo -e "${Y} Executing One Shot Postmigration ${C}";
		one_shot
      ;;
   *)
		echo -e "${R} This choice is under Development ${C}";
		exit 1
     ;;
esac
}
menu

