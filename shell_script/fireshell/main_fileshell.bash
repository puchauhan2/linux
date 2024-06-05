#!/bin/bash
source modules/report.bash
initializer

orgument='-q -o BatchMode=yes -o StrictHostKeyChecking=no'
bypass='-o StrictHostKeyChecking=no -O'

R='\033[1;31m'     # ${R}
G='\033[1;32m'     # ${G}
C='\033[0m'        # ${C}
Y='\033[1;33m'     # ${Y}
m100='\U01F4AF'
cross='\u274c'
ssh_user='ec2-user'
key=./key.pem 

echo -e "Please confirm mode of execution,type ${Y}Yes${C} for parallel server execution OR ${Y}No${C} for single sever execution\n"
read mode
case ${mode} in
   "yes" | "Yes")
		echo -e "${Y} You have selected parallel server execution ${C}\n"
      ;;
   "No" | "no")
		echo -e "${Y} single sever execution ${C}\n"
      ;;
   *)
		echo -e "${R} Wrong Choice or Nothing selected ${C}";
		exit 1
     ;;
esac

function system_info_executer(){
   ssh ${orgument} -i ${key} ${ssh_user}@${1} 'sudo -n bash -s' < modules/system_info.bash ;
}

function system_info_exec(){
   system_info_executer ${1}

   echo -e "${Y} Executing Command on ${1}${C}"
   system_info_executer ${1}
   errorCodeSystem_info=${?}

   if [[ ${errorCodeSystem_info} = 0 ]]
   then
      echo -e "${G} Command executed successfully on ${1}${C}"
      echo -e ${1} >> log/success_server.txt
   else
      echo -e "${R} Connection or Some error occured for ${1} ${cross}${Y} moving to next server ${C}\n"
      echo -e ${1} >> log/failed_server.txt
    fi
    echo "executed" >> log/count.txt
}

function system_info(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_system_info_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            
            if [[ ${mode} == "yes" ]] || [[ ${mode} == "Yes" ]]
            then
               system_info_exec ${ip} 2>&1| tee -a "${log_path}" &
            else
               system_info_exec ${ip} 2>&1| tee -a "${log_path}"
            fi
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

function menu (){
echo -e "${G} ########## Printing Menu ######### ${C}\n"
echo -e "${Y} Press 1 get System Info ${C}\n"
echo -e "${Y} Press 2 to Send package to servers ${C}\n"
echo -e "${Y} Press 3 to Execute Postmigration first time on server ${C}\n"
echo -e "${Y} Press 4 to Execute Postmigration normally on server ${C}\n"
echo -e "${Y} Press 5 to Delete Migration package  ${C}\n"
read -p "Please enter your choice OR Press CTRL + c to Exit " choice

case ${choice} in
   "1")
		echo -e "${Y} Executing System info ${C}\n"
		system_info
      ;;
   "2")
		echo -e "${Y} Executing Postmigration firstrun ${C}\n"
        execute_command
      ;;
   "3")
		echo -e "${Y} Executing Postmigration normally ${C}\n"
         postmigration_normal
      ;;
   "4")
		echo -e "${Y} Deleting Migration Package ${C}\n"
        delete_pkg_server
      ;;
   "5")
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