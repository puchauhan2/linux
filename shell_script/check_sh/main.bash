source ./var.bash

initializer () {

    > final.txt
    > failed_server.txt
    > count.txt
    mkdir -p log
    count=0
    num_ip=0
    tput sgr0
}
initializer

executer (){
    timeout 60s ssh ${bypass} -i ${key} ec2-user@${1} ${2}
}

send_file (){

    echo -e "${BY} Sending package check script to ${1} ${NC} \n"
    timeout 60s scp ${bypass} -i ${key} find_pkg.sh ec2-user@${1}:~
}

show_report (){
    echo "================================== Executed show report Function ======================================"
    count=`wc -l count.txt | awk '{print$1}'`  
    while [ ${count} != ${num_ip} ];
    do
        count=`wc -l count.txt | awk '{print$1}'`
        progressbar ${count} ${num_ip}
    done
    echo -e "\n Showing Report\n"
    echo -e "${BG} Suscessfully Fetched Server Report for Unavailable packages ${mark100}${NC}\n"
    cat final.txt
    echo -e "\n${BR} Failed to pull report for below servers because of network issue ${cross}${NC}\n"
    cat failed_server.txt
    tput sgr0
}

echo -e "#############################\n"

pack_check() {

    echo -e "${BY} Checking package for ${1}${NC}"
    log_path=${PWD}/log/pkg_result_${1}
    send_file ${1} && executer ${1} "sudo bash find_pkg.sh" > ${log_path}
    errorCode1=${?}

    if [[ ${errorCode1} = 0 ]]
    then
        is_installed=`cat ${log_path} | grep --fixed-strings "is_installed" | awk '{print $1}'`
        not_installed=`cat ${log_path} | grep --fixed-strings "not_installed" | awk '{print $1}'`
        echo ${1} ${not_installed} >> final.txt
        echo "executed" >> count.txt
    else
        echo "executed" >> count.txt
        echo -e "${BR} Connection error for ${1} ${cross}${BY} moving to next server ${NC}\n"
        echo -e ${1} >> failed_server.txt
    fi
}

server_ip(){

    initializer
    for ip in `cat server_list`; do
        pack_check ${ip} &
        let num_ip++
    done
    show_report
}

menu (){

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