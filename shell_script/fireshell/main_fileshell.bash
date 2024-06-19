#!/bin/bash
source modules/report.bash
source modules/logo.bash
initializer
logo

argument='-q -o BatchMode=yes -o StrictHostKeyChecking=no'
bypass='-o StrictHostKeyChecking=no -O'

R='\033[1;31m'     # ${R}
G='\033[1;32m'     # ${G}
C='\033[0m'        # ${C}
Y='\033[1;33m'     # ${Y}
m100='\U01F4AF'
cross='\u274c'
ssh_user='ec2-user'  # Change your user name here 
key=./key.pem        # Fix your key file here
port='22'            # Change port here

echo -e "\nPlease confirm mode of execution,type ${Y}Yes${C} for parallel server execution OR ${Y}No${C} for single sever execution\n"
read mode
case ${mode} in
   "yes"|"Yes"|"Y"|"y")
		echo -e "${Y} \nYou have selected ${G}Parallel${Y} server execution mode ${C}\n"
      ;;
   "No"|"no"|"N"|"n")
		echo -e "${Y} \nYou have selected ${G}Single${Y} sever execution mode${C}\n"
      ;;
   *)
		echo -e "${R} Wrong Choice or Nothing selected ${C}";
		exit 1
     ;;
esac

############### executers ####################

#### 1
function system_info_executer(){
   ssh ${argument} -i ${key} -p ${port} ${ssh_user}@${1} 'sudo -n bash -s' < modules/system_info.bash ;
}

#### 2
function run_your_script_executer(){
   ssh ${argument} -i ${key} -p ${port} ${ssh_user}@${1} 'sudo -n bash -s' < modules/run_your_script.bash ;
}

#### 3
function pack_check_executer(){
   ssh ${argument} -i ${key} -p ${port} ${ssh_user}@${1} 'sudo -n bash -s' < modules/check_pkg.bash ;
}

#### 4
function pack_install_executer(){
   pack_details=`cat log/${1}_install_pkg.txt`
   echo -e "\n Installing package ${pack_details} on ${1}"
   ssh ${argument} -i ${key} -p ${port} ${ssh_user}@${1} 'sudo -n bash -s' < modules/install_pkg.bash "${pack_details}" ;
}

##### 5
function scp_install_executer(){
    scp -i ${key} ${bypass} package/* ${ssh_user}@${1}:/tmp/    
}
#################### execution status check ##################
#### 1
function system_info_exec(){

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

#### 2
function run_your_script_exec(){
   
   echo -e "${Y} Executing Command on ${1}${C}"
   run_your_script_executer ${1}
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

#### 3
function pack_check_exec(){

    echo -e "${Y} Checking package on ${1}${C}"
    log_path_pack_check="log/pkg_result_${1}"
    pack_check_executer ${1} > ${log_path_pack_check}

    errorCodepackCheck=${?}

    if [[ ${errorCodepackCheck} = 0 ]]
    then
        is_installed=`awk '/is_installed/ {print $1}' ${log_path_pack_check}`
        not_installed=`awk '/not_installed/ {print $1}' ${log_path_pack_check}`

         if [[ -z ${not_installed} ]]
         then
            :
         else
            echo ${1} ${not_installed} >> log/not_installed.txt
            echo ${not_installed} > log/${1}_install_pkg.txt 
            echo -e ${1} >> log/success_server_pkg_install.txt          
         fi
        echo ${1} ${is_installed} >> log/is_installed_server.txt
    else
        echo -e "${R} Connection or Some error occured for ${1} ${cross}${Y} moving to next server ${C}\n"
        echo -e ${1} >> log/failed_server.txt
    fi
    echo "executed" >> log/count.txt
}

#### 4
function pack_install_exec(){

   echo -e " Sending Packages to ${1}"
   scp_install_executer ${1}
   errorPackSend=${?}
   if [[ ${errorPackSend} = 0 ]]
   then
      echo -e "${G} Package copied successfully on ${1}${C}"
   else
      echo -e "${R} Package Copy Fail on ${1} ${cross}${Y} moving to next server ${C}\n"
      echo -e ${1} >> log/failed_server.txt
      echo "executed" >> log/count.txt
      exit 1
    fi

   echo -e "${Y} Installing package on ${1}${C}"
   pack_install_executer ${1}
   errorPackInstall=${?}

   if [[ ${errorPackInstall} = 0 ]] && [[ ${errorPackSend} = 0 ]]
   then
      echo -e "${G} Installation successfully on ${1}${C}"
      echo -e ${1} >> log/success_server.txt
   else
      echo -e "${R} Connection or Some error occured for ${1} ${cross}${Y} moving to next server ${C}\n"
      echo -e ${1} >> log/failed_server.txt
    fi
    echo "executed" >> log/count.txt
}

############### job distributor and logger #################

#### 1
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
            
            if [[ ${mode} == "yes" ]] || [[ ${mode} == "Yes" ]] || [[ ${mode} == "Y" ]] || [[ ${mode} == "y" ]]
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

#### 2
function run_your_script(){
    initializer
    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
        exit 1
    else
        for ip in ${list_server}; do
            echo $ip
            log_path=${PWD}/log/${ip}_run_your_script_log.txt
            echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            
            if [[ ${mode} == "yes" ]] || [[ ${mode} == "Yes" ]] || [[ ${mode} == "Y" ]] || [[ ${mode} == "y" ]]
            then
               run_your_script_exec ${ip} 2>&1| tee -a "${log_path}" &
            else
               run_your_script_exec ${ip} 2>&1| tee -a "${log_path}"
            fi
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}

#### 3
function pack_check() {
   initializer
   > log/success_server_pkg_install.txt
   list_server=`cat server.txt`
   if [[ -z ${list_server} ]]
   then
      echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
      exit 1
   else
      for ip in ${list_server}; do
         echo $ip
         log_path=${PWD}/log/${ip}_pack_check_log.txt
         echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            
         if [[ ${mode} == "yes" ]] || [[ ${mode} == "Yes" ]] || [[ ${mode} == "Y" ]] || [[ ${mode} == "y" ]]
         then
            pack_check_exec ${ip} 2>&1| tee -a "${log_path}" &
         else
            pack_check_exec ${ip} 2>&1| tee -a "${log_path}"
         fi
            let num_ip++
        done
    fi
    sleep 0.01
    show_report_pack_check
}

#### 4
function pack_install() {
   echo -e "\n######################### Executed Package Install #########################\n"
   initializer
   list_server=`cat log/success_server_pkg_install.txt`
   if [[ -z ${list_server} ]]
   then
      echo -e "${R} Server list is empty ${cross}\n${Y} please fill server list${C}"
      exit 1
   else
      for ip in ${list_server}; do
         echo $ip
         log_path=${PWD}/log/${ip}_pack_install_log.txt
         echo -e "\n\n######################### `date` #########################\n" >> "${log_path}"
            
         if [[ ${mode} == "yes" ]] || [[ ${mode} == "Yes" ]] || [[ ${mode} == "Y" ]] || [[ ${mode} == "y" ]]
         then
            pack_install_exec ${ip} 2>&1| tee -a "${log_path}" &
         else
            pack_install_exec ${ip} 2>&1| tee -a "${log_path}"
         fi
            let num_ip++
        done
    fi
    sleep 0.01
    show_report
}
################ Menu ################

function menu (){
echo -e "${G} \n########## Printing Menu ######### ${C}\n"
echo -e "${Y} Press 1 Get System Info ${C}\n"
echo -e "${Y} Press 2 To run your script ${C}\n"
echo -e "${Y} Press 3 To run Package Check and install ${C}\n"
read -p "Please enter your choice OR Press CTRL + c to Exit " choice

case ${choice} in
   "1")
		echo -e "${Y} Executing System info ${C}\n"
		time system_info
      ;;
   "2")
		echo -e "${Y} Run Your Script ${C}\n"
      time run_your_script
      ;;
   "3")
		echo -e "${Y} Check Package ${C}\n"
      time pack_check
      ;;
   *)
		echo -e "${R} This choice is under Development ${C}";
		exit 1
     ;;
esac
}
menu