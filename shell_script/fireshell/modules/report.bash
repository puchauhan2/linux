function initializer () {
    mkdir -p log
    > log/success_server.txt
    > log/failed_server.txt
    > log/count.txt
    > log/not_installed.txt
    > log/is_installed_server.txt
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
    count=`awk 'END { print NR }' log/count.txt`  
    while [ ${count} != ${num_ip} ];
    do
        count=`awk 'END { print NR }' log/count.txt`  
        progressbar ${count} ${num_ip}
    done

    final=`cat log/success_server.txt`
    if [[ -z ${final} ]]
    then
        echo -e ""
    else
        echo -e "\n Showing Report\n"
        echo -e "\n${G} Operation Performed Successfully on below server ${m100}${C}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' log/success_server.txt
        printf " ${ldd// /-}\n "
    fi

    failed_server=`cat log/failed_server.txt`
    if [[ -z ${failed_server} ]]
    then
        echo -e ""
    else
        echo -e "\n${R} Failed to Performed Operation on below server ${cross}${C}"
        printf " ${ldd// /-} \n"
        awk '{print NR " -",$0}' log/failed_server.txt
        printf " ${ldd// /-} \n"
    fi
    echo -e "\n${Y} You can also check "log" dir for perticular server log ${C}"
    tput sgr0
}

function show_report_pack_check (){
    printf "\n${lde// /=} Showing Logs ${lde// /=}\n"
    count=`awk 'END { print NR }' log/count.txt`  
    while [ ${count} != ${num_ip} ];
    do
        count=`awk 'END { print NR }' log/count.txt`  
        progressbar ${count} ${num_ip}
    done

    echo -e "\n Showing Report\n"

    failed_server=`cat log/failed_server.txt`
    if [[ -z ${failed_server} ]]
    then
        echo -e ""
    else
        echo -e "\n${R} Failed to Perform Operation on below server ${cross}${C}"
        printf " ${ldd// /-} ${R}\n"
        awk '{print NR " -",$0}' log/failed_server.txt
        printf "${C} ${ldd// /-} \n"
    fi
    echo -e "\n${Y} You can also check "log" DIR for particular server log ${C}"
    tput sgr0

        is_installed_pk=`cat log/is_installed_server.txt`
    if [[ -z ${is_installed_pk} ]]
    then
    :
    else
        echo -e "\n${G} Package present for Below server.You can also check file is_installed_server.txt ${m100}${C}"
        printf " ${ldd// /-} \n${G}"
        awk '{print NR " -",$0}' log/is_installed_server.txt
        printf "${C} ${ldd// /-} \n"
    fi

    #final=`awk '{printf $2}' log/not_installed.txt`
    final=`cat log/not_installed.txt`
    if [[ -z ${final} ]]
    then
        echo -e "${G}\n No Missing package found for below server${C} "
        printf " ${ldd// /-} ${G}\n"        
        awk '{print NR " -",$1}' log/is_installed_server.txt
        printf "${C} ${ldd// /-} \n"
    else
        echo -e "\n${R} Found Missing package on below servers ${m100}${C}"
        printf " ${ldd// /-} ${R}\n"
        awk -e '{print NR " -",$0}' log/not_installed.txt ;
        printf "${C} ${ldd// /-}\n "

        echo -e "${C}\n Want to Proceed with Package installation ?\n Enter ${Y}Yes${C} to Proceed Or ${Y}[CTRL + c]${C}  to Exit${C}"
        read response
        case ${response} in
        "yes"|"Yes"|"Y"|"y")
		echo -e "${Y}\n You have selected to Proceed with Package installation ${C}\n";
        time pack_install
        ;;
        *)
		echo -e "${R} Wrong Choice or Nothing selected,quiting ${C}";
		exit 1
        ;;
        esac

    fi
    tput sgr0

}