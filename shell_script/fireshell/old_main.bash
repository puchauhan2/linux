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
    scp -v -i ${key} ${bypass} ${pack} ${ssh_user}@$1:/home/${ssh_user}/ 
}

function executer(){
    ssh ${orgument} -i ${key} ${ssh_user}@${1} 'sudo -n bash -s' < modules/post_migrationscript.bash firstrun ;
}

function executer_post_normal(){
    ssh ${orgument} -i ${key} ${ssh_user}@${1} 'sudo -n bash -s' < modules/post_migrationscript.bash 
}

function delete_pkg(){
    ssh ${orgument} -i ${key} ${ssh_user}@${1} 'bash -s' < modules/deletepkg.bash ;
}


function scp_xfer() { 

    echo -e "${Y} Sending File ${1}${C}"
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

function command_exec() { 

    echo -e "${Y} Executing Command on ${1}${C}"
    executer ${1}  
    errorCode2=${?}

    if [[ ${errorCode2} = 0 ]]
    then
        echo -e "${G} Command executed successfully on ${1}${C}"
        echo -e ${1} >> final.txt
    else
        echo -e "${R} Connection or Something error for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function post_log_function() { 

    echo -e "${Y} Executing Command on ${1}${C}"
    executer_post_normal ${1}  
    errorCode3=${?}

    if [[ ${errorCode3} = 0 ]]
    then
        echo -e "${G} Command executed successfully on ${1}${C}"
        echo -e ${1} >> final.txt
    else
        echo -e "${R} Connection or Something error for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function delete_pkg_comm() {

    echo -e "${Y} Executing delete on ${1}${C}"
    delete_pkg ${1}  
    errorCode4=${?}

    if [[ ${errorCode4} = 0 ]]
    then
        echo -e "${G} Migration package deleted successfully on ${1}${C}"
        echo -e ${1} >> final.txt
    else
        echo -e "${R} Connection or Something error for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function execute_command(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_exec_postmigration_firstrun_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            command_exec ${ip} 2>&1| tee -a "${log_path}" &
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

function send_postmgr_file(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_scp_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            scp_xfer ${ip} 2>&1| tee -a "${log_path}" &
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

function delete_pkg_server(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_delete_pkg_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            delete_pkg_comm ${ip} 2>&1| tee -a "${log_path}" &
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

function postmigration_normal(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_postmigration_normal_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            post_log_function ${ip} 2>&1| tee -a "${log_path}" &
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

function one_shot_scp_xfer() { 

    echo -e "${Y} Sending File ${1}${C}"
    server_ip_addr=${1}
    send_file ${1} 
    errorCode5=${?}
    echo -e "${Y} Executing Postmigration on ${1}${C}"
    executer ${server_ip_addr}
    errorCode6=${?}

    if [[ ${errorCode5} = 0 ]] && [[ ${errorCode6} = 0 ]]
    then
        echo -e "${G} Postmigration done on ${1}${C}"
        echo -e ${1} >> final.txt
    else
        echo -e "${R} Connection or Something error for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function one_shot(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server Slist${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_one_shot_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            one_shot_scp_xfer ${ip} 2>&1| tee -a "${log_path}" &
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