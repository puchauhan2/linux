#!/bin/bash
source ./var.bash

function initializer () {

    clear
    > final.txt
    > failed_server.txt
    > is_installed_server.text
    > count.txt
    > install_pkg
    mkdir -p log
    count=0
    num_ip=0
    tput sgr0
    cat check_pkg_s_line.bash | base64 -w 0 >encoded_code.sh
}
initializer

function executer (){
    timeout 25s ssh ${bypass} -i ${key} ec2-user@${1} ${2}
}

function send_file (){

    echo -e "${BY} Sending package check script to ${1} ${NC} \n"
    timeout 25s scp ${bypass} -i ${key} find_pkg.sh ec2-user@${1}:~
}

function show_report (){
    echo "================================== Executed show report Function ======================================"
    count=`awk 'END { print NR }' count.txt`  
    while [ ${count} != ${num_ip} ];
    do
        #count=`wc -l count.txt | awk '{print$1}'`
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

function pack_check() { # Where are you going ,look at here

    echo -e "${BY} Checking package for ${1}${NC}"
    log_path=${PWD}/log/pkg_result_${1}
    #send_file ${1} && executer ${1} "sudo bash find_pkg.sh" > ${log_path} # enable file base execution
    executer ${1} "echo "${2}" | base64 -d > check.sh && sudo bash check.sh" > ${log_path}
    errorCode1=${?}

    if [[ ${errorCode1} = 0 ]]
    then
        is_installed=`awk '/is_installed/ {print $1}' ${log_path}`
        not_installed=`awk '/not_installed/ {print $1}' ${log_path}`
        echo ${1} ${not_installed} >> final.txt
        echo ${not_installed} >> install_pkg
        echo ${1} ${is_installed} >> is_installed_server.text
        echo "executed" >> count.txt
    else
        echo "executed" >> count.txt
        echo -e "${BR} Connection or Something error for ${1} ${cross}${BY} moving to next server ${NC}\n"
        echo -e ${1} >> failed_server.txt
    fi
}

function pack_install(){
    install_server_list=`awk '{print $1}' final.txt`
    array_install_server_list=(${install_server_list})
    num_server=${#array_install_server_list[@]}
    for server_ip in seq ${num_server};do
    echo ${array_install_server_list[${server_ip}]}
    done
}

function server_ip(){

    initializer
    line_command=`cat encoded_code.sh`
    list_server=`cat server_list`
    if [[ -z ${list_server} ]]
        then
            echo -e "${BR} Server list is empty ${cross}\n${BY} please fill server_list${NC}"
            exit 1
        else
            for ip in ${list_server}; do
            pack_check ${ip} ${line_command} & # line execution and thread
            let num_ip++
            done
            show_report
        fi
}

function menu (){

echo -e "${BY} Press 1 to check package in server${NC}\n"
echo -e "${BY} Press 2 to install missing package${NC}\n"
echo -e "${BY} Press 3 to re-initialize and clear last work done ${NC}\n"
read -p "Please enter your choice OR Press CTRL + c to Exit " choice

case ${choice} in
   "1")
		echo -e "${BY} Checking Package${NC}\n"
		server_ip
      ;;
   "2")
		echo -e "${BY} Under development ${NC}\n"
        menu
      ;;
   "3")
		echo -e "${BY} Under development${NC}\n"
        menu
      ;;
   "4")
		echo -e "${BY} Under development${NC}\n"
        menu
      ;;
   "5")
		echo -e "${BY} Under development${NC}\n"
        menu
      ;;
   *)
		echo -e "${BR} No Match Found , Exiting ${cross}${NC}";
		exit 1
     ;;
esac
}

menu