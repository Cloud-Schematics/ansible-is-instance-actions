#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Correct Usage: ./automated-steps.sh <action-name> <start/stop/reboot> <target-ip>"
fi

if [[ $2 == "start" ]]; then
    playbook="start-vsi-playbook.yml"
elif [[ $2 == "stop" ]]; then
    playbook="stop-vsi-playbook.yml"
elif [[ $2 == "reboot" ]]; then
    playbook="reboot-vsi-playbook.yml"
else
    echo "Invalid action. Pass start/stop/reboot"
    exit 2
fi

#echo $playbook

############################# Action Create #######################
export ENABLE_ACTION=true
export SCHEMATICS_SERVER_URL=https://schematics-dev.us-east.containers.appdomain.cloud
echo "Creating a Schematics Action"
token=`ibmcloud iam oauth-tokens --output JSON | jq '.iam_token' | tr -d '"' `
action=`ibmcloud schematics action create -n $1 -r Default -l us_east --tr https://github.ibm.com/akjain25/ic-vsi-actions --pn $playbook --input instance_ip=$3 --input bearer_token="${token}" --json`
# echo $action
if [[ -z ${action} ]]; then
 echo "action create failed"
 exit 1
fi
action_id=`echo ${action} | jq '.id' | tr -d '"'`

echo "Draft action created with ID: ${action_id}"
action_status=""
while [ 1 ]
do
 # Get action CLI
 action_get=`ibmcloud schematics action get --id ${action_id} --profile detailed --json`
 #echo ${action_get}
 action_status=`echo ${action_get} | jq '.state.status_code' | tr -d '"'`
 echo "Action status is: ${action_status}"
 if [ ${action_status} == "normal" ]; then
   echo "Action creation completed!"
   break
 fi
 sleep 5
done
############################ Action create end ########################

############################ Job create ###############################

job=`ibmcloud schematics job create -c action --cid ${action_id} -n ansible_playbook_run --json`
#echo $job
if [[ -z ${job} ]]; then
 echo "job create failed"
 exit 1
fi
job_id=`echo ${job} | jq '.id' | tr -d '"'`
echo "Draft job created with ID: ${job_id}"

job_status=""
while [ 1 ]
do
 # Get job CLI
 job_get=`ibmcloud schematics job get --id ${job_id} --profile detailed --json`
 #echo ${job_get}
 job_status=`echo ${job_get} | jq '.status.action_job_status.status_code' | tr -d '"'`
 echo ${job_status}
 if [ ${job_status} == "job_finished" ]; then
 #if [ ${job_status} == "job_pending" ]; then
   echo "Job creation completed!"
   break
 fi
 sleep 10
done

#######################################################################