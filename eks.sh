#!/bin/bash
`aws ec2 describe-regions --region us-east-1 --output text | cut -f4 > region.txt`
region_count=$(cat region.txt|wc -l)
for (( i=1; i<=$region_count; i++ ))
do
    region=$(sed -n $i'p' region.txt)
    aws eks list-clusters --region $region --output text | grep -i clu > /dev/null 2>&1
    if [ $? == 0 ]
    then
        echo " "
        echo -e "The cluster is in the region: \e[1;32m$region\e[0m"
        aws eks list-clusters --region $region --output text
        echo " "
    fi
done
rm -rf region.txt
