# Trino-GCP Graceful Shutdown using Instance Groups.
Trino GCP Graceful Shutdown Instance Groups Autoscaling etc

Graceful Shutdown Script

Download Script trino-workers-shutdown-resize.sh and place on A GCP VM or Airflow Server. chmod file for execution and run with the following parameters.

Signals The Trino Workers to finish what they are doing and shutdown the Trino Service
<br>
#Invoke Command ./trino-workers-shutdown-resize.sh 1 SIGNAL-SHUTDOWN group-analytics-trino-worker-group-highmem16 0

Execute the Signal shutdown first and then use this script, Checks if trino has actually shutdown the Service , This can be run multiple times as machines wont be removed untill Trino has shutdown the Main trino service.
<br>
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN group-analytics-trino-worker-group-highmem16 0 --Invoke SIGNAL-SHUTDOWN First

This command just resizes the Trino Cluster - Use for UP only.
<br>
#Invoke Command ./trino-workers-shutdown-resize.sh 0 RESIZE group-analytics-trino-worker-group-highmem16 1

Execute the Signal shutdown first and then use this script to remove machines and resize back to the size requested . Good for refreshing machines.
<br>
#Invoke Command ./trino-workers-shutdown-resize.sh 0 SHUTDOWN-RESIZE group-analytics-trino-worker-group-highmem16 1 --Invoke SIGNAL-SHUTDOWN First

I will include Templates and Instance Group Commands and Setup for Trino on Instance Groups Autoscaling at a later date.
