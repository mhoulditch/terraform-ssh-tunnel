#! /bin/bash

# set working directory to scripts directory
cd "$(dirname "${BASH_SOURCE[0]}")" 

# prompt for env variables if they are not set.
AWS_ENV_ARRAY=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
for (( k = 0; k < ${#AWS_ENV_ARRAY[@]}; ++k)); do
    if [ ! -v "${AWS_ENV_ARRAY[$k]}" ]; then 
        read -p "input a value for "${AWS_ENV_ARRAY[$k]}" " envvar
        export "${AWS_ENV_ARRAY[$k]}"="$envvar"
        echo " "${AWS_ENV_ARRAY[$k]}" has been set "
    fi
done

# create a local keypair.
#TODO make idempotent, this prompts overwrite
if [ ! -f "~/.ssh/terrassh" ]; then
    echo " creating a key-pair to use for the ec2 instance ..."
    ssh-keygen -f ~/.ssh/terrassh
fi

# select a region
select region in us-west-1 us-east-2
do
	varfile=$region-cfg.tfvars
	echo "region $region selected using $varfile"
	break
done

#download all the modules and apply without prompting
terraform init
terraform apply -auto-approve -var-file=$varfile | tee tfapply.txt

# create bash variables from terraform output variables and then remove the temp file.
instance_ip_addr="$( cat tfapply.txt | grep instance_ip_addr | sed s/instance_ip_addr\ =\ //)"
instance_ssh_key="$( cat tfapply.txt | grep instance_ssh_key | sed s/instance_ssh_key\ =\ //)"
rm tfapply.txt

#TODO: add some better form of WAIT for the box to initialize
echo "waiting for the box to initialize in aws...."
sleep 45s

# ssh to the box
#NOTICE the user is named ubuntu 
echo " connecting to $instance_ip_addr that is using the key pair $instance_ssh_key ..."
 ssh -o "StrictHostKeyChecking=no" -i ~/.ssh/terrassh -D 43110 -qCN ubuntu@$instance_ip_addr &

# TODO: better teardown
# pgrep -f terrash
terraform destroy
