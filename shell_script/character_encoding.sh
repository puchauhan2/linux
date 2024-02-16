
tput cup 10 8 # to make space 

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}

showU8_256() { 
    local i a
    for a ;do
        for i in {0..9} {A..F}; do
            printf '\\U%05Xx: %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b\n' \
                0x$a$i \\U$a${i}{{0..9},{A..F}}
        done
    done
}

showU8_256 if(3,4)