#!/bin/bash
# DELIVERBI Trino Gracefull Shutdown GCP Instance Groups
# Shahed Munir
# Production Date 18/10/2021
#Auto Scaling - Trino Node Delivery.
#Invoke Command ./trino-workers-shutdown-resize.sh 1 SIGNAL-SHUTDOWN group-analytics-trino-worker-group-highmem16 0
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN group-analytics-trino-worker-group-highmem16 0 --Invoke SIGNAL-SHUTDOWN First
#Invoke Command ./trino-workers-shutdown-resize.sh 0 RESIZE group-analytics-trino-worker-group-highmem16 1
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN-RESIZE group-analytics-trino-worker-group-highmem16 1 --Invoke SIGNAL-SHUTDOWN First
#Helpers
#SIGNAL-SHUTDOWN --Signal Trino to Shutdown, SHUTDOWN --remove physical machines, RESIZE --resize workers to x amount , SHUTDOWN-RESIZE remove and resize
#Instance groups group-analytics-trino-worker-group-highmem16 , group-analytics-trino-worker-group
#Param 1 Number Of Workers to Remove
#Param 2 Signal
#Param 3 Instance Group NAME (InstanceGroupName)
#Param 4 Resize Instance Group to specific Size
#Remember run this Script as BASH

Pproject="group-analytics-platform"
Pzone="europe-west2-c"
P_num_of_workers_remove=$1
P_signal=$2
P_instancegroupname=$3
P_num_of_workers_resize=$4
P_filename=/tmp/trino-worker-to-remove.txt
#Export Filename and Location

if [ -z "$1" ]
  then
    echo "Please supply number of workers when restarted 0-100 as argument then signal SHUTDOWN or SIGNAL-SHUTDOWN or RESIZE as 2nd param and InstancegroupName 3rd Param"
    exit
    fi

if [ -z "$2" ]
  then
    echo "Please supply number of workers when restarted 0-100 as argument then signal SHUTDOWN or SIGNAL-SHUTDOWN or RESIZE as 2nd param and InstancegroupName 3rd Param"
    exit
    fi

if [ -z "$3" ]
  then
    echo "Please supply number of workers when restarted 0-100 as argument then signal SHUTDOWN or SIGNAL-SHUTDOWN or RESIZE as 2nd param , InstancegroupName 3rd Param"
    exit
    fi
	
if [ -z "$4" ]
  then
    echo "Please State Resize Value as 4th Param"
    exit
    fi	

#List Number of Instances required to be decommisioned in Signal Shutdown and Signal Gracefull Shutdown to Trino

if [[ $P_signal == 'SIGNAL-SHUTDOWN' ]] ; then

gcloud compute instance-groups managed list-instances $P_instancegroupname --project=$Pproject --zone=$Pzone --format='csv[no-heading](NAME)' | head -$P_num_of_workers_remove > $P_filename

# Send shutdown signals looper.
INPUTTAB=$P_filename
OLDTABIFS=$IFS
IFS=,
[ ! -f $INPUTTAB ] && { echo "$INPUTTAB file not found"; exit 99; }
while read workername

do
# Check if enabled flag in tables csv is active to run and that environment is as expected from csv also
v1=$workername

echo "Shutdown Signal sent for $workername"

#send shutdown to trino node gracefull shutdown only
curl -v -X PUT -d '"SHUTTING_DOWN"' -H "Content-type: application/json" http://$workername:8060/v1/info/state --header "X-Trino-User: admin"

echo "Signal Sent to Trino Worker"
sleep 2s
curl http://$workername:8060/v1/info/state


done < $INPUTTAB

IFS=$OLDTABIFS
fi


# When Shutting down check if Node is Active or Not (Keep Polling in Airflow and entries will get removed from trino-workers file)
if [[ $P_signal == 'SHUTDOWN' ]] ; then

# Delete Physical Machines from Instance Group Looper.
INPUTTAB=$P_filename
OLDTABIFS=$IFS
IFS=,
[ ! -f $INPUTTAB ] && { echo "$INPUTTAB file not found"; exit 99; }
while read workername

do

v1=$workername

isnodeactive=`curl http://$workername:8060/v1/info/state`
echo "Curl Response is : $isnodeactive"
#If response is null then shut it down as systemctl service has been shutdown completely
if [ -z "$isnodeactive" ] 
then isnodeactive='NotKnown'
fi
echo "Status: $isnodeactive"
if [ $isnodeactive == 'NotKnown' ]
then echo "Will shutdown this node Safely,Mode engaged and ready to fire"

echo "Destroy Instance Group Node $workername"

#destroy command
gcloud compute instance-groups managed delete-instances $P_instancegroupname --instances=$workername --project=$Pproject --zone=$Pzone

echo "Detonation Signal sent to Instance Group Node $workername"

echo "sed -i '/$workername/d' $P_filename"

sed -i "/$workername/d" $P_filename

#If active or shutting down then leave it
elif [ $isnodeactive == '"ACTIVE"' ] || [ $isnodeactive == '"SHUTTING_DOWN"' ]
then echo "Cant shutdown $workername Node as its still Active or finishing queries. Lets keep Polling , No Ammo required"
fi


done < $INPUTTAB
IFS=$OLDTABIFS

if [ `cat $P_filename | wc -l` == "0" ]
echo "ALLDONE"
fi

fi

# Increase Workers Only
if [[ $P_signal == 'RESIZE' ]] ; then
gcloud compute instance-groups managed resize $P_instancegroupname --size $P_num_of_workers_resize --project=$Pproject --zone=$Pzone
fi

# When Shutting down check if Node is Active or Not (Keep Polling in Airflow and entries will get removed from trino-workers file) and INCREASE TOO
if [[ $P_signal == 'SHUTDOWN-RESIZE' ]] ; then

# Delete Physical Machines from Instance Group Looper.
INPUTTAB=$P_filename
OLDTABIFS=$IFS
IFS=,
[ ! -f $INPUTTAB ] && { echo "$INPUTTAB file not found"; exit 99; }
while read workername

do

v1=$workername

isnodeactive=`curl http://$workername:8060/v1/info/state`
echo "Curl Response is : $isnodeactive"
#If response is null then shut it down as systemctl service has been shutdown completely
if [ -z "$isnodeactive" ] 
then isnodeactive='NotKnown'
fi
echo "Status: $isnodeactive"
if [ $isnodeactive == 'NotKnown' ]
then echo "Will shutdown this node Safely,Mode engaged and ready to fire"

echo "Destroy Instance Group Node $workername"

#destroy command
gcloud compute instance-groups managed delete-instances $P_instancegroupname --instances=$workername --project=$Pproject --zone=$Pzone

echo "Detonation Signal sent to Instance Group Node $workername"

echo "sed -i '/$workername/d' $P_filename"

sed -i "/$workername/d" $P_filename

#If active or shutting down then leave it
elif [ $isnodeactive == '"ACTIVE"' ] || [ $isnodeactive == '"SHUTTING_DOWN"' ]
then echo "Cant shutdown $workername Node as its still Active or finishing queries. Lets keep Polling , No Ammo required"
fi

done < $INPUTTAB
IFS=$OLDTABIFS

#Replace shutdown workers with fresh ones as resize fresh as a daisy
sleep 2s
if [ `cat $P_filename | wc -l` == "0" ]
then echo "Workers file ($P_filename) is empty so lets increase the workers now"
sleep 30s
gcloud compute instance-groups managed resize $P_instancegroupname --size $P_num_of_workers_resize --project=$Pproject --zone=$Pzone
echo "Issued to increase number of workers to $P_num_of_workers_resize for Instance Group $P_instancegroupname"
echo "ALLDONE"
fi

fi


