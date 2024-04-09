#!/bin/bash

> count.txt
BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
mark100='\U01F4AF'
wrong='\u274c'
argument1=${1}
echo ${argument1}

check_for_root_user(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BR}\n Script must be run as root or sudo ${wrong}${NC}" 1>&2
        exit 1
    fi
}
check_for_root_user

r_text="Detected OS type :"
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`

function create_user() {
    username='gehccloud'
    password='$6$eAmKdfzKWKmAssQL$vOCsi3XJvDVuw/ShbjC14YpD6s/LUmsLOCJVvGiYFx/BVRUbu20iPZja1UWDzJsgdbpG/7bHV/qtp3NDBiaLh1'

case $os_flavour_type in
   "Ubuntu")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently Ubuntu is not Supported ${NC}"
      exit 1
      ;;
   "CentOS")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}" 
		user_group=wheel
      ;;
   "SUSE")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently SLES linux is not Supported ${NC}"
      exit 1
		user_group=wheel
      ;;
   "Red")
		echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}" 
		user_group=wheel
      ;;
   "Oracle")
      echo -e "${BY} ${r_text} ${full_os_name} ${mark100}${NC}"
      echo -e "${BY} Currently Oracle linux is not Supported ${NC}"
      exit 1
      ;;
   *)
		echo -e "${BY} OS Type not detected , Exiting${wrong}${NC}";
		exit 1
     ;;
esac

echo -e "${BY}You are going to create user ${NC}${username}${NC}"
#read -p " Press any key to continue... OR Press CTRL + c to Exit " -n1 -s
echo " "

useradd ${username} && usermod -aG ${user_group} ${username} && echo -e "${BG} User created and added as sudo user ${mark100}${NC}"
erroCode=$?
if [[ $erroCode != 0 ]]
then
    echo -e "${BR} Error while creating user,Exiting ${wrong}${NC}"
else

mkdir -p /home/${username}
chown -R ${username}:${username} /home/${username}

echo ${username}:${password} | chpasswd -e && echo -e "${BG} Password adedd to user ${mark100}${NC}"
grep "+ :${username} : ALL" /etc/security/access.conf 
erroCode1=$?

if [[ $erroCode1 != 0 ]]
then
   echo "+ :${username} : ALL" >> /etc/security/access.conf && echo -e "${BG} witten acces.conf ${mark100}${NC}"
fi

grep "auth   \[default=1 ignore=ignore success=ok\] pam_localuser.so" /etc/pam.d/sshd
erroCode2=$?

if [[ $erroCode2 != 0 ]]
then
   echo "auth   [default=1 ignore=ignore success=ok] pam_localuser.so" >> /etc/pam.d/sshd && echo -e "${BG} Added parameter in sshd ${mark100}${NC}"
fi

grep "${username} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
erroCode3=$?

if [[ $erroCode3 != 0 ]]
then
   echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo -e "${BG} Added passwordless sudo user swithch ${mark100}${NC}"
fi
service sshd restart && echo -e "${BY} restarted SSH Daemon ${mark100}${NC}"

fi
echo "executed 1" >> count.txt
}

check_migration_pkg(){
    ls | grep 'cribl-4.tgz'
    errorcode1=$?
    ls | grep 'QualysCloudAgentx64.rpm'
    errorcode2=$?
    ls | grep 'MicrosoftDefenderATPOnboardingLinuxServer.py'
    errorcode3=$?
    if [[ ${errorcode1} = 0 ]] && [[ ${errorcode2} = 0 ]] && [[ ${errorcode3} = 0 ]]
    then
    echo -e "${BG} Migration Packages found${NC}"
    else
    echo -e "${BR} Migration Package not found, cannot go further ${wrong} ${wrong} ${wrong} ${wrong}${NC}"
    exit 1
    fi
}

function remove_splunk(){

    echo -e "${BY} Searching splunk..${NC}"
    pgrep splunkd
    erroCode4=$?
    if [[ ${erroCode4} != 0 ]]
    then
    echo -e "${BY} Splunk process id not found ,no further action needed${NC}"
    else 
    echo -e "${BG} Splunk Found$,${BY}Removing Splunk${NC}"
    /opt/splunkforwarder/bin/splunk stop && echo -e "${BY} Splunk Stopped${NC}"
    splunk_pkg_name=`rpm -q -a | grep splunk`
    rpm -e ${splunk_pkg_name} && echo -e "${BY} Splunk RPM Package removed${NC}"
    rm -rf /opt/splunkforwarder/ && echo -e "${BY} Directry /opt/splunkforwarder/ has been removed${NC}"
    fi
    echo "executed 2" >> count.txt
}

function remove_crowd_strike(){

    echo -e "${BY} Searching Crowd-strike package${NC}"
    pgrep falcon-sensor
    erroCode5=$?
    if [[ ${erroCode5} != 0 ]]
    then
    echo -e "${BY} Crowd-strike process id not found ,no further action needed ${NC}"
    else
    echo -e "${BG} Crowd-strike Found$,${BY}Removing Crowd-strike${NC}"
    yum remove -y falcon-sensor && echo -e "${BY} Crowd-strike RPM Package removed${NC}"
    fi
    echo "executed 3" >> count.txt
}

function install_cribil(){
    
    pgrep  cribl
    erroCode6=$?
    if [[ ${erroCode6} != 0 ]]
    then
    echo -e "${BY} Installing CRIBIL ${NC}"
    tar -xf cribl-4.tgz && echo -e "${BY} Cribil extracted ${NC}"
    mv -f cribl cribl-edge && mv -f cribl-edge /opt/ && echo -e "${BY} Cribil file copied to /opt/ DIR ${NC}"
    /opt/cribl-edge/bin/cribl mode-managed-edge -H logs-mgmt.data.idx.com -p 443 -u Ix2J7K1FgXEnfRZjK1UJiuRmmC2anCkkRBFADnxS -S true && echo -e "${BY} Cribil Started ${NC}"
    /opt/cribl-edge/bin/cribl boot-start enable -m systemd -u root && echo -e "${BG} Enabled boot start ${NC}"
    chown -R root:root /opt/cribl-edge && echo -e "${BY} Changed /opt/cribl-edge owner ship ${NC}\n"
    cat /opt/cribl-edge/local/cribl/auth/*.dat
    systemctl enable cribl-edge && systemctl restart cribl-edge && echo -e "${BG} systemctl enabled ${NC}"
    systemctl status cribl-edge
    else
    echo -e "${BY} CRIBIL found, no further action needed ${NC}"
    fi
    echo "executed 4" >> count.txt
}

function install_msdefender(){

    pgrep wdavdaemon
    erroCode7=$?
    if [[ ${erroCode7} != 0 ]]
    then
    echo -e "${BY} Installing MS Defender${NC}"
    mkdir -p /etc/opt/microsoft/mdatp/ && echo -e "${BG} Directry /etc/opt/microsoft/mdatp/ created ${NC}"
    yum-config-manager --add-repo=https://packages.microsoft.com/config/rhel/7.2/prod.repo && echo -e "${BG} Added Repository${NC}"
    yum install mdatp -y && echo -e "${BG} Installed mdatp ${NC}"
    python MicrosoftDefenderATPOnboardingLinuxServer.py && echo -e "${BG} mdatp activated ${NC}" 
    else
    echo -e "${BY} MS Defender Found, no further action needed ${NC}"
    fi
    echo "executed 5" >> count.txt
}

function install_qualys(){
    echo -e "${BY} Searching Qualys ${NC}"
    pgrep qualys-cloud-ag
    erroCode8=$?
    [[ ${argument1} == 'firstrun' ]] && erroCode8=1
    if [[ ${erroCode8} != 0 ]]
    then
    echo -e "${BY} ReIntalling Qualys ${NC}"
    rpm -e qualys-cloud-agent
    rpm -ivh QualysCloudAgentx64.rpm && echo -e "${BG}\n Installed Qualys RPM ${NC}"
    sudo /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=d2e94c58-521b-427e-b24c-f1238123d18e CustomerId=35ea7c0f-570c-5acb-81fb-a759ad2f4d9a
    else
    echo -e "${BY}\n Qualys Is already installed ,no further action is need ${NC}"  
    fi
    echo "executed 6" >> count.txt

}

function progressbar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "\033[1;32m%${_done}s")
    _empty=$(printf "\033[0m%${_left}s")
    printf "\rProgress : \033[1;33m[${_fill// /#}${_empty// / }\033[1;33m]\033[1;32m ${_progress}%%${NC}"
}

function show_warning(){
echo -e "
**************************************************************************************************
--------------------------------------------------------------------------------------------------
                        ${BY}Script Made for DEV and STAGE
               Before continue,please take AMI backups of the this VM.
                  Press any key to continue... OR Press CTRL + c to Exit${NC}
--------------------------------------------------------------------------------------------------
**************************************************************************************************"
echo "executed 7" >> count.txt
#read -p " " -n1 -s
}

function app_status(){
    echo -e "${BY} \nPrinting Cribl .dat file ${NC}"
    cat /opt/cribl-edge/local/cribl/auth/*.dat
    echo -e "${BY} \nPrinting Mount Points ${NC}"
    df -hT
    echo -e "${BY} \nPrinting Users ${NC}"
    cat /etc/passwd
    echo -e "${BY} \nPrinting Current running service ${NC}"
    systemctl | grep running
    echo -e "${BY} \nPrinting Qualys Status ${NC}"
    systemctl status qualys-cloud-agent
    echo -e "${BY} \nPrinting Cribil Status ${NC}"
    systemctl status cribl-edge
    echo -e "${BY} \nPrinting MS Defender Status ${NC}"
    systemctl status mdatp
    echo -e "${BY} \nPrinting MS Defender Health Status ${NC}"
    mdatp health
    #echo -e "${BY} \nPrinting MS Defender connectivity test ${NC}"
    #mdatp connectivity test
    exit 0
}

function progress() {

    func_no=7
    count=`awk 'END { print NR }' count.txt`  
    while [ ${count} != ${func_no} ];
    do
        count=`awk 'END { print NR }' count.txt`  
        #progressbar ${count} ${func_no}
    done
    app_status
}

function main (){
show_warning
check_migration_pkg
progress &
create_user
remove_splunk
remove_crowd_strike
install_cribil
install_msdefender
install_qualys
}
main