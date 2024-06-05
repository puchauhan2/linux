BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
mark100='\U01F4AF'
wrong='\u274c\n'

hostnamectl

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

app_status