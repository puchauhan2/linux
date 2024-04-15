#!/bin/bash

function initializer () {
    > final.txt
    > failed_server.txt
    > count.txt
    mkdir -p log
    count=0
    num_ip=0
    tput sgr0
}
initializer

ssh_user='ec2-user' # change user here
key=./key.pem       # Change pem key here
port=22             # Optional
orgument='-q -o BatchMode=yes -o StrictHostKeyChecking=no'

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
mark100='\U01F4AF'
cross='\u274c'
ldd=`printf "%105s"`
lde=`printf "%40s"`

function progressbar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "\033[1;32m%${_done}s")
    _empty=$(printf "\033[0m%${_left}s")
    printf "\rProgress : \033[1;33m[${_fill// /#}${_empty// / }\033[1;33m]\033[1;32m ${_progress}%%${NC}"
}

function executer (){
    timeout 35s ssh ${orgument} -i ${key} ${ssh_user}@${1} 'sudo -n bash -s' < check_vfat.bash;
}

function show_report (){
    printf "\n${lde// /=} Showing Logs ${lde// /=}\n"
    count=`awk 'END { print NR }' count.txt`  
    while [ ${count} != ${num_ip} ];
    do
        count=`awk 'END { print NR }' count.txt`  
        progressbar ${count} ${num_ip}
    done

    final=`cat final.txt`
    if [[ -z ${final} ]]
    then
        echo -e ""
    else
        echo -e "\n Showing Report\n"
        echo -e "\n${BG} Successfully Fetched Output for below server ${mark100}${NC}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' final.txt
        printf " ${ldd// /-}\n "
    fi

    failed_server=`cat failed_server.txt`
    if [[ -z ${failed_server} ]]
    then
        echo -e ""
    else
        echo -e "\n${BR} Unable to pull Output for below server ${cross}${NC}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' failed_server.txt
        printf " ${ldd// /-} \n"
    fi
    echo -e "\n${BY} You can also check "log" dir for perticular server log ${NC}"
    tput sgr0
}

echo -e "Executed Main Function"

function vfat_check() { 

    echo -e "${BY} Checking Vfat and Password lock for ${1}${NC}"
    log_path=${PWD}/log/${1}_vfat_output.txt
    > ${log_path}
    executer ${1} >> ${log_path}
    errorCode1=${?}

    if [[ ${errorCode1} = 0 ]]
    then
        is_output=`grep -i "output"  ${log_path}`
        echo ${1} ${is_output} >> final.txt
    else
        echo -e "${BR} Connection or Some error for ${1} ${cross}${BY} moving to next server ${NC}\n"
        echo -e ${1} >> failed_server.txt
    fi
    echo "executed" >> count.txt
}

function execute_main_ip(){

    initializer
    list_server=`cat server_list.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${BR} Server list is empty ${cross}\n${BY} please fill server_list${NC}"
        exit 1
    else
        for ip in ${list_server}; do
            vfat_check ${ip} & # Single execution and thread
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

execute_main_ip