for i in $(aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text)
do
    echo -e "\t"$i; aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text 2>/dev/null --region $i
done
