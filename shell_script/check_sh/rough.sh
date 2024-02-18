


disk_check() {
disk_available=$(df / | awk 'NR==2 {print $4}')
percent_inc=0.4
swap_inc=$(awk "BEGIN {print ${swap_size_in_KB} * ${percent_inc}}")
swap_40_inc=$(awk "BEGIN {print ${swap_size_in_KB} + ${swap_inc}}")

if [ $swap_40_inc -le $disk_available ]
then
echo -e "${BG}\nDisk size is 40% greater or equel to SWAP , Operation can be performed  ${NC}"
else
echo -e "${BR}\nDisk has less space available,please increase disk size alteast 40 % of SWAP  ${NC}"
exit 1
fi
}



swap_size_check(){
    swap_size_in_KB=$((1024 * ${swap_mb}))
    mem=`grep MemTotal /proc/meminfo | awk '{print $2}'`
    echo $swap_size_in_KB
    if [ ${swap_size_in_KB} -le ${mem} ]
    then
        echo -e "${BG}\nEntered SWAP value is less than RAM,Operation can be continued${NC}"
    else
        echo -e "${BR}\nEntered SWAP value is greater than RAM, Operation cannot be continued ${NC}"
        exit 1
    fi
}




swap_mb=1000
swap_size_check(){
    swap_size_in_KB=$((1024 * ${swap_mb}))
    mem_kb=`grep MemTotal /proc/meminfo | awk '{print $2}'`
    pref_inc_ram=0.05
    mem_20=$(awk "BEGIN {print ${mem_kb} * ${pref_inc_ram}}")
    mem=$(awk "BEGIN {print ${mem_kb} + ${mem_20}}")
    echo ${mem} ${swap_size_in_KB}
    
}

swap_size_check

grep "DirectMap4k:" /proc/meminfo

s1=$(grep "DirectMap4k:" /proc/meminfo | awk '{print $2}')
s2=$(grep "DirectMap2M:" /proc/meminfo | awk '{print $2}')
s3=$(($s1 + $s2))
s4=$(($s3/1024))
echo "RAM size in MB $s4"



_check() {

    for pkg in ${packages[@]}; do
        executer "54.163.13.66" "sudo yum -q list installed $pkg" 
    done
}

_check


    for pkg in ${packages[@]}; do
        check=`cat pkg_result | grep -i $pkg 2>&1 /dev/null`

            if [ $? -ne 0 ]; then
                 echo -e "${BY}${pkg}${BR} is not installed.${NC}"
            else
                echo -e  "${BY}${pkg}${BG} is installed.${NC}"
            fi
    done