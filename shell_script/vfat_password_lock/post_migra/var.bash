
function remove_splunk(){

    echo -e "${BY} Searching splunk..${NC}"
    pgrep splunkd
    erroCode=$?
    if [[ ${erroCode} != 0 ]]
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
    erroCode1=$?
    if [[ ${erroCode1} != 0 ]]
    then
    echo -e "${BR} Crowd-strike process id not found ,no further action needed ${NC}"
    else
    echo -e "${BG} Crowd-strike Found$,${BY}Removing Crowd-strike${NC}"
    yum remove -y falcon-sensor && echo -e "${BY} Crowd-strike RPM Package removed${NC}"
    fi
    echo "executed 3" >> count.txt
}

function install_cribil(){
    
    pgrep  cribl
    erroCode2=$?
    if [[ ${erroCode2} != 0 ]]
    then
    echo -e "${BY} Installing CRIBIL ${NC}"
    tar -xf cribl-4.tgz && echo -e "${BY} Cribil extracted ${NC}"
    mv cribl cribl-edge && mv cribl-edge /opt/ && echo -e "${BY} Cribil file copied to /opt/ DIR ${NC}"
    
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
    erroCode3=$?
    if [[ ${erroCode3} != 0 ]]
    then
    echo -e "${BY} Installing MS Defender${NC}"
    mkdir -p /etc/opt/microsoft/mdatp/ && echo -e "${BG} Directry /etc/opt/microsoft/mdatp/ created ${NC}"
    
    python MicrosoftDefenderATPOnboardingLinuxServer.py && echo -e "${BG} mdatp activated ${NC}" 
    else
    echo -e "${BY} MS Defender Found, no further action needed ${NC}"
    fi
    echo "executed 5" >> count.txt
}

function install_qualys(){
    echo -e "${BY} Searching Qualys ${NC}"
    pgrep qualys-cloud-ag
    erroCode=$?
    [[ ${1} == "firstrun" ]] && erroCode=1
    if [[ ${erroCode} != 0 ]]
    then
        echo -e "${BY} ReIntalling Qualys ${NC}"
        rpm -e qualys-cloud-agent
        rpm -ivh QualysCloudAgentx64.rpm && echo -e "${BG} Installed Qualys RPM ${NC}"
        
    else
        echo -e "${BG} Qualys Is installed ,no further action is need ${NC}"  
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
*******************************************************
-------------------------------------------------------
${BY}Script Made for DEV and STAGE
Before continue,please take AMI backups of the this VM.
Press any key to continue... OR Press CTRL + c to Exit${NC}
-------------------------------------------------------
*******************************************************"
echo "executed 7" >> count.txt
read -p " " -n1 -s
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
    echo -e "${BY} \nPrinting MS Defender connectivity test ${NC}"
    mdatp connectivity test
    exit 0
}

function progress() {

    func_no=7
    count=`awk 'END { print NR }' count.txt`  
    while [ ${count} != ${func_no} ];
    do
        count=`awk 'END { print NR }' count.txt`  
        progressbar ${count} ${func_no}
    done
    app_status
}