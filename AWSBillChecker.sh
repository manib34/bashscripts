#!/bin/bash

#VariableDeclartion
TodaysDate=`date "+%Y-%m-%d"`
CurrentMonth=`date "+%b"`
StartDate=`date "+%Y-%m-%d" | cut -d "-" -f1,2`
LoadStart=1
LoadEnd=100
Green="32"
Red="31"
Yellow="33"
BoldGreen="\e[1;${Green}m"
BoldRed="\e[1;${Red}m"
BoldYellow="\e[1;${Yellow}m"
EndColor="\e[0m"

TotalBill="$(aws ce get-cost-and-usage --time-period Start=${StartDate}-01,End=$TodaysDate --metrics "UnblendedCost" --granularity MONTHLY --output text | grep -i unblen | awk '{print $2}' | cut -d "." -f1 )"

#FunctionSection
TotalServices() {
    aws ce get-cost-and-usage \
    --time-period Start=${StartDate}-01,End=$TodaysDate \
    --metrics "UnblendedCost" \
    --granularity MONTHLY \
    --group-by Type=DIMENSION,Key=SERVICE \
    --output text > op1.txt
}

TopServices() {
    for j in $(cat op1.txt| grep -i unbl | sort -k2 -nr | head -n 3 | awk '{print $2}'); do
        grep $j op1.txt -B1;
    done | cut -f2  > op2.txt
}

ProgressBar() {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _done=$(printf "%${_done}s")
    _left=$(printf "%${_left}s")
    printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"

}
#WorkBeginsHere
echo ' '
if (( "$TotalBill" <= "500" ))
then
    echo -e '\t' "The as on date bill for the month of $CurrentMonth is: ${BoldGreen}$TotalBill USD${EndColor}"
elif (( "$TotalBill" >= "500" && "$TotalBill" <= "1500" ))
then
    echo -e '\t' "The as on date bill for the month of $CurrentMonth is: ${BoldYellow}$TotalBill USD${EndColor}"
else
    echo -e '\t' "The as on date bill for the month of $CurrentMonth is: ${BoldRed}$TotalBill USD${EndColor}"
fi
TotalServices
echo ' '
echo -e '\t\t' "The top 3 services are:"
for number in $(seq ${LoadStart} ${LoadEnd})
do
    sleep 0.01
    ProgressBar ${number} ${LoadEnd}
done
TopServices
echo ' '
echo ' '
paste -d'\n' - - /dev/null <op2.txt | awk '{print "\t\t\t", $0}'
rm -rf {op1,op2}.txt
echo "Please be mindful about your monthly bill. To get more details, please check the link: https://console.aws.amazon.com/billing/"
echo ''
