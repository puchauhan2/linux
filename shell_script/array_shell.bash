# -----------------------------------------------
# Yet another array, "area3".
# Yet another way of assigning array variables...
# array_name=([xx]=XXX [yy]=YYY ...)

area3=([17]=seventeen [24]=twenty-four [name]=puneet )

echo -n "area3[17] = "
echo ${area3[17]}

echo -n "area3[24] = "
echo ${area3[24]}

echo ${area3[name]}

declare -A aArray=(

    [fruit]=apple
    [car]=Maruti
    [flower]=sunflower
)

for key in ${!aArray[*]}
do
echo "$key=${aArray[$key]}"
done
# -----------------------------------------------