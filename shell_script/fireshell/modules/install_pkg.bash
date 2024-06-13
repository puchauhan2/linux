os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`;

arg1=${1};arg2=${2};arg3=${3};arg4=${4};arg5=${5};arg6=${6};arg7=${7};arg8=${8};arg9=${9};arg10=${10}

oracle_pkg() {
    hostnamectl | grep "Operating System"

    yum install "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}" "${arg9}" "${arg10}" 
    
}

Ubuntu_exec(){
    hostnamectl | grep "Operating System"
    echo ${*}
}
case $os_flavour_type in 
"Ubuntu") Ubuntu_exec;; 
"CentOS") oracle_pkg ;; 
"SUSE") echo "SUSE linux not supported" ;; 
"Red") oracle_pkg ;; 
"Oracle") oracle_pkg ;; 
"Amazon") oracle_pkg ;; 
*) echo -e "OS Type not detected ";; 
esac
