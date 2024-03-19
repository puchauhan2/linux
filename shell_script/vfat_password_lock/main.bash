#!/bin/bash
source ./var.bash

function initializer () {

    > final.txt
    > failed_server.txt
    > is_installed_server.text
    > count.txt
    mkdir -p log
    count=0
    num_ip=0
    tput sgr0
}
initializer

function executer (){
    timeout 60s ssh ${orgument} -i ${key} ec2-user@${1} 'sudo -n bash -s' < check_vfat.bash;
}


function show_report (){
    echo "================================== Executed show report Function ======================================"
    count=`awk 'END { print NR }' count.txt`  
    while [ ${count} != ${num_ip} ];
    do
        count=`awk 'END { print NR }' count.txt`  
        progressbar ${count} ${num_ip}
    done
    echo -e "\n Showing Report\n"
    echo -e "\n${BG} Suscessfully Fetched Unavailable Package Details for Below server.You can also check file final.txt ${mark100}${NC}"
    awk '{print NR " -",$0}' final.txt
    echo -e "\n${BR} Failed to pull Package Details for below servers because of network or login issue,please check log dir for more info ${cross}${NC}"
    awk '{print NR " -",$0}' failed_server.txt
    echo -e "\n${BG} Package present for Below server.You can also check file is_installed_server.text ${mark100}${NC}"
    awk '{print NR " -",$0}' is_installed_server.text
    tput sgr0
}

echo -e "#############################\n"

function vfat_check() { # Where are you going ,look at here

    echo -e "${BY} Checking package for ${1}${NC}"
    log_path=${PWD}/log/pkg_result_${1}
    executer ${1} "echo "${2}" | base64 -d > check.sh && sudo bash check.sh" > ${log_path}
    errorCode1=${?}

    if [[ ${errorCode1} = 0 ]]
    then
        is_installed=`awk '/is_installed/ {print $1}' ${log_path}`
        not_installed=`awk '/not_installed/ {print $1}' ${log_path}`
        echo ${1} ${not_installed} >> final.txt
        echo ${1} ${is_installed} >> is_installed_server.text
        echo "executed" >> count.txt
    else
        echo "executed" >> count.txt
        echo -e "${BR} Connection or Something error for ${1} ${cross}${BY} moving to next server ${NC}\n"
        echo -e ${1} >> failed_server.txt
    fi
}

function server_ip(){

    initializer
    list_server=`cat server_list.txt`
    if [[ -z ${list_server} ]]
        then
            echo -e "${BR} Server list is empty ${cross}\n${BY} please fill server_list${NC}"
            exit 1
        else
            for ip in ${list_server}; do
            vfat_check ${ip} & # line execution and thread
            let num_ip++
            done
            show_report
        fi
}

server_ip
