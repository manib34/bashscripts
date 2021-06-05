#!/bin/bash

green="32"
red="31"
boldgreen="\e[1;${green}m"
boldred="\e[1;${red}m"
endcolor="\e[0m"

echo "Enter the region:"
read region
#List all the environments to delete
echo ' '
echo -e "${boldgreen}The following applications will be deleted:${endcolor}" '\n'
aws elasticbeanstalk describe-applications --region $region | grep -i applicationname | cut -d : -f2 | tr -d '",' | tee  app.txt

echo ' '

for i in $(cat app.txt); do
    #echo -e "The application ${boldgreen}'$i'${endcolor} is now deleted"
    #echo ''
    aws elasticbeanstalk delete-application --region $region --application-name $i > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo -e "The application ${boldgreen}$i${endcolor} is now deleted"
    else
        echo -e "Unable to delete the application ${boldred}$i${endcolor} because it has a version that is deployed to a running environment"
    fi
done

rm -rf app.txt