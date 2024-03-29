orgument='-q -o BatchMode=yes -o StrictHostKeyChecking=no'

pack='cribl-4.tgz  post_migrationscript.bash* '


bypass='-o StrictHostKeyChecking=no -O '

function send_file(){

    scp ${bypass}  ${pack} gecloud@${1}:~
}


function executer (){
    ssh ${orgument} gecloud@${1} 'sudo bash post_migrationscript.bash' 
}


function execute_main_ip(){

    list_server=`cat server.txt`
    if [[ -z ${list_server} ]]
    then
        echo -e "${BR} Server list is empty ${cross}\n${BY} please fill server_list${NC}"
        exit 1
    else
        for ip in ${list_server}; do
            #send_file ${ip} & 
            executer ${ip} 
        done
    fi
}

execute_main_ip