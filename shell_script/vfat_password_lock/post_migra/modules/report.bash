function initializer () {
    > final.txt
    > failed_server.txt
    > count.txt
    mkdir -p log
    count=0
    num_ip=0
    tput sgr0
}


ldd=`printf "%105s"`
lde=`printf "%40s"`

function progressbar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "\033[1;32m%${_done}s")
    _empty=$(printf "\033[0m%${_left}s")
    printf "\rProgress : \033[1;33m[${_fill// /#}${_empty// / }\033[1;33m]\033[1;32m ${_progress}%%${C}"
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
        echo -e "\n${G} Operation Performed Successfully on below server ${mark100}${C}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' final.txt
        printf " ${ldd// /-}\n "
    fi

    failed_server=`cat failed_server.txt`
    if [[ -z ${failed_server} ]]
    then
        echo -e ""
    else
        echo -e "\n${R} Failed to Performed Operation on below server ${cross}${C}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' failed_server.txt
        printf " ${ldd// /-} \n"
    fi
    echo -e "\n${Y} You can also check "log" dir for perticular server log ${C}"
    tput sgr0
}